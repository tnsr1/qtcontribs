/*
 * $Id: listbox.prg 34 2012-10-13 21:57:41Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * Source file for the Wvg*Classes
 *
 * Copyright 2008-2010 Pritpal Bedi <bedipritpal@hotmail.com>
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
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*
 *                                EkOnkar
 *                          ( The LORD is ONE )
 *
 *                  Xbase++ xbpTreeView compatible Class
 *
 *                             Pritpal Bedi
 *                               26Nov2008
 */
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/

#include "hbclass.ch"
#include "common.ch"

#include "xbp.ch"
#include "appevent.ch"

/*----------------------------------------------------------------------*/

CLASS XbpListBox  INHERIT  XbpWindow, DataRef

   DATA     adjustHeight                          INIT .F.
   DATA     horizScroll                           INIT .F.
   DATA     markMode                              INIT XBPLISTBOX_MM_SINGLE
   DATA     multiColumn                           INIT .F.
   DATA     vertScroll                            INIT .T.
   DATA     drawMode                              INIT XBP_DRAW_NORMAL

   DATA     oStrList
   DATA     oStrModel
   DATA     aItems                                INIT {}

   DATA     nOldIndex                             INIT 0

   METHOD   init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   destroy()
   METHOD   handleEvent( nEvent, mp1, mp2 )
   METHOD   execSlot( cSlot, p )

   METHOD   setStyle()

   METHOD   setItemsHeight( nPixel )              VIRTUAL
   METHOD   getItemHeight()                       VIRTUAL
   METHOD   getTopItem()                          VIRTUAL
   METHOD   getVisibleItems()                     VIRTUAL
   METHOD   setTopItem( nIndex )                  VIRTUAL

   METHOD   numItems()                            INLINE  len( ::aItems )
   METHOD   addItem( cItem )
   METHOD   clear( lConnect )
   METHOD   delItem( nIndex )
   METHOD   getItem( nIndex )
   METHOD   insItem( nIndex, cItem )
   METHOD   setItem( nIndex, cItem )
   METHOD   setIcon( nIndex, oIcon )                               /* Harbour Extension */
   METHOD   setVisible( cItem )

   METHOD   getTabstops()                         VIRTUAL
   METHOD   setColumnWidth()                      VIRTUAL
   METHOD   setTabstops()                         VIRTUAL

   METHOD   getItemIndex( pItm )
   METHOD   toggleSelected( nIndex )
   METHOD   connect()
   METHOD   disConnect()
   METHOD   setItemColorFG( nIndex, aRGB )


   DATA     sl_hScroll
   DATA     sl_vScroll
   DATA     sl_itemMarked
   DATA     sl_itemSelected
   DATA     sl_drawItem
   DATA     sl_measureItem
   DATA     nCurSelected                          INIT   0

   METHOD   getCurItem()                          INLINE ::getItem( ::nCurSelected )

   METHOD   itemMarked( ... )                     SETGET
   METHOD   itemSelected( ... )                   SETGET
   METHOD   drawItem( ... )                       SETGET
   METHOD   measureItem( ... )                    SETGET
   METHOD   hScroll( ... )                        SETGET
   METHOD   vScroll( ... )                        SETGET

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD XbpListBox:init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::xbpWindow:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   #if 0
   IF ::multiColumn
      ::style += LBS_MULTICOLUMN
   ENDIF
   #endif

   ::oWidget  := QListWidget( ::pParent )
   ::oWidget:setMouseTracking( .t. )
   IF ::markMode == XBPLISTBOX_MM_MULTIPLE
      ::oWidget:setSelectionMode( QAbstractItemView_MultiSelection )
   ENDIF
   ::oWidget:setEditTriggers( QAbstractItemView_NoEditTriggers )
   IF ! ::horizScroll
      ::oWidget:setHorizontalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ENDIF
   IF ! ::vertScroll
      ::oWidget:setVerticalScrollBarPolicy( Qt_ScrollBarAlwaysOff )
   ENDIF
   ::oWidget:setContextMenuPolicy( Qt_CustomContextMenu )

   ::connect()
   ::setPosAndSize()
   IF ::visible
      ::show()
   ENDIF
   ::oParent:AddChild( SELF )
   ::postCreate()

   ::sl_editBuffer := {}

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:connect()

   ::oWidget:connect( "currentRowChanged(int)"                               , {|p,p1| ::execSlot( "currentRowChanged(int)"                               , p, p1 ) } )
   ::oWidget:connect( "itemClicked(QListWidgetItem*)"                        , {|p,p1| ::execSlot( "itemClicked(QListWidgetItem*)"                        , p, p1 ) } )
   ::oWidget:connect( "itemDoubleClicked(QListWidgetItem*)"                  , {|p,p1| ::execSlot( "itemDoubleClicked(QListWidgetItem*)"                  , p, p1 ) } )
   ::oWidget:connect( "itemEntered(QListWidgetItem*)"                        , {|p,p1| ::execSlot( "itemEntered(QListWidgetItem*)"                        , p, p1 ) } )
   ::oWidget:connect( "customContextMenuRequested(QPoint)"                   , {|p1  | ::execSlot( "customContextMenuRequested(QPoint)"                   , p1    ) } )
/*
   ::oWidget:connect( "currentItemChanged(QListWidgetItem*,QListWidgetItem*)", {|p,p1| ::execSlot( "currentItemChanged(QListWidgetItem*,QListWidgetItem*)", p, p1 ) } )
   ::oWidget:connect( "currentTextChanged(QString)"                          , {|p,p1| ::execSlot( "currentTextChanged(QString)"                          , p, p1 ) } )
   ::oWidget:connect( "itemActivated(QListWidgetItem*)"                      , {|p,p1| ::execSlot( "itemActivated(QListWidgetItem*)"                      , p, p1 ) } )
   ::oWidget:connect( "itemChanged(QListWidgetItem*)"                        , {|p,p1| ::execSlot( "itemChanged(QListWidgetItem*)"                        , p, p1 ) } )
   ::oWidget:connect( "itemPressed(QListWidgetItem*)"                        , {|p,p1| ::execSlot( "itemPressed(QListWidgetItem*)"                        , p, p1 ) } )
   ::oWidget:connect( "itemSelectionChanged()"                               , {|p,p1| ::execSlot( "itemSelectionChanged()"                               , p, p1 ) } )
*/
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:disConnect()

   ::oWidget:disConnect( "currentRowChanged(int)"                                )
   ::oWidget:disConnect( "itemClicked(QListWidgetItem*)"                         )
   ::oWidget:disConnect( "itemDoubleClicked(QListWidgetItem*)"                   )
   ::oWidget:disConnect( "itemEntered(QListWidgetItem*)"                         )
   ::oWidget:disconnect( "customContextMenuRequested(QPoint)"                    )

/*
   ::oWidget:disConnect( "currentItemChanged(QListWidgetItem*,QListWidgetItem*)" )
   ::oWidget:disConnect( "currentTextChanged(QString)"                           )
   ::oWidget:disConnect( "itemActivated(QListWidgetItem*)"                       )
   ::oWidget:disConnect( "itemChanged(QListWidgetItem*)"                         )
   ::oWidget:disConnect( "itemPressed(QListWidgetItem*)"                         )
   ::oWidget:disConnect( "itemSelectionChanged()"                                )
*/

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:toggleSelected( nIndex )
   LOCAL n

   IF ::markMode == XBPLISTBOX_MM_MULTIPLE
      IF ( n := ascan( ::sl_editBuffer, nIndex ) ) > 0
         hb_adel( ::sl_editBuffer, n, .t. )
      ELSE
         aadd( ::sl_editBuffer, nIndex )
      ENDIF
   ELSE
      ::sl_editBuffer := nIndex
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:getItemIndex( pItm )

   RETURN ascan( ::aItems, {|o| hbqt_IsEqual( o, pItm ) } )

/*----------------------------------------------------------------------*/

METHOD XbpListBox:execSlot( cSlot, p )
   LOCAL qPos, qItm, nIndex, n, qPt

   IF cSlot == "customContextMenuRequested(QPoint)"
      IF HB_ISBLOCK( ::hb_contextMenu )
         qPos := p
         IF ! empty( qItm := ::oWidget:itemAt( qPos ) )
            IF ( n := ascan( ::aItems, {|o| hbqt_IsEqual( o, qItm ) } ) ) > 0
               qPt := ::oWidget:mapToGlobal( QPoint( p ) )
               eval( ::hb_contextMenu, { qPt:x(), qPt:y() }, NIL, ::aItems[ n ] )
            ENDIF
         ENDIF
      ENDIF
      RETURN Self
   ENDIF

   IF HB_ISOBJECT( p )
      IF ( nIndex := ::getItemIndex( p ) ) > 0
         qItm := ::aItems[ nIndex ]
      ENDIF
      IF empty( qItm )
         RETURN Self
      ENDIF
   ENDIF

   SWITCH cSlot
   CASE "currentRowChanged(int)"
      ::nCurSelected := p + 1
      EXIT
   CASE "itemClicked(QListWidgetItem*)"
      ::toggleSelected( nIndex )
      ::itemMarked()
      EXIT
   CASE "itemDoubleClicked(QListWidgetItem*)"
      ::itemSelected()
      EXIT
   CASE "itemEntered(QListWidgetItem*)"
      ::oWidget:setToolTip( qItm:text() )
      EXIT
   #if 0
   CASE "currentItemChanged(QListWidgetItem*,QListWidgetItem*)"
      EXIT
   CASE "currentTextChanged(QString)"
      EXIT
   CASE "itemActivated(QListWidgetItem*)"
      EXIT
   CASE "itemChanged(QListWidgetItem*)"
      EXIT
   CASE "itemPressed(QListWidgetItem*)"
      EXIT
   CASE "itemSelectionChanged()"
      EXIT
   #endif
   ENDSWITCH

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:handleEvent( nEvent, mp1, mp2 )

   HB_SYMBOL_UNUSED( nEvent )
   HB_SYMBOL_UNUSED( mp1    )
   HB_SYMBOL_UNUSED( mp2    )

   RETURN HBXBP_EVENT_UNHANDLED

/*----------------------------------------------------------------------*/

METHOD XbpListBox:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   ::Initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:destroy()

   ::clear( .f. )
   ::xbpWindow:destroy()

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD XbpListBox:clear( lConnect )
   LOCAL qItm

   DEFAULT lConnect TO .t.

   #if 0
   ::disConnect()
   #endif

   FOR EACH qItm IN ::aItems
      qItm := NIL
   NEXT
   ::aItems := {}
   IF ! empty( ::oWidget )
      IF lConnect
         ::oWidget:clear()
      ENDIF
   ENDIF
   #if 0
   IF lConnect
      ::connect()
   ENDIF
   #endif
   RETURN .t.

/*----------------------------------------------------------------------*/

METHOD XbpListBox:addItem( cItem )
   LOCAL qItm := QListWidgetItem()

   qItm:setText( cItem )
   ::oWidget:addItem( qItm )
   aadd( ::aItems, qItm )

   RETURN len( ::aItems )

/*----------------------------------------------------------------------*/

METHOD XbpListBox:delItem( nIndex )

   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems )
      ::aItems[ nIndex ] := NIL
      hb_adel( ::aItems, nIndex, .t. )
   ENDIF

   RETURN len( ::aItems )

/*----------------------------------------------------------------------*/

METHOD XbpListBox:getItem( nIndex )

   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems )
      RETURN ::aItems[ nIndex ]:text()
   ENDIF

   RETURN ""

/*----------------------------------------------------------------------*/

METHOD XbpListBox:insItem( nIndex, cItem )
   LOCAL qItm := QListWidgetItem()

   qItm:setText( cItem )

   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems )
      ::oWidget:insertItem( nIndex - 1, qItm )
      hb_aIns( ::aItems, qItm, .t. )
   ELSE
      ::oWidget:insertItem( len( ::aItems ) - 1, qItm )
      aadd( ::aItems, qItm )
   ENDIF

   RETURN len( ::aItems )

/*----------------------------------------------------------------------*/

METHOD XbpListBox:setItem( nIndex, cItem )
   LOCAL cText := ""

   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems )
      cText := ::aItems[ nIndex ]:text()
      ::aItems[ nIndex ]:setText( cItem )
   ENDIF

   RETURN cText

/*----------------------------------------------------------------------*/
/* Harbour Extention - Xbase++ does not have such implementation FOR list boxes */
METHOD XbpListBox:setIcon( nIndex, oIcon )
   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems ) .AND. HB_ISOBJECT( oIcon )
      ::aItems[ nIndex ]:setIcon( oIcon )
      RETURN .T.
   ENDIF
   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD XbpListBox:setVisible( cItem )
   LOCAL nIndex

   IF ( nIndex := ascan( ::aItems, {|o| o:text() == cItem } ) ) > 0
      ::oWidget:scrollToItem( ::aItems[ nIndex ] )
   ENDIF

   RETURN Self

/*------------------------------------------------------------------------*/

METHOD XbpListBox:setItemColorFG( nIndex, aRGB )

   IF HB_ISNUMERIC( nIndex ) .AND. nIndex > 0 .AND. nIndex <= len( ::aItems )
      IF ::nOldIndex > 0  .AND. ::nOldIndex <= len( ::aItems )
         ::aItems[ ::nOldIndex ]:setForeGround( QBrush( QColor( 0,0,0 ) ) )
      ENDIF
      ::aItems[ nIndex ]:setForeGround( QBrush( QColor( aRGB[ 1 ], aRGB[ 2 ], aRGB[ 3 ] ) ) )
      ::nOldIndex := nIndex

   ELSEIF HB_ISSTRING( nIndex )
      IF ( nIndex := ascan( ::aItems, {|o| o:text() == nIndex } ) ) > 0
         IF ::nOldIndex > 0  .AND. ::nOldIndex <= len( ::aItems )
            ::aItems[ ::nOldIndex ]:setForeGround( QBrush( QColor( 0,0,0 ) ) )
         ENDIF
         ::aItems[ nIndex ]:setForeGround( QBrush( QColor( aRGB[ 1 ], aRGB[ 2 ], aRGB[ 3 ] ) ) )
         ::nOldIndex := nIndex
      ENDIF
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:itemMarked( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_itemMarked := a_[ 1 ]
   ELSEIF len( a_ ) >= 0 .AND. HB_ISBLOCK( ::sl_itemMarked )
      eval( ::sl_itemMarked, NIL, NIL, Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:itemSelected( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_itemSelected := a_[ 1 ]
   ELSEIF len( a_ ) >= 0 .AND. HB_ISBLOCK( ::sl_itemSelected )
      eval( ::sl_itemSelected, NIL, NIL, Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:drawItem( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_xbePDrawItem := a_[ 1 ]
   ELSEIF len( a_ ) >= 2 .AND. HB_ISBLOCK( ::sl_xbePDrawItem )
      eval( ::sl_xbePDrawItem, a_[ 1 ], a_[ 2 ], Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:measureItem( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_measureItem := a_[ 1 ]
   ELSEIF len( a_ ) >= 2 .AND. HB_ISBLOCK( ::sl_measureItem )
      eval( ::sl_measureItem, a_[ 1 ], a_[ 2 ], Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:hScroll( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_hScroll := a_[ 1 ]
   ELSEIF len( a_ ) >= 0 .AND. HB_ISBLOCK( ::sl_hScroll )
      eval( ::sl_hScroll, NIL, NIL, Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:vScroll( ... )
   LOCAL a_:= hb_aParams()
   IF len( a_ ) == 1 .AND. HB_ISBLOCK( a_[ 1 ] )
      ::sl_vScroll := a_[ 1 ]
   ELSEIF len( a_ ) >= 0 .AND. HB_ISBLOCK( ::sl_vScroll )
      eval( ::sl_vScroll, NIL, NIL, Self )
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpListBox:setStyle()
   LOCAL s, txt_:={}

   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView {                                                                                 ' )
   aadd( txt_, '     alternate-background-color: yellow;                                                     ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView {                                                                                 ' )
   aadd( txt_, '     show-decoration-selected: 1; /* make the selection span the entire width of the view */ ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView::item:alternate {                                                                 ' )
   aadd( txt_, '     background: #EEEEEE;                                                                    ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView::item:selected {                                                                  ' )
   aadd( txt_, '     border: 1px solid #6a6ea9;                                                              ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView::item:selected:!active {                                                          ' )
   aadd( txt_, '     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,                                 ' )
   aadd( txt_, '                                 stop: 0 #ABAFE5, stop: 1 #8588B2);                          ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView::item:selected:active {                                                           ' )
   aadd( txt_, '     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,                                 ' )
   aadd( txt_, '                                 stop: 0 #6a6ea9, stop: 1 #888dd9);                          ' )
   aadd( txt_, ' }                                                                                           ' )
   aadd( txt_, '                                                                                             ' )
   aadd( txt_, ' QListView::item:hover {                                                                     ' )
   aadd( txt_, '     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,                                 ' )
   aadd( txt_, '                                 stop: 0 #FAFBFE, stop: 1 #DCDEF1);                          ' )
   aadd( txt_, '}                                                                                            ' )
   aadd( txt_, '                                                                                             ' )

   s := ""
   aeval( txt_, {|e| s += e + chr( 13 )+chr( 10 ) } )

   ::oWidget:setStyleSheet( s )

   RETURN self

/*----------------------------------------------------------------------*/
