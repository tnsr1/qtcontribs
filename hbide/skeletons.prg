/*
 * $Id: skeletons.prg 411 2015-06-17 00:43:27Z bedipritpal $
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
 *                               18Mar2010
 */
/*----------------------------------------------------------------------*/

#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"


#define __buttonNew_clicked__                     2001
#define __buttonRename_clicked__                  2002
#define __buttonDelete_clicked__                  2003
#define __buttonClear_clicked__                   2004
#define __buttonGetSel_clicked__                  2005
#define __buttonUpdate_clicked__                  2006
#define __listNames_itemSelectionChanged__        2007
#define __oTree_itemSelected__                    2008
#define __oTree_contextMenu__                     2009


CLASS IdeSkeletons INHERIT IdeObject

   DATA   oRoot
   DATA   oTree
   DATA   nPosCursor
   DATA   aItems                                  INIT {}
   DATA   aMetas                                  INIT { { "", NIL } }

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD show()
   METHOD execEvent( nEvent, p )
   METHOD postSkeleton( cSkeleton )
   METHOD selectByMenuAndPostText( qEdit )
   METHOD getText( cSkeleton )
   METHOD parseText( cText )
   METHOD parseMeta( cMeta )
   METHOD postText( qEdit, cText )
   METHOD showTree()
   METHOD clearTree()
   METHOD updateTree()
   METHOD save( cName, cText )
   METHOD saveAs( cText )
   METHOD delete( cName )
   METHOD rename( cName )
   METHOD refreshList()

   ENDCLASS


METHOD IdeSkeletons:new( oIde )

   ::oIde := oIde

   RETURN Self


METHOD IdeSkeletons:create( oIde )

   DEFAULT oIde TO ::oIde
   ::oIde := oIde

   RETURN Self


METHOD IdeSkeletons:destroy()

   IF !empty( ::oUI )
      ::oUI:buttonNew   :disconnect( "clicked()" )
      ::oUI:buttonRename:disconnect( "clicked()" )
      ::oUI:buttonDelete:disconnect( "clicked()" )
      ::oUI:buttonClear :disconnect( "clicked()" )
      ::oUI:buttonGetSel:disconnect( "clicked()" )
      ::oUI:buttonUpdate:disconnect( "clicked()" )
      ::oUI:listNames   :disconnect( "itemSelectionChanged()" )

      ::oUI:destroy()
   ENDIF

   ::aItems := {}
   ::oTree  := NIL

   RETURN Self


METHOD IdeSkeletons:show()

   IF empty( ::oUI )
      ::oUI := hbide_getUI( "skeletons" )

      ::oSkeltnDock:oWidget:setWidget( ::oUI:oWidget )

      ::oUI:buttonNew   :connect( "clicked()"             , {|| ::execEvent( __buttonNew_clicked__              ) } )
      ::oUI:buttonRename:connect( "clicked()"             , {|| ::execEvent( __buttonRename_clicked__           ) } )
      ::oUI:buttonDelete:connect( "clicked()"             , {|| ::execEvent( __buttonDelete_clicked__           ) } )
      ::oUI:buttonClear :connect( "clicked()"             , {|| ::execEvent( __buttonClear_clicked__            ) } )
      ::oUI:buttonGetSel:connect( "clicked()"             , {|| ::execEvent( __buttonGetSel_clicked__           ) } )
      ::oUI:buttonUpdate:connect( "clicked()"             , {|| ::execEvent( __buttonUpdate_clicked__           ) } )
      ::oUI:listNames   :connect( "itemSelectionChanged()", {|| ::execEvent( __listNames_itemSelectionChanged__ ) } )

      //::oUI:editCode:setFontFamily( "Courier New" )
      //::oUI:editCode:setFontPointSize( 10 )

      ::oUI:editCode:setFont( ::oFont:oWidget )
   ENDIF
   ::refreshList()

   RETURN Self


METHOD IdeSkeletons:execEvent( nEvent, p )
   LOCAL cName, qItem, cCode, n, cOpt
   LOCAL aPops := {}

   HB_SYMBOL_UNUSED( p )

   IF ::lQuitting
      RETURN Self
   ENDIF

   SWITCH nEvent

   CASE __buttonNew_clicked__
      IF !empty( cName := hbide_fetchAString( ::oUI:listNames, "", "Name", "New Skeleton" ) )
         ::oUI:listNames:addItem( cName )
         aadd( ::oIde:aSkltns, { cName, "" } )
         ::oUI:listNames:setCurrentRow( Len( ::aSkltns ) - 1 )
      ENDIF
      EXIT

   CASE __buttonRename_clicked__
      qItem := ::oUI:listNames:currentItem()
      qItem:setText( ::rename( qItem:text() ) )
      EXIT

   CASE __buttonDelete_clicked__
      qItem := ::oUI:listNames:currentItem()
      ::delete( qItem:text() )
      EXIT

   CASE __buttonClear_clicked__
      ::oUI:editCode:clear()
      EXIT

   CASE __buttonGetSel_clicked__
      IF !empty( cCode := ::oEM:getSelectedText() )
         // TODO: Format cCode
         ::oUI:editCode:setPlainText( cCode )
      ENDIF
      EXIT

   CASE __buttonUpdate_clicked__
      qItem := ::oUI:listNames:currentItem()
      ::save( qItem:text(), ::oUI:editCode:toPlainText() )
      EXIT

   CASE __listNames_itemSelectionChanged__
      qItem := ::oUI:listNames:currentItem()
      cName := qItem:text()
      IF ( n := ascan( ::aSkltns, {|e_| e_[ 1 ] == cName } ) ) > 0
         ::oUI:editCode:setPlainText( ::aSkltns[ n, 2 ] )
      ENDIF
      EXIT

   CASE __oTree_contextMenu__
      IF p[ 3 ]:caption == "Skeletons"
         // Root node - nothing to do.
      ELSE
         aadd( aPops, { 'Delete', {|| NIL } } )
         aadd( aPops, { ""      , {|| NIL } } )
         aadd( aPops, { 'Rename', {|| NIL } } )

         IF !empty( cOpt := hbide_ExecPopup( aPops, p[ 1 ], ::oSkltnsTreeDock:oWidget ) )
            IF     cOpt == "Delete"
               ::delete( p[ 3 ]:caption )
            ELSEIF cOpt == "Rename"
               ::rename( p[ 3 ]:caption )
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE __oTree_itemSelected__
      ::oIde:manageFocusInEditor()
      ::postSkeleton( p:caption )
      EXIT

   ENDSWITCH

   RETURN NIL


METHOD IdeSkeletons:refreshList()

   ::oUI:listNames:clear()
   aeval( ::aSkltns, {|e_| ::oUI:listNames:addItem( e_[ 1 ] ) } )

   RETURN Self


METHOD IdeSkeletons:rename( cName )
   LOCAL n, cNewName

   IF ( n := ascan( ::aSkltns, {|e_| e_[ 1 ] == cName } ) ) > 0
      cNewName := hbide_fetchAString( ::oDlg:oWidget, cName, "Name", "Change Skeleton's Name" )
      IF !empty( cNewName ) .AND. !( cNewName == cName )
         ::aSkltns[ n, 1 ] := cNewName
         ::updateTree()
         hbide_saveSkltns( ::oIde )
      ENDIF
   ENDIF
   RETURN iif( empty( cNewName ), cName, cNewName )


METHOD IdeSkeletons:delete( cName )
   LOCAL n

   IF ( n := ascan( ::aSkltns, {|e_| e_[ 1 ] == cName } ) ) > 0
      hb_adel( ::aSkltns, n, .t. )
      ::updateTree()
      hbide_saveSkltns( ::oIde )
      IF !empty( ::oUI )
         ::refreshList()
      ENDIF
   ENDIF

   RETURN Self


METHOD IdeSkeletons:save( cName, cText )
   LOCAL n

   n := ascan( ::aSkltns, {|e_| e_[ 1 ] == cName } )
   IF n > 0
      ::aSkltns[ n, 2 ] := cText
   ELSE
      aadd( ::aSkltns, { cName, cText } )
   ENDIF
   ::updateTree()
   hbide_saveSkltns( ::oIde )

   RETURN Self


METHOD IdeSkeletons:saveAs( cText )
   LOCAL cName

   cName := hbide_fetchAString( ::oDlg, "", "Skeleton's Name" )
   IF !empty( cName )
      ::save( cName, cText )
   ENDIF

   RETURN Self


METHOD IdeSkeletons:postSkeleton( cSkeleton )
   LOCAL oEdit, cText := ::getText( cSkeleton )

   IF !empty( cText )
      IF !empty( oEdit := ::oEM:getEditObjectCurrent() )
         ::postText( oEdit:qEdit, cText )
      ENDIF
   ENDIF

   RETURN Self


METHOD IdeSkeletons:selectByMenuAndPostText( qEdit )
   LOCAL cText, qCursor, qRect, qMenu, qAct, a_, aAct := {}

   IF !empty( ::aSkltns )
      qCursor := qEdit:textCursor()

      /* Look for if a macro is executed */
      qCursor:select( QTextCursor_WordUnderCursor )
      cText := qCursor:selectedText()
      IF !empty( cText ) .AND. ascan( ::aSkltns, {|e_| e_[ 1 ] == cText } ) > 0
         qCursor:insertText( "" )
         qEdit:setTextCursor( qCursor )
         ::postText( qEdit, ::getText( cText  ) )

      ELSE
         qRect := qEdit:cursorRect( qCursor )

         qMenu := QMenu( qEdit )
         FOR EACH a_ IN ::aSkltns
            aadd( aAct, qMenu:addAction( a_[ 1 ] ) )
         NEXT

         IF ! empty( qAct := qMenu:exec( qEdit:mapToGlobal( QPoint( qRect:x(), qRect:y() ) ) ) )
            IF !empty( cText := ::getText( qAct:text() ) )
               ::postText( qEdit, cText )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN Self


METHOD IdeSkeletons:parseMeta( cMeta )
   LOCAL xVal, cData, n, cKey, cVal, nMeta

   IF hbide_parseKeyValPair( cMeta, @cKey, @cVal )
      cMeta := cVal
      cKey := upper( cKey )
      IF ( nMeta := ascan( ::aMetas, {|e_| e_[ 1 ] == cKey } ) ) == 0
         aadd( ::aMetas, { cKey, "" } )
         nMeta := Len( ::aMetas )
      ENDIF
   ENDIF

   IF ( n := at( ":", cMeta ) ) > 0
      cMeta := substr( cMeta, 1, n - 1 )
      cData := substr( cMeta, n + 1 )
   ENDIF
   cMeta := upper( cMeta )

   SWITCH cMeta

   CASE "CUR"
      xVal := 0
      EXIT

   CASE "PROMPT"
      DEFAULT cData TO "A string value ?"
      xVal := hbide_fetchAString( ::oDlg:oWidget, "", cData, "Fetch a skeleton request" )
      IF !empty( xVal ) .AND. !empty( nMeta )
         ::aMetas[ nMeta, 2 ] := xVal
      ENDIF
      EXIT

   OTHERWISE
      IF ( nMeta := ascan( ::aMetas, {|e_| e_[ 1 ] == cMeta } ) ) > 0
         xVal := ::aMetas[ nMeta, 2 ]
      ELSE
         xVal := cMeta
      ENDIF

   ENDSWITCH

   RETURN xVal


METHOD IdeSkeletons:parseText( cText )
   LOCAL n, n1, cTkn, xVal

   n := 0
   DO WHILE .t.
      IF ( n := hb_at( "<-", cText, n ) ) > 0
         IF ( n1 := hb_at( ">", cText, n ) ) > 0
            IF !empty( cTkn := substr( cText, n + 2, n1 - n - 2 ) )

               xVal := ::parseMeta( hbide_evalAsString( cTkn ) )

               IF valtype( xVal ) == "C"
                  cText := substr( cText, 1, n - 1 ) + xVal + substr( cText, n1 + 1 )

               ELSEIF valtype( xVal ) == "N"
                  cText := substr( cText, 1, n - 1 ) + "" + substr( cText, n1 + 1 )
                  ::nPosCursor := n

               ENDIF
            ENDIF
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO

   RETURN cText


METHOD IdeSkeletons:getText( cSkeleton )
   LOCAL n, cText := ""

   IF ( n := ascan( ::aSkltns, {|e_| e_[ 1 ] == cSkeleton } ) ) > 0
      cText := ::aSkltns[ n, 2 ]
   ENDIF

   RETURN cText


METHOD IdeSkeletons:postText( qEdit, cText )
   LOCAL s, a_, nCol, nPos, nRowCur, nColCur, n
   LOCAL qCursor := qEdit:textCursor()

   ::nPosCursor := NIL
   ::aMetas     := { { "", "" } }

   nPos := qCursor:position()
   nCol := qCursor:columnNumber()

   a_:= hbide_memoToArray( cText )
   FOR EACH s IN a_
      IF ( n := s:__enumIndex() ) > 0
         s := iif( n > 1, space( nCol ), "" ) + ::parseText( s )
         IF valtype( ::nPosCursor ) == "N"
            IF empty( nRowCur )
               nRowCur := n
               nColCur := ::nPosCursor
            ENDIF
         ENDIF
      ENDIF
   NEXT

   qCursor:insertText( hbide_arrayToMemoEx( a_ ) )
   qCursor:setPosition( nPos )
   IF !empty( nRowCur )
      qCursor:movePosition( QTextCursor_Down, QTextCursor_MoveAnchor, nRowCur -1 )
   ENDIF
   IF !empty( nColCur )
      qCursor:movePosition( QTextCursor_StartOfBlock )
      qCursor:movePosition( QTextCursor_Right, QTextCursor_MoveAnchor, nCol + nColCur - 1 )
   ENDIF
   qEdit:setTextCursor( qCursor )

   RETURN Self


METHOD IdeSkeletons:showTree()

   IF empty( ::oTree )
      ::oTree := XbpTreeView():new()
      ::oTree:hasLines   := .T.
      ::oTree:hasButtons := .T.
      ::oTree:create( ::oSkltnsTreeDock, , { 0,0 }, { 10,10 }, , .t. )

      ::oTree:oWidget:setMinimumWidth( 100 )
      ::oTree:oWidget:setSizePolicy( QSizePolicy_MinimumExpanding, QSizePolicy_Preferred )
      ::oTree:oWidget:setIconSize( QSize( 12,12 ) )
      ::oTree:oWidget:setIndentation( 12 )

      ::oTree:itemSelected  := {|oItem         | ::execEvent( __oTree_itemSelected__, oItem ) }
      ::oTree:hbContextMenu := {|mp1, mp2, oXbp| ::execEvent( __oTree_contextMenu__ , { mp1, mp2, oXbp } ) }

      ::oRoot := ::oTree:rootItem:addItem( "Skeletons" )

      ::updateTree()

      ::oRoot:expand( .t. )

      ::oSkltnsTreeDock:oWidget:setWidget( ::oTree:oWidget )
   ENDIF

   ::oTree:oWidget:setStyleSheet( GetStyleSheet( "QTreeWidgetHB", ::nAnimantionMode ) )

   RETURN Self


METHOD IdeSkeletons:updateTree()
   LOCAL oItem, a_

   ::clearTree()

   FOR EACH a_ IN ::aSkltns
      oItem := ::oRoot:addItem( a_[ 1 ] )
      oItem:tooltipText := a_[ 2 ]
      aadd( ::aItems, oItem )
   NEXT

   ::oRoot:oWidget:sortChildren( 0, Qt_AscendingOrder )

   RETURN Self


METHOD IdeSkeletons:clearTree()
   LOCAL oItem

   FOR EACH oItem IN ::aItems
      ::oRoot:delItem( oItem )
      oItem := NIL
   NEXT
   ::aItems := {}

   RETURN Self

