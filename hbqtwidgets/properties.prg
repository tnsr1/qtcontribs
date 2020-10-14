/*
 * $Id: properties.prg 475 2020-02-20 03:07:47Z bedipritpal $
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2014 Pritpal Bedi <bedipritpal@hotmail.com>
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
 *                    Harbour HbQtPropertySheet Class
 *
 *                             Pritpal Bedi
 *                              12Oct2014
 */
/*----------------------------------------------------------------------*/


#include "inkey.ch"
#include "hbclass.ch"
#include "common.ch"
#include "hbtoqt.ch"
#include "hbqtstd.ch"
#include "hbqtgui.ch"
#include "hbtrace.ch"


CLASS HbQtPropertiesManager

   DATA   oWidget
   DATA   oParent
   DATA   oLayout
   DATA   oPropertyWidget

   DATA   hSheets                                 INIT {=>}

   METHOD init( oParent )
   METHOD create( oParent )
   METHOD destroy()                               VIRTUAL
   METHOD refreshPropertySheet( cSheet )

   METHOD setEnabled( cSheet, lEnabled )
   METHOD propertySheet( cSheet )
   METHOD addPropertySheet( cSheet, oHbQtPropertySheet )
   METHOD setCurrentPropertySheet( cSheet )
   METHOD setPropertySheetProperty( cSheet, cProperty, xValue )
   METHOD setPropertySheetProperties( cSheet, hProperties, lHideRest, lEditable )
   METHOD getPropertySheetProperties( cSheet )

   ENDCLASS


METHOD HbQtPropertiesManager:init( oParent )
   DEFAULT oParent  TO ::oParent
   ::oParent := oParent
   hb_HKeepOrder( ::hSheets, .T. )
   hb_HCaseMatch( ::hSheets, .F. )
   RETURN Self


METHOD HbQtPropertiesManager:create( oParent )
   LOCAL oVLay, oHLay

   DEFAULT oParent  TO ::oParent
   ::oParent := oParent

   ::oWidget := QWidget()
   WITH OBJECT oVLay := QVBoxLayout()
      :setContentsMargins( 0,0,0,0 )
      :setSpacing( 0 )
   ENDWITH
   ::oWidget:setLayout( oVLay )
   ::oWidget:setStyleSheet( __hbqtTreeViewStyleSheet() )

   WITH OBJECT oHLay := QHBoxLayout()
      :setContentsMargins( 0,0,0,0 )
      :setSpacing( 0 )
   ENDWITH
   oVLay:addLayout( oHLay )

   ::oPropertyWidget := QStackedWidget()
   oVLay:addWidget( ::oPropertyWidget )

   IF __objDerivedFrom( ::oParent, "QVBOXLAYOUT" )
      ::oLayout := ::oParent
   ELSEIF __objDerivedFrom( ::oParent, "QHBOXLAYOUT" )
      ::oLayout := ::oParent
   ELSE
      IF Empty( ::oLayout := ::oParent:layout() )
         WITH OBJECT ::oLayout := QVBoxLayout()
            :setContentsMargins( 0,0,0,0 )
            :setSpacing( 0 )
         ENDWITH
         ::oParent:setLayout( ::oLayout )
      ENDIF
   ENDIF
   IF ! Empty( ::oLayout )
      ::oLayout:addWidget( ::oWidget )
   ENDIF
   RETURN Self


METHOD HbQtPropertiesManager:addPropertySheet( cSheet, oHbQtPropertySheet )
   LOCAL oWidget, oLay

   DEFAULT oHbQtPropertySheet TO HbQtPropertySheet():new():create( cSheet )

   WITH OBJECT oLay := QVBoxLayout()
      :setContentsMargins( 0,0,0,0 )
      :setSpacing( 0 )
   ENDWITH
   WITH OBJECT oWidget := QWidget()
      :setObjectName( cSheet )
      :setLayout( oLay )
   ENDWITH
   oLay:addWidget( oHbQtPropertySheet:oWidget )

   ::oPropertyWidget:addWidget( oWidget )
   ::hSheets[ cSheet ] := oHbQtPropertySheet

   RETURN oHbQtPropertySheet


METHOD HbQtPropertiesManager:refreshPropertySheet( cSheet )
   IF hb_HHasKey( ::hSheets, cSheet )
      RETURN ::hSheets[ cSheet ]:refresh()
   ENDIF
   RETURN Self


METHOD HbQtPropertiesManager:setEnabled( cSheet, lEnabled )
   IF hb_HHasKey( ::hSheets, cSheet )
      RETURN ::hSheets[ cSheet ]:setEnabled( lEnabled )
   ENDIF
   RETURN Self


METHOD HbQtPropertiesManager:propertySheet( cSheet )
   IF hb_HHasKey( ::hSheets, cSheet )
      RETURN ::hSheets[ cSheet ]
   ENDIF
   RETURN NIL


METHOD HbQtPropertiesManager:setCurrentPropertySheet( cSheet )
   LOCAL oWidget

   FOR EACH oWidget IN ::oPropertyWidget:count()
      IF Upper( oWidget:objectName() ) == Upper( cSheet )
         ::oPropertyWidget:setCurrentWidget( oWidget )
      ENDIF
   NEXT
   RETURN Self


METHOD HbQtPropertiesManager:setPropertySheetProperty( cSheet, cProperty, xValue )
   IF hb_HHasKey( ::hSheets, cSheet )
      ::hSheets[ cSheet ]:setProperty( cProperty, xValue )
   ENDIF
   RETURN Self


METHOD HbQtPropertiesManager:setPropertySheetProperties( cSheet, hProperties, lHideRest, lEditable )
   IF hb_HHasKey( ::hSheets, cSheet )
      ::hSheets[ cSheet ]:setProperties( hProperties, lHideRest, lEditable )
   ENDIF
   RETURN Self


METHOD HbQtPropertiesManager:getPropertySheetProperties( cSheet )
   LOCAL hProperties
   IF hb_HHasKey( ::hSheets, cSheet )
      hProperties := ::hSheets[ cSheet ]:getProperties()
   ENDIF
   RETURN hProperties

//----------------------------------------------------------------------//
//                        CLASS HbQtPropertySheet
//----------------------------------------------------------------------//

CLASS HbQtPropertySheet

   DATA   oWidget
   DATA   cSheet                                  INIT ""
   DATA   cParent
   DATA   hProperties                             INIT {=>}

   METHOD init( cSheet )
   METHOD create( cSheet )
   METHOD destroy()                               VIRTUAL
   METHOD refresh()

   ACCESS name()                                  INLINE ::cSheet

   METHOD addProperty( cProperty, cLabel, cParent, nType, xValue, xValues )
   METHOD setProperty( cProperty, xValue )
   METHOD setProperties( hProperties, lHideRest, lEditable )
   METHOD getProperties()
   METHOD setEnabled( lEnabled )

   METHOD editTriggered( oTreeWidgetItem )

   DATA   bPropertyChangedBlock
   METHOD propertyChangedBlock( bBlock )          SETGET

   ENDCLASS


METHOD HbQtPropertySheet:init( cSheet )
   hb_HKeepOrder( ::hProperties, .T. )
   hb_HCaseMatch( ::hProperties, .F. )

   DEFAULT cSheet TO ::cSheet
   ::cSheet := cSheet
   RETURN Self


METHOD HbQtPropertySheet:create( cSheet )
   LOCAL oListLabels

   DEFAULT cSheet TO ::cSheet
   ::cSheet := cSheet

   WITH OBJECT oListLabels := QStringList()
      :append( "  Name" )
      :append( "  Value" )
   ENDWITH
   WITH OBJECT ::oWidget := QTreeWidget()
      :setColumnCount( 2 )
      :setFrameShape( QFrame_NoFrame )
      :setHeaderLabels( oListLabels )
   // :setAlternatingRowColors( .T. )
      :setIndentation( 15 )
      :setEditTriggers( QAbstractItemView_NoEditTriggers )
      :setSelectionMode( QAbstractItemView_NoSelection )
      :setFocusPolicy( Qt_NoFocus )
      :setVerticalScrollMode( QAbstractItemView_ScrollPerPixel )
      :setHorizontalScrollMode( QAbstractItemView_ScrollPerPixel )
      :setHorizontalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
      :setVerticalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
      :setRootIsDecorated( .T. )
      :setMinimumWidth( 0 )
   ENDWITH
   __hbqtApplyStandardScroller( ::oWidget )

   RETURN Self


METHOD HbQtPropertySheet:addProperty( cProperty, cLabel, cParent, nType, xValue, xValues )
   LOCAL oHbQtProperty := HbQtProperty():new():create( cProperty, cLabel, cParent, nType, xValue, xValues )

   ::hProperties[ cProperty ] := oHbQtProperty
   IF Empty( cParent ) .OR. ! hb_HHasKey( ::hProperties, cParent )
      ::oWidget:addTopLevelItem( oHbQtProperty:oWidget )
   ELSE
      ::hProperties[ cParent ]:oWidget:addChild( oHbQtProperty:oWidget )
   ENDIF
   ::oWidget:setItemWidget( oHbQtProperty:oWidget, 1, oHbQtProperty:oStack )

   oHbQtProperty:propertyChangedBlock := {|cProperty,xValue| iif( HB_ISBLOCK( ::propertyChangedBlock() ), ;
                                       Eval( ::propertyChangedBlock(), ::name(), cProperty, xValue ), NIL ) }

   ::oWidget:resizeColumnToContents( 0 )
   RETURN Self


METHOD HbQtPropertySheet:refresh()
   LOCAL oHbQtProperty

   IF HB_ISHASH( ::hProperties )
      FOR EACH oHbQtProperty IN ::hProperties
         oHbQtProperty:refresh()
      NEXT
   ENDIF
   RETURN Self


METHOD HbQtPropertySheet:getProperties()
   LOCAL oHbQtProperty
   LOCAL hProperties := {=>}

   hb_HCaseMatch( hProperties, .F. )
   hb_HKeepOrder( hProperties, .T. )

   IF HB_ISHASH( ::hProperties )
      FOR EACH oHbQtProperty IN ::hProperties
         hProperties[ oHbQtProperty:name() ] := oHbQtProperty:value()
      NEXT
   ENDIF
   RETURN hProperties


METHOD HbQtPropertySheet:setProperties( hProperties, lHideRest, lEditable )
   LOCAL oHbQtProperty, cProperty, xValue

   DEFAULT lHideRest TO .F.

   FOR EACH oHbQtProperty IN ::hProperties
      oHbQtProperty:oWidget:setHidden( .F. )
   NEXT
   IF lHideRest
      FOR EACH oHbQtProperty IN ::hProperties
         IF oHbQtProperty:oWidget:childCount() == 0
            IF ! hb_HHasKey( hProperties, oHbQtProperty:__enumKey() )
               oHbQtProperty:oWidget:setHidden( .T. )
            ENDIF
         ENDIF
      NEXT
   ENDIF

   FOR EACH xValue IN hProperties
      cProperty := xValue:__enumKey()

      IF HB_ISHASH( xValue )
         IF hb_HHasKey( ::hProperties, cProperty )
            ::setProperty( cProperty, xValue[ "Value" ] )
            IF hb_HHasKey( xValue, "Options" ) .AND. HB_ISARRAY( xValue[ "Options" ] )
               ::hProperties[ cProperty ]:setOptions( xValue[ "Options" ] )
            ENDIF
            IF hb_HHasKey( xValue, "Label" ) .AND. HB_ISSTRING( xValue[ "Label" ] )
               ::hProperties[ cProperty ]:setLabel( xValue[ "Label" ] )
            ENDIF
            IF HB_ISLOGICAL( lEditable ) .AND. ! lEditable
               ::hProperties[ cProperty ]:setReadonly( .T. )
            ELSE
               IF hb_HHasKey( xValue, "ReadOnly" ) .AND. HB_ISLOGICAL( xValue[ "ReadOnly" ] )
                  ::hProperties[ cProperty ]:setReadonly( xValue[ "ReadOnly" ] )
               ENDIF
               IF hb_HHasKey( xValue, "Editable" ) .AND. HB_ISLOGICAL( xValue[ "Editable" ] )
                  ::hProperties[ cProperty ]:setReadonly( xValue[ "ReadOnly" ] )
               ENDIF
            ENDIF
         ENDIF
      ELSE
         ::setProperty( xValue:__enumKey(), xValue )
      ENDIF
   NEXT
   ::oWidget:resizeColumnToContents( 0 )
   RETURN Self


METHOD HbQtPropertySheet:setEnabled( lEnabled )
   IF HB_ISLOGICAL( lEnabled )
      ::oWidget:setEnabled( lEnabled )
   ENDIF
   RETURN Self


METHOD HbQtPropertySheet:setProperty( cProperty, xValue )
   IF hb_HHasKey( ::hProperties, cProperty )
      ::hProperties[ cProperty ]:setProperty( xValue )
   ENDIF
   RETURN .F.


METHOD HbQtPropertySheet:editTriggered( oTreeWidgetItem )
   LOCAL cProperty := oTreeWidgetItem:text( 0 )

   IF hb_HHasKey( ::hProperties, cProperty )
      ::hProperties[ cProperty ]:editTriggered()
   ENDIF
   RETURN Self


METHOD HbQtPropertySheet:propertyChangedBlock( bBlock )
   LOCAL bOldBlock := ::bPropertyChangedBlock
   IF PCount() == 1
      ::bPropertyChangedBlock := bBlock
   ENDIF
   RETURN bOldBlock

//----------------------------------------------------------------------//
//                        CLASS HbQtProperty
//----------------------------------------------------------------------//

CLASS HbQtProperty

   DATA   oStack
   DATA   oWidget
   DATA   oValueLabel
   DATA   oPropertyWidget
   DATA   oComboWidget

   DATA   cProperty                               INIT ""
   DATA   cLabel                                  INIT ""
   DATA   cParent                                 INIT ""
   DATA   nType                                   INIT 0
   DATA   cValueType                              INIT ""
   DATA   lEditable                               INIT .T.
   DATA   xOrigValue
   DATA   xOrigValues
   DATA   xValue
   DATA   xValues
   DATA   lBlockNotifier                         INIT .F.

   METHOD init( cProperty, cLabel, cParent, nType, xValue, xValues, lEditable )
   METHOD create( cProperty, cLabel, cParent, nType, xValue, xValues, lEditable )
   METHOD destroy()                               VIRTUAL
   METHOD propertyWidget()

   METHOD refresh()
   ACCESS name()                                  INLINE ::cProperty
   ACCESS value()                                 INLINE ::xValue
   METHOD setValue( xValue )
   METHOD setProperty( xValue )
   METHOD setOptions( aOptions )
   METHOD setLabel( cLabel )
   METHOD setReadOnly( lReadOnly )

   DATA   bValueChanged
   METHOD propertyChangedBlock( bBlock )          SETGET
   METHOD valueChanged( xValue )
   METHOD editTriggered()
   METHOD manageEvent( oKeyEvent, oWidget )
   METHOD execColorDialog()
   METHOD execColorNameSliding( oProperty )
   METHOD execFontDialog()
   METHOD execFontNameSliding( oProperty )
   METHOD execFontSizeSliding( oProperty )
   METHOD execBrushStyleSliding( oProperty )

   ENDCLASS


METHOD HbQtProperty:init( cProperty, cLabel, cParent, nType, xValue, xValues, lEditable )

   DEFAULT cProperty TO ::cProperty
   DEFAULT cLabel    TO ::cLabel
   DEFAULT cParent   TO ::cParent
   DEFAULT nType     TO ::nType
   DEFAULT xValue    TO ::xValue
   DEFAULT xValues   TO ::xValues
   DEFAULT lEditable TO ::lEditable

   ::cProperty := cProperty
   ::cLabel    := cLabel
   ::cParent   := cParent
   ::nType     := nType
   ::xValue    := xValue
   ::xValues   := xValues
   ::lEditable := lEditable

   RETURN Self


METHOD HbQtProperty:create( cProperty, cLabel, cParent, nType, xValue, xValues, lEditable )
   LOCAL oLay

   DEFAULT cProperty TO ::cProperty
   DEFAULT cLabel    TO ::cLabel
   DEFAULT cParent   TO ::cParent
   DEFAULT nType     TO ::nType
   DEFAULT xValue    TO ::xValue
   DEFAULT xValues   TO ::xValues
   DEFAULT lEditable TO ::lEditable

   ::cProperty := cProperty
   ::cLabel    := cLabel
   ::cParent   := cParent
   ::nType     := nType
   ::xValue    := xValue
   ::xValues   := xValues
   ::lEditable := lEditable

   ::xOrigValue  := ::xValue
   ::xOrigValues := iif( HB_ISARRAY( ::xValues ), AClone( ::xValues ), ::xValues )
   ::cValueType  := ValType( ::xOrigValue )

   WITH OBJECT oLay := QHBoxLayout()
      :setContentsMargins( 0,0,0,0 )
      :setSpacing( 0 )
   ENDWITH
   WITH OBJECT ::oWidget := QTreeWidgetItem()
      :setText( 0, cLabel )
   ENDWITH
   WITH OBJECT ::oValueLabel := QLabel( __xtos( ::xValue ) )
      :setStyleSheet( "border-left: 1px solid black; font-size: " + __hbqtCssPX( 16 ) + "font-weight: bold;" )
      :connect( QEvent_MouseButtonPress, {|oEvent| iif( ! ::lEditable, NIL, ;
                                         iif( oEvent:button() == Qt_LeftButton, ::editTriggered(), NIL ) ) } )
   ENDWITH
   WITH OBJECT ::oPropertyWidget := ::propertyWidget()
      //
   ENDWITH
   WITH OBJECT ::oStack := QStackedWidget()
      :addWidget( ::oValueLabel )
      :addWidget( ::oPropertyWidget )
      :setCurrentIndex( 0 )
   ENDWITH

   HB_SYMBOL_UNUSED( oLay )
   RETURN Self


METHOD HbQtProperty:refresh()
   WITH OBJECT ::oStack
      :setCurrentIndex( 0 )
   ENDWITH
   ::lEditable := .F.
   RETURN Self


METHOD HbQtProperty:propertyWidget()
   LOCAL oWidget

   SWITCH ::nType
   CASE __HBQT_PRP_EDIT__
      SWITCH ::cValueType
      CASE "C"
         WITH OBJECT oWidget := QLineEdit()
            :setInputMethodHints( Qt_ImhNoPredictiveText )
            :connect( "editingFinished()", {|| ::valueChanged() } )
            :connect( "returnPressed()"  , {|| ::valueChanged(), ::oStack:setCurrentIndex( 0 ) } )
            :connect( QEvent_Show        , {|| ::oPropertyWidget:setText( __xtos( ::xValue ) ) } )
            :connect( QEvent_FocusOut    , {|| ::oStack:setCurrentIndex( 0 ) } )
            :connect( QEvent_KeyRelease  , {|e| ::manageEvent( e, oWidget  ) } )
         ENDWITH
         EXIT
      CASE "N"
         WITH OBJECT oWidget := QLineEdit()
            :setInputMethodHints( Qt_ImhFormattedNumbersOnly )
            :connect( "editingFinished()", {|| ::valueChanged() } )
            :connect( "returnPressed()"  , {|| ::valueChanged(), ::oStack:setCurrentIndex( 0 ) } )
            :connect( QEvent_Show        , {|| ::oPropertyWidget:setText( __xtos( ::xValue ) ) } )
            :connect( QEvent_FocusOut    , {|| ::oStack:setCurrentIndex( 0 ) } )
            :connect( QEvent_KeyRelease  , {|e| ::manageEvent( e, oWidget  ) } )
         ENDWITH
         EXIT
      CASE "D"
         WITH OBJECT oWidget := QDateEdit()
            :connect( "dateChanged(QDate)", {|oDate| ::valueChanged( oDate ) } )
            :connect( QEvent_Show         , {|| ::oPropertyWidget:setDate( __d2QDate( ::xValue ) ) } )
            :connect( QEvent_FocusOut     , {|| ::oStack:setCurrentIndex( 0 ) } )
            :connect( QEvent_KeyRelease   , {|e| ::manageEvent( e, oWidget  ) } )
         ENDWITH
         EXIT
      CASE "L"
         WITH OBJECT oWidget := QCheckBox()
            :connect( "stateChanged(int)", {|nState| ::valueChanged( nState ) } )
            :connect( QEvent_Show        , {|| ::oPropertyWidget:setCheckState( iif( ! ::xValue, Qt_Unchecked, Qt_Checked ) ) } )
            :connect( QEvent_FocusOut    , {|| ::oStack:setCurrentIndex( 0 ) } )
         ENDWITH
         EXIT
      ENDSWITCH
      EXIT
   CASE __HBQT_PRP_COMBO__
      WITH OBJECT oWidget := QComboBox()
         :connect( "activated(QString)", {| cString | ::valueChanged( cString ), ::oStack:setCurrentIndex( 0 ) } )
         :connect( QEvent_Show         , {|| ::oPropertyWidget:setCurrentIndex( AScan( ::xValues, ::xValue ) - 1 ) } )
         :connect( QEvent_FocusOut     , {|| iif( oWidget:view():isVisible(), NIL, ::oStack:setCurrentIndex( 0 ) ) } )
      ENDWITH
      EXIT
   CASE __HBQT_PRP_FONT__
      WITH OBJECT oWidget := QLabel()
         :connect( QEvent_Show         , {|| ::oPropertyWidget:setText( ::oValueLabel:text() ), ::execFontNameSliding( Self ) } )
         :connect( QEvent_FocusOut     , {|| ::oStack:setCurrentIndex( 0 ), ::oStack:setFocus() } )
      ENDWITH
      EXIT
   CASE __HBQT_PRP_FONTSIZE__
      WITH OBJECT oWidget := QLabel()
         :connect( QEvent_Show         , {|| ::oPropertyWidget:setText( ::oValueLabel:text() ), ::execFontSizeSliding( Self ) } )
         :connect( QEvent_FocusOut     , {|| ::oStack:setCurrentIndex( 0 ), ::oStack:setFocus() } )
      ENDWITH
      EXIT
   CASE __HBQT_PRP_BRUSHSTYLE__
      WITH OBJECT oWidget := QLabel()
         :connect( QEvent_Show         , {|| ::oPropertyWidget:setText( ::oValueLabel:text() ), ::execBrushStyleSliding( Self ) } )
         :connect( QEvent_FocusOut     , {|| ::oStack:setCurrentIndex( 0 ), ::oStack:setFocus() } )
      ENDWITH
      EXIT
   CASE __HBQT_PRP_COLOR__
      WITH OBJECT oWidget := QLabel( ::xValue )
      //   :connect( QEvent_Show         , {|| ::execColorDialog(), ::oStack:setCurrentIndex( 0 ) } )
         :connect( QEvent_Show         , {|| ::oPropertyWidget:setText( ::oValueLabel:text() ), ::execColorNameSliding( Self ) } )
         :connect( QEvent_FocusOut     , {|| ::oStack:setCurrentIndex( 0 ), ::oStack:setFocus() } )
      ENDWITH
      EXIT
   CASE __HBQT_PRP_TEXTURE__
      WITH OBJECT oWidget := QLineEdit()
         :connect( "editingFinished()", {|| ::valueChanged() } )
         :connect( "returnPressed()"  , {|| ::valueChanged(), ::oStack:setCurrentIndex( 0 ) } )
         :connect( QEvent_Show        , {|| ::oPropertyWidget:setText( __xtos( ::xValue ) ) } )
         :connect( QEvent_FocusOut    , {|| ::oStack:setCurrentIndex( 0 ) } )
         :connect( QEvent_KeyRelease  , {|e| ::manageEvent( e, oWidget  ) } )
      ENDWITH
      EXIT
   OTHERWISE
      WITH OBJECT oWidget := QLabel()
         :connect( QEvent_FocusOut, {|| ::oStack:setCurrentIndex( 0 ) } )
      ENDWITH
   ENDSWITCH
   RETURN oWidget


METHOD HbQtProperty:editTriggered()
   LOCAL xTmp

   IF HB_ISOBJECT( ::oPropertyWidget )
      ::oStack:setCurrentIndex( 1 )
      ::oPropertyWidget:setFocus()

      IF ::nType == __HBQT_PRP_COMBO__
         IF ::oPropertyWidget:count() <= 0
            WITH OBJECT ::oPropertyWidget
               :clear()
               IF HB_ISARRAY( ::xValues )
                  FOR EACH xTmp IN ::xValues
                     :addItem( __xtos( xTmp ) )
                  NEXT
               ENDIF
            ENDWITH
         ENDIF
         QApplication():sendEvent( ::oPropertyWidget, ;
            QMouseEvent( QEvent_MouseButtonPress, QPoint( 1,1 ), Qt_LeftButton, Qt_LeftButton, Qt_NoModifier ) )
      ENDIF
   ENDIF
   RETURN Self


METHOD HbQtProperty:valueChanged( xValue )
   LOCAL zValue

   SWITCH ::nType
   CASE __HBQT_PRP_EDIT__
      SWITCH ::cValueType
      CASE "C" ; zValue := ::oPropertyWidget:text()        ; EXIT
      CASE "N" ; zValue := Val( ::oPropertyWidget:text() ) ; EXIT
      CASE "L" ; zValue := ( xValue == Qt_Checked )        ; EXIT
      CASE "D" ; zValue := __qDate2d( xValue )             ; EXIT
      ENDSWITCH
      EXIT
   CASE __HBQT_PRP_COMBO__
      zValue := xValue
      EXIT
   CASE __HBQT_PRP_COLOR__
      zValue := xValue
      //::oPropertyWidget:hidePopup()
      EXIT
   CASE __HBQT_PRP_BRUSHSTYLE__
   CASE __HBQT_PRP_FONTSIZE__
   CASE __HBQT_PRP_FONT__
      zValue := xValue
      EXIT
   CASE __HBQT_PRP_TEXTURE__
      zValue := ::oPropertyWidget:text()
      EXIT
   OTHERWISE
      zValue := ""
   ENDSWITCH

   ::setValue( zValue )
   IF HB_ISBLOCK( ::propertyChangedBlock() )
      Eval( ::propertyChangedBlock(), ::name(), zValue )
   ENDIF
   RETURN Self


METHOD HbQtProperty:setValue( xValue )
   ::xValue := xValue
   ::oValueLabel:setText( __xtos( ::xValue ) )
   IF ::nType == __HBQT_PRP_COLOR__
      ::oValueLabel:setStyleSheet( "background-color: " + ::xValue + ";" )
   ENDIF
   RETURN .T.


METHOD HbQtProperty:setProperty( xValue )
   RETURN ::setValue( xValue )


METHOD HbQtProperty:setLabel( cLabel )
   WITH OBJECT ::oWidget
      :setText( 0, cLabel )
   ENDWITH
   RETURN Self


METHOD HbQtProperty:setReadonly( lReadOnly )
   ::lEditable := ! lReadOnly
   RETURN Self


METHOD HbQtProperty:setOptions( aOptions )
   LOCAL xTmp

   IF ::nType == __HBQT_PRP_COMBO__
      ::xValues := aOptions
      WITH OBJECT ::oPropertyWidget
         :clear()
         FOR EACH xTmp IN aOptions
            :addItem( __xtos( xTmp ) )
         NEXT
         :setCurrentIndex( AScan( aOptions, {|e| e == __xtos( ::xValue ) } ) - 1 )
      ENDWITH
   ENDIF
   RETURN Self


METHOD HbQtProperty:manageEvent( oKeyEvent, oWidget )
   SWITCH oKeyEvent:key()
   CASE Qt_Key_Return
      ::oApp:postEvent( oWidget, QEvent( QEvent_CloseSoftwareInputPanel ) )
      RETURN .T.
   ENDSWITCH
   RETURN .F.


METHOD HbQtProperty:propertyChangedBlock( bBlock )
   LOCAL bOldBlock := ::bValueChanged
   IF HB_ISBLOCK( bBlock )
      ::bValueChanged := bBlock
   ENDIF
   RETURN bOldBlock


METHOD HbQtProperty:execFontDialog()
   LOCAL cFont, oDlg

   WITH OBJECT oDlg := QFontDialog( QColor( ::xValue ), ::oWidget )
      :exec()
      cFont := oDlg:selectedFont()
   ENDWITH
   __hbqt_delete( oDlg )
   IF ! Empty( cFont )
      ::valueChanged( cFont )
   ENDIF
   RETURN Self


METHOD HbQtProperty:execColorDialog()
   LOCAL cColor, oColorDlg

   WITH OBJECT oColorDlg := QColorDialog( QColor( ::xValue ) )
      :connect( "colorSelected(QColor)", {|oColor| cColor := oColor:name() } )
      :exec()
   ENDWITH
   __hbqt_delete( oColorDlg )
   IF ! Empty( cColor )
      ::oValueLabel:setStyleSheet( "background-color: " + cColor + ";" )
      ::valueChanged( cColor )
   ENDIF
   RETURN .F.


METHOD HbQtProperty:execColorNameSliding( oProperty )
   STATIC oColorNameSliding
   LOCAL cColor, aClr, hState, oPixmap, oState

   IF Empty( oColorNameSliding )
      HbQtActivateSilverLight( .T., "Pulling Color Info" )
      WITH OBJECT oColorNameSliding := HbQtSlidingList():new()
         :setSlidingDirection( __HBQTSLIDINGLIST_DIRECTION_RIGHTTOLEFT__ )
         :setDuration( 70 )
         :setFocusOut( .F. )
         :setWidth( 150 )
         :setHeaderText( "Available Colors" )
         :hidingBlock( {|| oProperty:oStack:setCurrentIndex( 0 ), oProperty:oStack:setFocus() } )
         :create()
      ENDWITH
      aClr := {}
      AAdd( aClr, "#ffffff" )
      AAdd( aClr, "#000000" )
      AAdd( aClr, "#7f7f7f" )
      AAdd( aClr, "#c3c3c3" )
      AAdd( aClr, "#880014" )
      AAdd( aClr, "#b97957" )
      AAdd( aClr, "#ed1c23" )
      AAdd( aClr, "#ffaec9" )
      AAdd( aClr, "#ff7d27" )
      AAdd( aClr, "#ffc90e" )
      AAdd( aClr, "#fff200" )
      AAdd( aClr, "#efe5b0" )
      AAdd( aClr, "#22b14d" )
      AAdd( aClr, "#b4e61d" )
      AAdd( aClr, "#00a2e8" )
      AAdd( aClr, "#99d8ea" )
      AAdd( aClr, "#3f48cc" )
      AAdd( aClr, "#7092be" )
      AAdd( aClr, "#a249a4" )
      AAdd( aClr, "#c8bfe7" )

      FOR EACH cColor IN aClr
         hState := {=>}
         //
         hState[ "BorderStyle" ] := Qt_SolidLine
         hState[ "Style" ] := Qt_SolidPattern
         hState[ "Color" ] := cColor
         hState[ "Area" ] := __STATE_AREA_OVERALL__
         //
         oState := HbQtVisualItemState():new( hState )
         oPixmap := oState:pixmap( __hbqtPixelsByDPI( 64 ), __hbqtPixelsByDPI( 64 ) )
         //
         oColorNameSliding:addItem( cColor, { cColor, oPixmap }, NIL )
      NEXT
      HbQtActivateSilverLight( .F. )
   ENDIF
   oColorNameSliding:activatedBlock( {|cName| oProperty:valueChanged( cName ) } )
   oColorNameSliding:show()
   RETURN Self


METHOD HbQtProperty:execFontNameSliding( oProperty )
   STATIC oFontNameSliding
   LOCAL oFontFamilies, i, cFont

   IF Empty( oFontNameSliding )
      HbQtActivateSilverLight( .T., "Pulling Fonts Info" )
      WITH OBJECT oFontNameSliding := HbQtSlidingList():new()
         :setSlidingDirection( __HBQTSLIDINGLIST_DIRECTION_RIGHTTOLEFT__ )
         :setDuration( 70 )
         :setFocusOut( .F. )
         :setWidth( 300 )
         :setHeaderText( "Available Fonts" )
         :hidingBlock( {|| oProperty:oStack:setCurrentIndex( 0 ), oProperty:oStack:setFocus() } )
         :create()

         oFontFamilies := QFontDatabase():families()
         FOR i := 0 TO oFontFamilies:size() - 1
            QApplication():processEvents()
            cFont := oFontFamilies:at( i )
            :addItem( cFont, { cFont, NIL, QFont( cFont ) }, NIL )
         NEXT
      ENDWITH
      HbQtActivateSilverLight( .F. )
   ENDIF
   oFontNameSliding:activatedBlock( {|cName| oProperty:valueChanged( cName ) } )
   oFontNameSliding:show()

   RETURN Self


METHOD HbQtProperty:execFontSizeSliding( oProperty )
   STATIC oFontSizeSliding
   LOCAL i, nMin, cSize

   IF Empty( oFontSizeSliding )
      WITH OBJECT oFontSizeSliding := HbQtSlidingList():new()
         :setSlidingDirection( __HBQTSLIDINGLIST_DIRECTION_RIGHTTOLEFT__ )
         :setDuration( 70 )
         :setFocusOut( .F. )
         :setWidth( 100 )
         :setHeaderText( "Font Sizes" )
         :hidingBlock( {|| oProperty:oStack:setCurrentIndex( 0 ), oProperty:oStack:setFocus() } )
         :create()

         nMin := 3.5
         FOR i := 0 TO 19
            cSize := LTrim( Str( nMin + ( i * 0.5 ) ) )
            :addItem( cSize, { cSize, NIL }, NIL )
         NEXT
      ENDWITH
   ENDIF
   oFontSizeSliding:activatedBlock( {|cName| oProperty:valueChanged( cName ) } )
   oFontSizeSliding:show()

   RETURN Self


METHOD HbQtProperty:execBrushStyleSliding( oProperty )
   STATIC oBrushStyleSliding
   LOCAL i, cStyle, aStyles

   IF Empty( oBrushStyleSliding )
      aStyles := {}

      AAdd( aStyles, "NoBrush"                )
      AAdd( aStyles, "SolidPattern"           )
      AAdd( aStyles, "Dense1Pattern"          )
      AAdd( aStyles, "Dense2Pattern"          )
      AAdd( aStyles, "Dense3Pattern"          )
      AAdd( aStyles, "Dense4Pattern"          )
      AAdd( aStyles, "Dense5Pattern"          )
      AAdd( aStyles, "Dense6Pattern"          )
      AAdd( aStyles, "Dense7Pattern"          )
      AAdd( aStyles, "HorPattern"             )
      AAdd( aStyles, "VerPattern"             )
      AAdd( aStyles, "CrossPattern"           )
      AAdd( aStyles, "BDiagPattern"           )
      AAdd( aStyles, "FDiagPattern"           )
      AAdd( aStyles, "DiagCrossPattern"       )
#if 0
      AAdd( aStyles, "LinearGradientPattern"  )
      AAdd( aStyles, "ConicalGradientPattern" )
      AAdd( aStyles, "RadialGradientPattern"  )
      AAdd( aStyles, "TexturePattern"         )
#endif
      WITH OBJECT oBrushStyleSliding := HbQtSlidingList():new()
         :setSlidingDirection( __HBQTSLIDINGLIST_DIRECTION_RIGHTTOLEFT__ )
         :setDuration( 70 )
         :setFocusOut( .F. )
         :setWidth( 200 )
         :setHeaderText( "Brush Styles" )
         :hidingBlock( {|| oProperty:oStack:setCurrentIndex( 0 ), oProperty:oStack:setFocus() } )
         :create()
         FOR i := 1 to Len( aStyles )
            cStyle := aStyles[ i ]
            :addItem( cStyle, { cStyle, NIL, NIL }, NIL  )
         NEXT
      ENDWITH
   ENDIF
   oBrushStyleSliding:activatedBlock( {|cName| oProperty:valueChanged( cName ) } )
   oBrushStyleSliding:show()

   RETURN Self


STATIC FUNCTION __xtos( xValue )
   SWITCH ValType( xValue )
   CASE "C" ; RETURN Trim( xValue )
   CASE "N" ; RETURN LTrim( Str( xValue ) )
   CASE "D" ; RETURN DToC( xValue )
   CASE "L" ; RETURN iif( xValue, "Yes", "No" )
   ENDSWITCH
   RETURN ""


STATIC FUNCTION __d2QDate( dDate )
   LOCAL oDate := QDate()
   IF HB_ISDATE( dDate )
      oDate:setDate( Year( dDate ), Month( dDate ), Day( dDate ) )
   ENDIF
   RETURN oDate


STATIC FUNCTION __qDate2d( oDate )
   LOCAL dDate := SToD( StrZero( oDate:year(), 4 ) + StrZero( oDate:month(), 2 ) + StrZero( oDate:day(), 2 ) )
   RETURN dDate


