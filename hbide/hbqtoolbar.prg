/*
 * $Id: hbqtoolbar.prg 434 2016-11-09 02:32:49Z bedipritpal $
 */

/*
 * Copyright 2010-2015 Pritpal Bedi <bedipritpal@hotmail.com>
 * www - http://harbour-project.org
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
 *                                EkOnkar
 *                          ( The LORD is ONE )
 *
 *                            Harbour-Qt IDE
 *
 *                 Pritpal Bedi <bedipritpal@hotmail.com>
 *                               07Aug2010
 */
/*----------------------------------------------------------------------*/

#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"


CLASS HbqToolbar

   DATA   oWidget
   DATA   cName
   DATA   oParent
   DATA   hItems                                  INIT   {=>}
   DATA   hActions                                INIT   {=>}

   DATA   allowedAreas                            INIT   Qt_TopToolBarArea + Qt_LeftToolBarArea + Qt_BottomToolBarArea + Qt_RightToolBarArea
   DATA   initialArea                             INIT   Qt_TopToolBarArea
   DATA   orientation                             INIT   Qt_Horizontal
   DATA   size
   DATA   moveable                                INIT   .T.
   DATA   floatable                               INIT   .T.

   DATA   lPressed                                INIT   .f.
   DATA   qPos
   DATA   qDrag
   DATA   qMime
   DATA   qDropAction
   DATA   qPix
   DATA   qByte

   METHOD new( cName, oParent )
   METHOD create( cName, oParent )
   METHOD destroy()
   METHOD execEvent( cEvent, p, p1 )
   METHOD addToolButton( cName, cDesc, cImage, bAction, lCheckable, lDragEnabled )
   METHOD setItemChecked( cName, lState )
   METHOD setItemEnabled( cName, lEnabled )
   METHOD addWidget( cName, qWidget )
   METHOD addAction( cName, qAction, bBlock )
   METHOD addSeparator()
   METHOD contains( cName )                       INLINE hb_hHasKey( ::hActions, cName )
   METHOD getItem( cName )                        INLINE iif( hb_hHasKey( ::hActions, cName ), ::hActions[ cName ], NIL )
   METHOD itemToggle( cName )

   ERROR HANDLER onError( ... )
   ENDCLASS


METHOD HbqToolbar:new( cName, oParent )

   ::cName   := cName
   ::oParent := oParent

   RETURN Self


METHOD HbqToolbar:create( cName, oParent )

   STATIC nID := 0

   DEFAULT cName   TO ::cName
   DEFAULT oParent TO ::oParent
   ::cName   := cName
   ::oParent := oParent

   DEFAULT ::cName TO "HbqToolbar_" + hb_ntos( ++nID )

   DEFAULT ::size TO QSize( 16,16 )

   WITH OBJECT ::oWidget := QToolbar( ::oParent )
      :setObjectName( ::cName )
      :setAllowedAreas( ::allowedAreas )
      :setOrientation( ::orientation )
      :setIconSize( ::size )
      :setMovable( ::moveable )
      :setFloatable( ::floatable )
      :setFocusPolicy( Qt_NoFocus )
      :setAttribute( Qt_WA_AlwaysShowToolTips, .T. )
   ENDWITH

   RETURN Self


METHOD HbqToolbar:onError( ... )
   LOCAL cMsg := __GetMessage()

   IF SubStr( cMsg, 1, 1 ) == "_"
      cMsg := SubStr( cMsg, 2 )
   ENDIF
   RETURN ::oWidget:&cMsg( ... )


METHOD HbqToolbar:destroy()
   LOCAL xTmp

   FOR EACH xTmp IN ::hItems
      IF xTmp:className() == "QTOOLBUTTON"
         xTmp:disconnect( QEvent_MouseButtonPress   )
         xTmp:disconnect( QEvent_MouseButtonRelease )
         xTmp:disconnect( QEvent_MouseMove          )
         xTmp:disconnect( QEvent_Enter              )
         xTmp:disconnect( "clicked()" )
      ENDIF
      xTmp := NIL
   NEXT
   ::cName              := NIL
   ::oParent            := NIL
   ::hItems             := NIL
   ::allowedAreas       := NIL
   ::initialArea        := NIL
   ::orientation        := NIL
   ::size               := NIL
   ::moveable           := NIL
   ::floatable          := NIL
   ::lPressed           := NIL
   ::qPos               := NIL
   ::qDrag              := NIL
   ::qMime              := NIL
   ::qDropAction        := NIL
   ::qPix               := NIL
   ::qByte              := NIL
   ::oWidget            := NIL

   ::hActions           := NIL

   RETURN Self


METHOD HbqToolbar:execEvent( cEvent, p, p1 )
   LOCAL qEvent, qRC

   qEvent := p

   SWITCH cEvent
   CASE "QEvent_MouseLeave"
      EXIT

   CASE "QEvent_MouseMove"
      qRC := QRect( ::qPos:x() - 5, ::qPos:y() - 5, 10, 10 ):normalized()
      IF qRC:contains( qEvent:pos() )
         ::qByte := QByteArray( ::hItems[ p1 ]:objectName() )

         ::qMime := QMimeData()
         ::qMime:setData( "application/x-toolbaricon", ::qByte )
         ::qMime:setHtml( ::hItems[ p1 ]:objectName() )

         ::qPix  := QIcon( ::hItems[ p1 ]:icon ):pixmap( 16,16 )

         ::qDrag := QDrag( hbide_setIde():oDlg:oWidget )
         ::qDrag:setMimeData( ::qMime )
         ::qDrag:setPixmap( ::qPix )
         ::qDrag:setHotSpot( QPoint( 15,15 ) )
         ::qDrag:setDragCursor( ::qPix, Qt_CopyAction + Qt_IgnoreAction )
         ::qDropAction := ::qDrag:exec( Qt_CopyAction + Qt_IgnoreAction )  /* Why this is not terminated GPF's */

         ::qDrag := NIL
         ::qPos  := NIL
         ::hItems[ p1 ]:setChecked( .f. )
         ::hItems[ p1 ]:setWindowState( 0 )
      ENDIF
      EXIT

   CASE "QEvent_MouseRelease"
      ::qDrag := NIL
      EXIT

   CASE "QEvent_MousePress"
      ::qPos := qEvent:pos()
      EXIT

   CASE "buttonNew_clicked"
      EXIT

   ENDSWITCH

   RETURN NIL


METHOD HbqToolbar:addWidget( cName, qWidget )
   LOCAL qAction

   DEFAULT cName TO hbide_getNextIDasString( "IdeToolButtonWidget" )

   qAction := QWidgetAction( ::oWidget )
   qAction:setDefaultWidget( qWidget )
   ::oWidget:addAction( qAction )

   ::hItems[ cName ] := qWidget
   ::hActions[ cName ] := qAction

   RETURN NIL


METHOD HbqToolbar:addSeparator()
   LOCAL qAction
   LOCAL cName := hbide_getNextIDasString( "IdeToolButtonSeparator" )

   qAction := ::oWidget:addSeparator()

   ::hItems[ cName ] := cName
   ::hActions[ cName ] := qAction

   RETURN NIL


METHOD HbqToolbar:addAction( cName, qAction, bBlock )
   LOCAL qAct

   DEFAULT cName TO hbide_getNextIdAsString( "IdeToolButtonAction" )

   IF __objGetClsName( qAction ) == "QACTION"
      ::oWidget:addAction( qAction )

      ::hItems[ cName ] := cName
      ::hActions[ cName ] := qAction
      IF HB_ISBLOCK( bBlock )
         qAction:connect( "triggered()", bBlock )
      ENDIF

   ELSEIF __objGetClsName( qAction ) == "QTOOLBUTTON"
      qAct := QWidgetAction( ::oWidget )
      qAct:setDefaultWidget( qAction )
      ::oWidget:addAction( qAct )

      ::hItems[ cName ] := qAction
      ::hActions[ cName ] := qAct
      IF HB_ISBLOCK( bBlock )
         qAct:connect( "triggered()", bBlock )
      ENDIF

   ENDIF

   RETURN NIL


METHOD HbqToolbar:addToolButton( cName, cDesc, cImage, bAction, lCheckable, lDragEnabled )
   LOCAL oButton, oActBtn

   DEFAULT cName        TO hbide_getNextIDasString( "IdeToolButton" )
   DEFAULT cDesc        TO ""
   DEFAULT lCheckable   TO .f.
   DEFAULT lDragEnabled TO .f.

   WITH OBJECT oButton := QToolButton( ::oWidget )
      :setObjectName( cName )
      :setTooltip( cDesc )
      :setIcon( QIcon( cImage ) )
      :setCheckable( lCheckable )
      :setFocusPolicy( Qt_NoFocus )
      :setAttribute( Qt_WA_AlwaysShowToolTips, .T. )
      :setCursor( QCursor( Qt_ArrowCursor ) )
      :setAutoRaise( .T. )
      IF lDragEnabled
         :connect( QEvent_MouseButtonPress  , {|p| ::execEvent( "QEvent_MousePress"  , p, cName ) } )
         :connect( QEvent_MouseButtonRelease, {|p| ::execEvent( "QEvent_MouseRelease", p, cName ) } )
         :connect( QEvent_MouseMove         , {|p| ::execEvent( "QEvent_MouseMove"   , p, cName ) } )
         :connect( QEvent_Enter             , {|p| ::execEvent( "QEvent_MouseEnter"  , p, cName ) } )
      ENDIF
   ENDWITH

   IF HB_ISBLOCK( bAction )
      oButton:connect( "clicked()", bAction )
   ENDIF
   oActBtn := ::oWidget:addWidget( oButton )

   ::hItems[ cName ] := oButton
   ::hActions[ cName ] := oActBtn

   RETURN oButton


METHOD HbqToolbar:setItemChecked( cName, lState )
   LOCAL lOldState

   IF hb_hHasKey( ::hActions, cName )
      IF ::hActions[ cName ]:isCheckable()
         lOldState := ::hActions[ cName ]:isChecked()
         IF HB_ISLOGICAL( lState )
            ::hActions[ cName ]:setChecked( lState )
         ENDIF
      ENDIF
   ENDIF

   RETURN lOldState


METHOD HbqToolbar:setItemEnabled( cName, lEnabled )
   LOCAL lOldEnabled

   IF hb_hHasKey( ::hActions, cName )
      lOldEnabled := ::hActions[ cName ]:isEnabled()
      IF HB_ISLOGICAL( lEnabled )
         ::hActions[ cName ]:setEnabled( lEnabled )
      ENDIF
   ENDIF

   RETURN lOldEnabled


METHOD HbqToolbar:itemToggle( cName )
   LOCAL lOldState

   IF hb_hHasKey( ::hActions, cName )
      IF ::hActions[ cName ]:isCheckable()
         lOldState := ::hActions[ cName ]:isChecked()
         ::hActions[ cName ]:setChecked( ! lOldState )
      ENDIF
   ENDIF

   RETURN lOldState

