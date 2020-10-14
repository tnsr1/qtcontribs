/*
 * $Id: demoqt.prg 426 2016-10-20 00:14:06Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Marcos Antonio Gambeta <marcosgambeta at gmail dot com>
 * Copyright 2009 Pritpal Bedi <bedipritpal@hotmail.com>
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

#include "hbqtgui.ch"
#include "hbtrace.ch"

/*----------------------------------------------------------------------*/
/*
 *                               A NOTE
 *
 *   This demo is built on auto generated classes by the engine. No attemp
 *   is exercised to refine the way the code must be written. At this moment
 *   my emphasis is on testing phase of QT wrapper functions and classes
 *   generated thereof. In near future the actual implementation will be
 *   based on the Xbase++ XBPParts  compatible framework. You just are
 *   encouraged to sense the power of QT through this expression.
 *
 *                             Pritpal Bedi
 */
/*----------------------------------------------------------------------*/

STATIC oSys, oMenuSys, oActShow, oActHide  /* To keep variables in scope for entire duration of appn */

REQUEST HB_QStyleOption

/*----------------------------------------------------------------------*/

PROCEDURE Main()

   hbqt_errorsys()

   ExecTheDialog()

   RETURN

/*----------------------------------------------------------------------*/

PROCEDURE ExecTheDialog()
   LOCAL oBtn, oDA, aMenu, aTool, aTabs, oStyle, lExit := .f.
   LOCAL oELoop, oWnd

   hbqt_errorsys()

   oWnd := QMainWindow()
   oWnd:setAttribute( Qt_WA_DeleteOnClose, .F. )
   oWnd:show()

   oWnd:setMouseTracking( .t. )
   oWnd:setWindowTitle( "[" + hb_ntos( hb_threadID() ) + "] Harbour-Qt" )
   oWnd:setWindowIcon( QIcon( "test" ) )
   oWnd:resize( 900, 500 )

   oDA    := QWidget( oWnd )
   oWnd:setCentralWidget( oDA )

   aMenu  := Build_MenuBar( oWnd, @lExit )
   aTool  := Build_ToolBar( oWnd )

   oWnd:statusBar():showMessage( "Harbour-QT Statusbar Ready!" )

   Build_Grid( oDA, { 30, 30 }, { 450,150 } )
   Build_ProgressBar( oDA, { 30,300 }, { 200,30 } )
   Build_ListBox( oDA, { 310,240 }, { 150, 100 } )
   Build_Label( oDA, { 30,190 }, { 300, 30 } )

   aTabs := Build_Tabs( oDA, { 510, 5 }, { 360, 400 } )

   oStyle := HBQProxyStyle()
   oStyle:hb_setDrawBlock( {|...| DrawButton( ... ) } )
   oBtn := Build_PushButton( oDA, { 30,240 }, { 100,50 } )
   oBtn:setStyle( oStyle )

   oWnd:connect( QEvent_KeyPress, {|e| My_Events( oWnd, e, @lExit ) } )
   oWnd:connect( QEvent_Close   , {|| lExit := .T. } )

   oWnd:Show()

   oELoop := QEventLoop( oWnd )
   DO WHILE .t.
      oELoop:processEvents( 0 )
      hb_idleState()
      IF lExit
         EXIT
      ENDIF
   ENDDO
   oELoop:exit( 0 )
   xReleaseMemory( { oBtn, aMenu, aTool, aTabs, oDA, oWnd } )

   HB_TRACE( HB_TR_DEBUG, "  " )
   HB_TRACE( HB_TR_DEBUG, ".............. E X I T I N G ...................", hb_threadID() )
   HB_TRACE( HB_TR_DEBUG, "  " )

   RETURN

/*----------------------------------------------------------------------*/

FUNCTION My_Events( oWnd, e, lExit )
   MsgInfo( oWnd, "Pressed: " + hb_ntos( e:key() ) )
   IF e:key() == Qt_Key_Escape
      lExit := .T.
   ENDIF
   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION xReleaseMemory( aObj )
   #if 0
   LOCAL i
   FOR i := 1 TO len( aObj )
      IF HB_ISOBJECT( aObj[ i ] )
         aObj[ i ] := NIL
      ELSEIF HB_ISARRAY( aObj[ i ] )
         xReleaseMemory( aObj[ i ] )
      ENDIF
   NEXT
   #else
      HB_SYMBOL_UNUSED( aObj )
   #endif
   RETURN nil

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_MenuBar( oWnd, lExit )
   LOCAL oMenuBar, oMenu1, oMenu2
   LOCAL oActNew, oActOpen, oActSave, oActExit
   LOCAL oActColors, oActFonts, oActPgSetup, oActPreview, oActWiz, oActWeb, oActOther

   oMenuBar := oWnd:menuBar()

   //    F I L E
   oMenu1 := QMenu( oMenuBar )
   oMenu1:setTitle( "&File" )

   oActNew := QAction( oMenu1 )
   oActNew:setText( "&New" )
   oActNew:setIcon( QIcon( hb_dirBase() + "new.png" ) )
   oActNew:connect( "triggered(bool)", {|w,l| FileDialog( "New" , w, l ) } )
   oMenu1:addAction( oActNew )

   oActOpen := oMenu1:addAction( QIcon( hb_dirBase() + "open.png" ), "&Open" )
   oActOpen:connect( "triggered(bool)", {|w,l| FileDialog( "Open" , w, l ) } )

   oMenu1:addSeparator()

   oActSave := oMenu1:addAction( QIcon( hb_dirBase() + "save.png" ), "&Save" )
   oActSave:connect( "triggered(bool)", {|w,l| FileDialog( "Save" , w, l ) } )

   oMenu1:addSeparator()

   oActExit := oMenu1:addAction( "E&xit" )
   oActExit:connect( "triggered(bool)", {|| lExit := .T. } )

   oMenuBar:addMenu( oMenu1 )

   //     D I A L O G S
   oMenu2 := QMenu( oMenuBar )
   oMenu2:setTitle( "&Dialogs" )

   oActColors := oMenu2:addAction( "&Colors" )
   oActColors:connect( "triggered(bool)", {|| Dialogs( "Colors", oWnd ) } )

   oActFonts := oMenu2:addAction( "&Fonts" )
   oActFonts:connect( "triggered(bool)", {|| Dialogs( "Fonts", oWnd ) } )

   oMenu2:addSeparator()

   oActPgSetup := oMenu2:addAction( "&PageSetup" )
   oActPgSetup:connect( "triggered(bool)", {|| Dialogs( "PageSetup", oWnd ) } )

   oActPreview := oMenu2:addAction( "P&review" )
   oActPreview:connect( "triggered(bool)", {|| Dialogs( "Preview", oWnd ) } )

   oMenu2:addSeparator()

   oActWiz := oMenu2:addAction( "&Wizard" )
   oActWiz:connect( "triggered(bool)", {|| Dialogs( "Wizard", oWnd ) } )

   oActWeb := oMenu2:addAction( "W&ebPage" )
   oActWeb:connect( "triggered(bool)", {|| Dialogs( "WebPage", oWnd ) } )

   oMenu2:addSeparator()

   oActOther := oMenu2:addAction( "&Another Dialog" )
   oActOther:connect( "triggered(bool)", {|| hb_threadStart( {|| ExecTheDialog( oWnd ) } ) } )

   oMenuBar:addMenu( oMenu2 )

   RETURN { oActNew, oActOpen, oActSave, oActExit, oActColors, oActFonts, ;
            oActPgSetup, oActPreview, oActWiz, oActWeb, oActOther }

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_ToolBar( oWnd )
   LOCAL oTB, oActNew, oActOpen, oActSave

   /* Create a Toolbar Object */
   oTB := QToolBar( oWnd )

   /* Create an action */
   oActNew := QAction( oWnd )
   oActNew:setText( "&New" )
   oActNew:setIcon( QIcon( hb_dirBase() + "new.png" ) )
   oActNew:setToolTip( "A New File" )
   oActNew:connect( "triggered(bool)", {|w,l| FileDialog( "New" , w, l ) } )
   /* Attach Action with Toolbar */
   oTB:addAction( oActNew )

   /* Create another action */
   oActOpen := QAction( oWnd )
   oActOpen:setText( "&Open" )
   oActOpen:setIcon( QIcon( hb_dirBase() + "open.png" ) )
   oActOpen:setToolTip( "Select a file to be opened!" )
   oActOpen:connect( "triggered(bool)", {|w,l| FileDialog( "Open" , w, l ) } )
   /* Attach Action with Toolbar */
   oTB:addAction( oActOpen )

   oTB:addSeparator()

   /* Create another action */
   oActSave := QAction( oWnd )
   oActSave:setText( "&Save" )
   oActSave:setIcon( QIcon( hb_dirBase() + "save.png" ) )
   oActSave:setToolTip( "Save this file!" )
   oActSave:connect( "triggered(bool)", {|w,l| FileDialog( "Save" , w, l ) } )
   /* Attach Action with Toolbar */
   oTB:addAction( oActSave )

   /* Add this toolbar with main window */
   oWnd:addToolBar( oTB )

   RETURN { oActNew, oActOpen, oActSave }

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_PushButton( oWnd, aPos, aSize, cLabel, cMsg, lExit )
   LOCAL oBtn

   hb_default( @cLabel, "Push Button" )
   hb_default( @cMsg  , "Push Button Pressed" )

   oBtn := QPushButton( oWnd )
   oBtn:setText( cLabel )
   oBtn:move( aPos[ 1 ],aPos[ 2 ] )
   oBtn:resize( aSize[ 1 ],aSize[ 2 ] )
   oBtn:show()
   IF HB_ISLOGICAL( lExit )
      oBtn:connect( "clicked()", {|| lExit := .t. } )
   ELSE
      oBtn:connect( "clicked()", {|| MsgInfo( oWnd, cMsg ), lExit := .t. } )
   ENDIF

   RETURN oBtn

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_Grid( oWnd, aPos, aSize )
   LOCAL oGrid, oBrushBackItem0x0, oBrushForeItem0x0, oGridItem0x0

   oGrid := QTableWidget( oWnd )
   oGrid:setRowCount( 2 )
   oGrid:setColumnCount( 4 )
   //
   oBrushBackItem0x0 := QBrush()
   oBrushBackItem0x0:setStyle( 1 )        // Solid Color
   oBrushBackItem0x0:setColor( 10 )     // http://doc.qtsoftware.com/4.5/qt.html#GlobalColor-enum
   //
   oBrushForeItem0x0 := QBrush()
   oBrushForeItem0x0:setColor( 7 )
   //
   oGridItem0x0 := QTableWidgetItem()
   oGridItem0x0:setBackground( oBrushBackItem0x0 )
   oGridItem0x0:setForeground( oBrushForeItem0x0 )
   oGridItem0x0:setText( "Item 0x0" )
   //
   oGrid:setItem( 0, 0, oGridItem0x0 )
   //
   oGrid:Move( aPos[ 1 ], aPos[ 2 ] )
   oGrid:ReSize( aSize[ 1 ], aSize[ 2 ] )
   //
   oGrid:Show()

   RETURN {}

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_Tabs( oWnd, aPos, aSize )
   LOCAL oTabWidget, oTab1, oTab2, oTab3, aCtrls

   oTabWidget := QTabWidget( oWnd )

   oTab1 := QWidget( oTabWidget )
   oTab2 := QWidget( oTabWidget )
   oTab3 := QWidget( oTabWidget )

   oTabWidget:addTab( oTab2, "Controls" )
   oTabWidget:addTab( oTab3, "TextBox"  )
   oTabWidget:addTab( oTab1, "Folders"  )

   oTabWidget:Move( aPos[ 1 ], aPos[ 2 ] )
   oTabWidget:ReSize( aSize[ 1 ], aSize[ 2 ] )
   oTabWidget:show()

   Build_Treeview( oTab1 )
   aCtrls := Build_Controls( oTab2 )
   Build_TextBox( oTab3 )

   RETURN { aCtrls }

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_TreeView( oWnd )
#if .T. // defined( __HB_QT_MAJOR_VERSION_5__ )
   HB_SYMBOL_UNUSED( oWnd )
#else
   LOCAL oDirModel
   LOCAL oTV

   oDirModel := QDirModel( oWnd )

   oTV := QTreeView( oWnd )
   oTV:setMouseTracking( .t. )
// oTV:connect( "hovered()", {|i| HB_TRACE( HB_TR_DEBUG, ( "oTV:hovered" ) } )
   oTV:setModel( oDirModel )
   oTV:move( 5, 7 )
   oTV:resize( 345, 365 )
   OTV:show()
#endif
   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_ListBox( oWnd, aPos, aSize )
   LOCAL oListBox, oStrList, oStrModel

   oListBox := QListView( oWnd )

   oStrList := QStringList()
   oStrList:append( "India"          )
   oStrList:append( "United States"  )
   oStrList:append( "England"        )
   oStrList:append( "Japan"          )
   oStrList:append( "Hungary"        )
   oStrList:append( "Argentina"      )
   oStrList:append( "China"          )
   oStrList:sort()

   oStrModel := QStringListModel( oStrList, oListBox )

   oListBox:setModel( oStrModel )
   oListBox:Move( aPos[ 1 ], aPos[ 2 ] )
   oListBox:ReSize( aSize[ 1 ], aSize[ 2 ] )
   oListBox:Show()

   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_TextBox( oWnd )
   LOCAL oTextBox

   oTextBox := QTextEdit( oWnd )
   oTextBox:Move( 5, 7 )
   oTextBox:Resize( 345,365 )
   oTextBox:setAcceptRichText( .t. )
   oTextBox:setPlainText( "This is Harbour QT implementation" )
   oTextBox:Show()

   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_Controls( oWnd )
   LOCAL oEdit, oCheckBox, oComboBox, oSpinBox, oRadioButton

   oEdit := QLineEdit( oWnd )
   oEdit:connect( "returnPressed()", {|i| i := i, MsgInfo( oWnd, oEdit:text() ) } )
   oEdit:move( 5, 10 )
   oEdit:resize( 345, 30 )
   oEdit:setMaxLength( 40 )
   oEdit:setText( "TextBox Testing Max Length = 40" )
   oEdit:setAlignment( 1 )   // 1: Left  2: Right  4: center 8: use all textbox length
   oEdit:show()

   oComboBox := QComboBox( oWnd )
   oComboBox:setInsertPolicy( QComboBox_InsertAlphabetically )
   oComboBox:addItem( "Third"  )
   oComboBox:addItem( "First"  )
   oComboBox:addItem( "Second" )
   oComboBox:connect( "currentIndexChanged(int)", {|i| i := i, MsgInfo( oWnd, oComboBox:itemText( i ) ) } )
   oComboBox:move( 5, 60 )
   oComboBox:resize( 345, 30 )
   oComboBox:show()

   oCheckBox := QCheckBox( oWnd )
   oCheckBox:connect( "stateChanged(int)", {|i| i := i, MsgInfo( oWnd, iif( i == 0,"Uncheckd","Checked" ) ) } )
   oCheckBox:setText( "Testing CheckBox HbQt" )
   oCheckBox:move( 5, 110 )
   oCheckBox:resize( 345, 30 )
   oCheckBox:show()

   oSpinBox := QSpinBox( oWnd )
   oSpinBox:Move( 5, 160 )
   oSpinBox:ReSize( 345, 30 )
   oSpinBox:Show()

   oRadioButton := QRadioButton( oWnd )
   oRadioButton:connect( "clicked()", {|i| i := i, MsgInfo( oWnd, "Checked" ) } )
   oRadioButton:Move( 5, 210 )
   oRadioButton:ReSize( 345, 30 )
   oRadioButton:Show()

   RETURN { oEdit, oComboBox, oCheckBox, oRadioButton }

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_ProgressBar( oWnd, aPos, aSize )
   LOCAL oProgressBar

   oProgressBar := QProgressBar( oWnd )
   oProgressBar:SetRange( 1, 1500 )
   oProgressBar:Setvalue( 500 )
   oProgressBar:Move( aPos[ 1 ], aPos[ 2 ] )
   oProgressBar:ReSize( aSize[ 1 ], aSize[ 2 ] )
   oProgressBar:Show()

   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION Build_Label( oWnd, aPos, aSize )
   LOCAL oLabel

   oLabel := QLabel( oWnd )
   oLabel:SetTextFormat( 1 )  // 0 text plain  1 RichText
   oLabel:SetText( [<font color="Blue" size=6 ><u>This is a</u> <i>Label</i> in <b>Harbour QT</b></font>] )
   oLabel:Move( aPos[ 1 ], aPos[ 2 ] )
   oLabel:ReSize( aSize[ 1 ], aSize[ 2 ] )
   oLabel:Show()

   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION MsgInfo( oWnd, cMsg )
   LOCAL oMB

   oMB := QMessageBox( oWnd )
   oMB:setInformativeText( cMsg )
   oMB:setWindowTitle( "Harbour-QT" )
   oMB:exec()

   oMB:setParent( QWidget() )

   RETURN NIL

/*----------------------------------------------------------------------*/

STATIC FUNCTION FileDialog()

   STATIC oFD

   IF Empty( oFD )
      WITH OBJECT oFD := QFileDialog()
         :setOption( QFileDialog_DontResolveSymlinks, .t. )
         :setWindowTitle( "Select a File" )
         :setAttribute( Qt_WA_DeleteOnClose, .F. )
         :connect( QEvent_Close, {|| oFD:hide() } )
      ENDWITH
   ENDIF

   RETURN oFD:exec()

/*----------------------------------------------------------------------*/

STATIC FUNCTION Dialogs( cType, oParent )
   LOCAL oDlg

   DO CASE
   CASE cType == "PageSetup"
      oDlg := QPageSetupDialog()
      oDlg:setWindowTitle( "Harbour-QT PageSetup Dialog" )
      oDlg:exec()
   CASE cType == "Preview"
      oDlg := QPrintPreviewDialog()
      oDlg:setWindowTitle( "Harbour-QT Preview Dialog" )
      oDlg:exec()
   CASE cType == "Wizard"
      QMessageBox():critical( oParent, "XXX", "yyy" )
      oDlg := QWizard()
      oDlg:setWindowTitle( "Harbour-QT Wizard to Show Slides etc." )
      oDlg:exec()
   CASE cType == "Colors"
      oDlg := QColorDialog( oParent )
      oDlg:setWindowTitle( "Harbour-QT Color Selection Dialog" )
      oDlg:exec()
      oDlg:setParent( QWidget() )
   CASE cType == "WebPage"
#if 0    // Till we resolve for oDlg:show()
      oDlg := QWebView()
      oUrl := QUrl()
      oUrl:setUrl( "http://www.harbour.vouch.info" )
      oDlg:setWindowTitle( "Harbour-QT Web Page Navigator" )
      oDlg:exec()
#endif
   CASE cType == "Fonts"
      oDlg := QFontDialog()
      oDlg:setWindowTitle( "Harbour-QT Font Selector" )
      oDlg:exec()
   ENDCASE

   oDlg:setParent( QWidget() )
   oDlg := NIL

   RETURN NIL

/*----------------------------------------------------------------------*/

#ifdef __PLATFORM__WINDOWS
PROCEDURE hb_GtSys()
   HB_GT_GUI_DEFAULT()
   RETURN
#endif

/*----------------------------------------------------------------------*/

FUNCTION ShowInSystemTray( oWnd )

   oMenuSys := QMenu( oWnd )
   oMenuSys:setTitle( "&File" )

   oActShow := oMenuSys:addAction( hb_dirBase() + "new.png" , "&Show" )
   oActShow:connect( "triggered(bool)", {|| oWnd:show() } )

   oMenuSys:addSeparator()

   oActHide := oMenuSys:addAction( hb_dirBase() + "new.png" , "&Show" )
   oActHide:connect( "triggered(bool)", {|| oWnd:hide() } )

   oSys := QSystemTrayIcon( oWnd )
   oSys:setIcon( QIcon( hb_dirBase() + "new.png" ) )
   oSys:setContextMenu( oMenuSys )
   oSys:showMessage( "Harbour-QT", "This is Harbour-QT System Tray" )
   oSys:show()
   oWnd:hide()

   RETURN nil

/*----------------------------------------------------------------------*/

STATIC FUNCTION DrawButton( ... )
   LOCAL oColor, oPainter, oRect, oOptions
   LOCAL aP := hb_AParams()

   SWITCH aP[ 1 ]
   CASE HBQT_DRAW_CONTROL
      IF aP[ 2 ] == QStyle_CE_PushButton
         oOptions := aP[ 3 ]
         oPainter := aP[ 4 ]
         oRect    := QRect( 0, 0, aP[ 5 ]:width(), aP[ 5 ]:height() )
         IF hb_bitAnd( oOptions:state(), QStyle_State_MouseOver ) == QStyle_State_MouseOver
            oColor   := QColor( 120,12,200 )
         ELSE
            oColor   := QColor( 0, 255, 255 )
         ENDIF

         oPainter:fillRect( oRect, oColor )
         oPainter:drawRect( oRect:adjusted( 0,0,-1,-1 ) )
         oPainter:drawText( 31, 31, "Harbour" )

         HB_TRACE( HB_TR_ALWAYS, "HBQT_DRAW_CONTROL:element", aP[ 2 ], oOptions:state() )
         RETURN .T.  /* Tell that you have drawn the control */
      ENDIF
      EXIT
   CASE HBQT_DRAW_ITEMTEXT
      HB_TRACE( HB_TR_ALWAYS, "HBQT_DRAW_ITEMTEXT:element", aP[ 7 ] )
      IF .T.
         RETURN .T.
      ENDIF
      EXIT
   CASE HBQT_DRAW_PRIMITIVE
      HB_TRACE( HB_TR_ALWAYS, "HBQT_DRAW_PRIMITIVE:element", aP[ 2 ] )
      EXIT
   ENDSWITCH
   RETURN NIL

/*----------------------------------------------------------------------*/
