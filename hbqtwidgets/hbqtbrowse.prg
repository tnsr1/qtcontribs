/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
 *
 * Copyright 2012-2013 Pritpal Bedi <bedipritpal@hotmail.com>
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


#include "hbqtgui.ch"
#include "inkey.ch"
#include "hbclass.ch"

#include "hbtrace.ch"


#define __ev_keypress__                           1                /* Keypress Event */
#define __ev_mousepress_on_frozen__               31               /* Mousepress on Frozen */
#define __ev_mousepress__                         2                /* Mousepress */
#define __ev_xbpBrw_itemSelected__                3                /* xbeBRW_ItemSelected */
#define __ev_wheel__                              4                /* wheelEvent */
#define __ev_horzscroll_via_qt__                  11               /* Horizontal Scroll Position : sent by Qt */
#define __ev_vertscroll_via_user__                101              /* Vertical Scrollbar Movements by the User */
#define __ev_vertscroll_sliderreleased__          102              /* Vertical Scrollbar: Slider Released */
#define __ev_horzscroll_slidermoved__             103              /* Horizontal Scrollbar: Slider moved */
#define __ev_horzscroll_sliderreleased__          104              /* Horizontal Scrollbar: Slider Released */
#define __ev_columnheader_pressed__               111              /* Column Header Pressed */
#define __ev_headersec_resized__                  121              /* Header Section Resized */
#define __ev_footersec_resized__                  122              /* Footer Section Resized */
#define __editor_closeEditor__                    1400
#define __editor_commitData__                     1401

#define __ev_tableViewBlock_main__                1501
#define __ev_tableViewBlock_left__                1502
#define __ev_tableViewBlock_right__               1503

#define __ev_frame_resized__                      2001
#define __ev_contextMenuRequested__               2002


#define XBPBRW_CURSOR_NONE                        1
#define XBPBRW_CURSOR_CELL                        2
#define XBPBRW_CURSOR_ROW                         3

#define XBPBRW_Navigate_NextLine                  1
#define XBPBRW_Navigate_PrevLine                  2
#define XBPBRW_Navigate_NextPage                  3
#define XBPBRW_Navigate_PrevPage                  4
#define XBPBRW_Navigate_GoTop                     5
#define XBPBRW_Navigate_GoBottom                  6
#define XBPBRW_Navigate_Skip                      7    // MsgPar2 == <nSkip>
#define XBPBRW_Navigate_NextCol                   8
#define XBPBRW_Navigate_PrevCol                   9
#define XBPBRW_Navigate_FirstCol                  10
#define XBPBRW_Navigate_LastCol                   11
#define XBPBRW_Navigate_GoPos                     12  // MsgPar2 == <nNewPercentPos>
#define XBPBRW_Navigate_SkipCols                  13  // MsgPar2 == <nColsToSkip>
#define XBPBRW_Navigate_GotoItem                  14  // MsgPar2 == <aRowCol>
#define XBPBRW_Navigate_GotoRecord                15  // MsgPar2 == <nRecordId>

#define XBPBRW_Pan_Left                           1
#define XBPBRW_Pan_Right                          2
#define XBPBRW_Pan_FirstCol                       3
#define XBPBRW_Pan_LastCol                        4
#define XBPBRW_Pan_Track                          5

#define xbeB_Event                                1048576
#define xbeP_Keyboard                             ( 004 + xbeB_Event )

#define xbeBRW_ItemMarked                         ( 400 + xbeB_Event )
#define xbeBRW_ItemSelected                       ( 401 + xbeB_Event )
#define xbeBRW_ItemRbDown                         ( 402 + xbeB_Event )
#define xbeBRW_HeaderRbDown                       ( 403 + xbeB_Event )
#define xbeBRW_FooterRbDown                       ( 404 + xbeB_Event )
#define xbeBRW_Navigate                           ( 405 + xbeB_Event )
#define xbeBRW_Pan                                ( 406 + xbeB_Event )
#define xbeBRW_ForceStable                        ( 408 + xbeB_Event )

#define XBPCOL_TYPE_ICON                          1
#define XBPCOL_TYPE_BITMAP                        2
#define XBPCOL_TYPE_SYSICON                       3
#define XBPCOL_TYPE_TEXT                          4
#define XBPCOL_TYPE_FILEICON                      5
#define XBPCOL_TYPE_FILEMINIICON                  6
#define XBPCOL_TYPE_MULTILINETEXT                 7


FUNCTION HbQtBrowseNew( nTop, nLeft, nBottom, nRight, oParent, oFont )
   RETURN HbQtBrowse():new( nTop, nLeft, nBottom, nRight, oParent, oFont )


STATIC FUNCTION SetAppEvent( ... )
   RETURN NIL


STATIC FUNCTION hbxbp_ConvertAFactFromXBP( ... )
   RETURN NIL


CLASS HbQtBrowse INHERIT TBrowse

   DATA   oWidget

   METHOD new( nTop, nLeft, nBottom, nRight, oParent, oFont )
   METHOD create()
   METHOD execSlot( nEvent, p1, p2, p3 )
   METHOD supplyInfo( nMode, nCall, nRole, nX, nY )
   METHOD compatColor( nColor )
   METHOD compatIcon( cIcon )

   DATA   oParent
   DATA   oFont

   DATA   oDbfModel
   DATA   oModelIndex                             INIT      QModelIndex()
   DATA   oVHeaderView
   DATA   oHeaderView
   DATA   oVScrollBar                             INIT      QScrollBar()
   DATA   oHScrollBar                             INIT      QScrollBar()
   DATA   oViewport                               INIT      QWidget()
   DATA   pCurIndex

   DATA   lFirst                                  INIT      .t.
   DATA   nRowsInView                             INIT      1

   METHOD connect()

   METHOD setHorzOffset()
   METHOD setVertScrollBarRange( lPageStep )
   METHOD setHorzScrollBarRange( lPageStep )
   METHOD updateVertScrollBar()
   METHOD updatePosition()

   METHOD navigate( p1, p2 )                      SETGET
   METHOD pan( p1 )                               SETGET

   DATA   sl_xbeBRW_Navigate
   DATA   sl_xbeBRW_Pan

   DATA   lHScroll                                INIT      .T.
   METHOD hScroll                                 SETGET
   DATA   lVScroll                                INIT      .T.
   METHOD vScroll                                 SETGET
   DATA   nCursorMode                             INIT      1
   METHOD cursorMode                              SETGET

   DATA   lSizeCols                               INIT      .T.
   METHOD sizeCols                                SETGET

   DATA   softTrack                               INIT      .T.
   DATA   nHorzOffset                             INIT      -1
   DATA   lReset                                  INIT      .F.
   DATA   lHorzMove                               INIT      .f.

   DATA   oTableView
   DATA   oGridLayout
   DATA   oFooterView
   DATA   oFooterModel

   DATA   oLeftView
   DATA   oLeftVHeaderView
   DATA   oLeftHeaderView
   DATA   oLeftFooterView
   DATA   oLeftFooterModel
   DATA   oLeftDbfModel

   DATA   oRightView
   DATA   oRightVHeaderView
   DATA   oRightHeaderView
   DATA   oRightFooterView
   DATA   oRightFooterModel
   DATA   oRightDbfModel

   METHOD buildLeftFreeze()
   METHOD buildRightFreeze()
   METHOD fetchColumnInfo( nCall, nRole, nArea, nRow, nCol )

   METHOD setLeftFrozen( aColFrozens )
   METHOD setRightFrozen( aColFrozens )
   DATA   aLeftFrozen                             INIT   {}
   DATA   aRightFrozen                            INIT   {}
   DATA   nLeftFrozen                             INIT   0
   DATA   nRightFrozen                            INIT   0

   DATA   gridStyle                               INIT   Qt_SolidLine

   DATA   nCellHeight                             INIT   20
   DATA   oDefaultCellSize
   METHOD setCellHeight( nCellHeight )
   METHOD setCurrentIndex( lReset )
   METHOD setIndex( qModelIndex )                 INLINE ::oTableView:setCurrentIndex( qModelIndex )
   METHOD getCurrentIndex()                       INLINE ::oDbfModel:index( ::rowPos - 1, ::colPos - 1 )
   ACCESS getDbfModel()                           INLINE ::oDbfModel
   METHOD openPersistentEditor()


   METHOD setFocus()                              INLINE ::oTableView:setFocus()

   DATA   qDelegate
   METHOD edit()                                  INLINE ::oTableView:edit( ::getCurrentIndex() )

   METHOD manageFrameResized()
   METHOD manageCommitData( qWidget )
   METHOD manageEditorClosed( pWidget, nHint )
   METHOD manageScrollContents( nX, nY )
   METHOD manageMouseDblClick( oMouseEvent )
   METHOD manageMousePress( oMouseEvent )
   METHOD manageMouseWheel( oWheelEvent )

   DATA   hColors                                 INIT {=>}
   DATA   hIcons                                  INIT {=>}

   ENDCLASS


METHOD HbQtBrowse:new( nTop, nLeft, nBottom, nRight, oParent, oFont )

   HB_SYMBOL_UNUSED( nTop )
   HB_SYMBOL_UNUSED( nLeft )
   HB_SYMBOL_UNUSED( nBottom )
   HB_SYMBOL_UNUSED( nRight )

   hb_default( @oFont, QFont( "Courier new", 10 ) )

   ::oParent := oParent
   ::oFont   := oFont

   ::create()

   RETURN Self


METHOD HbQtBrowse:connect()

   ::oLeftHeaderView  : connect( "sectionPressed(int)"               , {|i      | ::execSlot( __ev_mousepress_on_frozen__     , i    ) } )
   ::oLeftFooterView  : connect( "sectionPressed(int)"               , {|i      | ::execSlot( __ev_mousepress_on_frozen__     , i    ) } )

   ::oRightHeaderView : connect( "sectionPressed(int)"               , {|i      | ::execSlot( __ev_mousepress_on_frozen__     , i    ) } )
   ::oRightFooterView : connect( "sectionPressed(int)"               , {|i      | ::execSlot( __ev_mousepress_on_frozen__     , i    ) } )

   ::oTableView       : connect( QEvent_KeyPress                     , {|p      | ::execSlot( __ev_keypress__                 , p    ) } )
   ::oTableView       : connect( "customContextMenuRequested(QPoint)", {|p      | ::execSlot( __ev_contextMenuRequested__     , p    ) } )

   ::oHScrollBar      : connect( "actionTriggered(int)"              , {|i      | ::execSlot( __ev_horzscroll_slidermoved__   , i    ) } )
   ::oHScrollBar      : connect( "sliderReleased()"                  , {|i      | ::execSlot( __ev_horzscroll_sliderreleased__, i    ) } )

   ::oVScrollBar      : connect( "actionTriggered(int)"              , {|i      | ::execSlot( __ev_vertscroll_via_user__      , i    ) } )
   ::oVScrollBar      : connect( "sliderReleased()"                  , {|i      | ::execSlot( __ev_vertscroll_sliderreleased__, i    ) } )

   ::oHeaderView      : connect( "sectionPressed(int)"               , {|i      | ::execSlot( __ev_columnheader_pressed__     , i    ) } )
   ::oHeaderView      : connect( "sectionResized(int,int,int)"       , {|i,i1,i2| ::execSlot( __ev_headersec_resized__   , i, i1, i2 ) } )

   ::oWidget          : connect( QEvent_Resize                       , {|       | ::execSlot( __ev_frame_resized__                   ) } )

   ::qDelegate        : connect( "closeEditor(QWidget*,QAbstractItemDelegate::EndEditHint)", {|p,p1   | ::execSlot( __editor_closeEditor__, p, p1          ) } )
   ::qDelegate        : connect( "commitData(QWidget*)"              , {|p      | ::execSlot( __editor_commitData__           , p    ) } )

   RETURN Self


METHOD HbQtBrowse:buildLeftFreeze()

   /*  Left Freeze */
   ::oLeftView := HBQTableView()
   //
   ::oLeftView:setHorizontalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ::oLeftView:setVerticalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ::oLeftView:setTabKeyNavigation( .t. )
   ::oLeftView:setShowGrid( .t. )
   ::oLeftView:setGridStyle( ::gridStyle )   /* to be based on column definition */
   ::oLeftView:setSelectionMode( QAbstractItemView_SingleSelection )
   ::oLeftView:setSelectionBehavior( iif( ::cursorMode == 1, QAbstractItemView_SelectRows, QAbstractItemView_SelectItems ) )
   //
   /*  Veritical Header because of Performance boost */
   ::oLeftVHeaderView := ::oLeftView:verticalHeader()
   ::oLeftVHeaderView:hide()
   /*  Horizontal Header Fine Tuning */
   ::oLeftHeaderView := ::oLeftView:horizontalHeader()
   ::oLeftHeaderView:setHighlightSections( .F. )

   ::oLeftDbfModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 151, t, role, x, y ) } )

   ::oLeftView:setModel( ::oLeftDbfModel )
   //
   //::oLeftView:hide()

   /*  Horizontal Footer */
   ::oLeftFooterView := QHeaderView( Qt_Horizontal )
   //
   ::oLeftFooterView:setHighlightSections( .F. )
   ::oLeftFooterView:setMinimumHeight( 20 )
   ::oLeftFooterView:setMaximumHeight( 20 )
   ::oLeftFooterView:setResizeMode( QHeaderView_Fixed )
   ::oLeftFooterView:setFocusPolicy( Qt_NoFocus )
   //
   ::oLeftFooterModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 152, t, role, x, y ) } )

   ::oLeftFooterView:setModel( ::oLeftFooterModel )
   //
   //::oLeftFooterView:hide()

   RETURN Self


METHOD HbQtBrowse:buildRightFreeze()
   LOCAL oVHdr

   /*  Left Freeze */
   ::oRightView := HBQTableView()
   //
   ::oRightView:setHorizontalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ::oRightView:setVerticalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ::oRightView:setTabKeyNavigation( .t. )
   ::oRightView:setShowGrid( .t. )
   ::oRightView:setGridStyle( ::gridStyle )   /* to be based on column definition */
   ::oRightView:setSelectionMode( QAbstractItemView_SingleSelection )
   ::oRightView:setSelectionBehavior( iif( ::cursorMode == 1, QAbstractItemView_SelectRows, QAbstractItemView_SelectItems ) )
   //
   /*  Veritical Header because of Performance boost */
   oVHdr := ::oRightView:verticalHeader()
   oVHdr:hide()
   /*  Horizontal Header Fine Tuning */
   ::oRightHeaderView := ::oRightView:horizontalHeader()
   ::oRightHeaderView:setHighlightSections( .F. )

   ::oRightDbfModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 161, t, role, x, y ) } )

   ::oRightView:setModel( ::oRightDbfModel )

   /*  Horizontal Footer */
   ::oRightFooterView := QHeaderView( Qt_Horizontal )
   //
   ::oRightFooterView:setHighlightSections( .F. )
   ::oRightFooterView:setMinimumHeight( 20 )
   ::oRightFooterView:setMaximumHeight( 20 )
   ::oRightFooterView:setResizeMode( QHeaderView_Fixed )
   ::oRightFooterView:setFocusPolicy( Qt_NoFocus )
   //
   ::oRightFooterModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 162, t, role, x, y ) } )

   ::oRightFooterView:setModel( ::oRightFooterModel )

   RETURN Self


METHOD HbQtBrowse:create()
   LOCAL qRect

   ::oWidget := QFrame( ::oParent )
   ::oWidget:setFrameStyle( QFrame_Panel + QFrame_Plain )

   /* Important here as other parts will be based on it*/
   ::oWidget:resize( ::oParent:width(), ::oParent:height() )

   /* Subclass of QTableView */
   ::oTableView := HBQTableView()
   /* Set block to receive protected information */
   ::oTableView:hbSetBlock( {|p,p1,p2| ::execSlot( __ev_tableViewBlock_main__, p, p1, p2 ) } )
   /* Some parameters */
   ::oTableView:setTabKeyNavigation( .t. )
   ::oTableView:setShowGrid( .t. )
   ::oTableView:setGridStyle( ::gridStyle )   /* to be based on column definition */
   ::oTableView:setSelectionMode( QAbstractItemView_SingleSelection )
   ::oTableView:setSelectionBehavior( iif( ::cursorMode == 1, QAbstractItemView_SelectRows, QAbstractItemView_SelectItems ) )
   ::oTableView:setAlternatingRowColors( .t. )
   ::oTableView:setContextMenuPolicy( Qt_CustomContextMenu )

   /* Finetune Horizontal Scrollbar */
   ::oTableView:setHorizontalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   //
   ::oHScrollBar := QScrollBar()
   ::oHScrollBar:setOrientation( Qt_Horizontal )

   /*  Replace Vertical Scrollbar with our own */
   ::oTableView:setVerticalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   //
   ::oVScrollBar := QScrollBar()
   ::oVScrollBar:setOrientation( Qt_Vertical )

   /*  Veritical Header because of Performance boost */
   ::oVHeaderView := ::oTableView:verticalHeader()
   ::oVHeaderView:hide()

   /*  Horizontal Header Fine Tuning */
   ::oHeaderView := ::oTableView:horizontalHeader()
   ::oHeaderView:setHighlightSections( .F. )

   /* .DBF Manipulation Model */
   ::oDbfModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 141, t, role, x, y ) } )

   /*  Attach Model with the View */
   ::oTableView:setModel( ::oDbfModel )

   /*  Horizontal Footer */
   ::oFooterView := QHeaderView( Qt_Horizontal )
   //
   ::oFooterView:setHighlightSections( .F. )
   ::oFooterView:setMinimumHeight( 20 )
   ::oFooterView:setMaximumHeight( 20 )
   ::oFooterView:setResizeMode( QHeaderView_Fixed )
   ::oFooterView:setFocusPolicy( Qt_NoFocus )
   //
   ::oFooterModel := HBQAbstractItemModel( {|t,role,x,y| ::supplyInfo( 142, t, role, x, y ) } )
   //
   ::oFooterView:setModel( ::oFooterModel )

   /*  Widget for ::setLeftFrozen( aColumns )  */
   ::buildLeftFreeze()
   /*  Widget for ::setRightFrozen( aColumns )  */
   ::buildRightFreeze()

   /* Place all widgets in a Grid Layout */
   ::oGridLayout := QGridLayout( ::oWidget )
   ::oGridLayout:setContentsMargins( 0,0,0,0 )
   ::oGridLayout:setHorizontalSpacing( 0 )
   ::oGridLayout:setVerticalSpacing( 0 )
   /*  Rows */
   ::oGridLayout:addWidget( ::oLeftView       , 0, 0, 1, 1 )
   ::oGridLayout:addWidget( ::oLeftFooterView , 1, 0, 1, 1 )
   //
   ::oGridLayout:addWidget( ::oTableView      , 0, 1, 1, 1 )
   ::oGridLayout:addWidget( ::oFooterView     , 1, 1, 1, 1 )
   //
   ::oGridLayout:addWidget( ::oRightView      , 0, 2, 1, 1 )
   ::oGridLayout:addWidget( ::oRightFooterView, 1, 2, 1, 1 )
   //
   ::oGridLayout:addWidget( ::oHScrollBar     , 2, 0, 1, 3 )
   /*  Columns */
   ::oGridLayout:addWidget( ::oVScrollBar     , 0, 3, 2, 1 )

   ::oWidget:show()

   ::oFooterView:hide()

   /* Viewport */
   ::oViewport := ::oTableView:viewport()

   qRect := ::oWidget:geometry()
   ::oWidget:setGeometry( qRect )

   /* Handle the delegate */
   ::qDelegate := QItemDelegate()
   ::oTableView:setItemDelegate( ::qDelegate )

   //::oTableView:setEditTriggers( QAbstractItemView_AllEditTriggers )
   //::oTableView:setEditTriggers( QAbstractItemView_DoubleClicked )
   //::oTableView:setEditTriggers( QAbstractItemView_SelectedClicked )
   ::oTableView:setEditTriggers( QAbstractItemView_AnyKeyPressed )

   ::connect()

   RETURN Self


METHOD HbQtBrowse:execSlot( nEvent, p1, p2, p3 )
   LOCAL oPoint

   SWITCH nEvent
   CASE __ev_tableViewBlock_main__
      SWITCH p1
      CASE QEvent_MouseButtonPress
         ::manageMousePress( p2 )
         EXIT
      CASE QEvent_MouseButtonDblClick
         ::manageMouseDblClick( p2 )
         EXIT
      CASE QEvent_Wheel
         ::manageMouseWheel( p2 )
         EXIT
      CASE HBQT_HBQTABLEVIEW_scrollContentsBy
         ::manageScrollContents( p2, p3 )
         EXIT
      ENDSWITCH
      EXIT
   CASE __ev_mousepress_on_frozen__
      ::oTableView:setFocus( 0 )
      EXIT
   CASE __ev_horzscroll_via_qt__
      ::manageScrollContents( p1, p2 )
      EXIT
   CASE __ev_keypress__
      SetAppEvent( xbeP_Keyboard, hbqt_qtEventToHbEvent( p1 ), NIL, Self )
      RETURN .T.   /* Stop Propegation to parent */
   CASE __ev_contextMenuRequested__
      oPoint := ::oTableView:mapToGlobal( QPoint( p1 ) )
      ::hbContextMenu( { oPoint:x(), oPoint:y() } )
      EXIT
   CASE __editor_commitData__
      ::manageCommitData( p1 )
      EXIT
   CASE __editor_closeEditor__
      ::manageEditorClosed( p1, p2 )
      EXIT
   CASE __ev_vertscroll_via_user__
      SWITCH p1
      CASE QAbstractSlider_SliderNoAction
         RETURN NIL
      CASE QAbstractSlider_SliderSingleStepAdd
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_Skip, 1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderSingleStepSub
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_Skip, -1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderPageStepAdd
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_NextPage, 1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderPageStepSub
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_PrevPage, 1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderToMinimum
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_GoTop, 1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderToMaximum
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_GoBottom, 1, Self )
         ::updateVertScrollBar()
         EXIT
      CASE QAbstractSlider_SliderMove
         ::updatePosition()
         EXIT
      ENDSWITCH
      ::oTableView:setFocus( 0 )
      EXIT
   CASE __ev_vertscroll_sliderreleased__
      ::updatePosition()
      ::oTableView:setFocus()
      EXIT
   CASE __ev_horzscroll_slidermoved__
      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, ( ::oHScrollBar:value() + 1 ) - ::colPos, Self )
      ::oTableView:setFocus()
      EXIT
   CASE __ev_horzscroll_sliderreleased__
      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, ( ::oHScrollBar:value() + 1 ) - ::colPos, Self )
      ::oTableView:setFocus()
      EXIT
   CASE __ev_columnheader_pressed__
      SetAppEvent( xbeBRW_HeaderRbDown, { 0,0 }, p1+1, Self )
      EXIT
   CASE __ev_headersec_resized__
      ::oFooterView:resizeSection( p1, p3 )
      EXIT
   CASE __ev_footersec_resized__
      ::oHeaderView:resizeSection( p1, p3 )
      EXIT
   CASE __ev_frame_resized__
      ::manageFrameResized()
      RETURN .T.

   ENDSWITCH

   RETURN .F.


METHOD HbQtBrowse:manageFrameResized()
   LOCAL nRowPos, nColPos, nOff

   ::oHeaderView:resizeSection( 0, ::oHeaderView:sectionSize( 0 )+1 )
   ::oHeaderView:resizeSection( 0, ::oHeaderView:sectionSize( 0 )-1 )

   nRowPos := ::rowPos()
   nColPos := ::colPos()
   //
   ::nConfigure := 9
   ::doConfigure()
   //
   ::colPos := nColPos
   IF nRowPos > ::rowCount()
      nOff := nRowPos - ::rowCount()
      ::rowPos := ::rowCount()
   ELSE
      nOff := 0
   ENDIF
   ::refreshAll()
   ::forceStable()
   ::setCurrentIndex( nRowPos > ::rowCount() )
   IF nOff > 0
      /* I think we can honor this STEP directly instead of populating the event queue */
      ::skipRows( nOff )
   ENDIF

   RETURN Self


METHOD HbQtBrowse:manageCommitData( qWidget )
   LOCAL cTxt    := qWidget:property( "text" ):toString()
   LOCAL oCol    := ::columns[ ::colPos ]
   LOCAL cTyp    := valtype( eval( oCol:block ) )

   HB_TRACE( HB_TR_DEBUG, cTxt )
   DO CASE
   CASE cTyp == "C"
      oCol:setData( cTxt )
   CASE cTyp == "N"
      oCol:setData( val( cTxt ) )
   CASE cTyp == "D"
      oCol:setData( ctod( cTxt ) )
   CASE cTyp == "L"
      oCol:setData( cTxt $ "Yy" )
   ENDCASE

   RETURN Self


METHOD HbQtBrowse:manageEditorClosed( pWidget, nHint )

   pWidget:close()

   DO CASE
   CASE nHint == QAbstractItemDelegate_NoHint                 /* 0  RETURN is presses    */

   CASE nHint == QAbstractItemDelegate_EditNextItem           /* 1  TAB is pressed       */
      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, 1, Self )

   CASE nHint == QAbstractItemDelegate_EditPreviousItem       /* 2  SHIFT_TAB is pressed */
      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, -1, Self )

   CASE nHint == QAbstractItemDelegate_SubmitModelCache       /* 3  ENTER is pressed     */
      #if 0
      IF ::colPos < ::colCount
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, 1, Self )
         ::edit()
      ENDIF
      #endif
   CASE nHint == QAbstractItemDelegate_RevertModelCache       /* 4  ESC is pressed       */

   ENDCASE

   RETURN Self


METHOD HbQtBrowse:manageScrollContents( nX, nY )

   HB_SYMBOL_UNUSED( nY )

   IF nX != 0
      ::setHorzOffset()
   ENDIF

   RETURN Self


METHOD HbQtBrowse:manageMouseDblClick( oMouseEvent )

   IF oMouseEvent:button() == Qt_LeftButton
      SetAppEvent( xbeBRW_ItemSelected, NIL, NIL, Self )
   ENDIF

   RETURN Self


METHOD HbQtBrowse:manageMouseWheel( oWheelEvent )

   IF oWheelEvent:orientation() == Qt_Vertical
      IF oWheelEvent:delta() > 0
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_Skip, -1, Self )
      ELSE
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_Skip, 1, Self )
      ENDIF
   ELSE
      IF oWheelEvent:delta() > 0
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, 1, Self )
      ELSE
         SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, -1, Self )
      ENDIF
   ENDIF

   RETURN Self


METHOD HbQtBrowse:manageMousePress( oMouseEvent )
   HB_TRACE( HB_TR_DEBUG, __objGetClsName( oMouseEvent ), valtype( oMouseEvent:pos() ), ProcName( 1 ), procName( 2 ), ProcName( 3 ) )

   ::oModelIndex := ::oTableView:indexAt( oMouseEvent:pos() )
   IF ::oModelIndex:isValid()      /* Reposition the record pointer */
      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_Skip, ( ::oModelIndex:row() + 1 ) - ::rowPos, Self )

      SetAppEvent( xbeBRW_Navigate, XBPBRW_Navigate_SkipCols, ( ::oModelIndex:column() + 1 ) - ::colPos, Self )
   ENDIF

   IF oMouseEvent:button() == Qt_LeftButton
      SetAppEvent( xbeBRW_ItemMarked, { ::rowPos, ::colPos }, NIL, Self )

   ELSEIF oMouseEvent:button() == Qt_RightButton
      SetAppEvent( xbeBRW_ItemRbDown, { oMouseEvent:x(), oMouseEvent:y() }, { ::rowPos, ::colPos }, Self )

   ENDIF

   RETURN Self


METHOD HbQtBrowse:openPersistentEditor()

   ::oTableView:openPersistentEditor( ::oDbfModel:index( ::rowPos - 1, ::colPos - 1 ) )

   RETURN Self


METHOD HbQtBrowse:supplyInfo( nMode, nCall, nRole, nX, nY )

   IF nCall == HBQT_QAIM_headerData .AND. nX == Qt_Vertical
      RETURN NIL
   ENDIF

   IF nCall == HBQT_QAIM_flags
      RETURN Qt_ItemIsEnabled + Qt_ItemIsSelectable + Qt_ItemIsEditable
   ENDIF

   DO CASE
   CASE nMode == 141       /* Main View Header|Data */
      IF nCall == HBQT_QAIM_columnCount
         IF ::colCount > 0
            ::forceStable()
            ::setHorzScrollBarRange( .t. )
         ENDIF
         RETURN ::colCount
      ELSEIF nCall == HBQT_QAIM_rowCount
         IF ::colCount > 0
            ::forceStable()
            ::setVertScrollBarRange( .f. )
         ENDIF
         RETURN ::rowCount
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall, nRole, 0, nY+1, nX+1 )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall, nRole, 0, 0, nY+1 )
      ENDIF
      RETURN nil

   CASE nMode == 142       /* Main View Footer */
      IF nCall == HBQT_QAIM_columnCount
         IF ::colCount > 0
            ::forceStable()
         ENDIF
         RETURN ::colCount
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall, nRole, 1, nY+1, nX+1 )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall, nRole, 1, 0, nY+1 )
      ENDIF
      RETURN nil

   CASE nMode == 151       /* Left Frozen Header|Data */
      IF nCall == HBQT_QAIM_columnCount
         IF ::nLeftFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::nLeftFrozen
      ELSEIF nCall == HBQT_QAIM_rowCount
         IF ::nLeftFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::rowCount
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall,nRole, 0, nY+1, ::aLeftFrozen[ nX+1 ] )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall,nRole, 0, 0, ::aLeftFrozen[ nY+1 ] )
      ENDIF
      RETURN nil

   CASE nMode == 152       /* Left Frozen Footer */
      IF nCall == HBQT_QAIM_columnCount
         IF ::nLeftFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::nLeftFrozen
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall,nRole, 1, nY+1, ::aLeftFrozen[ nX+1 ] )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall,nRole, 1, 0, ::aLeftFrozen[ nY+1 ] )
      ENDIF

   CASE nMode == 161       /* Right Frozen Header|Data */
      IF nCall == HBQT_QAIM_columnCount
         IF ::nRightFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::nRightFrozen
      ELSEIF nCall == HBQT_QAIM_rowCount
         IF ::nRightFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::rowCount
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall,nRole, 0, nY+1, ::aRightFrozen[ nX+1 ] )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall,nRole, 0, 0, ::aRightFrozen[ nY+1 ] )
      ENDIF

   CASE nMode == 162       /* Right Frozen Footer */
      IF nCall == HBQT_QAIM_columnCount
         IF ::nRightFrozen > 0
            ::forceStable()
         ENDIF
         RETURN ::nRightFrozen
      ELSEIF nCall == HBQT_QAIM_data
         RETURN ::fetchColumnInfo( nCall,nRole, 1, nY+1, ::aRightFrozen[ nX+1 ] )
      ELSEIF nCall == HBQT_QAIM_headerData
         RETURN ::fetchColumnInfo( nCall,nRole, 1, 0, ::aRightFrozen[ nY+1 ] )
      ENDIF

   ENDCASE

   RETURN NIL


METHOD HbQtBrowse:fetchColumnInfo( nCall, nRole, nArea, nRow, nCol )
   LOCAL aColor
   LOCAL oCol := ::columns[ nCol ]

   SWITCH nCall
   CASE HBQT_QAIM_data

      SWITCH ( nRole )
      CASE Qt_ForegroundRole
         IF HB_ISBLOCK( oCol:colorBlock )
            aColor := eval( oCol:colorBlock, ::cellValueA( nRow, nCol ) )
            IF HB_ISARRAY( aColor ) .AND. HB_ISNUMERIC( aColor[ 1 ] )
               RETURN ::compatColor( hbxbp_ConvertAFactFromXBP( "Color", aColor[ 1 ] ) )
            ELSE
               RETURN ::compatColor( oCol:dFgColor )
            ENDIF
         ELSE
            RETURN ::compatColor( oCol:dFgColor )
         ENDIF

      CASE Qt_BackgroundRole
         IF HB_ISBLOCK( oCol:colorBlock )
            aColor := Eval( oCol:colorBlock, ::cellValueA( nRow, nCol ) )
            IF HB_ISARRAY( aColor ) .AND. HB_ISNUMERIC( aColor[ 2 ] )
               RETURN ::compatColor( hbxbp_ConvertAFactFromXBP( "Color", aColor[ 2 ] ) )
            ELSE
               RETURN ::compatColor( oCol:dBgColor )
            ENDIF
         ELSE
            RETURN ::compatColor( oCol:dBgColor )
         ENDIF

      CASE Qt_TextAlignmentRole
         RETURN oCol:dAlignment

      CASE Qt_SizeHintRole
         RETURN ::oDefaultCellSize

      CASE Qt_DecorationRole
         IF oCol:type == XBPCOL_TYPE_FILEICON
            RETURN ::compatIcon( ::cellValue( nRow, nCol ) )
         ELSE
            RETURN NIL
         ENDIF
      CASE Qt_EditRole
      CASE Qt_DisplayRole
         IF oCol:type == XBPCOL_TYPE_FILEICON
            RETURN nil
         ELSE
            RETURN ::cellValue( nRow, nCol )
         ENDIF
      ENDSWITCH
      RETURN NIL

   CASE HBQT_QAIM_headerData
      IF nArea == 0                    /* Header Area */
         SWITCH nRole
         CASE Qt_SizeHintRole
            RETURN ::oDefaultCellSize //oCol:hHeight
         CASE Qt_DisplayRole
            RETURN oCol:heading
         CASE Qt_TextAlignmentRole
            RETURN oCol:hAlignment
         CASE Qt_ForegroundRole
            RETURN ::compatColor( oCol:hFgColor )
         CASE Qt_BackgroundRole
            RETURN ::compatColor( oCol:hBgColor )
         ENDSWITCH
      ELSE                             /* Footer Area */
         SWITCH nRole
         CASE Qt_SizeHintRole
            RETURN ::oDefaultCellSize //oCol:fHeight
         CASE Qt_DisplayRole
            RETURN oCol:footing
         CASE Qt_TextAlignmentRole
            RETURN oCol:fAlignment
         CASE Qt_ForegroundRole
            RETURN ::compatColor( oCol:fFgColor )
         CASE Qt_BackgroundRole
            RETURN ::compatColor( oCol:fBgColor )
         ENDSWITCH
      ENDIF
      RETURN NIL
   ENDSWITCH

   RETURN NIL


METHOD HbQtBrowse:compatColor( nColor )

   IF ! hb_hHasKey( ::hColors, nColor )
      ::hColors[ nColor ] := QColor( nColor )
   ENDIF

   RETURN ::hColors[ nColor ]


METHOD HbQtBrowse:compatIcon( cIcon )

   IF ! hb_hHasKey( ::hIcons, cIcon )
      ::hIcons[ cIcon ] := QIcon( QPixmap( Trim( cIcon ) ) )
   ENDIF

   RETURN ::hIcons[ cIcon ]


METHOD HbQtBrowse:setVertScrollBarRange( lPageStep )
   LOCAL nMin, nMax

   hb_default( @lPageStep, .F. )

   IF HB_ISNUMERIC( nMin := eval( ::bFirstPosBlock  ) ) .and. HB_ISNUMERIC( nMax := eval( ::bLastPosBlock ) )
      ::oVScrollBar:setMinimum( nMin - 1 )
      ::oVScrollBar:setMaximum( nMax - 1 )
      ::oVScrollBar:setSingleStep( 1 )
      //
      IF lPageStep
         ::oVScrollBar:setPageStep( ::rowCount() )
      ENDIF
   ENDIF

   RETURN Self


METHOD HbQtBrowse:setHorzScrollBarRange( lPageStep )

   hb_default( @lPageStep, .F. )

   ::oHScrollBar:setMinimum( 0 )
   ::oHScrollBar:setMaximum( ::colCount - 1 )
   ::oHScrollBar:setSingleStep( 1 )
   ::oHScrollBar:setPageStep( 1 )

   RETURN Self


METHOD HbQtBrowse:updatePosition()

   IF HB_ISBLOCK( ::goPosBlock )
      eval( ::goPosBlock, ::oVScrollBar:value() + 1 )
      ::refreshAll()
      ::forceStable()
      ::setCurrentIndex()
   ENDIF

   RETURN Self


METHOD HbQtBrowse:updateVertScrollBar()

   ::oVScrollBar:setValue( eval( ::posBlock ) - 1 )

   RETURN Self


METHOD HbQtBrowse:setHorzOffset()

   IF ::colPos == ::colCount
      ::oHeaderView:setOffsetToLastSection()
      ::oFooterView:setOffsetToLastSection()
   ELSE
      ::oHeaderView:setOffsetToSectionPosition( ::colPos - 1 )
      ::oFooterView:setOffsetToSectionPosition( ::colPos - 1 )
   ENDIF

   RETURN Self


METHOD HbQtBrowse:setCurrentIndex( lReset )

   hb_default( @lReset, .T. )

   IF lReset
      ::oDbfModel:reset()                         /* Important */
      //
      IF HB_ISOBJECT( ::oLeftDbfModel )
         ::oLeftDbfModel:reset()
      ENDIF
      IF HB_ISOBJECT( ::oRightDbfModel )
         ::oRightDbfModel:reset()
      ENDIF
   ENDIF
   ::oTableView:setCurrentIndex( ::oDbfModel:index( ::rowPos - 1, ::colPos - 1 ) )

   RETURN Self


METHOD HbQtBrowse:hScroll( lYes )

   IF HB_ISLOGICAL( lYes )
      ::lHScroll := lYes
      ::setUnstable()
      ::configure( 128 )
   ENDIF

   RETURN ::lHScroll


METHOD HbQtBrowse:vScroll( lYes )

   IF HB_ISLOGICAL( lYes )
      ::lVScroll := lYes
      ::setUnstable()
      ::configure( 128 )
   ENDIF

   RETURN ::lHScroll


METHOD HbQtBrowse:sizeCols( lYes )

   IF HB_ISLOGICAL( lYes )
      ::lSizeCols := lYes
      ::setUnstable()
      ::configure( 128 )
   ENDIF

   RETURN Self


METHOD HbQtBrowse:cursorMode( nMode )

   IF HB_ISNUMERIC( nMode )
      ::nCursorMode := nMode
      ::setUnstable()
      ::configure( 128 )
   ENDIF

   RETURN ::nCursorMode


METHOD HbQtBrowse:setRightFrozen( aColFrozens )
   LOCAL aFrozen := aclone( ::aRightFrozen )

   IF HB_ISARRAY( aColFrozens )
      ::aRightFrozen := aColFrozens
      ::nRightFrozen := len( ::aRightFrozen )
      ::setUnstable()
      ::configure( 128 )
      ::forceStable()
   ENDIF

   RETURN aFrozen


METHOD HbQtBrowse:setLeftFrozen( aColFrozens )
   LOCAL aFrozen := aclone( ::aLeftFrozen )

   IF HB_ISARRAY( aColFrozens )
      ::aLeftFrozen := aColFrozens
      ::nLeftFrozen := len( ::aLeftFrozen )
      ::setUnstable()
      ::configure( 128 )
      ::forceStable()
   ENDIF

   RETURN aFrozen


METHOD HbQtBrowse:setCellHeight( nCellHeight )
   LOCAL i

   FOR i := 1 TO ::nRowsInView
      ::oTableView : setRowHeight( i-1, nCellHeight )
      IF !empty( ::oLeftView )
         ::oLeftView  : setRowHeight( i-1, nCellHeight )
      ENDIF
      IF !empty( ::oRightView )
         ::oRightView : setRowHeight( i-1, nCellHeight )
      ENDIF
   NEXT
   RETURN Self


METHOD HbQtBrowse:navigate( p1, p2 )

   IF HB_ISBLOCK( p1 )
      ::sl_xbeBRW_Navigate := p1

   ELSEIF HB_ISNUMERIC( p1 )
      IF HB_ISBLOCK( ::sl_xbeBRW_Navigate )
         Eval( ::sl_xbeBRW_Navigate, p1, p2, self )
      ENDIF
   ENDIF

   RETURN NIL


METHOD HbQtBrowse:pan( p1 )

   IF HB_ISBLOCK( p1 )
      ::sl_xbeBRW_Pan := p1

   ELSEIF HB_ISNUMERIC( p1 )
      IF HB_ISBLOCK( ::sl_xbeBRW_Pan )
         eval( ::sl_xbeBRW_Pan, p1, NIL, self )
      ENDIF
   ENDIF

   RETURN Self
