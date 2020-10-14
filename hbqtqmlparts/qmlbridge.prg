/*
 * $Id: qmlbridge.prg 475 2020-02-20 03:07:47Z bedipritpal $
 */

/*
 * Copyright 2015 Pritpal Bedi <bedipritpal@hotmail.com>
 * http://harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */
/*----------------------------------------------------------------------*/
/*
 *                               EkOnkar
 *                         ( The LORD is ONE )
 *
 *                             Pritpal Bedi
 *                              18Jul2015
 */
/*----------------------------------------------------------------------*/

#include "hbclass.ch"
#include "common.ch"
#include "inkey.ch"
#include "hbqtgui.ch"
#include "hbtrace.ch"
#include "hbtoqt.ch"
#include "hbqtstd.ch"


CLASS HbQtQmlBridge

   METHOD init( oParent )
   METHOD create( oParent )
   METHOD setQml( cQml )
   METHOD show()
   METHOD setProperty( cProperty, xValue )
   METHOD setChildProperty( cChild, cProperty, xValue )
   METHOD getProperty( cProperty )
   METHOD getChildProperty( cChild, cProperty )
   METHOD invokeMethod( cMethod, ... )
   METHOD connect( cSignal, bBlock )
   METHOD connectChild( cChild, cSignal, bBlock )

   PROTECTED:

   DATA   oWidget
   DATA   oParent
   DATA   oRootObject
   DATA   oQuickWindow
   DATA   oMetaObject
   DATA   lLoaded                                 INIT .F.

   DATA   hChildren                               INIT __hbqtStandardHash()

   METHOD manageEventClose()

   ENDCLASS


METHOD HbQtQmlBridge:init( oParent )
   ::oParent := oParent
   RETURN Self


METHOD HbQtQmlBridge:create( oParent )

   DEFAULT oParent TO ::oParent
   ::oParent := oParent

   WITH OBJECT ::oWidget := QQuickWidget( ::oParent )
      :setResizeMode( QQuickWidget_SizeRootObjectToView )
      :setFocusPolicy( Qt_NoFocus )
      //:connect( "sceneGraphError(QQuickWindow::SceneGraphError,QString)", {|nError,cDesc| __hbqtLog( hb_ntos( nError ) + ":" + cDesc ) } )
      :connect( "sceneGraphError(QQuickWindow::SceneGraphError,QString)", {|nError,cDesc| HB_SYMBOL_UNUSED( nError+cDesc ) } )
      :connect( "statusChanged(QQuickWidget::Status)"                   , {|nStatus     | __logErrors( ::oWidget, nStatus ) } )
   ENDWITH

   __hbqtLayoutWidgetInParent( ::oWidget, ::oParent )

   __hbqtRegisterForEventClose( {|| ::manageEventClose() } )

   RETURN Self


STATIC FUNCTION __logErrors( oQWidget, nStatus )
   LOCAL oErrors, i, s

   s := "Status : " + hb_ntos( nStatus ) + chr( 10 )
   oErrors := oQWidget:errors()
   FOR i := 0 TO oErrors:count() - 1
      s += "         " + oErrors:at( i ):description() + chr( 10 )
   NEXT
   //__hbqtLog( s )

   RETURN s //NIL


METHOD HbQtQmlBridge:setQml( cQml )

   WITH OBJECT ::oWidget
      :setSource( QUrl( cQml ) )
      ::oRootObject := :rootObject()
   ENDWITH
   IF HB_ISOBJECT( ::oRootObject )
      ::oMetaObject := ::oRootObject:metaObject()
   ENDIF

   __hbqtAppRefresh()

   RETURN ( ::lLoaded := HB_ISOBJECT( ::oRootObject ) )


METHOD HbQtQmlBridge:setProperty( cProperty, xValue )
   IF ::lLoaded
      RETURN ::oRootObject:setProperty( cProperty, xValue )
   ENDIF
   RETURN .F.


METHOD HbQtQmlBridge:setChildProperty( cChild, cProperty, xValue )
   LOCAL lSet := .F.

   IF ::lLoaded .AND. PCount() == 3
      IF ! hb_HHasKey( ::hChildren, cChild )
         ::hChildren[ cChild ] := __hbqt_findChildObject( ::oRootObject, cChild )
      ENDIF
      IF HB_ISOBJECT( ::hChildren[ cChild ] )
         lSet := ::hChildren[ cChild ]:setProperty( cProperty, QVariant( xValue ) )
      ENDIF
   ENDIF
   RETURN lSet


METHOD HbQtQmlBridge:getProperty( cProperty )
   IF ::lLoaded
      RETURN ::oRootObject:property( cProperty )
   ENDIF
   RETURN NIL


METHOD HbQtQmlBridge:getChildProperty( cChild, cProperty )

   IF ::lLoaded .AND. PCount() == 3
      IF ! hb_HHasKey( ::hChildren, cChild )
         ::hChildren[ cChild ] := __hbqt_findChildObject( ::oRootObject, cChild )
      ENDIF
      IF HB_ISOBJECT( ::hChildren[ cChild ] )
         RETURN ::hChildren[ cChild ]:property( cProperty )
      ENDIF
   ENDIF
   RETURN NIL


METHOD HbQtQmlBridge:invokeMethod( cMethod, ... )
   LOCAL oVariant
   LOCAL aParams := { ... }

   IF ::lLoaded
      IF HB_ISSTRING( cMethod ) .AND. ! Empty( cMethod )
         IF Empty( aParams )
            oVariant := ::oMetaObject:invokeMethod( ::oRootObject, cMethod )
         ELSE
            oVariant := ::oMetaObject:invokeMethod( ::oRootObject, cMethod, hb_ArrayToParams( aParams ) )
         ENDIF
      ENDIF
   ENDIF
   RETURN oVariant


METHOD HbQtQmlBridge:connect( cSignal, bBlock )
   IF ::lLoaded
      IF HB_ISOBJECT( ::oRootObject )
         RETURN ::oRootObject:connect( cSignal, bBlock )
      ENDIF
   ENDIF
   RETURN .F.


METHOD HbQtQmlBridge:connectChild( cChild, cSignal, bBlock )
   LOCAL lConnected := .F.

   IF ::lLoaded .AND. PCount() == 3
      IF ! hb_HHasKey( ::hChildren, cChild )
         ::hChildren[ cChild ] := __hbqt_findChildObject( ::oRootObject, cChild )
      ENDIF
      IF HB_ISOBJECT( ::hChildren[ cChild ] )
         lConnected := ::hChildren[ cChild ]:connect( cSignal, bBlock )
      ENDIF
   ENDIF
   RETURN lConnected


METHOD HbQtQmlBridge:show()
   __hbqtAppRefresh()
   RETURN NIL


METHOD HbQtQmlBridge:manageEventClose()
   //IF ::oWidget:isVisible()
      //
   //ENDIF
   RETURN .F.

