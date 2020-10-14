/*
 * $Id: reports.prg 426 2016-10-20 00:14:06Z bedipritpal $
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2010-2012 Pritpal Bedi <bedipritpal@hotmail.com>
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
/*----------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/

#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"
#include "hbtrace.ch"
#include "xbp.ch"

/*----------------------------------------------------------------------*/

#define  UNIT  0.1

#define  INI_KEY( cKey, n )     cKey + "_" + hb_ntos( n ) + "="

#define hbqt_screen_heightMM ( QDesktopWidget():height() / QDesktopWidget():physicalDpiY() * 25.4 )
#define hbqt_screen_widthMM  ( QDesktopWidget():width()  / QDesktopWidget():physicalDpiX() * 25.4 )

#define HBQT_GRAPHICSVIEW_ZOOM_IN                 1
#define HBQT_GRAPHICSVIEW_ZOOM_OUT                2
#define HBQT_GRAPHICSVIEW_ZOOM_WYSIWYG            3
#define HBQT_GRAPHICSVIEW_ZOOM_ORIGINAL           4

#define HQR_BARCODE_3OF9                          1

#define TO_MMS( n )   ( ( n ) * 10 / 25.4 )

#define SHP_ACT_RECTANGLE                         1
#define SHP_ACT_ROUNDRECT                         2
#define SHP_ACT_ELLIPSE                           3
#define SHP_ACT_LINEVERT                          4
#define SHP_ACT_LINEHORZ                          5
#define SHP_ACT_LINEDIAGRIGHT                     6
#define SHP_ACT_LINEDIAGLEFT                      7
#define SHP_ACT_ARC                               8
#define SHP_ACT_CHORD                             9
#define SHP_ACT_DIAMOND                           10
#define SHP_ACT_TRIANGLE                          11

#define NUM_SHAPES                                11

#define __graphicsScene_block__                   2001
#define __treeObjects_clicked__                   2002
#define __tabBar_currentChanged__                 2003
#define __buttonNew_clicked__                     2004
#define __buttonOpen_clicked__                    2005
#define __buttonSave_clicked__                    2006
#define __buttonClose_clicked__                   2007
#define __buttonPrint_clicked__                   2008
#define __buttonToBack_clicked__                  2009
#define __buttonToFront_clicked__                 2010
#define __buttonRotateL_clicked__                 2011
#define __buttonRotateR_clicked__                 2012
#define __buttonPortrait_clicked__                2013
#define __buttonLandscape_clicked__               2014
#define __buttonFontG_clicked__                   2015
#define __buttonFontB_clicked__                   2016
#define __buttonFontI_clicked__                   2017
#define __buttonFontU_clicked__                   2018
#define __buttonFontS_clicked__                   2019
#define __buttonJustL_clicked__                   2020
#define __buttonJustC_clicked__                   2021
#define __buttonJustR_clicked__                   2022
#define __buttonJustJ_clicked__                   2023
#define __buttonJustT_clicked__                   2024
#define __buttonJustM_clicked__                   2025
#define __buttonJustB_clicked__                   2026
#define __buttonBoxT_clicked__                    2027
#define __buttonBoxL_clicked__                    2028
#define __buttonBoxB_clicked__                    2029
#define __buttonBoxR_clicked__                    2030
#define __buttonBoxA_clicked__                    2031
#define __buttonBoxP_clicked__                    2032
#define __buttonBoxS_clicked__                    2033
#define __buttonZoom_clicked__                    2034
#define __buttonGrid_clicked__                    2035
#define __buttonNew0_clicked__                    2036    // Tobe assined
#define __buttonShapes_clicked__                  2037
#define __QEvent_MousePressMenu__                 2038
#define __QEvent_MouseMoveMenu__                  2039
#define __QEvent_MouseReleaseMenu__               2040

/*----------------------------------------------------------------------*/

STATIC hIDs := {=>}

/*----------------------------------------------------------------------*/

CLASS HbpReports

   DATA   lRegistered                             INIT .F.

   DATA   oWidget
   DATA   oParent
   DATA   qLayout
   DATA   qToolbar
   DATA   qToolbarL
   DATA   qToolbarAlign
   DATA   qStack
   DATA   qStatus
   DATA   qTabBar
   DATA   qWidget1
   DATA   qWidget2
   DATA   qWidget3

   DATA   qPaper

   DATA   qSpliter
   DATA   qLayoutD
   DATA   qFrameL
   DATA   qScroll
   DATA   qFrameR

   DATA   qLayL
   DATA   qLayR
   DATA   qSplL
   DATA   qSplR

   DATA   qTabL0
   DATA   qPageL01
   DATA   qPageL02
   DATA   qPageL01Lay
   DATA   qTreeObjects

   DATA   qTabL1
   DATA   qPageL11
   DATA   qPageL12
   DATA   qPageL11Lay
   DATA   qTreeProp

   DATA   qEditDesc

   DATA   qTabR1
   DATA   qPageR11
   DATA   qPageR11Lay
   DATA   qTreeData
   DATA   qPageR12
   DATA   qPageR13

   DATA   qDesign
   DATA   qHRuler
   DATA   qVRuler
   DATA   qPort
   DATA   qView
   DATA   qScene

   DATA   aStatusPnls                             INIT {}
   DATA   aItems                                  INIT {}
   DATA   hItems                                  INIT {=>}
   DATA   hObjTree                                INIT {=>}
   DATA   qCurGraphicsItem
   DATA   hHqrObjects                             INIT {=>}

   DATA   aPages                                  INIT {}
   DATA   aSources                                INIT {}
   DATA   aObjects                                INIT {}
   DATA   aRptPages                               INIT {}
   DATA   aRptSources                             INIT {}
   DATA   aRptObjects                             INIT {}

   DATA   lNew                                    INIT .t.
   DATA   cSaved                                  INIT ""

   DATA   nScreenDpiX                             INIT 96
   DATA   nScreenDpiY                             INIT 96

   /* Report's Properties */
   DATA   symposis                                INIT "HBReports Designer"
   DATA   version                                 INIT 0.1
   DATA   title                                   INIT "Report"
   DATA   author                                  INIT "HbIDE"
   DATA   created                                 INIT date()
   DATA   modified                                INIT date()

   DATA   xData
   DATA   qPos                                    INIT QPoint( -1,-1 )
   DATA   qDrag
   DATA   qDropAction
   DATA   qByte
   DATA   qMime
   DATA   qPix
   DATA   qAct
   DATA   qShapesMenu
   DATA   aShapesAct                              INIT array( NUM_SHAPES )
   DATA   lShowGrid                               INIT .F.

   METHOD init( oParent )
   METHOD create( oParent )
   METHOD destroy()

   METHOD execEvent( nEvent, p, p1, p2 )

   METHOD buildToolbar()
   METHOD buildToolbarAlign()
   METHOD buildToolbarLeft()
   METHOD buildStacks()
   METHOD buildStatusBar()
   METHOD buildTabBar()
   METHOD buildDesignReport()
   METHOD addField( cAlias, cField, qPos, qGeo )
   METHOD addObject( cType, qPos, qGeo )
   METHOD loadReport( xData )
   METHOD saveReport( lSaveAs )
   METHOD prepareReport()
   METHOD getNextID( cType )
   METHOD getImageOfType( cType )
   METHOD updateObjectsTree( cType, cParent, cName, cSubType )
   METHOD contextMenuItem( p1, p2 )
   METHOD contextMenuScene( p1 )
   METHOD addSource( cAlias, aStruct )
   METHOD clear()
   METHOD buildReportStream()
   METHOD toString()
   METHOD openReport()
   METHOD parseBuffer( cBuffer )
   METHOD presentBlankPage()
   METHOD printReport( qPrinter )
   METHOD printPreview( qPrinter )
   METHOD paintRequested( qPrinter )
   METHOD zoom( nMode )

   METHOD objectSelected( hqrObject )
   METHOD execMenuShapes()

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD HbpReports:init( oParent )

   IF ! ::lRegistered
      ::lRegistered := .T.
      QResource():registerResource_1( hbqtres_xbp() )
   ENDIF

   DEFAULT oParent TO ::oParent
   ::oParent := oParent

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:create( oParent )
   LOCAL oLayout

   DEFAULT oParent TO ::oParent
   ::oParent := oParent

   IF HB_ISOBJECT( oParent )
      ::oWidget := QWidget( oParent )
      IF Empty( oLayout := oParent:layout() )
         oLayout := QHBoxLayout()
         ::oParent:setLayout( oLayout )
         oLayout:addWidget( ::oWidget )
      ELSE
         SWITCH __objGetClsName( oLayout )
         CASE "QVBOXLAYOUT"
         CASE "QHBOXLAYOUT"
            oLayout:addWidget( ::oWidget )
            EXIT
         CASE "QGRIDLAYOUT"
            oLayout:addWidget( ::oWidget, 0, 0, 1, 1 )
            EXIT
         ENDSWITCH
      ENDIF
   ELSE
      ::oWidget := QWidget()
   ENDIF

   /* Layout applied to RM widget */
   ::qLayout := QGridLayout()
   ::qLayout:setContentsMargins( 0,0,0,0 )
   ::qLayout:setSpacing( 0 )

   ::oWidget:setLayout( ::qLayout )

   /* Toolbar */
   ::buildToolbar()
   ::qLayout:addWidget( ::qToolbar:oWidget      , 0, 0, 1, 2 )
   ::buildToolbarAlign()
   ::qLayout:addWidget( ::qToolbarAlign:oWidget , 1, 0, 1, 2 )

   /* Toolbar left */
   ::buildToolbarLeft()
   ::qLayout:addWidget( ::qToolbarL:oWidget     , 2, 0, 2, 1 )

   /* ::qTabBar */
   ::buildTabBar()
   ::qLayout:addWidget( ::qTabBar               , 2, 1, 1, 1 )

   /* Stacked widget */
   ::buildStacks()
   ::qLayout:addWidget( ::qStack                , 3, 1, 1, 1 )

   /* StatusBar */
   ::buildStatusBar()
   ::qLayout:addWidget( ::qStatus               , 4, 0, 1, 2 )

   /* Document manipulation interface */
   ::buildDesignReport()
   ::loadReport()
   ::zoom( HBQT_GRAPHICSVIEW_ZOOM_WYSIWYG )
   ::qScene:setOrientation( QPrinter_Landscape )

   ::qTabBar:setCurrentIndex( 2 )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:destroy()

   ::qScene:hbClearBlock()
   ::hItems := NIL
#if 0
   FOR EACH obj IN ::hItems
      obj:destroy()
      obj := NIL
   NEXT
#endif
   ::qScene := NIL
   ::oWidget:setParent( QWidget() )
   ::oWidget := NIL
   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildDesignReport()

   WITH OBJECT ::qLayoutD := QHBoxLayout( ::qWidget3 )
      :setContentsMargins( 0,0,0,0 )
      :setSpacing( 1 )
   ENDWITH
   ::qWidget3:setLayout( ::qLayoutD )

   WITH OBJECT ::qSpliter := QSplitter()
      :setOrientation( Qt_Horizontal )
   ENDWITH
   ::qLayoutD:addWidget( ::qSpliter )

   WITH OBJECT ::qFrameL := QFrame()
      :setMinimumWidth( 100 )
   ENDWITH
   ::qSpliter:addWidget( ::qFrameL )

   WITH OBJECT ::qScene := HBQGraphicsScene()
      :hbSetBlock( {|p,p1,p2| ::execEvent( __graphicsScene_block__, p, p1, p2 ) } )
      :setLeftMagnet( .t. )
      :setTopMagnet( .t. )
      :setRightMagnet( .t. )
      :setBottomMagnet( .t. )
   ENDWITH
   WITH OBJECT ::qView := QGraphicsView( ::qDesign )
      :setMouseTracking( .t. )
      :setScene( ::qScene )
   ENDWITH
   ::qSpliter:addWidget( ::qView )

   WITH OBJECT ::qFrameR := QFrame()
      :setMinimumWidth( 100 )
   ENDWITH
   ::qSpliter:addWidget( ::qFrameR )

   ::qLayL := QVBoxLayout()
   ::qLayL:setContentsMargins( 0,0,0,0 )
   ::qLayL:setSpacing( 1 )
   ::qFrameL:setLayout( ::qLayL )
   ::qSplL := QSplitter()
   ::qSplL:setOrientation( Qt_Vertical )
   ::qLayL:addWidget( ::qSplL )

   ::qLayR := QVBoxLayout()
   ::qLayR:setContentsMargins( 0,0,0,0 )
   ::qLayR:setSpacing( 1 )
   ::qFrameR:setLayout( ::qLayR )
   ::qSplR := QSplitter()
   ::qSplR:setOrientation( Qt_Vertical )
   ::qLayR:addWidget( ::qSplR )

   ::qTabL0 := QTabWidget()
   ::qSplL:addWidget( ::qTabL0 )
   /* Left Pane Objects Page */
   ::qPageL01 := QWidget()
   ::qTabL0:addTab( ::qPageL01, "Objects" )
   ::qPageL01Lay := QVBoxLayout()
   ::qPageL01:setLayout( ::qPageL01Lay )
   ::qPageL01Lay:setContentsMargins( 0,0,0,0 )
   /* Left Pane Events page */
   ::qPageL02 := QWidget()
   ::qTabL0:addTab( ::qPageL02, "Else" )
   /* Left pane Properties Treeview */
   WITH OBJECT ::qTreeObjects := QTreeWidget()
      :setHeaderHidden( .t. )
      :setObjectName( "ObjectsTree" )
      :setIconSize( QSize( 12,12 ) )
      :setIndentation( 12 )
      :connect( "itemClicked(QTreeWidgetItem*,int)", {|p,p1| ::execEvent( __treeObjects_clicked__, p, p1 ) } )
   ENDWITH
   ::qPageL01Lay:addWidget( ::qTreeObjects )

   ::qTabL1 := QTabWidget()
   ::qSplL:addWidget( ::qTabL1 )
   /* Left Pane Properties Page */
   ::qPageL11 := QWidget()
   ::qTabL1:addTab( ::qPageL11, "Props" )
   ::qPageL11Lay := QVBoxLayout()
   ::qPageL11:setLayout( ::qPageL11Lay )
   ::qPageL11Lay:setContentsMargins( 0,0,0,0 )
   /* Left Pane Events page */
   ::qPageL12 := QWidget()
   ::qTabL1:addTab( ::qPageL12, "Events" )
   /* Left pane Properties Treeview */
   WITH OBJECT ::qTreeProp := QTreeWidget()
      :setHeaderHidden( .t. )
      :setObjectName( "PropertiesTree" )
   ENDWITH
   ::qPageL11Lay:addWidget( ::qTreeProp )

   WITH OBJECT ::qEditDesc := QTextEdit()
      :setPlainText( "Interface implemented is just a proof of concept, no promises yet, please." )
      :setMaximumHeight( 120 )
   ENDWITH
   ::qSplL:addWidget( ::qEditDesc )

   ::qTabR1 := QTabWidget()
   ::qSplR:addWidget( ::qTabR1 )
   ::qPageR11 := QWidget()
   ::qTabR1:addTab( ::qPageR11, "Data" )
   ::qPageR12 := QWidget()
   ::qTabR1:addTab( ::qPageR12, "Variables" )
   ::qPageR13 := QWidget()
   ::qTabR1:addTab( ::qPageR13, "Functions" )

   WITH OBJECT ::qPageR11Lay := QVBoxLayout()
      :setContentsMargins( 0,0,0,0 )
   ENDWITH
   ::qPageR11:setLayout( ::qPageR11Lay )

   WITH OBJECT ::qTreeData := QTreeWidget()
      :setHeaderHidden( .t. )
      :setObjectName( "DataTree" )
      :setDragEnabled( .t. )
   ENDWITH
   ::qPageR11Lay:addWidget( ::qTreeData )

   ::qToolbarAlign:setItemChecked( "Grid", ::qScene:showGrid() )
   ::qLayoutD:setStretch( 1,1 )

   ::qSpliter:setStretchFactor( 0, 0 )
   ::qSpliter:setStretchFactor( 1, 2 )
   ::qSpliter:setStretchFactor( 2, 0 )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:execEvent( nEvent, p, p1, p2 )
   LOCAL qMime, qDrag, qByte, qPix, i, qList, cFile, nArea, aStruct, cAlias, cPath, qRC, qIcon, cType
#if 0
   LOCAL oPainter, oScnR, oPixmap
#endif

   SWITCH nEvent
   CASE __graphicsScene_block__
      DO CASE
      CASE p == 21201                             // drawBackground( oPainter, oRectF ) with an example
#if 0
         oPainter := p1
         oScnR := ::qScene:sceneRect()
         oPixmap:= QPixmap( Hbp_image( "harbour" ) )
         oPainter:drawPixmap( QPoint( oScnR:x(), oScnR:y() ), oPixmap:scaled( oScnR:width(), oScnR:height(), Qt_KeepAspectRatio ) )
#endif
      CASE p == 21001
         ::nScreenDpiX := p1
         ::nScreenDpiY := p2

      CASE p == 21107                             // Left button pressed nowhere on an item
         IF ! empty( ::qCurGraphicsItem )
            ::qCurGraphicsItem := NIL
            ::qTreeObjects:setCurrentItem( QTreeWidgetItem() )
         ENDIF

      CASE p == QEvent_GraphicsSceneContextMenu
         ::contextMenuScene( p1 )

      CASE p == QEvent_GraphicsSceneDragEnter
         p1:acceptProposedAction()

      CASE p == QEvent_GraphicsSceneDragMove
         p1:acceptProposedAction()

      CASE p == QEvent_GraphicsSceneDragLeave
         p1:acceptProposedAction()

      CASE p == QEvent_GraphicsSceneDrop
         qMime := p1:mimeData()
         IF qMime:hasFormat( "application/x-qabstractitemmodeldatalist" )
            IF p2[ 1 ] == "DataTree"
               IF p2[ 2 ] != p2[ 3 ]
                  ::addField( p2[ 2 ], p2[ 3 ], p1:scenePos(), NIL )
               ENDIF
            ENDIF
         ELSEIF qMime:hasFormat( "application/x-toolbaricon"  )
            ::addObject( qMime:html(), p1:scenePos(), NIL )
         ELSEIF qMime:hasFormat( "application/x-menuitem" )
            cType := qMime:html()
            SWITCH cType
            CASE "Rectangle"          ;                        EXIT
            CASE "Ellipse"            ;                        EXIT
            CASE "Arc"                ;                        EXIT
            CASE "Chord"              ;                        EXIT
            CASE "Triangle"           ;                        EXIT
            CASE "Diamond"            ;                        EXIT
            CASE "Rounded Rectangle"  ; cType := "RoundRect" ; EXIT
            CASE "Horizontal Line"    ; cType := "LineH"     ; EXIT
            CASE "Vertical Line"      ; cType := "LineV"     ; EXIT
            CASE "Diagonal Line Right"; cType := "LineDR"    ; EXIT
            CASE "Diagonal Line Left" ; cType := "LineDL"    ; EXIT
            ENDSWITCH
            ::addObject( cType, p1:scenePos(), NIL )

         ELSEIF qMime:hasUrls()
            qList := qMime:urls()
            FOR i := 0 TO qList:size() - 1
               cFile := qList:at( i ):toLocalFile()

               IF ".dbf" == right( lower( cFile ), 4 )
                  hb_fNameSplit( cFile, @cPath, @cAlias )

                  BEGIN SEQUENCE
                     nArea := select()
                     USE ( cFile ) ALIAS "RPTDUMMY" NEW SHARED VIA "DBFCDX"
                     IF ! neterr()
                        aStruct := DbStruct()
                        DbCloseArea()
                        ::addSource( upper( substr( cAlias, 1, 1 ) ) + lower( substr( cAlias, 2 ) ), aStruct )
                     ENDIF
                     select( nArea )
                  END SEQUENCE
               ENDIF
            NEXT
         ENDIF
         p1:acceptProposedAction()
      ENDCASE
      EXIT

   CASE __treeObjects_clicked__
      IF hb_hHasKey( ::hItems, p:text( 0 ) )
         ::qScene:clearSelection()
         //::hItems[ qItem:text( 0 ) ]:setSelected( .t. )
         ::hItems[ p:text( 0 ) ]:oWidget:setSelected( .t. )
      ENDIF
      EXIT

   CASE __tabBar_currentChanged__
      IF !empty( ::qStack ) .AND. p < ::qStack:count()
         ::qStack:setCurrentIndex( p )
      ENDIF
      EXIT

   CASE "dataTree_dropEvent"
   CASE "dataTree_mouseReleseEvent"
   CASE "dataTree_dragMoveEvent"
   CASE "dataTree_dragEnterEvent"
      EXIT

   CASE __QEvent_MouseMoveMenu__
      IF empty( ::qPos ) .OR. empty( ::qAct )
         EXIT
      ENDIF
      qRC := QRect( ::qPos:x() - 5, ::qPos:y() - 5, 10, 10 ):normalized()
      IF qRC:contains( p:pos() )
         qIcon := QIcon( ::qAct:icon() )
         qPix  := qIcon:pixmap( 16,16 )
         qByte := QByteArray( ::qAct:text() )
         WITH OBJECT qMime := QMimeData()
            :setData( "application/x-menuitem", qByte )
            :setHtml( ::qAct:text() )
         ENDWITH
         WITH OBJECT qDrag := QDrag( ::oWidget )
            :setMimeData( qMime )
            :setPixmap( qPix )
            :setHotSpot( QPoint( 15,15 ) )
            :setDragCursor( qPix, Qt_MoveAction )
            :exec( Qt_MoveAction )
         ENDWITH
         qDrag:setParent( QWidget() )
         qDrag := NIL
         ::qPos  := NIL
         ::qAct  := NIL
      ENDIF
      EXIT
   CASE __QEvent_MouseReleaseMenu__
      EXIT
   CASE __QEvent_MousePressMenu__
      ::qPos := p:pos()
      ::qAct := ::qShapesMenu:actionAt( ::qPos )
      EXIT

   CASE __buttonShapes_clicked__
      ::execMenuShapes()
      EXIT
   CASE __buttonLandscape_clicked__
      ::qScene:setOrientation( QPrinter_Landscape )
      EXIT
   CASE __buttonPortrait_clicked__
      ::qScene:setOrientation( QPrinter_Portrait )
      EXIT
   CASE __buttonRotateL_clicked__
      IF !empty( ::qCurGraphicsItem )
         ::qCurGraphicsItem:rotate( -10 )
      ENDIF
      EXIT
   CASE __buttonRotateR_clicked__
      IF !empty( ::qCurGraphicsItem )
         ::qCurGraphicsItem:rotate( 10 )
      ENDIF
      EXIT
   CASE __buttonToBack_clicked__
      EXIT
   CASE __buttonToFront_clicked__
      EXIT
   CASE __buttonNew_clicked__
      EXIT
   CASE __buttonOpen_clicked__
      ::openReport()
      EXIT
   CASE __buttonSave_clicked__
      ::saveReport()
      EXIT
   CASE __buttonClose_clicked__
      EXIT
   CASE __buttonPrint_clicked__
      ::printPreview()
      EXIT
   CASE __buttonGrid_clicked__
      ::lShowGrid := ! ::lShowGrid
      ::qScene:setShowGrid( ::lShowGrid )
      EXIT
   CASE __buttonZoom_clicked__
      DO CASE
      CASE p == 1
         ::zoom( HBQT_GRAPHICSVIEW_ZOOM_IN )
      CASE p == 2
         ::zoom( HBQT_GRAPHICSVIEW_ZOOM_OUT )
      CASE p == 3
         ::zoom( HBQT_GRAPHICSVIEW_ZOOM_WYSIWYG )
      CASE p == 4
         ::zoom( HBQT_GRAPHICSVIEW_ZOOM_ORIGINAL )
      ENDCASE
      EXIT
   ENDSWITCH

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:objectSelected( hqrObject )
   LOCAL cName := hqrObject:cName

   IF hb_hHasKey( ::hObjTree, cName )
      ::qCurGraphicsItem := ::hItems[ cName ]
      ::qTreeObjects:setCurrentItem( ::hObjTree[ cName ] )
   ELSE
      ::qCurGraphicsItem := NIL
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:presentBlankPage()

   aadd( ::aPages, { "Page_1" } )

   ::qScene:setOrientation( QPrinter_Portrait )

   ::updateObjectsTree( "ReportName", NIL, "Report" )
   ::updateObjectsTree( "Page", "Report", "Page_1" )

   ::addSource( "Customer", { { "Title" ,"C",35,0 }, { "Street","C",20,0 }, { "Revenue","N",12,2 } } )
   ::addSource( "Invoice" , { { "Number","C",10,0 }, { "Date"  ,"D",08,0 }, { "Amount" ,"N",12,2 } } )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:openReport()
   LOCAL qFileDlg, qList, cFile

   qFileDlg := QFileDialog( ::oWidget )

   qFileDlg:setAcceptMode( QFileDialog_AcceptOpen )
   qFileDlg:setFileMode( QFileDialog_AnyFile )
   qFileDlg:setViewMode( QFileDialog_List )
   qFileDlg:setNameFilter( "HB Reports (*.hqr)" )

   IF qFileDlg:exec() == 1
      qList := qFileDlg:selectedFiles()
      cFile := qList:at( 0 )
      IF !empty( cFile ) .AND. lower( right( cFile, 4 ) ) == ".hqr"
         ::loadReport( cFile )
      ENDIF
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:saveReport( lSaveAs )
   LOCAL cFile, cBuffer, qFileDlg, qList, cExt
   LOCAL lSave := .t.

   DEFAULT lSaveAs TO .f.

   IF lSaveAs .OR. ::lNew .OR. empty( ::cSaved )
      qFileDlg := QFileDialog( ::oWidget )

      qFileDlg:setAcceptMode( QFileDialog_AcceptSave )
      qFileDlg:setFileMode( QFileDialog_AnyFile )
      qFileDlg:setViewMode( QFileDialog_List )
      qFileDlg:setNameFilter( "HB Reports (*.hqr)" )

      IF qFileDlg:exec() == 1
         qList := qFileDlg:selectedFiles()
         cFile := qList:at( 0 )
         hb_fNameSplit( cFile, , , @cExt )
         IF empty( cExt )
            cFile += ".hqr"
         ENDIF
         ::cSaved := cFile
      ELSE
         lSave := .f.
      ENDIF
   ENDIF

   IF lSave .AND. !empty( ::cSaved )
      cBuffer  := ::buildReportStream()
      hb_memowrit( ::cSaved, hb_strtoutf8( cBuffer ) )

      RETURN hb_fileExists( ::cSaved )
   ENDIF

   RETURN .f.

/*----------------------------------------------------------------------*/

METHOD HbpReports:prepareReport()
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:toString()
   RETURN ::buildReportStream()

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildReportStream()
   LOCAL txt_:= {}, n, a_, s, oWidget, qPos, qTran

   aadd( txt_, "[GENERAL]" )
   aadd( txt_, "" )
   aadd( txt_, "Symposis"     + "=" + "HBReportsManager"   )
   aadd( txt_, "Version"      + "=" + hb_ntos( ::version ) )
   aadd( txt_, "Title"        + "=" + ::title              )
   aadd( txt_, "Author"       + "=" + ::author             )
   aadd( txt_, "DateCreated"  + "=" + dtos( ::created )    )
   aadd( txt_, "DateModified" + "=" + dtos( ::modified )   )
   aadd( txt_, "Properties"   + "=" + ""                   )
   aadd( txt_, "" )
   aadd( txt_, "[SOURCES]" )
   aadd( txt_, "" )
   FOR EACH a_ IN ::aSources
      n := a_:__enumIndex()
      aadd( txt_, INI_KEY( "source", n ) + a_[ 1 ] + "," + rmgr_a2arrayStr( a_[ 2 ] ) )
   NEXT
   aadd( txt_, "" )
   aadd( txt_, "[PAGES]" )
   aadd( txt_, "" )
   FOR EACH a_ IN ::aPages
      n := a_:__enumIndex()
      aadd( txt_, INI_KEY( "page", n ) + rmgr_a2arrayStr( a_ ) )
   NEXT
   aadd( txt_, "" )
   aadd( txt_, "[OBJECTS]" )
   aadd( txt_, "" )
   FOR EACH a_ IN ::aObjects
      n := a_:__enumIndex()
      IF hb_hHasKey( ::hItems, a_[ 3 ] )
         oWidget := ::hItems[ a_[ 3 ] ]:oWidget
         qPos    := oWidget:scenePos()
         qTran   := oWidget:transform()

         a_[ 5 ] := { { 0, 0, oWidget:width(), oWidget:height() }, ;
                      { qPos:x(), qPos:y() }, ;
                      { qTran:m11(), qTran:m12(), qTran:m13(), qTran:m21(), qTran:m22(), qTran:m23(), qTran:m31(), qTran:m32(), qTran:m33() }, ;
                    }

         aadd( txt_, INI_KEY( "object", n ) + rmgr_a2arrayStr( a_ ) )
      ENDIF
   NEXT
   aadd( txt_, "" )

   s := ""
   aeval( txt_, {|e| s += e + chr( 13 ) + chr( 10 ) } )

   RETURN s

/*----------------------------------------------------------------------*/

METHOD HbpReports:parseBuffer( cBuffer )
   LOCAL aTxt, s, nPart, cKey, cVal

   aTxt := hb_ATokens( StrTran( cBuffer, Chr( 13 ) ), Chr( 10 ) )

   FOR EACH s IN aTxt
      s := alltrim( s )
      IF empty( s )
         LOOP
      ENDIF

      SWITCH Upper( s )
      CASE "[GENERAL]" ; nPart := "HQR_GENERAL" ; EXIT
      CASE "[SOURCES]" ; nPart := "HQR_SOURCES" ; EXIT
      CASE "[PAGES]"   ; nPart := "HQR_PAGES"   ; EXIT
      CASE "[OBJECTS]" ; nPart := "HQR_OBJECTS" ; EXIT
      OTHERWISE
         DO CASE
         CASE nPart == "HQR_GENERAL"
         CASE nPart == "HQR_SOURCES"
            IF rmgr_keyValuePair( s, @cKey, @cVal, "=" )
               IF rmgr_keyValuePair( cVal, @cKey, @cVal, "," )
                  aadd( ::aRptSources, { "Source", rmgr_evalAsArray( cVal ) } )
               ENDIF
            ENDIF
         CASE nPart == "HQR_PAGES"
            IF rmgr_keyValuePair( s, @cKey, @cVal, "=" )
               aadd( ::aRptPages, { "Page", rmgr_evalAsArray( cVal ) } )
            ENDIF
         CASE nPart == "HQR_OBJECTS"
            IF rmgr_keyValuePair( s, @cKey, @cVal, "=" )
               aadd( ::aRptObjects, rmgr_evalAsArray( cVal ) )
            ENDIF
         ENDCASE
      ENDSWITCH
   NEXT

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:loadReport( xData )
   LOCAL cBuffer, a_, d_, n, cName, cAlias, cField, oWidget
   LOCAL aGeo, aPt, aTran
   LOCAL qGeo, qPt, qTran

   ::clear()

   IF empty( xData )
      ::presentBlankPage()
      ::lNew := .t.

   ELSE
      ::lNew := .f.

      IF Len( xData ) <= 300 .AND. hb_fileExists( xData )
         ::cSaved := xData
         cBuffer  := hb_utf8tostr( hb_memoread( xData ) )

         IF !empty( ::oParent )
            ::oParent:setWindowTitle( "HbReportsManager : " + ::cSaved )
         ENDIF
      ELSE
         ::cSaved := ""
         cBuffer  := xData
      ENDIF

      ::parseBuffer( cBuffer )

      ::qScene:setOrientation( QPrinter_Portrait )

      ::updateObjectsTree( "ReportName", NIL, "Report" )
      ::updateObjectsTree( "Page", "Report", "Page_1" )

      FOR EACH a_ IN ::aRptSources
         ::addSource( a_[ 1 ], a_[ 2 ] )
      NEXT

      FOR EACH a_ IN ::aRptObjects
         d_:= a_[ 5 ] ; aGeo := d_[ 1 ] ; aPt := d_[ 2 ] ; aTran := d_[ 3 ]

         qGeo := QRectF( aGeo[ 1 ], aGeo[ 2 ], aGeo[ 3 ], aGeo[ 4 ] )
         qPt  := QPointF( aPt[ 1 ], aPt[ 2 ] )

         SWITCH a_[ 1 ]
         CASE "Object"
            oWidget := ::addObject( a_[ 4 ], qPt, qGeo )
            EXIT
         CASE "Field"
            cName   := a_[ 3 ] ; n := at( "...", cName ) ; cAlias := substr( cName, 1, n-1 )
            cField  := substr( cName, n + 3 ) ; n := at( "_", cField ) ; cField := substr( cField, 1, n-1 )
            oWidget := ::addField( cAlias, cField, qPt, qGeo )
            EXIT
         ENDSWITCH

         qTran   := QTransform()
         qTran   :  setMatrix( aTran[ 1 ], aTran[ 2 ], aTran[ 3 ], aTran[ 4 ], aTran[ 5 ], aTran[ 6 ], aTran[ 7 ], aTran[ 8 ], aTran[ 9 ] )
         oWidget :  setTransform( qTran )
      NEXT
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:addObject( cType, qPos, qGeo )
   LOCAL cName, qGrad, oHqrObject, aGeo, aPos

   aPos := iif( empty( qPos ), NIL, { qPos:x(), qPos:y() } )
   aGeo := iif( empty( qGeo ), NIL, { qGeo:x(), qGeo:y(), qGeo:width(), qGeo:height() } )

   cName := cType + "_" + hb_ntos( ::getNextID( cType ) )

   oHqrObject := HqrGraphicsItem():new( Self, /*cParent*/, cType, cName, aPos, aGeo )

   SWITCH cType
   CASE "Image"
      oHqrObject:setPixmap( QPixmap( Hbp_image( "harbour" ) ) )
      oHqrObject:setBorderWidth( 2 )
      EXIT
   CASE "Chart"
      EXIT
   CASE "Gradient"
      qGrad := QLinearGradient()
      qGrad:setColorAt( 0, QColor( 195,225,255 ) )
      qGrad:setColorAt( 1, QColor( Qt_darkBlue ):darker( 150 ) )
      qGrad:setCoordinateMode( QGradient_StretchToDeviceMode )
      oHqrObject:setBrush( QBrush( qGrad ) )
      oHqrObject:setPen( QPen( Qt_NoPen ) )
      EXIT
   CASE "Barcode"
      oHqrObject:setText( "Harbour" )
      oHqrObject:setBarcodeType( HQR_BARCODE_3OF9 )
      EXIT
   CASE "Text"
      oHqrObject:setText( "Harbour" )
      EXIT
   ENDSWITCH

   ::hItems[ cName ] := oHqrObject
   ::updateObjectsTree( "Object", "Page_1", cName, cType )
   aadd( ::aObjects, { "Object", "Page_1", cName, cType, {} } )

   RETURN oHqrObject:oWidget

/*----------------------------------------------------------------------*/

METHOD HbpReports:addField( cAlias, cField, qPos, qGeo )
   LOCAL cName, oHqrObject, aGeo, aPos

   aPos := iif( empty( qPos ), NIL, { qPos:x(), qPos:y() } )
   aGeo := iif( empty( qGeo ), NIL, { qGeo:x(), qGeo:y(), qGeo:width(), qGeo:height() } )

   cName := cAlias + "..." + cField
   cName := cName + "_" + hb_ntos( ::getNextID( cName ) )

   oHqrObject := HqrGraphicsItem():new( Self, /*cParent*/, "Field", cName, aPos, aGeo )

   oHqrObject:setText( cName )

   ::hItems[ cName ] := oHqrObject
   ::updateObjectsTree( "Field", "Page_1", cName, "Field" )
   aadd( ::aObjects, { "Field", "Page_1", cName, "Field", {} } )

   RETURN oHqrObject:oWidget

/*----------------------------------------------------------------------*/

METHOD HbpReports:addSource( cAlias, aStruct )
   LOCAL qItem, qItmC, b_

   qItem := QTreeWidgetItem()
   qItem:setText( 0, cAlias )
   ::qTreeData:addTopLevelItem( qItem )

   FOR EACH b_ IN aStruct
      qItmC := QTreeWidgetItem()
      qItmC:setText( 0, b_[ 1 ] )
      qItem:addChild( qItmC )
      qItem:setExpanded( .t. )
   NEXT

   aadd( ::aSources, { cAlias, aStruct } )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:clear()
   LOCAL oHrqObject, qObj

   FOR EACH oHrqObject IN ::hItems
      qObj := oHrqObject:oWidget
      ::qScene:removeItem( qObj )
      qObj := NIL
   NEXT
   ::hItems      := {=>}

   ::qTreeObjects:clear()
   ::qTreeData:clear()

   ::aObjects    := {}
   ::aPages      := {}
   ::aSources    := {}

   ::aRptObjects := {}
   ::aRptPages   := {}
   ::aRptSources := {}

   hIDs          := {=>}

   ::qScene:invalidate()

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:updateObjectsTree( cType, cParent, cName, cSubType )
   LOCAL qParent, qItem

   DO CASE
   CASE cType == "ReportName"
      qItem := QTreeWidgetItem() ; qItem:setText( 0, cName )
      qItem:setIcon( 0, QIcon( Hbp_Image( "r-report" ) ) )
      ::qTreeObjects:addTopLevelItem( qItem )
      ::hObjTree[ cName ] := qItem
      qItem:setExpanded( .t. )

   CASE cType == "Page" .OR. cType == "Object" .OR. cType == "Field"
      IF hb_hHasKey( ::hObjTree, cParent )
         qParent := ::hObjTree[ cParent ]
      ENDIF
      IF !empty( qParent )
         IF hb_hHasKey( ::hObjTree, cName )
            //
         ENDIF
         qItem := QTreeWidgetItem() ; qItem:setText( 0, cName )
         qParent:addChild( qItem )
         ::hObjTree[ cName ] := qItem

         IF cType == "Page"
            qItem:setIcon( 0, QIcon( Hbp_Image( "r-page" ) ) )
         ELSEIF cType == "Object"
            qItem:setIcon( 0, QIcon( ::getImageOfType( cSubType ) ) )
         ELSEIF cType == "Field"
            qItem:setIcon( 0, QIcon( ::getImageOfType( "Field" ) ) )
         ENDIF

         qParent:setExpanded( .t. )
      ENDIF
   ENDCASE

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:zoom( nMode )

   SWITCH nMode
   CASE HBQT_GRAPHICSVIEW_ZOOM_IN
      ::qView:scale( 1.1, 1.1 )
      EXIT
   CASE HBQT_GRAPHICSVIEW_ZOOM_OUT
      ::qView:scale( 0.9, 0.9 )
      EXIT
   CASE HBQT_GRAPHICSVIEW_ZOOM_WYSIWYG
      ::qView:resetMatrix()
      ::qView:scale( ::nScreenDpiX / 25.4 / 10.0, ::nScreenDpiY / 25.4 / 10.0 )
      ::qView:centerOn( 0.0, 0.0 )
      EXIT
   CASE HBQT_GRAPHICSVIEW_ZOOM_ORIGINAL
      ::qView:resetMatrix()
      ::qView:centerOn( 0.0, 0.0 )
      EXIT
   ENDSWITCH

   RETURN sELF

/*----------------------------------------------------------------------*/

METHOD HbpReports:contextMenuScene( p1 )
   LOCAL qMenu, qAct, aAct := {}

   qMenu := QMenu( ::qView )
   aadd( aAct, qMenu:addAction( "Refresh"  ) )
   aadd( aAct, qMenu:addAction( "Zoom+" ) )

   IF ! empty( qAct := qMenu:exec( p1:screenPos() ) )
      SWITCH qAct:text()
      CASE "Refresh"
         EXIT
      CASE "Zoom+"
         EXIT
      ENDSWITCH
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:contextMenuItem( p1, p2 )
   LOCAL qMenu, qAct, aAct := {}

   HB_SYMBOL_UNUSED( p2 )

   qMenu := QMenu()
   aadd( aAct, qMenu:addAction( "Cut"  ) )
   aadd( aAct, qMenu:addAction( "Copy" ) )

   IF ! empty( qAct := qMenu:exec( p1:screenPos() ) )
      SWITCH qAct:text()
      CASE "Cut"
         EXIT
      CASE "Copy"
         EXIT
      ENDSWITCH
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildTabBar()

   ::qTabBar := QTabBar()
   ::qTabBar:setShape( QTabBar_TriangularNorth )

   ::qTabBar:addTab( "Code"    )
   ::qTabBar:addTab( "Dialogs" )
   ::qTabBar:addTab( "Page_1"  )

   ::qTabBar:connect( "currentChanged(int)", {|p| ::execEvent( __tabBar_currentChanged__, p ) } )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildStacks()

   ::qStack := QStackedWidget()

   ::qWidget1 := QWidget()
   ::qStack:addWidget( ::qWidget1 )

   ::qWidget2 := QWidget()
   ::qStack:addWidget( ::qWidget2 )

   ::qWidget3 := QWidget()
   ::qStack:addWidget( ::qWidget3 )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildStatusBar()
   LOCAL qLabel

   ::qStatus := QStatusBar()
   ::qStatus:setSizeGripEnabled( .f. )

   qLabel := QLabel(); qLabel:setMinimumWidth( 40 )
   ::qStatus:addPermanentWidget( qLabel, 0 )
   aadd( ::aStatusPnls, qLabel )
   qLabel:setText( "Ready" )

   qLabel := QLabel(); qLabel:setMinimumWidth( 40 )
   ::qStatus:addPermanentWidget( qLabel, 0 )
   aadd( ::aStatusPnls, qLabel )

   qLabel := QLabel(); qLabel:setMinimumWidth( 40 )
   ::qStatus:addPermanentWidget( qLabel, 0 )
   aadd( ::aStatusPnls, qLabel )

   qLabel := QLabel(); qLabel:setMinimumWidth( 40 )
   ::qStatus:addPermanentWidget( qLabel, 1 )
   aadd( ::aStatusPnls, qLabel )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:getImageOfType( cType )
   LOCAL cImage

   DO CASE
   CASE cType == "Image"     ;   cImage := "f-image"
   CASE cType == "Barcode"   ;   cImage := "f_barcode"
   CASE cType == "Chart"     ;   cImage := "f_chart"
   CASE cType == "Gradient"  ;   cImage := "f_gradient"
   CASE cType == "Text"      ;   cImage := "text"
   CASE cType == "Field"     ;   cImage := "text"
   CASE cType == "Rectangle" ;   cImage := "rp_rectangle"
   CASE cType == "RoundRect" ;   cImage := "rp_roundrectangle"
   CASE cType == "Ellipse"   ;   cImage := "rp_ellipse"
   CASE cType == "LineH"     ;   cImage := "rp_linehorz"
   CASE cType == "LineV"     ;   cImage := "rp_linevert"
   CASE cType == "LineDR"    ;   cImage := "rp_linediagright"
   CASE cType == "LineDL"    ;   cImage := "rp_linediagleft"
   CASE cType == "Arc"       ;   cImage := "rp_arc"
   CASE cType == "Chord"     ;   cImage := "rp_chord"
   CASE cType == "Diamond"   ;   cImage := "rp_diamond"
   CASE cType == "Triangle"  ;   cImage := "rp_triangle"
   ENDCASE

   RETURN Hbp_Image( cImage )

/*----------------------------------------------------------------------*/

METHOD HbpReports:getNextID( cType )

   IF ! hb_hHasKey( hIDs, cType )
      hIDs[ cType ] := 0
   ENDIF

   RETURN ++hIDs[ cType ]

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildToolbar()
   LOCAL qTBar

   qTBar := XbpToolbar():new()
   qTBar:orientation := Qt_Horizontal
   qTBar:imageWidth  := 16
   qTBar:imageHeight := 16
   qTBar:create()
   qTBar:buttonClick := {|oButton| iif( HB_ISBLOCK( oButton:key ), Eval( oButton:key ), NIL ) }

   qTBar:addItem( { "New"      , "New Report"            , QIcon( Hbp_Image( "new"         ) ), {|| ::execEvent( __buttonNew_clicked__       ) } } )
   qTBar:addItem( { "Open"     , "Open Report"           , QIcon( Hbp_Image( "open3"       ) ), {|| ::execEvent( __buttonOpen_clicked__      ) } } )
   qTBar:addItem( { "Save"     , "Save Report"           , QIcon( Hbp_Image( "save3"       ) ), {|| ::execEvent( __buttonSave_clicked__      ) } } )
   qTBar:addItem( { "Close"    , "Close Report"          , QIcon( Hbp_Image( "close3"      ) ), {|| ::execEvent( __buttonClose_clicked__     ) } } )
   qTBar:addItem( { "Print"    , "Print Report"          , QIcon( Hbp_Image( "print"       ) ), {|| ::execEvent( __buttonPrint_clicked__     ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "ToBack"   , "Push to back"          , QIcon( Hbp_Image( "toback"      ) ), {|| ::execEvent( __buttonToBack_clicked__    ) }, .f., .f. } )
   qTBar:addItem( { "ToFront"  , "Bring to front"        , QIcon( Hbp_Image( "tofront"     ) ), {|| ::execEvent( __buttonToFront_clicked__   ) }, .f., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "RotateL"  , "Rotate anti-clock wise", QIcon( Hbp_Image( "unload_1"    ) ), {|| ::execEvent( __buttonRotateL_clicked__   ) }, .f., .f. } )
   qTBar:addItem( { "RotateR"  , "Rotate clock wise"     , QIcon( Hbp_Image( "load_1"      ) ), {|| ::execEvent( __buttonRotateR_clicked__   ) }, .f., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "Portrait" , "Portrait orientation"  , QIcon( Hbp_Image( "r-portrait"  ) ), {|| ::execEvent( __buttonPortrait_clicked__  ) }, .f., .f. } )
   qTBar:addItem( { "Landscape", "Landscape orientation" , QIcon( Hbp_Image( "r-landscape" ) ), {|| ::execEvent( __buttonLandscape_clicked__ ) }, .f., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )

   ::qToolbar := qTBar

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildToolbarAlign()
   LOCAL qTBar

   qTBar := XbpToolbar():new()
   qTBar:orientation := Qt_Horizontal
   qTBar:imageWidth  := 16
   qTBar:imageHeight := 16
   qTBar:create()
   qTBar:buttonClick := {|oButton| iif( HB_ISBLOCK( oButton:key ), Eval( oButton:key ), NIL ) }

   qTBar:addItem( { "FontG"  , "Font"              , QIcon( Hbp_Image( "f-generic"       ) ), {|| ::execEvent( __buttonFontG_clicked__ ) }, .f., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "FontB"  , "Text Bold"         , QIcon( Hbp_Image( "f-bold-1"        ) ), {|| ::execEvent( __buttonFontB_clicked__ ) } } )
   qTBar:addItem( { "FontI"  , "Text Italic"       , QIcon( Hbp_Image( "f-italic-1"      ) ), {|| ::execEvent( __buttonFontI_clicked__ ) } } )
   qTBar:addItem( { "FontU"  , "Text Underlined"   , QIcon( Hbp_Image( "f-underline-1"   ) ), {|| ::execEvent( __buttonFontU_clicked__ ) } } )
   qTBar:addItem( { "FontS"  , "Text Strikethrough", QIcon( Hbp_Image( "f-strike-1"      ) ), {|| ::execEvent( __buttonFontS_clicked__ ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "JustL"  , "Align left"        , QIcon( Hbp_Image( "f_align_left"    ) ), {|| ::execEvent( __buttonJustL_clicked__ ) } } )
   qTBar:addItem( { "JustC"  , "Align center"      , QIcon( Hbp_Image( "f_align_center"  ) ), {|| ::execEvent( __buttonJustC_clicked__ ) } } )
   qTBar:addItem( { "JustR"  , "Align right"       , QIcon( Hbp_Image( "f_align_right"   ) ), {|| ::execEvent( __buttonJustR_clicked__ ) } } )
   qTBar:addItem( { "JustJ"  , "Align justify"     , QIcon( Hbp_Image( "f_align_justify" ) ), {|| ::execEvent( __buttonJustJ_clicked__ ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "JustT"  , "Align top"         , QIcon( Hbp_Image( "f_align_top"     ) ), {|| ::execEvent( __buttonJustT_clicked__ ) } } )
   qTBar:addItem( { "JustM"  , "Align middle"      , QIcon( Hbp_Image( "f_align_middle"  ) ), {|| ::execEvent( __buttonJustM_clicked__ ) } } )
   qTBar:addItem( { "JustB"  , "Align bottom"      , QIcon( Hbp_Image( "f_align_bottom"  ) ), {|| ::execEvent( __buttonJustB_clicked__ ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "BoxT"   , "Box-frame top"     , QIcon( Hbp_Image( "f_box_top"       ) ), {|| ::execEvent( __buttonBoxT_clicked__  ) }, .t., .F. } )
   qTBar:addItem( { "BoxL"   , "Box-frame left"    , QIcon( Hbp_Image( "f_box_left"      ) ), {|| ::execEvent( __buttonBoxL_clicked__  ) }, .t., .f. } )
   qTBar:addItem( { "BoxB"   , "Box-frame bottom"  , QIcon( Hbp_Image( "f_box_bottom"    ) ), {|| ::execEvent( __buttonBoxB_clicked__  ) }, .t., .f. } )
   qTBar:addItem( { "BoxR"   , "Box-frame right"   , QIcon( Hbp_Image( "f_box_right"     ) ), {|| ::execEvent( __buttonBoxR_clicked__  ) }, .t., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "BoxA"   , "Box-frame all"     , QIcon( Hbp_Image( "f_box_all"       ) ), {|| ::execEvent( __buttonBoxA_clicked__  ) } } )
   qTBar:addItem( { "BoxP"   , "No box-frame"      , QIcon( Hbp_Image( "f_box_plain"     ) ), {|| ::execEvent( __buttonBoxP_clicked__  ) } } )
   qTBar:addItem( { "BoxS"   , "Box shadowed"      , QIcon( Hbp_Image( "f_box_shadow"    ) ), {|| ::execEvent( __buttonBoxS_clicked__  ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "ZoomIn" , "Zoom In"           , QIcon( Hbp_Image( "zoomin3"         ) ), {|| ::execEvent( __buttonZoom_clicked__, 1 ) } } )
   qTBar:addItem( { "ZoomOut", "Zoom Out"          , QIcon( Hbp_Image( "zoomout3"        ) ), {|| ::execEvent( __buttonZoom_clicked__, 2 ) } } )
   qTBar:addItem( { "ZoomWYS", "Zoom WYSIWYG"      , QIcon( Hbp_Image( "zoomin"          ) ), {|| ::execEvent( __buttonZoom_clicked__, 3 ) } } )
   qTBar:addItem( { "ZoomOrg", "Zoom Original"     , QIcon( Hbp_Image( "zoomout"         ) ), {|| ::execEvent( __buttonZoom_clicked__, 4 ) } } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "Grid"   , "Show Grid"         , QIcon( Hbp_Image( "grid"            ) ), {|| ::execEvent( __buttonGrid_clicked__    ) }, .t., .f. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )

   ::qToolbarAlign := qTBar

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:buildToolbarLeft()
   LOCAL qTBar

   qTBar := XbpToolbar():new()
   qTBar:orientation := Qt_Vertical
   qTBar:imageWidth  := 16
   qTBar:imageHeight := 16
   qTBar:create()
   qTBar:buttonClick := {|oButton| iif( HB_ISBLOCK( oButton:key ), Eval( oButton:key ), NIL ) }

   ::qToolbarL := qTBar

   qTBar:addItem( { "Image"   , "Image"   , QIcon( Hbp_Image( "f-image"    ) ), {|| ::execEvent( __buttonNew_clicked__    ) }, .t., .t. } )
   qTBar:addItem( { "Chart"   , "Chart"   , QIcon( Hbp_Image( "f_chart"    ) ), {|| ::execEvent( __buttonNew_clicked__    ) }, .t., .t. } )
   qTBar:addItem( { "Gradient", "Gradient", QIcon( Hbp_Image( "f_gradient" ) ), {|| ::execEvent( __buttonNew_clicked__    ) }, .t., .t. } )
   qTBar:addItem( { "Barcode" , "Barcode" , QIcon( Hbp_Image( "f_barcode"  ) ), {|| ::execEvent( __buttonNew_clicked__    ) }, .t., .t. } )
   qTBar:addItem( { "Text"    , "Text"    , QIcon( Hbp_Image( "text"       ) ), {|| ::execEvent( __buttonNew_clicked__    ) }, .t., .t. } )
   qTBar:addItem( , , , , , XBPTOOLBAR_BUTTON_SEPARATOR )
   qTBar:addItem( { "Shapes"  , "Shapes"  , QIcon( Hbp_Image( "rp_shapes"  ) ), {|| ::execEvent( __buttonShapes_clicked__ ) }, .t., .f. } )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:execMenuShapes()

   IF empty( ::qShapesMenu )
      ::qShapesMenu := QMenu()

      ::aShapesAct[ SHP_ACT_RECTANGLE     ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_rectangle"     ) ), "Rectangle"           )
      ::aShapesAct[ SHP_ACT_ROUNDRECT     ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_roundrectangle") ), "Rounded Rectangle"   )
      ::aShapesAct[ SHP_ACT_ELLIPSE       ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_ellipse"       ) ), "Ellipse"             )
      ::aShapesAct[ SHP_ACT_LINEHORZ      ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_linehorz"      ) ), "Horizontal Line"     )
      ::aShapesAct[ SHP_ACT_LINEVERT      ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_linevert"      ) ), "Vertical Line"       )
      ::aShapesAct[ SHP_ACT_LINEDIAGRIGHT ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_linediagright" ) ), "Diagonal Line Right" )
      ::aShapesAct[ SHP_ACT_LINEDIAGLEFT  ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_linediagleft"  ) ), "Diagonal Line Left"  )
      ::aShapesAct[ SHP_ACT_ARC           ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_arc"           ) ), "Arc"                 )
      ::aShapesAct[ SHP_ACT_CHORD         ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_chord"         ) ), "Chord"               )
      ::aShapesAct[ SHP_ACT_DIAMOND       ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_diamond"       ) ), "Diamond"             )
      ::aShapesAct[ SHP_ACT_TRIANGLE      ] := ::qShapesMenu:addAction( QIcon( Hbp_Image( "rp_triangle"      ) ), "Triangle"            )

      ::qShapesMenu:connect( QEvent_MouseButtonPress  , {|p| ::execEvent( __QEvent_MousePressMenu__  , p ) } )
      ::qShapesMenu:connect( QEvent_MouseMove         , {|p| ::execEvent( __QEvent_MouseMoveMenu__   , p ) } )
      ::qShapesMenu:connect( QEvent_MouseButtonRelease, {|p| ::execEvent( __QEvent_MouseReleaseMenu__, p ) } )
   ENDIF

   ::qShapesMenu:exec( QCursor():pos() )

   ::qToolbarL:setItemChecked( "Shapes", .f. )

   RETURN Self

/*----------------------------------------------------------------------*/

/*
STATIC FUNCTION rmgr_xtos( x )
   SWITCH valtype( x )
   CASE "C" ; RETURN x
   CASE "D" ; RETURN dtos( x )
   CASE "L" ; RETURN iif( x, "YES", "NO" )
   CASE "N" ; RETURN hb_ntos( x )
   ENDSWITCH
   RETURN ""

STATIC FUNCTION rmgr_array2String( aArray )
   LOCAL a_, s, x

   s := ""
   FOR EACH a_ IN aArray
      FOR EACH x IN a_
         s += rmgr_xtos( x ) + " "
      NEXT
      s := trim( s ) + ","
   NEXT

   RETURN s
*/

STATIC FUNCTION rmgr_a2arrayStr( aArray )
   LOCAL s, x

   s := "{"
   FOR EACH x IN aArray
      SWITCH valtype( x )
      CASE "C"
         s += '"' + x + '"'               ; EXIT
      CASE "N"
         s += hb_ntos( x )                ; EXIT
      CASE "D"
         s += "stod(" + dtos( x ) + ")"   ; EXIT
      CASE "L"
         s += iif( x, ".t.", ".f." )      ; EXIT
      CASE "A"
         s += rmgr_a2arrayStr( x )        ; EXIT
      OTHERWISE
         s += "NIL"                       ; EXIT
      ENDSWITCH
      s += ","
   NEXT
   s := iif( Len( s ) == 1, s, substr( s, 1, len( s ) - 1 ) ) + "}"

   RETURN s

/*----------------------------------------------------------------------*/

STATIC FUNCTION rmgr_generateNextColor()
   RETURN QColor( hb_random( 0,255 ), hb_random( 0,255 ), hb_random( 0,255 ), 255 )

/*----------------------------------------------------------------------*/

STATIC FUNCTION rmgr_keyValuePair( s, cKey, cVal, cDlm )
   LOCAL n

   DEFAULT cDlm TO "="

   IF ( n := at( cDlm, s ) ) > 0
      cKey := alltrim( substr( s, 1, n - 1 ) )
      cVal := alltrim( substr( s, n + 1 ) )
      RETURN .t.
   ENDIF
   RETURN .f.

/*----------------------------------------------------------------------*/

STATIC FUNCTION rmgr_evalAsArray( cStr )
   LOCAL a_, bErr := ErrorBlock( {|| break() } )

   BEGIN SEQUENCE
      a_:= Eval( hb_macroBlock( cStr ) )
   RECOVER
      a_:= {}
   ENDSEQUENCE

   ErrorBlock( bErr )
   RETURN a_

/*----------------------------------------------------------------------*/
/*                                                                      */
/*   NOTE: the code below is works of someone else I do not remmeber    */
/*         the name. Please let me know who that is so due credits be   */
/*         given to him. I had downloaded this code many years back     */
/*         and adopted to Vouch32 library and Vouch32 Active-X Server.  */

STATIC FUNCTION fetchBarString( cCode, lCheck, nType )
   STATIC cCars   := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%'
   STATIC aBarras := {  '1110100010101110',;  // 1
                        '1011100010101110',;  // 2
                        '1110111000101010',;  // 3
                        '1010001110101110',;  // 4
                        '1110100011101010',;  // 5
                        '1011100011101010',;  // 6
                        '1010001011101110',;  // 7
                        '1110100010111010',;  // 8
                        '1011100010111010',;  // 9
                        '1010001110111010',;  // 0
                        '1110101000101110',;  // A
                        '1011101000101110',;  // B
                        '1110111010001010',;  // C
                        '1010111000101110',;  // D
                        '1110101110001010',;  // E
                        '1011101110001010',;
                        '1010100011101110',;
                        '1110101000111010',;
                        '1011101000111010',;
                        '1010111000111010',;
                        '1110101010001110',;  // K
                        '1011101010001110',;
                        '1110111010100010',;
                        '1010111010001110',;
                        '1110101110100010',;
                        '1011101110100010',;  // p
                        '1010101110001110',;
                        '1110101011100010',;
                        '1011101011100010',;
                        '1010111011100010',;
                        '1110001010101110',;
                        '1000111010101110',;
                        '1110001110101010',;
                        '1000101110101110',;
                        '1110001011101010',;
                        '1000111011101010',;  // Z
                        '1000101011101110',;  // -
                        '1110001010111010',;  // .
                        '1000111010111010',;  // ' '
                        '1000101110111010',;  // *
                        '1000100010100010',;
                        '1000100010100010',;
                        '1000101000100010',;
                        '1010001000100010' }

   LOCAL cCar, m, n, cBarra := '',  nCheck := 0

   DEFAULT lCheck TO .f.
   DEFAULT nType  TO HQR_BARCODE_3OF9

   DO CASE
   CASE nType == HQR_BARCODE_3OF9
      cCode := upper( cCode )
      IF Len( cCode ) > 32
         cCode := left( cCode,32 )
      ENDIF

      cCode := '*' + cCode + '*'
      FOR n := 1 TO Len( cCode )
         cCar := substr( cCode,n,1 )
         m    := at( cCar, cCars )
         IF m > 0
            cBarra := cBarra + aBarras[ m ]
            nCheck += ( m-1 )
         ENDIF
      NEXT

      IF lCheck
         cBarra += aBarras[ nCheck % 43 + 1 ]
      ENDIF
   ENDCASE

   RETURN cBarra

/*----------------------------------------------------------------------*/

METHOD HbpReports:printPreview( qPrinter )
   LOCAL qDlg //, qInfo //, qList, i, qStr

   qPrinter := QPrinter()

#if 0
   qInfo := QPrinterInfo( qPrinter )
   qList := qInfo:availablePrinters()
   FOR i := 0 TO qList:size() - 1
      qStr := qList:at( i )
   NEXT
#endif
   qPrinter:setOutputFormat( QPrinter_PdfFormat )
   qPrinter:setOrientation( ::qScene:orientation() )
   qPrinter:setPaperSize( ::qScene:pageSize() )
   // qPrinter:setFullPage( .t. )

   qDlg := QPrintPreviewDialog( qPrinter, ::qView )
   qDlg:connect( "paintRequested(QPrinter*)", {|p| ::paintRequested( p ) } )

   qDlg:setWindowTitle( "HBReportGenerator : " + iif( !empty( ::cSaved ), ::cSaved, "Untitled" ) )
   qDlg:move( 20, 20 )
   qDlg:resize( 400, 600 )
   qDlg:exec()
   qDlg:disconnect( "paintRequested(QPrinter*)" )

   RETURN NIL //qStr

/*----------------------------------------------------------------------*/

METHOD HbpReports:paintRequested( qPrinter )
   ::printReport( qPrinter )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbpReports:printReport( qPrinter )
   LOCAL qPainter, a_, qRectF, oHqrObject, qT

   qPainter := QPainter()
   qPainter:begin( qPrinter )

   qRectF := ::qScene:paperRect()
   qPainter:setWindow( qRectF:x(), qRectF:y(), qRectF:width(), qRectF:height() )
   qPainter:setViewPort( 0, 0, qPrinter:width(), qPrinter:height() )
   FOR EACH a_ IN ::aObjects
      IF hb_hHasKey( ::hItems, a_[ 3 ] )
         oHqrObject := ::hItems[ a_[ 3 ] ]
         qRectF     := oHqrObject:geometry()
         qRectF     := QRectF( TO_MMS( qRectF:x() ), TO_MMS( qRectF:y() ), TO_MMS( qRectF:width() ), TO_MMS( qRectF:height() ) )

         qT := oHqrObject:transform()
//HB_TRACE( HB_TR_DEBUG, qT:m11(), qT:m12(), qT:m13(), qT:m21(), qT:m22(), qT:m23(), qT:m31(), qT:m32(), qT:m33() )
         qT:translate( 0,0 )
         qPainter:resetMatrix()
         qPainter:setWorldTransform( qT )

         oHqrObject:draw( qPainter, qRectF, .f. )
      ENDIF
   NEXT
   qPainter:end()

   RETURN Self

/*----------------------------------------------------------------------*/
//                       HqrGraphicsItem() Class
/*----------------------------------------------------------------------*/

CLASS HqrGraphicsItem

   DATA   oRM
   DATA   oWidget
   DATA   cParent

   /* Constructor data */
   DATA   cType                                   INIT ""
   DATA   cName                                   INIT ""

   DATA   nX                                      INIT 0
   DATA   nY                                      INIT 0
   DATA   aPos                                    INIT {}
   DATA   aGeometry                               INIT {}

   /* Runtime data */
   DATA   cText                                   INIT ""
   DATA   qPen
   DATA   qBrush
   DATA   qGBrush
   DATA   qBgBrush
   DATA   qPixmap
   DATA   qFont
   DATA   xData
   DATA   qGeometry

   DATA   nBarcodeType                            INIT HQR_BARCODE_3OF9
   DATA   nTextFlags                              INIT Qt_AlignCenter
   DATA   nBorderWidth                            INIT 0
   DATA   nLineStyle                              INIT HBQT_GRAPHICSITEM_LINE_HORIZONTAL
   DATA   nBackgroundMode                         INIT Qt_TransparentMode
   DATA   nOpacity                                INIT 100
   DATA   nWidth                                  INIT 200
   DATA   nHeight                                 INIT 100
   DATA   nStartAngle                             INIT 30
   DATA   nSpanAngle                              INIT 120
   DATA   nLineType                               INIT HBQT_GRAPHICSITEM_LINE_HORIZONTAL

   DATA   nPointSize                              INIT 3.5

   METHOD new( oRM, cParent, cType, cName, aPos, aGeometry )
   METHOD execEvent( cEvent, p, p1, p2 )
   METHOD contextMenu( p1, p2 )
   METHOD update()
   METHOD destroy()

   ACCESS text()                                  INLINE ::setText()
   ACCESS textFlags()                             INLINE ::setTextFlags()
   ACCESS pen()                                   INLINE ::setPen()
   ACCESS brush()                                 INLINE ::setBrush()
   ACCESS backgroundBrush()                       INLINE ::setBackgroundBrush()
   ACCESS font()                                  INLINE ::setFont()
   ACCESS barcodeType()                           INLINE ::setBarcodeType()
   ACCESS gradient()                              INLINE ::setBrush()
   ACCESS pixmap()                                INLINE ::setPixmap()
   ACCESS borderWidth()                           INLINE ::setBorderWidth()
   ACCESS lineStyle()                             INLINE ::setLineStyle()
   ACCESS backgroundMode()                        INLINE ::setBackgroundMode()
   ACCESS opacity()                               INLINE ::setOpacity()
   ACCESS width()                                 INLINE ::setWidth()
   ACCESS height()                                INLINE ::setHeight()
   ACCESS geometry()                              INLINE ::setGeometry()
   ACCESS pos()                                   INLINE ::setPos()
   ACCESS lineType()                              INLINE ::setLineType()

   METHOD setText( ... )                          SETGET
   METHOD setPen( ... )                           SETGET
   METHOD setBrush( ... )                         SETGET
   METHOD setBackgroundBrush( ... )               SETGET
   METHOD setFont( ... )                          SETGET
   METHOD setGradient( ... )                      SETGET
   METHOD setPixmap( ... )                        SETGET
   METHOD setTextFlags( ... )                     SETGET
   METHOD setBarcodeType( ... )                   SETGET
   METHOD setBorderWidth( ... )                   SETGET
   METHOD setLineStyle( ... )                     SETGET
   METHOD setBackgroundMode( ... )                SETGET
   METHOD setOpacity( ... )                       SETGET
   METHOD setWidth( ... )                         SETGET
   METHOD setHeight( ... )                        SETGET
   METHOD setGeometry( ... )                      SETGET
   METHOD setPos( ... )                           SETGET
   METHOD setLineType( ... )                      SETGET

   METHOD draw( qPainter, qRectF, lDrawSelection )
   METHOD setupPainter( qPainter, lDrawSelection )
   METHOD drawBarcode( qPainter, qRectF )
   METHOD drawImage( qPainter, qRectF )
   METHOD drawChart( qPainter, qRect )
   METHOD drawText( qPainter, qRectF )
   METHOD drawField( qPainter, qRectF )
   METHOD drawGradient( qPainter, qRectF )
   METHOD drawLine( qPainter, qRect )
   METHOD drawRect( qPainter, qRectF )
   METHOD drawRoundRect( qPainter, qRectF )
   METHOD drawEllipse( qPainter, qRectF )
   METHOD drawPie( qPainter, qRectF )
   METHOD drawArc( qPainter, qRectF )
   METHOD drawChord( qPainter, qRectF )
   METHOD drawDiamond( qPainter, qRectF )
   METHOD drawTriangle( qPainter, qRectF )
   METHOD drawSelection( qPainter, qRect )

   ERROR  HANDLER OnError( ... )
   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:new( oRM, cParent, cType, cName, aPos, aGeometry )

   HB_TRACE( HB_TR_DEBUG, "HqrGraphicsItem:new" )

   ::oRM       := oRM
   ::cParent   := cParent
   ::cType     := cType
   ::cName     := cName
   ::aPos      := aPos
   ::aGeometry := aGeometry

   SWITCH cType
   CASE "Image"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_PICTURE )
      EXIT
   CASE "Chart"
      ::nWidth := 400 ;  ::nHeight := 250
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_CHART )
      EXIT
   CASE "Gradient"
      ::nWidth := 300 ;  ::nHeight := 50
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_RECT )
      EXIT
   CASE "Barcode"
      ::nWidth := 300 ;  ::nHeight := 200
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_BARCODE )
      EXIT
   CASE "Text"
      ::nWidth := 300 ;  ::nHeight := 50
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_SIMPLETEXT )//, ::oRM:qScene )
      EXIT
   CASE "Field"
      ::nWidth := 300 ;  ::nHeight := 50
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_SIMPLETEXT )
      EXIT
   //
   CASE "Rectangle"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_RECT )
      EXIT
   CASE "RoundRect"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_ROUNDRECT )
      EXIT
   CASE "Ellipse"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_ELLIPSE )
      EXIT
   CASE "Arc"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_ARC )
      EXIT
   CASE "Chord"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_CHORD )
      EXIT
   CASE "LineH"
      ::nWidth := 300 ;  ::nHeight := 50
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_LINE )
      ::nLineType := HBQT_GRAPHICSITEM_LINE_HORIZONTAL
      EXIT
   CASE "LineV"
      ::nWidth := 50  ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_LINE )
      ::nLineType := HBQT_GRAPHICSITEM_LINE_VERTICAL
      EXIT
   CASE "LineDR"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_LINE )
      ::nLineType := HBQT_GRAPHICSITEM_LINE_BACKWARDDIAGONAL
      EXIT
   CASE "LineDL"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_LINE )
      ::nLineType := HBQT_GRAPHICSITEM_LINE_FORWARDDIAGONAL
      EXIT
   CASE "Diamond"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_ROUNDRECT )
      EXIT
   CASE "Triangle"
      ::nWidth := 300 ;  ::nHeight := 300
      ::oWidget := HBQGraphicsItem( HBQT_GRAPHICSITEM_ROUNDRECT )
      EXIT
   ENDSWITCH

   ::oWidget:setObjectType( cType )
   ::oWidget:setObjectName( cName )
   ::oWidget:setTooltip( cName )

   ::oWidget:hbSetBlock( {|p,p1,p2| ::execEvent( "graphicsItem_block", p, p1, p2 ) } )

   ::oRM:qScene:addItem( ::oWidget )

   DEFAULT ::aGeometry TO { 0, 0, ::nWidth, ::nHeight }
   ::setGeometry( ::aGeometry[ 1 ], ::aGeometry[ 2 ], ::aGeometry[ 3 ], ::aGeometry[ 4 ] )
   IF !empty( ::aPos )
      ::setPos( ::aPos[ 1 ], ::aPos[ 2 ] )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:destroy()
   ::oWidget:hbClearBlock()
   ::oWidget := NIL
   RETURN NIL


METHOD HqrGraphicsItem:onError( ... )
   LOCAL cMsg := __GetMessage()
   IF SubStr( cMsg, 1, 1 ) == "_"
      cMsg := SubStr( cMsg, 2 )
   ENDIF
   RETURN ::oWidget:&cMsg( ... )

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:execEvent( cEvent, p, p1, p2 )

   HB_TRACE( HB_TR_DEBUG, "HqrGraphicsItem:execEvent", P, P1, P2 )

   DO CASE
   CASE cEvent == "graphicsItem_block"
      DO CASE
      CASE p == 21101
         ::oRM:objectSelected( Self )

      CASE p == 21017
         ::draw( p1, p2 )

      CASE p == QEvent_GraphicsSceneContextMenu
         ::contextMenu( p1, p2 )

      ENDCASE
   ENDCASE

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:contextMenu( p1, p2 )
   LOCAL qMenu, qAct

   HB_SYMBOL_UNUSED( p2 )

   qMenu := QMenu()
   qMenu:addAction( "Cut"  )
   qMenu:addAction( "Copy" )

   IF ! empty( qAct := qMenu:exec( p1:screenPos() ) )
      SWITCH qAct:text()
      CASE "Cut"
         EXIT
      CASE "Copy"
         EXIT
      ENDSWITCH
   ENDIF
   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:update()
   ::oWidget:update()
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setText( ... )
   LOCAL a_:= hb_aParams()
   IF empty( a_ )
      RETURN ::cText
   ENDIF
   IF HB_ISSTRING( a_[ 1 ] )
      ::cText := a_[ 1 ]
      ::update()
   ENDIF
   RETURN ::cText

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setTextFlags( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nTextFlags := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nTextFlags

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setPen( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qPen )
         ::qPen := QPen( Qt_black )
         ::qPen:setStyle( Qt_SolidLine )
      ENDIF
      RETURN ::qPen
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qPen := a_[ 1 ]
      ELSE
         ::qPen := QPen( ... )
      ENDIF
      ::update()
   ENDSWITCH
   RETURN ::qPen

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setBrush( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qBrush )
         ::qBrush := QBrush()
      ENDIF
      EXIT
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qBrush := a_[ 1 ]
      ELSE
         ::qBrush := QBrush( ... )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::qBrush

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setBackgroundBrush( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qBgBrush )
         ::qBgBrush := QBrush()
      ENDIF
      EXIT
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qBgBrush := a_[ 1 ]
      ELSE
         ::qBgBrush := QBrush( ... )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::qBgBrush

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setFont( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qFont )
         ::qFont := QFont( "Serif" )
         ::qFont:setPointSizeF( ::nPointSize )
         ::qFont:setStyleStrategy( QFont_PreferMatch )
         ::qFont:setStyleStrategy( QFont_ForceOutline )
      ENDIF
      EXIT
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qFont := a_[ 1 ]
      ELSE
         ::qFont := QFont( ... )
      ENDIF
      ::nPointSize := ::qFont:pointSize()
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::qFont

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setBarcodeType( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nBarcodeType := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nBarcodeType

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setGradient( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qGBrush )
         ::qGBrush := QBrush()
      ENDIF
      EXIT
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qGBrush := a_[ 1 ]
      ELSE
         ::qGBrush := QBrush( ... )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::qGBrush

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setPixmap( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      IF empty( ::qPixmap )
         ::qPixmap := QPixmap()
      ENDIF
      EXIT
   OTHERWISE
      IF HB_ISOBJECT( a_[ 1 ] )
         ::qPixmap := a_[ 1 ]
      ELSE
         ::qPixmap := QPixmap( ... )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::qPixmap

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setBorderWidth( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nBorderWidth := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nBorderWidth

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setWidth( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      RETURN ::oWidget:width()
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nWidth := a_[ 1 ]
         ::oWidget:setWidth( ::nWidth )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nBorderWidth

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setHeight( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      RETURN ::oWidget:height()
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nHeight := a_[ 1 ]
         ::oWidget:setHeight( ::nHeight )
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nBorderWidth

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setGeometry( ... )
   LOCAL qRectF, qPos, a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      qPos := ::oWidget:pos()
      RETURN QRectF( qPos:x(), qPos:y(), ::width(), ::height() )
   CASE 1
      IF HB_ISOBJECT( a_[ 1 ] )
         qRectF := a_[ 1 ]
         ::oWidget:setPos( QPointF( qRectF:x(), qRectF:y() ) )
         ::oWidget:setWidth( qRectF:width() )
         ::oWidget:setHeight( qRectF:height() )
         ::update()
      ENDIF
      EXIT
   CASE 4
      ::oWidget:setPos( QPointF( a_[ 1 ], a_[ 2 ] ) )
      ::oWidget:setWidth( a_[ 3 ] )
      ::oWidget:setHeight( a_[ 4 ] )
      ::update()
      EXIT
   ENDSWITCH
   RETURN QRectF( 0, 0, ::nWidth, ::nHeight )

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setPos( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      RETURN ::oWidget:pos()
   CASE 1
      IF HB_ISOBJECT( a_[ 1 ] )
         ::oWidget:setPos( a_[ 1 ] )
         ::update()
      ENDIF
      EXIT
   CASE 2
      ::oWidget:setPos( QPointF( a_[ 1 ], a_[ 2 ] ) )
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::oWidget:pos()

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setLineStyle( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nLineStyle := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nLineStyle

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setBackgroundMode( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nBackgroundMode := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nBackgroundMode

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setOpacity( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nOpacity := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nOpacity

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setLineType( ... )
   LOCAL a_:= hb_aParams()
   SWITCH Len( a_ )
   CASE 0
      EXIT
   OTHERWISE
      IF HB_ISNUMERIC( a_[ 1 ] )
         ::nLineType := a_[ 1 ]
      ENDIF
      ::update()
      EXIT
   ENDSWITCH
   RETURN ::nLineType

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:setupPainter( qPainter, lDrawSelection )
   LOCAL qFont

   qPainter:setPen( ::pen() )
   qPainter:setBrush( ::brush() )

   qFont := ::font()

   qFont:setPixelSize( iif( lDrawSelection, ::nPointSize / UNIT, TO_MMS( ::nPointSize / UNIT ) ) )
   qPainter:setFont( qFont )

   qPainter:setBackgroundMode( ::backgroundMode() )
   qPainter:setBackground( ::backgroundBrush() )

   qPainter:setOpacity( ::opacity() / 100.0 )
   qPainter:setRenderHint( QPainter_TextAntialiasing )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawSelection( qPainter, qRect )
   LOCAL a, p, lt, rt, lb, rb
   LOCAL drawSelectionBorder := .t.
   LOCAL iResizeHandle := 2 / UNIT
   LOCAL nW, nH

   qPainter:save()

   nW := qRect:width() ; nH := qRect:height()

   IF ::oWidget:isSelected()
      a := QBrush()
      a:setColor( QColor( 255,0,0 ) )
      a:setStyle( Qt_SolidPattern )
      IF drawSelectionBorder
         p := QPen()
         p:setStyle( Qt_DashLine )
         p:setBrush( a )
         qPainter:setPen( p )
         qPainter:drawRect( qRect )
      ENDIF
      lt := QPainterPath()
      lt:moveTo( 0,0 )
      lt:lineTo( 0, iResizeHandle )
      lt:lineTo( iResizeHandle, 0 )
      qPainter:fillPath( lt, a )

      rt := QPainterPath()
      rt:moveTo( nW,0 )
      rt:lineTo( nW, iResizeHandle )
      rt:lineTo( nW-iResizeHandle, 0 )
      qPainter:fillPath( rt,a )

      lb := QPainterPath()
      lb:moveTo( 0, nH )
      lb:lineTo( 0, nH - iResizeHandle )
      lb:lineTo( iResizeHandle, nH )
      qPainter:fillPath( lb,a )

      rb := QPainterPath()
      rb:moveTo( nW, nH )
      rb:lineTo( nW, nH - iResizeHandle )
      rb:lineTo( nW-iResizeHandle, nH )
      qPainter:fillPath( rb,a )
   ELSE
      IF drawSelectionBorder
         a := QBrush()
         a:setColor( QColor( 100,100,100,200 ) )
         a:setStyle( Qt_SolidPattern )

         p := QPen()
         p:setStyle( Qt_DashDotDotLine )
         p:setBrush( a )
         qPainter:setPen( p )
         qPainter:drawRect( qRect )
      ELSE
         qPainter:setPen( "QColor", QColor( 0, 0, 0, 100 ) )

         qPainter:drawLine( 0 , 0 , 0                 , 2*iResizeHandle    )
         qPainter:drawLine( 0 , 0 , 2*iResizeHandle   , 0                  )
         qPainter:drawLine( nW, 0 , nW-2*iResizeHandle, 0                  )
         qPainter:drawLine( nW, 0 , nW                , 2*iResizeHandle    )
         qPainter:drawLine( nW, nH, nW-2*iResizeHandle, nH                 )
         qPainter:drawLine( nW, nH, nW                , nH-2*iResizeHandle )
         qPainter:drawLine( 0 , nH, 2*iResizeHandle   , nH                 )
         qPainter:drawLine( 0 , nH, 0                 , nH-2*iResizeHandle )
      ENDIF
   ENDIF
   qPainter:restore()
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:draw( qPainter, qRectF, lDrawSelection )

   DEFAULT lDrawSelection TO .t.

   ::setupPainter( qPainter, lDrawSelection )

   SWITCH ::cType
   CASE "Barcode"    ;   ::drawBarcode( qPainter, qRectF )      ;    EXIT
   CASE "Image"      ;   ::drawImage( qPainter, qRectF )        ;    EXIT
   CASE "Chart"      ;   ::drawChart( qPainter, qRectF )        ;    EXIT
   CASE "Gradient"   ;   ::drawGradient( qPainter, qRectF )     ;    EXIT
   CASE "Text"       ;   ::drawText( qPainter, qRectF )         ;    EXIT
   CASE "Field"      ;   ::drawField( qPainter, qRectF )        ;    EXIT
   CASE "Rectangle"  ;   ::drawRect( qPainter, qRectF )         ;    EXIT
   CASE "RoundRect"  ;   ::drawRoundRect( qPainter, qRectF )    ;    EXIT
   CASE "Ellipse"    ;   ::drawEllipse( qPainter, qRectF )      ;    EXIT
   CASE "LineH"      ;   ::drawLine( qPainter, qRectF )         ;    EXIT
   CASE "LineV"      ;   ::drawLine( qPainter, qRectF )         ;    EXIT
   CASE "LineDR"     ;   ::drawLine( qPainter, qRectF )         ;    EXIT
   CASE "LineDL"     ;   ::drawLine( qPainter, qRectF )         ;    EXIT
   CASE "Arc"        ;   ::drawArc( qPainter, qRectF )          ;    EXIT
   CASE "Chord"      ;   ::drawChord( qPainter, qRectF )        ;    EXIT
   CASE "Diamond"    ;   ::drawDiamond( qPainter, qRectF )      ;    EXIT
   CASE "Triangle"   ;   ::drawTriangle( qPainter, qRectF )     ;    EXIT
   ENDSWITCH

   IF lDrawSelection
      ::drawSelection( qPainter, qRectF )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawRect( qPainter, qRectF )
   qPainter:drawRect( qRectF )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawRoundRect( qPainter, qRectF )
   qPainter:drawRoundedRect( qRectF, 10/UNIT, 10/UNIT )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawEllipse( qPainter, qRectF )
   qPainter:drawEllipse( qRectF )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawLine( qPainter, qRect )

   SWITCH ::lineType()
   CASE HBQT_GRAPHICSITEM_LINE_VERTICAL
      qPainter:drawLine( qRect:x() + qRect:width() / 2, qRect:y(), qRect:x() +  qRect:width() / 2, qRect:y() + qRect:height() )
      EXIT
   case HBQT_GRAPHICSITEM_LINE_HORIZONTAL
      qPainter:drawLine( qRect:x(), qRect:y() + qRect:height() / 2, qRect:x() + qRect:width(), qRect:y() + qRect:height() / 2 )
      EXIT
   case HBQT_GRAPHICSITEM_LINE_BACKWARDDIAGONAL
      qPainter:drawLine( qRect:right(), qRect:y(), qRect:x(), qRect:bottom() )
      EXIT
   case HBQT_GRAPHICSITEM_LINE_FORWARDDIAGONAL
      qPainter:drawLine( QPointF( qRect:x(), qRect:y() ), QPointF( qRect:right(), qRect:bottom() ) )
      EXIT
   ENDSWITCH
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawPie( qPainter, qRectF )
   qPainter:drawPie( qRectF, ::nStartAngle * 16, ::nSpanAngle * 16 )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawDiamond( qPainter, qRectF )
   LOCAL p := QPainterPath()
   LOCAL x := qRectF:x(), y := qRectF:y(), w := qRectF:width(), h := qRectF:height()

   p:moveTo( x, y + h / 2 )
   p:lineTo( x + w / 2, y )
   p:lineTo( x + w, y + h / 2 )
   p:lineTo( x + w / 2, y + h )
   p:lineTo( x, y + h / 2 )

   qPainter:drawPath( p )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawTriangle( qPainter, qRectF )
   LOCAL p := QPainterPath()

   p:moveTo( qRectF:x(), qRectF:y() + qRectF:height() )
   p:lineTo( qRectF:x() + qRectF:width() / 2, qRectF:y() )
   p:lineTo( qRectF:x() + qRectF:width(), qRectF:y() + qRectF:height() )
   p:lineTo( qRectF:x(), qRectF:y() + qRectF:height() )

   qPainter:drawPath( p )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawArc( qPainter, qRectF )
   qPainter:drawArc( qRectF, ::nStartAngle * 16, ::nSpanAngle * 16 )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawChord( qPainter, qRectF )
   qPainter:drawChord( qRectF, ::nStartAngle * 16, ::nSpanAngle * 16 )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawText( qPainter, qRectF )
   qPainter:drawText( qRectF, ::textFlags(), ::text() )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawField( qPainter, qRectF )
   qPainter:drawText( qRectF, ::textFlags(), ::text() )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawGradient( qPainter, qRectF )
   qPainter:drawRect( qRectF )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawBarcode( qPainter, qRectF )
   LOCAL rc, w, x, i, cCode

   rc    := qRectF:adjusted( 5, 5, -10, -10 )
   cCode := fetchBarString( ::text() )
   w     := rc:width() / Len( cCode )
   x     := 0.0

   FOR i := 1 TO Len( cCode )
      IF substr( cCode, i, 1 ) == "1"
         qPainter:fillRect( QRectF( rc:x() + x, rc:y(), w, rc:height() ), QColor( Qt_black ) )
      ELSE
         qPainter:fillRect( QRectF( rc:x() + x, rc:y(), w, rc:height() ), QColor( Qt_white ) )
      ENDIF
      x += w
   NEXT

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawImage( qPainter, qRectF )
   LOCAL qPix, image, rc, img, point
   LOCAL drawTextType := HBQT_GRAPHICSITEM_TEXT_DRAW_ABOVE
   LOCAL paintType    := HBQT_GRAPHICSITEM_RESIZE_PICTURE_TO_ITEM_KEEP_ASPECT_RATIO
   LOCAL borderWidth  := 0
   LOCAL borderColor  := 0, pen, textH, sw, sh, cx, cy, cw, ch, textColor := 0
   LOCAL cText        := "Picture"
   LOCAL qObj         := ::oWidget

   rc    := qRectF:adjusted( 1, 1, -2, -2 )

   textH := 0
   sw    := 0
   sh    := 0

   IF drawTextType == HBQT_GRAPHICSITEM_TEXT_DRAW_ABOVE .OR. ::drawTextType == HBQT_GRAPHICSITEM_TEXT_DRAW_BELOW
      textH := qPainter:font():pixelSize()
   ENDIF

   qPix  := ::pixmap()
   image := qPix:toImage()

   IF image:isNull()
      qPainter:drawRect( qRectF )
   ELSE
      img   := QImage( 0, 0 )
      point := qRectF:topLeft()
      cx    := 0; cy := 0; cw := qPix:width(); ch := qPix:height()

      SWITCH paintType
      CASE HBQT_GRAPHICSITEM_RESIZE_PICTURE_TO_ITEM_KEEP_ASPECT_RATIO
         img := QImage( image:scaled( rc:width(), rc:height() - textH, Qt_KeepAspectRatio, Qt_SmoothTransformation ) )
         EXIT
      CASE HBQT_GRAPHICSITEM_RESIZE_PICTURE_TO_ITEM_IGNORE_ASPECT_RATIO
         img := QImage( image:scaled( rc:width(), rc:height() - textH, Qt_IgnoreAspectRatio, Qt_SmoothTransformation ) )
         EXIT
      CASE HBQT_GRAPHICSITEM_CENTER_PICTURE_TO_ITEM
         point:setX( point:x() + ( rc:width() - image:width() ) / 2 )
         point:setY( point:y() + ( rc:height() - image:height() - textH ) / 2 )
         IF point:x() < 0
            cx := abs( point:x() )
            cw -= 2 * cx
            point:setX( 0 )
         ENDIF
         IF point:y() < 0
            cy := abs( point:y() )
            ch -= 2 * cy
            point:setY( 0 )
         ENDIF
         img := QImage( image:copy( cx, cy, cw, ch ) )
         EXIT
      CASE HBQT_GRAPHICSITEM_RESIZE_ITEM_TO_PICTURE
         img := image
         sw := img:width() - qObj:width()
         sh := img:height() - ( qObj:height() - textH )
         EXIT
      ENDSWITCH

      IF drawTextType == HBQT_GRAPHICSITEM_TEXT_DRAW_ABOVE
         point:setY( point:y() + textH )
      ENDIF

      qPainter:drawImage( point, img )
   ENDIF
   qPainter:setPen( QPen( textColor ) )

   SWITCH drawTextType
   CASE HBQT_GRAPHICSITEM_TEXT_DRAW_TOP
      qPainter:drawText( rc, Qt_AlignTop + Qt_AlignHCenter, cText )
      EXIT
   CASE HBQT_GRAPHICSITEM_TEXT_DRAW_BOTTOM
      qPainter:drawText( rc, Qt_AlignBottom + Qt_AlignHCenter, cText )
      EXIT
   CASE HBQT_GRAPHICSITEM_TEXT_DRAW_ABOVE
      qPainter:drawText( rc, Qt_AlignTop + Qt_AlignHCenter, cText )
      EXIT
   CASE HBQT_GRAPHICSITEM_TEXT_DRAW_BELOW
      qPainter:drawText( rc, Qt_AlignBottom + Qt_AlignHCenter, cText )
      EXIT
   ENDSWITCH

   IF !empty( sw ) .OR. !empty( sh )
      qObj:setWidth( qObj:width() + sw )
      qObj:setHeight( qObj:height() + sh )
   ENDIF

   IF borderWidth > 0
      pen := QPen()
      pen:setWidth( borderWidth )
      pen:setColor( borderColor )
      pen:setJoinStyle( Qt_MiterJoin )
      qPainter:setPen( pen )
      qPainter:setBrush( QBrush( Qt_NoBrush ) )
      qPainter:drawRect( rc:x() + borderWidth / 2, rc:y() + borderWidth / 2, ;
                         rc:width() - borderWidth, rc:height() - borderWidth )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HqrGraphicsItem:drawChart( qPainter, qRect )
   LOCAL qFMetrix, maxpv, minnv, absMaxVal, powVal, chartStep, powStep, maxHeight, valstep, maxLabelWidth
   LOCAL pw, rc, maxval, y, i, x, cv, barWidth, lg, py, f, cMaxVal, nDec, nFHeight, nLabelWidth, br, nPlanes
   LOCAL m_drawBorder      := .t.
   LOCAL m_showLabels      := .t.
   LOCAL m_showGrid        := .t.
   LOCAL m_barsIdentation  := 1.0 / UNIT
   LOCAL nColorFactor      := 1.7

   qFMetrix := qPainter:fontMetrics()
   nFHeight := qFMetrix:height()

   IF empty( ::xData )
      ::xData := {}

      aadd( ::xData, { "Bananas", 040.0, rmgr_generateNextColor() } )
      aadd( ::xData, { "Oranges", 150.0, rmgr_generateNextColor() } )
      aadd( ::xData, { "Mangoes", 095.0, rmgr_generateNextColor() } )
   ENDIF

   maxpv     := 0
   minnv     := 0
   aeval( ::xData, {|e_| iif( e_[ 2 ] < 0, minnv := min( minnv, e_[ 2 ] ), NIL ), iif( e_[ 2 ] > 0, maxpv := max( maxpv, e_[ 2 ] ), NIL ) } )

   absMaxVal := maxpv - minnv
   cMaxVal   := hb_ntos( absMaxVal )
   nDec      := at( ".", cMaxVal )

   powVal    := iif( absMaxVal < 1,  10.0 ^ ( Len( substr( cMaxVal, nDec+1 ) ) + 1 ), 1 )
   maxpv     *= powVal
   minnv     *= powVal

   maxpv     := maxpv
   minnv     := -minnv
   minnv     := -minnv

   qPainter:fillRect( qRect, ::brush() )

   IF m_drawBorder
      qPainter:drawRect( qRect )
   ENDIF

   pw := iif( abs( ::pen():widthF() ) > 0, abs( ::pen():widthF() ), 1 )
   rc := qRect:adjusted( pw / 2, pw / 2, -pw, -pw )

   f  := 2
   chartStep := ( 10.0 ^ ( Len( substr( cMaxVal, 1, nDec - 1 ) ) - 1 ) ) / f
   powStep   := iif( chartStep < 1, 10, 1 )
   chartStep *= powStep
   maxpv     *= powStep
   minnv     *= powStep
   powVal    *= powStep
   maxpv     := maxpv + ( iif( (   maxpv % chartStep ) != 0, ( chartStep - (   maxpv % chartStep ) ), 0 ) ) / powVal
   minnv     := minnv - ( iif( ( - minnv % chartStep ) != 0, ( chartStep - ( - minnv % chartStep ) ), 0 ) ) / powVal
   maxVal    := maxpv - minnv

   maxHeight := rc:height() - nFHeight
   valstep := maxHeight / ( maxVal / chartStep )

   IF ( valstep < nFHeight )
      chartStep *= ( ( ( nFHeight / valstep ) ) + 1 )
      valstep := ( ( ( nFHeight / valstep ) ) + 1 ) * valstep
   ENDIF

   nPlanes := maxVal / chartStep + 1 + iif( maxVal % chartStep != 0, 1, 0 )

   IF m_showLabels
      maxLabelWidth := 0
      FOR i := 1 TO nPlanes
         nLabelWidth := qFMetrix:width( hb_ntos( Int( ( maxVal * i - chartStep * i ) / powVal ) ) )
         IF maxLabelWidth < nLabelWidth
            maxLabelWidth := nLabelWidth
         ENDIF
      NEXT
      y := 0
      FOR i := 1 TO nPlanes
         qPainter:drawText( QRectF( rc:x(), rc:y() + y, maxLabelWidth, nFHeight ), ;
                         Qt_AlignRight + Qt_AlignVCenter, hb_ntos( Int( ( maxpv - chartStep * ( i - 1 ) ) / powVal ) ) )
         y += valstep
      NEXT

      qPainter:drawLine( rc:x() + maxLabelWidth + 1 / UNIT / 4, rc:y(), rc:x() + maxLabelWidth + 1 / UNIT / 4, rc:y() + qRect:height() )
      rc := rc:adjusted( maxLabelWidth + 1 / UNIT / 4, 0, 0, 0 )
   ENDIF

   IF m_showGrid
      y :=  nFHeight / 2
      FOR i := 1 TO nPlanes
         qPainter:drawLine( rc:x(), rc:y() + y, rc:x() + rc:width(), rc:y() + y )
         y += valstep
      NEXT
   ENDIF

   rc := rc:adjusted( 0,  nFHeight / 2, 0, 0 )
   x  := m_barsIdentation
   barWidth := ( rc:width() - m_barsIdentation * ( Len( ::xData ) + 1 ) ) / len( ::xData )
   py := maxHeight / maxVal

   FOR EACH cv IN ::xData
      lg := QLinearGradient( QPointF( x + barWidth / 2, 0.0 ), QPointF( x + barWidth, 0.0 ) )
      //
      lg:setSpread( QGradient_ReflectSpread )
      lg:setColorAt( 0, cv[ 3 ] )
      lg:setColorAt( 1, QColor( cv[ 3 ]:red() * nColorFactor, cv[ 3 ]:green() * nColorFactor, cv[ 3 ]:blue() * nColorFactor, cv[ 3 ]:alpha() ) )
      //
      br := QBrush( lg )
      //
      qPainter:fillRect( QRectF( rc:x() + x, rc:y() + py * maxpv - py * cv[ 2 ] * powVal, barWidth, py * cv[ 2 ] * powVal ), br )

      IF m_showLabels
         qPainter:drawText( QRectF( rc:x() + x - m_barsIdentation / 2, rc:y() + py * maxpv - iif( cv[ 2 ] >= 0, nFHeight, 0 ), ;
                                      barWidth + m_barsIdentation, nFHeight ), Qt_AlignCenter, hb_ntos( Int( cv[ 2 ] ) ) )
      ENDIF
      x += barWidth + m_barsIdentation
   NEXT

#if 0  /* Legend */
   qPainter:fillRect( qRect, ::brush() )
   qPainter:drawRect( qRect )
   qPainter:translate( qRect:topLeft() )
   qreal y := 1 / UNIT
   qreal vstep := ( qRect:height() - y - 1 / UNIT * val:size() ) / Len( ::aData )
   FOR EACH cv IN ::aData
   {
      qPainter:fillRect( QRectF( 1 / UNIT / 2, y, m_legendColorqRectWidth, vstep ), QBrush( cv[ 3 ] ) )
      qPainter:drawText( QRectF( 1 / UNIT + m_legendColorqRectWidth, y, qRect:width() - ( 1 / UNIT + m_legendColorqRectWidth ), vstep ),
                                                                            Qt_AlignVCenter + Qt_AlignLeft, cv[ 1 ] )
      y += vstep + 1 / UNIT
   }
#endif

   RETURN Self

/*----------------------------------------------------------------------*/
