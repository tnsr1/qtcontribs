               /*
 * $Id: scripts.prg 471 2019-04-04 23:42:20Z bedipritpal $
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2013-2016 Pritpal Bedi <bedipritpal@hotmail.com>
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
 *                              17Nov2016
 */
/*----------------------------------------------------------------------*/

#include "hbclass.ch"
#include "common.ch"
#include "inkey.ch"
#include "fileio.ch"
#include "hbgtinfo.ch"
#include "hbhrb.ch"
#include "hbqtgui.ch"

#if defined( __PLATFORM__WINDOWS )
REQUEST HB_GT_WVG
REQUEST HB_GT_WIN
REQUEST HB_GT_WVT
#else
REQUEST HB_GT_TRM
#endif

#define __btnAddGroupClicked__                    2005
#define __treeScriptsDoubleClicked__              2006
#define __treeScriptsContextMenuRequested__       2007
#define __btnSaveViewClicked__                    2008
#define __btnRestViewClicked__                    2009


FUNCTION HbQtSetScript( oHbQtScripts )
   STATIC s_oHbQtScripts
   LOCAL l_oHbQtScripts := s_oHbQtScripts
   IF HB_ISOBJECT( oHbQtScripts ) .AND. __objGetClsName( oHbQtScripts ) == "HBQTSCRIPTS"
      s_oHbQtScripts := oHbQtScripts
   ENDIF
   RETURN l_oHbQtScripts


CLASS HbQtScripts

   DATA   oWidget
   DATA   oUI
   DATA   oParent
   DATA   oHbQtEditor
   DATA   cCurScriptName                          INIT "new..."
   DATA   cLastPath                               INIT hb_DirBase()
   DATA   cScriptFile                             INIT "..."

   DATA   oTree
   DATA   hScripts                                INIT {=>}
   DATA   oRootNode

   ACCESS widget()                                INLINE ::oUI:widget()

   METHOD init( oParent )
   METHOD create( oParent )
   METHOD execEvent( nEvent, p1, p2 )

   METHOD newScript()
   METHOD runScript( nMode )
   METHOD loadScript( cScript )
   METHOD saveScript()

   METHOD populateScriptsTree( cScript )
   METHOD prepareScriptsTree()
   METHOD findScriptNode( cNodeText )
   METHOD removeScripts( oItem )
   METHOD getFile( cTitle, cFilter, lAllowMulti, lCreateNew )

   METHOD keyPressed( nKey, aModifiers )

   ENDCLASS


METHOD HbQtScripts:init( oParent )
   DEFAULT oParent TO ::oParent
   ::oParent := oParent

   hb_HCaseMatch( ::hScripts, .F. )
   RETURN Self


METHOD HbQtScripts:create( oParent )
   LOCAL oLay

   DEFAULT oParent TO ::oParent
   ::oParent := oParent

   WITH OBJECT oLay := QHBoxLayout()
      :setContentsMargins( 0,0,0,0 )
   ENDWITH

   ::oParent:setLayout( oLay )

   WITH OBJECT ::oUI := hbqtui_scripts()
      ::oTree := :treeScripts
      ::oRootNode := ::oTree:invisibleRootItem()

      oLay:addWidget( ::oUI:widget() )

      WITH OBJECT ::oHbQtEditor := HbQtEditor():new( ::oUI:hbqTextEdit, "Bare Minimum" )
         :create()
         :keyPressedBlock := {| nKey, aModifiers | ::keyPressed( nKey, aModifiers ) }
      ENDWITH
      ::newScript()

      :labelSourceName:setText( ::cCurScriptName )

      :btnRunScript:connect( "clicked()", {|| ::runScript( 0 ) } )
      :btnRunConsole:connect( "clicked()", {|| ::runScript( 1 ) } )
      :btnOpenClose:connect( "clicked()", {|| iif( ::oUI:frameLeft:isVisible(), ::oUI:frameLeft:hide(), ::oUI:frameLeft:show() ), ;
            ::oUI:btnOpenClose:setIcon( QIcon( __hbqtImage( iif( ::oUI:frameLeft:isVisible(), "left-close", "left-open" ) ) ) ), ;
            ::oUI:btnOpenClose:setToolTip( iif( ::oUI:frameLeft:isVisible(), "Close Left Pane", "Open Left Pane" ) ) } )
      :btnNewSource :connect( "clicked()", {|| ::newScript() } )
      :btnLoadSource:connect( "clicked()", {|| ::loadScript() } )
      :btnSaveSource:connect( "clicked()", {|| ::saveScript() } )
      :btnAddGroup  :connect( "clicked()", {|| ::execEvent( __btnAddGroupClicked__ ) } )
      :btnSaveView  :connect( "clicked()", {|| ::execEvent( __btnSaveViewClicked__ ) } )
      :btnRestView  :connect( "clicked()", {|| ::execEvent( __btnRestViewClicked__ ) } )

      :comboInc     :connect( "customContextMenuRequested(QPoint)", {|oPoint,v| v := __hbqtExecPopup( { "Delete This Entry" }, ;
                                                                                       ::oUI:comboInc:mapToGlobal( oPoint ) ), ;
                            iif( v == "Delete This Entry", ::oUI:comboInc:removeItem( ::oUI:comboInc:currentIndex() ), NIL ) } )

      :progressBar:hide()

      ::prepareScriptsTree()
   ENDWITH
   ::oWidget := ::oUI:widget()
   HbQtSetScript( Self )
   RETURN Self


METHOD HbQtScripts:keyPressed( nKey, aModifiers )
   IF nKey == Qt_Key_S .AND. aModifiers[ 2 ]
      ::saveScript()
      RETURN .T.
   ENDIF
   RETURN NIL


METHOD HbQtScripts:execEvent( nEvent, p1, p2 )
   LOCAL i, cGroup, oItem, xTmp, hTree, hNode, cHsv

   HB_SYMBOL_UNUSED( p2 )

   SWITCH nEvent
   CASE __btnAddGroupClicked__
      IF ! Empty( cGroup := HbQtFetchString( ::oTree, "", "Scripts Group" ) )
         ::oTree:addTopLevelItem( __treeWidgetItem( cGroup, "Group - " + cGroup, "group" ) )
      ENDIF
      EXIT
   CASE __treeScriptsContextMenuRequested__
      IF ! Empty( oItem := ::oTree:itemAt( p1 ) )
         IF ! Empty( xTmp := __hbqtExecPopup( { "Collapse Children", "Expand Children", "Delete" }, ::oTree:mapToGlobal( p1 ) ) )
            SWITCH xTmp
            CASE "Collapse Children" ; __hbqtTreeCollapseAll( oItem ) ; EXIT
            CASE "Expand Children"   ; __hbqtTreeExpandAll( oItem ) ; EXIT
            CASE "Delete"
               IF ! oItem:text( 0 ) == "Default"
                  IF HbQtAlert( { "Do you want to delete [ " + oItem:text( 0 ) + " ]", "and all its children?" }, { "No", "Yes" } ) == 2
                     ::removeScripts( oItem )
                  ENDIF
               ENDIF
               EXIT
            ENDSWITCH
         ENDIF
      ENDIF
      EXIT
   CASE __btnSaveViewClicked__
      cHsv := ::getFile( "Save this Scripts View", "Scripts View (*.hsv)", .F., .T. )
      IF ! Empty( cHsv )
         hTree := {=>}
         //
         hTree[ "es2"      ] := ::oUI:checkES2:isChecked()
         hTree[ "w3"       ] := ::oUI:checkW3:isChecked()
         hTree[ "switches" ] := ::oUI:editSwitches:text()
         xTmp := ""
         IF ::oUI:comboInc:count() > 0
            FOR i := 0 TO ::oUI:comboInc:count() - 1
               xTmp += AllTrim( ::oUI:comboInc:itemText( i ) ) + " "
            NEXT
            xTmp := AllTrim( xTmp )
         ENDIF
         hTree[ "includes" ] := xTmp
         hTree[ "items"    ] := {}

         FOR i := 0 TO ::oTree:topLevelItemCount() - 1
            __itemToJson( ::oTree:topLevelItem( i ), hTree[ "items" ] )
         NEXT

         hb_MemoWrit( cHsv, hb_jsonEncode( hTree ) )
      ENDIF
      EXIT
   CASE __btnRestViewClicked__
      cHsv := ::getFile( "Restore Scripts View From...", "Scripts View (*.hsv)", .F., .F. )
      IF ! Empty( cHsv )
         hb_jsonDecode( hb_MemoRead( cHsv ), @hTree )
         IF HB_ISHASH( hTree ) .AND. ! Empty( hTree )
            ::cScriptFile := cHsv
            ::oTree:setHeaderLabel( " " + ::cScriptFile )
            ::oTree:clear()
            ::newScript()
            WITH OBJECT ::oUI
               :checkES2:setChecked( hTree[ "es2" ] )
               :checkW3:setChecked( hTree[ "w3" ] )
               :editSwitches:setText( hTree[ "switches" ] )
               :comboInc:clear()
               FOR EACH xTmp IN hb_ATokens( hTree[ "includes" ], " " )
                  IF ! Empty( xTmp )
                     :comboInc:addItem( xTmp )
                  ENDIF
               NEXT
               :comboInc:setCurrentIndex( 0 )
            ENDWITH
            IF hb_HHasKey( hTree, "items" ) .AND. ! Empty( hTree[ "items" ] )
               hNode := hTree[ "items" ]
               FOR EACH xTmp IN hNode
                  __jsonToTree( ::oTree:invisibleRootItem(), xTmp, ::hScripts )
               NEXT
            ENDIF
            __hbqtTreeExpandAll( ::oRootNode )
         ENDIF
      ENDIF
      EXIT
   ENDSWITCH
   RETURN Self


METHOD HbQtScripts:getFile( cTitle, cFilter, lAllowMulti, lCreateNew )
   LOCAL cFileName, cPath, cOpenPath

   IF ".hsv" $ cFilter .AND. ! ::cScriptFile == "..."
      cOpenPath := ::cScriptFile
   ELSE
      cOpenPath := ::cLastPath
   ENDIF
   IF ! Empty( cFileName := HbQtOpenFileDialog( cOpenPath, cTitle, cFilter, lAllowMulti, lCreateNew ) )
      IF lCreateNew .AND. hb_FileExists( cFileName )
         IF HbQtAlert( "File already exists, overright ?", { "No", "Overwrite" } ) != 2
            RETURN NIL
         ENDIF
      ENDIF
      IF ".hsv" $ cFilter
         ::cScriptFile := cFileName
         ::oTree:setHeaderLabel( " " + ::cScriptFile )
      ELSE
         hb_FNameSplit( cFileName, @cPath )
         ::cLastPath := cPath
      ENDIF
   ENDIF
   RETURN cFileName


STATIC FUNCTION __treeWidgetItem( cText, cTooltip, cWhatsThis )
   LOCAL oItem
   WITH OBJECT oItem := QTreeWidgetItem()
      :setText( 0, cText )
      :setTooltip( 0, cTooltip )
      :setWhatsThis( 0, cWhatsThis )
   ENDWITH
   RETURN oItem


STATIC FUNCTION __jsonToTree( oParent, hChild, hScripts )
   LOCAL oItem, hNode

   oItem := __treeWidgetItem( hChild[ "text" ], hChild[ "tooltip" ], hChild[ "whatsthis" ] )
   oParent:addChild( oItem )
   IF hChild[ "whatsthis" ] == "script"
      hScripts[ hChild[ "tooltip" ] ] := NIL
   ENDIF
   IF hb_HHasKey( hChild, "items" ) .AND. ! Empty( hChild[ "items" ] )
      FOR EACH hNode IN hChild[ "items" ]
         __jsonToTree( oItem, hNode, hScripts )
      NEXT
   ENDIF
   RETURN NIL


STATIC FUNCTION __itemToJson( oItem, aItems )
   LOCAL i, hNode

   hNode := hb_Hash( "text", oItem:text( 0 ), "tooltip", oItem:tooltip( 0 ), "whatsthis", oItem:whatsThis( 0 ), "items", {} )
   AAdd( aItems, hNode )
   IF oItem:childCount() > 0
      FOR i := 0 TO oItem:childCount() - 1
         __itemToJson( oItem:child( i ), hNode[ "items" ] )
      NEXT
   ENDIF
   RETURN NIL


METHOD HbQtScripts:removeScripts( oItem )
   LOCAL i, nChildren, oItm, nIndex, cScript

   IF ( nChildren := oItem:childCount() ) > 0
      FOR i := nChildren TO 1 STEP -1
         ::removeScripts( oItem:child( i - 1 ) )
      NEXT
      ::removeScripts( oItem )
   ELSE
      IF ( nIndex := ::oTree:indexOfTopLevelItem( oItem ) ) >= 0
         oItm := ::oTree:takeTopLevelItem( nIndex )
      ELSE
         nIndex := oItem:parent():indexOfChild( oItem )
         oItm := oItem:parent():takeChild( nIndex )
      ENDIF
      IF ! Empty( oItm )
         IF oItm:whatsThis( 0 ) == "script"
            cScript := oItm:tooltip( 0 )
            IF hb_HHasKey( ::hScripts, cScript )
               hb_HDel( ::hScripts, cScript )
               IF ::cCurScriptName == cScript
                  ::cCurScriptName := "new..."
                  ::oHbQtEditor:clear()
                  ::oUI:labelSourceName:setText( ::cCurScriptName )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   RETURN Self


METHOD HbQtScripts:populateScriptsTree( cScript )
   LOCAL oParent, cName, cExt

   IF ! hb_HHasKey( ::hScripts, cScript )
      IF ! Empty( oParent := ::findScriptNode( "Default" ) )
         hb_FNameSplit( cScript, , @cName, @cExt )
         oParent:addChild( __treeWidgetItem( cName + cExt, cScript, "script" ) )
         oParent:setExpanded( .T. )
         //
         ::hScripts[ cScript ] := NIL
      ENDIF
   ENDIF
   RETURN Self


METHOD HbQtScripts:findScriptNode( cNodeText )
   LOCAL i, oNode

   FOR i := 0 TO ::oTree:topLevelItemCount() - 0
      IF ::oTree:topLevelItem( i ):text( 0 ) == cNodeText
         RETURN ::oTree:topLevelItem( i )
      ENDIF
   NEXT
   // Not one of the top level items - find in children
   //
   FOR i := 0 TO ::oTree:topLevelItemCount() - 0
      IF ! Empty( oNode := __hbqtTreeFindNode( ::oTree:topLevelItem( i ), cNodeText ) )
         RETURN oNode
      ENDIF
   NEXT
   RETURN oNode


METHOD HbQtScripts:prepareScriptsTree()
   LOCAL oItem := __treeWidgetItem( "Default", "Group - Default", "group" )

   WITH OBJECT ::oTree
      :setHeaderLabel( " " + ::cScriptFile )
      :addTopLevelItem( oItem )
      :setContextMenuPolicy( Qt_CustomContextMenu )
      :connect( "itemDoubleClicked(QTreeWidgetItem*,int)", {|oItem| iif( oItem:whatsThis( 0 ) == "script", ::loadScript( oItem:tooltip( 0 ) ), NIL ) } )
      :connect( "customContextMenuRequested(QPoint)"     , {|oPoint| ::execEvent( __treeScriptsContextMenuRequested__, oPoint ) } )
   ENDWITH

   ::oUI:btnCSoft:connect( "clicked()", {|| __hbqtTreeCollapseAll( ::oRootNode, .T. ) } )
   ::oUI:btnCAll :connect( "clicked()", {|| __hbqtTreeCollapseAll( ::oRootNode  )     } )
   ::oUI:btnESoft:connect( "clicked()", {|| __hbqtTreeExpandAll( ::oRootNode, .T. )   } )
   ::oUI:btnEAll :connect( "clicked()", {|| __hbqtTreeExpandAll( ::oRootNode  )       } )
   RETURN Self


METHOD HbQtScripts:newScript()
   LOCAL cNew := ""

   cNew += Chr( 10 )
   cNew += "FUNCTION __test()"
   cNew += Chr( 10 )
   cNew += Chr( 10 )
   cNew += "   RETURN Alert( 'Wow, Harbour Scripts!' )"
   cNew += Chr( 10 )
   cNew += Chr( 10 )

   ::cCurScriptName := "new..."
   ::oUI:labelSourceName:setText( ::cCurScriptName )
   //::oHbQtEditor:setSource( cNew )
   
   HB_SYMBOL_UNUSED( cNew )
   RETURN Self


METHOD HbQtScripts:loadScript( cScript )
   LOCAL cBuffer

   IF Empty( cScript )
      cScript := ::getFile( "Select a Harbour Script", "Harbour Source (*.prg);Harbour Script (*.hb)", .F., .F. )
      IF ! Empty( cBuffer := hb_MemoRead( cScript ) )
         ::oHbQtEditor:setSource( cBuffer )
         ::cCurScriptName := cScript
         ::oUI:labelSourceName:setText( ::cCurScriptName )
         //
         ::populateScriptsTree( cScript )
      ENDIF
   ELSE
      IF ! Empty( cBuffer := hb_MemoRead( cScript ) )
         ::oHbQtEditor:setSource( cBuffer )
         ::cCurScriptName := cScript
         ::oUI:labelSourceName:setText( ::cCurScriptName )
      ENDIF
   ENDIF
   RETURN Self


METHOD HbQtScripts:saveScript()
   LOCAL cScript

   IF ::cCurScriptName == "new..."
      cScript := ::getFile( "Save this Harbour Script", "Harbour Source (*.prg);Harbour Script (*.hb)", .F., .T. )
      IF Empty( cScript )
         RETURN Self
      ENDIF
      ::cCurScriptName := cScript
      ::oUI:labelSourceName:setText( ::cCurScriptName )
      //
      ::populateScriptsTree( cScript )
   ENDIF

   hb_MemoWrit( ::cCurScriptName, ::oHbQtEditor:getSource() )
   RETURN Self


STATIC FUNCTION __hbqtValToChar( uVal )
   SWITCH ValType( uVal )
   CASE "C"
   CASE "M"
      RETURN uVal
   CASE "D"
      RETURN DToC( uVal )
   CASE "T"
      RETURN iif( Year( uVal ) == 0, HB_TToC( uVal, '', Set( _SET_TIMEFORMAT ) ), HB_TToC( uVal ) )
   CASE "L"
      RETURN If( uVal, ".T.", ".F." )
   CASE "N"
      RETURN AllTrim( Str( uVal ) )
   CASE "B"
      RETURN "{|| ... }"
   CASE "A"
      RETURN "{ ... }"
   CASE "O"
      RETURN iif( __ObjHasData( uVal, "cClassName" ), uVal:cClassName, uVal:ClassName() )
   CASE "H"
      RETURN "{=>}"
   CASE "P"
      RETURN "0x" + hb_NumToHex( uVal )
   ENDSWITCH
   RETURN ""


STATIC FUNCTION __errorDesc( e )
   LOCAL n
   LOCAL cErrorLog := e:description + Chr( 10 ) + e:operation + Chr( 10 )
   LOCAL aStack := {}

   IF ValType( e:Args ) == "A"
      cErrorLog += "   Args:" + Chr( 10 )
      FOR n := 1 to Len( e:Args )
         cErrorLog += "     [" + Str( n, 4 ) + "] = " + ValType( e:Args[ n ] ) + ;
                      "   " + __hbqtValToChar( __hbqtValToChar( e:Args[ n ] ) ) + ;
                      iif( ValType( e:Args[ n ] ) == "A", " length: " + ;
                      AllTrim( Str( Len( e:Args[ n ] ) ) ), "" ) + Chr( 10 )
      NEXT
   ENDIF

   cErrorLog += Chr( 10 ) + "Stack Calls" + Chr( 10 )
   cErrorLog += "===========" + Chr( 10 )
   n := 1
   WHILE  ( n < 74 )
      IF ! Empty( ProcName( n ) )
         AAdd( aStack, "   Called from: " + ProcFile( n ) + " => " + Trim( ProcName( n ) ) + ;
                        "( " + hb_ntos( ProcLine( n ) ) + " )" )
         cErrorLog += ATail( aStack ) + Chr( 10 )
      ENDIF
      n++
   END
   RETURN cErrorLog


STATIC FUNCTION __consoleScript( cBuffer, cCompFlags, xParam, cPath )
   IF hb_mtvm()
#if defined( __PLATFORM__WINDOWS )
      hb_threadStart( {||
                        LOCAL cGuiPath
                        LOCAL oCrt := WvgCrt():New( NIL, NIL, { -1, -1 }, { 24, 79 }, NIL, .T. )

                        cGuiPath := hb_cwd( cPath )
                        WITH OBJECT oCrt
                           :resizeMode := HB_GTI_RESIZEMODE_ROWS
                           :create()
                           hb_gtInfo( HB_GTI_WINTITLE, "Harbour Script" )
                           __runScript( cBuffer, cCompFlags, xParam, .T. )
                           :destroy()
                        ENDWITH
                        hb_cwd( cGuiPath )
                        RETURN NIL
                      } )
#else
      hb_threadStart( {|| hb_gtReload( "TRM" ),__runScript( cBuffer, cCompFlags, xParam, .T. ) } )
#endif
   ELSE
      __runScript( cBuffer, cCompFlags, xParam, .F. )
   ENDIF
   HB_SYMBOL_UNUSED( cPath )
   RETURN NIL


METHOD HbQtScripts:runScript( nMode )
   LOCAL cBuffer, cCompFlags, xParam, cInc, cI, i, cPath

   cCompFlags := ""
   IF ::oUI:checkES2:isChecked()
      cCompFlags += " -es2"
   ENDIF
   IF ::oUI:checkW3:isChecked()
      cCompFlags += " -w3"
   ENDIF

   IF ! Empty( cInc := ::oUI:editSwitches:text() )
      cInc := StrTran( cInc, "    ", " " )
      cInc := StrTran( cInc, "   ", " " )
      cInc := StrTran( cInc, "  ", " " )
      FOR EACH cI IN hb_ATokens( cInc, " " )
         cI := AllTrim( cI )
         IF Left( cI, 1 ) == "-"
            cCompFlags += " " + cI
         ENDIF
      NEXT
   ENDIF
   IF ::oUI:comboInc:count() > 0
      FOR i := 0 TO ::oUI:comboInc:count() - 1
         cCompFlags += " -i" + ::oUI:comboInc:itemText( i )
      NEXT
   ENDIF
   cCompFlags += " -i" + hb_DirBase()
   IF ::oUI:labelSourceName:text() != "new..."
      hb_FNameSplit( ::oUI:labelSourceName:text(), @cPath )
      IF ! Empty( cPath )
         cCompFlags += " -i" + cPath
      ENDIF
   ENDIF
   cCompFlags += " -D__HBQTSCRIPTS__"
   cCompFlags := AllTrim( cCompFlags )

   cBuffer := ::oHbQtEditor:getSource()

   cBuffer := '#command SELECT <fld,...> FROM <from> [INTO <into>] [ORDER BY <order,...>] [GROUP BY <group,...>] [WHERE <*whr*>] ' + ;
              ' => ' + ;
              ' __hbqtExecSelect( #<fld>, <"from">, #<whr>, #<order>, <"into">, #<group> )' + ;
              Chr( 10 ) + Chr( 10 ) + cBuffer

   xParam := NIL
   IF nMode == 1
      __consoleScript( cBuffer, cCompFlags, xParam, cPath )
   ELSE
      __runScript( cBuffer, cCompFlags, xParam, .F. )
   ENDIF
   RETURN NIL


STATIC FUNCTION __runScript( cBuffer, cCompFlags, xParam, lThreaded )
   LOCAL cFile, pHrb, oErr
   LOCAL a_:={}
   LOCAL lError := .F.
   LOCAL bError := ErrorBlock( {|o| break( o ) } )

   BEGIN SEQUENCE
      AAdd( a_, cBuffer )
      AEval( hb_ATokens( cCompFlags, " " ), {|s| iif( ! Empty( s ), AAdd( a_,s ), NIL ) } )
      cFile := hb_compileFromBuf( hb_ArrayToParams( a_ ) )
      IF ! Empty( cFile )
         IF lThreaded
            pHrb := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, cFile )
         ELSE
            pHrb := hb_hrbLoad( HB_HRB_BIND_LOCAL, cFile )
         ENDIF
      ENDIF
   RECOVER USING oErr
      IF lThreaded
         Alert( __errorDesc( oErr ) )
      ELSE
         HbQtAlert( __errorDesc( oErr ) )
      ENDIF
      lError := .t.
   END SEQUENCE

   IF ! lError .AND. !empty( pHrb )
      BEGIN SEQUENCE
         hb_hrbDo( pHrb, xParam )
      RECOVER USING oErr
         IF lThreaded
            Alert( __errorDesc( oErr ) )
         ELSE
            HbQtAlert( __errorDesc( oErr ) )
         ENDIF
      END SEQUENCE
   ENDIF
   IF ! Empty( pHrb )
      hb_hrbUnload( pHrb )
   ENDIF
   ErrorBlock( bError )
   RETURN NIL

//--------------------------------------------------------------------//
//               Select Statement Parser & Executer
//--------------------------------------------------------------------//

FUNCTION __hbqtExecSelect( cFields, cFrom, cWhere, cOrder, cInto, cGroup )
   LOCAL oSQL
   SetColor( "N/W" )
   CLS

   DEFAULT cWhere TO ""
   DEFAULT cOrder TO ""
   DEFAULT cInto  TO ""
   DEFAULT cGroup TO ""

   oSQL := HbSQL():new():create( cFields, cFrom, cWhere, cOrder, cInto, cGroup )

   HB_SYMBOL_UNUSED( oSQL )
   RETURN NIL

//--------------------------------------------------------------------//

STATIC FUNCTION __browseData( aData, aStruct )
   LOCAL i, oBrw

   WITH OBJECT oBrw := TBrowseNew( 0, 0, MaxRow(), MaxCol() )
      :cargo         := { aData, 1 }
      :goTopBlock    := {|| oBrw:cargo[ 2 ] := 1 }
      :goBottomBlock := {|| oBrw:cargo[ 2 ] := Len( oBrw:cargo[ 1 ] ) }
      :SkipBlock     := {| nSkip, nPos | nPos := oBrw:cargo[ 2 ], ;
                           oBrw:cargo[ 2 ] := iif( nSkip > 0, Min( Len( oBrw:cargo[ 1 ] ), oBrw:cargo[ 2 ] + nSkip ), ;
                           Max( 1, oBrw:cargo[ 2 ] + nSkip ) ), oBrw:cargo[ 2 ] - nPos }
      :HeadSep       := Chr( 196 ) + Chr( 194 ) + Chr( 196 )
      :ColSep        := ' ' + Chr( 179 ) + ' '
      :ColorSpec     := 'N/W,W+/R,N/W,N/W'
   ENDWITH
   FOR i := 1 TO Len( aStruct )
      oBrw:addColumn( TBColumnNew( __formatHeading( aStruct, i ), __buildColumnBlock( oBrw, i ) ) )
      oBrw:getColumn( i ):picture := __buildPicture( aStruct, i )
   NEXT

   __handleBrowse( oBrw )
   RETURN NIL


STATIC FUNCTION __formatHeading( aStruct, i )
   LOCAL cHeading := aStruct[ i, 1 ]
   IF aStruct[ i, 2 ] == "N"
      IF aStruct[ i, 3 ] > Len( cHeading )
         cHeading := PadL( cHeading, aStruct[ i, 3 ] )
      ENDIF
   ENDIF
   RETURN cHeading


STATIC FUNCTION __buildColumnBlock( oBrw, i )
   RETURN {|| oBrw:cargo[ 1 ][ oBrw:cargo[ 2 ], i ] }


STATIC FUNCTION __buildPicture( aStruct, i )

   SWITCH aStruct[ i,2 ]
   CASE "C" ; RETURN "@ " + Replicate( "X", aStruct[ i, 3 ] )
   CASE "N" ; RETURN iif( aStruct[ i, 4 ] == 0, "@Z " + Replicate( "9", aStruct[ i, 3 ] ), ;
                    "@Z " + Replicate( "9", aStruct[ i, 3 ] - 1 - aStruct[ i, 4 ] ) + "." + Replicate( "9", aStruct[ i, 4 ] ) )
   ENDSWITCH
   RETURN NIL


STATIC FUNCTION  __handleBrowse( oBrw )
   LOCAL nLastKey
   LOCAL lContinue := .T.

   SetCursor( 0 )

   WHILE ( ! oBrw:stabilize() ) ; END

   DO WHILE lContinue
      DO WHILE ( ( nLastKey := Inkey( NIL, INKEY_ALL + HB_INKEY_GTEVENT ) ) == 0 .OR. nLastKey == 1001 ) .AND. !( oBrw:Stabilize() )
      ENDDO
      IF nLastKey == 0
         HB_GtInfo( HB_GTI_WINTITLE, '[ ' + LTrim( Transform( oBrw:cargo[ 2 ], "999,999,999,999" ) ) + '/' + ;
                                            LTrim( Transform( Len( oBrw:cargo[ 1 ] ),"999,999,999,999" ) ) + ' ]' )
         DO WHILE ( nLastKey == 0 .OR. nLastKey == 1001 )
            nLastKey := Inkey( 0, INKEY_ALL + HB_INKEY_GTEVENT )
            hb_idleSleep()
         ENDDO
      ENDIF
      DO CASE
      CASE nLastKey == K_ESC
         lContinue := .F.
      CASE nLastKey == HB_K_CLOSE
         lContinue := .F.
      CASE nLastKey == K_UP
         oBrw:Up()
      CASE nLastKey == K_DOWN
         oBrw:Down()
      CASE nLastKey == K_PGUP
         oBrw:pageUp()
      CASE nLastKey == K_PGDN
         oBrw:pageDown()
      CASE nLastKey == K_CTRL_PGUP
         oBrw:goTop()
         oBrw:refreshAll()
         oBrw:forceStable()
      CASE nLastKey == K_CTRL_PGDN
         oBrw:goBottom()
      CASE nLastKey == K_RIGHT
         oBrw:right()
      CASE nLastKey == K_LEFT
         oBrw:left()
      CASE nLastKey == K_HOME
         oBrw:home()
      CASE nLastKey == K_END
         oBrw:end()
      CASE nLastKey == K_CTRL_HOME
         oBrw:PanHome()
      CASE nLastKey == K_CTRL_END
         oBrw:PanEnd()
      CASE nLastKey == K_MWBACKWARD
         oBrw:down()
      CASE nLastKey == K_MWFORWARD
         oBrw:up()
      CASE nLastKey == HB_K_RESIZE
         oBrw:nBottom := MaxRow()
         oBrw:nRight := MaxCol()
         oBrw:RefreshAll()
         DispBox( 0, 0, MaxRow(), MaxCol(), "         ", "N/W" )
      ENDCASE
   ENDDO
   RETURN NIL

//--------------------------------------------------------------------//

CLASS HbSQL

   DATA   cFields                                  INIT ""
   DATA   cFrom                                    INIT ""
   DATA   cWhere                                   INIT ""
   DATA   cOrder                                   INIT ""
   DATA   cGroup                                   INIT ""
   DATA   cInto                                    INIT ""

   DATA   aData                                    INIT {}
   DATA   aStruct                                  INIT {}
   DATA   aStructF                                 INIT {}
   DATA   aFields                                  INIT {}
   DATA   nFields                                  INIT {}
   DATA   aTags                                    INIT {}
   DATA   aInfo                                    INIT {}
   DATA   aWhere                                   INIT {}

   DATA   cAlias                                   INIT "__SOURCE__"
   DATA   cDriver
   DATA   cTable
   DATA   cPath
   DATA   cName
   DATA   cExt
   DATA   cMsg                                     INIT ""
   DATA   cSearch                                  INIT ""
   DATA   nIndex                                   INIT 0
   DATA   cFor                                     INIT ""
   DATA   bFor
   DATA   cSearchType                              INIT ""
   DATA   lAggregate                               INIT .F.

   METHOD init()
   METHOD create( cFields, cFrom, cWhere, cOrder, cInto, cGroup )
   METHOD openTable()
   METHOD parseFields()
   METHOD pullIndexes()
   METHOD closeAndAlert( cAlert )
   METHOD parseWhere()
   METHOD pullWheres()
   METHOD pullKeyValueOperator( cWhere, cOperator )
   METHOD collectData()
   METHOD collectFields()
   METHOD orderData( cOrderBy )
   METHOD saveData()
   METHOD consolidateData()
   METHOD browseData()
   METHOD parseParams( cFunc, aParam, aResult )

   ENDCLASS


METHOD HbSQL:init()
   RETURN Self


METHOD HbSQL:create( cFields, cFrom, cWhere, cOrder, cInto, cGroup )

   DEFAULT cFields TO ::cFields
   DEFAULT cFrom   TO ::cFrom
   DEFAULT cWhere  TO ::cWhere
   DEFAULT cOrder  TO ::cOrder
   DEFAULT cInto   TO ::cInto
   DEFAULT cGroup  TO ::cGroup

   ::cFields := cFields
   ::cFrom   := cFrom
   ::cWhere  := cWhere
   ::cOrder  := cOrder
   ::cInto   := cInto
   ::cGroup  := cGroup

   IF ::openTable()
      IF ! ::parseFields()
         RETURN ::closeAndAlert( ::cMsg )
      ENDIF
      IF ! ::lAggregate .AND. Empty( ::aFields )
         RETURN ::closeAndAlert( "Fields requested are not present in the table!" )
      ENDIF
      ::pullIndexes()
      IF ::parseWhere()
         // Collect data from the source table based on WHERE clause
         //
         ::collectData()
         // We have pulled data, close the source table
         //
         Select( ::cAlias )
         dbCloseArea()
         //
         IF ! Empty( ::aData )
            IF ::lAggregate
               IF ! ::consolidateData()
                  RETURN ::closeAndAlert( ::cMsg )
               ENDIF
            ENDIF
            // Sort data per ORDER BY clause
            //
            ::orderData()

            // Save if INTO clause is present
            //
            ::saveData()

            // We are done, browse results
            //
            ::browseData()
         ENDIF
      ENDIF
   ENDIF
   RETURN NIL


METHOD HbSQL:collectData()

   IF ! HB_ISBLOCK( ::bFor )
      IF ::nIndex > 0
         IF dbSeek( ::cSearch )
            IF ::cSearchType == "=="
               DO WHILE Trim( ( ::cAlias )->( &( IndexKey( ::nIndex ) ) ) ) == ::cSearch
                  ::collectFields()
                  ( ::cAlias )->( dbSkip() )
               ENDDO
            ELSE
               DO WHILE ( ::cAlias )->( &( IndexKey( ::nIndex ) ) ) = ::cSearch
                  ::collectFields()
                  ( ::cAlias )->( dbSkip() )
               ENDDO
            ENDIF
         ENDIF
      ELSE
         DO WHILE ! ( ::cAlias )->( Eof() )
            ::collectFields()
            ( ::cAlias )->( dbSkip() )
         ENDDO
      ENDIF
   ELSE
      IF ::nIndex > 0
         IF dbSeek( ::cSearch )
            IF ::cSearchType == "=="
               DO WHILE Trim( ( ::cAlias )->( &( IndexKey( ::nIndex ) ) ) ) == ::cSearch
                  IF Eval( ::bFor )
                     ::collectFields()
                  ENDIF
                  ( ::cAlias )->( dbSkip() )
               ENDDO
            ELSE
               DO WHILE ( ::cAlias )->( &( IndexKey( ::nIndex ) ) ) = ::cSearch
                  IF Eval( ::bFor )
                     ::collectFields()
                  ENDIF
                  ( ::cAlias )->( dbSkip() )
               ENDDO
            ENDIF
         ENDIF
      ELSE
         DO WHILE ! ( ::cAlias )->( Eof() )
            IF Eval( ::bFor )
               ::collectFields()
            ENDIF
            ( ::cAlias )->( dbSkip() )
         ENDDO
      ENDIF
   ENDIF
   RETURN NIL


METHOD HbSQL:collectFields()
   LOCAL aTmp, aField

   aTmp := {}
   FOR EACH aField IN ::aInfo
      AAdd( aTmp, Eval( aField[ 6 ] ) )
   NEXT
   AAdd( ::aData, aTmp )
   RETURN NIL


METHOD HbSQL:parseFields()
   LOCAL xTmp, cField, nField, aToken, n, aParam, cFunc, cParams

   IF "*" == ::cFields
      FOR EACH xTmp IN ::aStruct
         n := xTmp:__enumIndex()
         AAdd( ::aFields, xTmp[ 1 ] )
         AAdd( ::nFields, n )
         AAdd( ::aInfo, { xTmp[ 1 ], xTmp[ 2 ], xTmp[ 3 ], xTmp[ 4 ], "FIELD", &( "{|| fieldget(" + hb_ntos( n ) + ") }" ) } )
      NEXT
      AEval( ::aStruct, {|e_,i| AAdd( ::aFields, e_[ 1 ] ), AAdd( ::nFields, i ) } )
   ELSE
      xTmp := __tokenizeList( ::cFields )
      FOR EACH aToken IN xTmp
         cField := Upper( aToken )
         IF ( n := At( "(", cField ) ) > 0
            cFunc := Left( cField, n - 1 )
            cParams := " " + SubStr( cField, n + 1 )
            cParams := Left( cParams, Len( cParams ) - 1 )

            SWITCH cFunc
            CASE "COUNT"
               ::lAggregate := .T.
               AAdd( ::aInfo, { cField, "N", 10, 0, cFunc, {|| 1 } } )
               EXIT
            CASE "SUM"
            CASE "AVG"
            CASE "MIN"
            CASE "MAX"
               ::lAggregate := .T.
            CASE "FUNC"
               aParam := __pullFieldsFromExp( cParams )
               FOR EACH xTmp IN ::aStruct
                  IF AScan( aParam, {|e| e == xTmp[ 1 ] } ) > 0
                     cParams := StrTran( cParams, xTmp[ 1 ], "fieldget(" + hb_ntos( xTmp:__enumIndex() ) + ")" )
                  ENDIF
               NEXT
               xTmp := NIL
               IF HB_ISHASH( xTmp := __evalAsIs( cParams ) )
                  AAdd( ::aInfo, { cField, xTmp[ "type" ], xTmp[ "length" ], xTmp[ "dec" ], cFunc, &( "{|| " + cParams + " }" ) } )
               ENDIF
               EXIT
            CASE "SUBSTR"
            CASE "LEFT"
            CASE "RIGHT"
            CASE "LOWER"
            CASE "UPPER"
               aParam := __pullFieldsFromExp( cParams )
               FOR EACH xTmp IN ::aStruct
                  IF AScan( aParam, {|e| e == xTmp[ 1 ] } ) > 0
                     cParams := StrTran( cParams, xTmp[ 1 ], "fieldget(" + hb_ntos( xTmp:__enumIndex() ) + ")" )
                  ENDIF
               NEXT
               cParams := cFunc + "( " + cParams + ")"
               xTmp := NIL
               IF HB_ISHASH( xTmp := __evalAsIs( cParams ) )
                  AAdd( ::aInfo, { cField, xTmp[ "type" ], xTmp[ "length" ], xTmp[ "dec" ], cFunc, &( "{|| " + cParams + " }" ) } )
               ENDIF
               EXIT
            CASE "RECNO"
               AAdd( ::aInfo, { cField, "N", 10, 0, cFunc, &( "{|| RecNo() }" ) } )
               EXIT
            ENDSWITCH
         ELSE
            IF ( nField := AScan( ::aStruct, {|e_| e_[ 1 ] == cField } ) ) > 0
               AAdd( ::aFields, cField )
               AAdd( ::nFields, nField )
               AAdd( ::aInfo, { cField, ::aStruct[ nField, 2 ], ::aStruct[ nField, 3 ], ::aStruct[ nField, 4 ], ;
                                "FIELD", &( "{|| FieldGet(" + hb_ntos( nField ) + ") }" ) } )
            ELSE
               ::aFields := {}
               ::cMsg := "Defined field does not exist in table!"
               RETURN .F.
            ENDIF
         ENDIF
      NEXT
   ENDIF
   IF ::lAggregate
      AAdd( ::aInfo, { "_$B$_", "N", 1, 0, "BASE", {|| 1 } } )
   ENDIF
   RETURN .T.


STATIC FUNCTION __tokenizeList( cList )
   LOCAL n, cChr, lFunc, nBraceOp, nBraceCl
   LOCAL a_:= {}

   n := 1
   nBraceOp := nBraceCl := 0
   lFunc := .F.
   FOR EACH cChr IN cList
      IF cChr == "("                               // function starts
         IF ! lFunc
            lFunc := .T.
         ENDIF
         nBraceOp++
      ELSEIF cChr == ")"
         IF lFunc
            nBraceCl++
            IF nBraceOp == nBraceCl
               nBraceOp := nBraceCl := 0
               lFunc := .F.
            ENDIF
         ENDIF
      ELSEIF cChr $ ",+-*/"
         IF ! lFunc
            AAdd( a_, AllTrim( SubStr( cList, n, cChr:__enumIndex() - n ) ) )
            n := cChr:__enumIndex() + 1
         ENDIF
      ENDIF
   NEXT
   IF n < Len( cList )
      AAdd( a_, AllTrim( SubStr( cList, n ) ) )
   ENDIF
   RETURN a_


STATIC FUNCTION __pullFieldsFromExp( cExp, aFlds )
   LOCAL aParams, cToken, n

   DEFAULT aFlds TO {}

   aParams := __tokenizeList( cExp )
   IF HB_ISARRAY( aParams )
      FOR EACH cToken IN aParams
         IF ( n := At( "(", cToken ) ) > 0
            __pullFieldsFromExp( SubStr( cToken, n + 1, Len( cToken ) - n - 1 ), @aFlds )
         ELSE
            AAdd( aFlds, cToken )
         ENDIF
      NEXT
   ENDIF

   // larger fields first - avoid errors if another field has subset of characters of another field
   // no_11, no_111
   //
   ASort( aFlds, NIL, NIL, {|e,f| Len( e ) > Len( f ) } )
   RETURN aFlds


STATIC FUNCTION __evalAsIs( cParams )
   LOCAL hRet, xTmp
   LOCAL bError := ErrorBlock( {|| Break() } )

   BEGIN SEQUENCE
      xTmp := Eval( &( "{|| " + cParams + " }" ) )
      hRet := {=>}
      hRet[ "type"   ] := ValType( xTmp )
      hRet[ "length" ] := iif( hRet[ "type" ] == "C", Len( xTmp ), iif( hRet[ "type" ] == "N", 15, iif( hRet[ "type" ] == "D", 8, 1 ) ) )
      hRet[ "dec"    ] := iif( hRet[ "type" ] == "N", 3, 0 )
   RECOVER
      // nothing to do
   END SEQUENCE
   ErrorBlock( bError )
   RETURN hRet


METHOD HbSQL:parseParams( cFunc, aParam, aResult )
   LOCAL lError := .F.
   LOCAL cF, aF, nField, nWid, nDec, cN

   nWid := nDec := 0
   cN := ""
   IF Len( aParam ) >= 1 .AND. ! ( Len( aParam ) % 2 == 0 )
      FOR EACH aF IN aParam
         cF := aF[ 1 ]
         cN += cF
         IF ! cF $ "+*-/"
            IF ( nField := AScan( ::aStruct, {|e_| e_[ 1 ] == cF } ) ) > 0
               IF ::aStruct[ nField, 2 ] == "N"
                  aF[ 2 ] := "fieldget(" + hb_ntos( nField ) + ")"
                  nWid := Max( nWid, ::aStruct[ nField, 3 ] )
                  nDec := Max( nDec, ::aStruct[ nField, 4 ] )
               ELSE
                  lError := .T.
               ENDIF
            ELSE
               lError := .T.
            ENDIF
         ENDIF
         IF lError
            ::cMsg := "Defined field does not exist in table!"
            RETURN .F.
         ENDIF
      NEXT
      IF cFunc == "COUNT"
         aResult := { cFunc + "(" + cN + ")", "N", 8, 0, cFunc, &( "{|| 1 }" ) }
      ELSE
         IF Len( aParam ) == 5
            cF := aParam[ 1, 2 ] + aParam[ 2, 1 ] + aParam[ 3,2 ] + aParam[ 4, 1 ] + aParam[ 5,2 ]
         ELSEIF Len( aParam ) == 3
            cF := aParam[ 1, 2 ] + aParam[ 2, 1 ] + aParam[ 3,2 ]
         ELSEIF Len( aParam ) == 1
            cF := aParam[ 1, 2 ]
         ENDIF
         aResult := { cFunc + "(" + cN + ")", "N", 12, nDec, cFunc,  &( "{|| " + cF + "}" ) }
      ENDIF
   ELSE
      ::cMsg := "Defined field does not exist in table!"
      RETURN .F.
   ENDIF
   RETURN .T.


METHOD HbSQL:consolidateData()
   LOCAL aGroup, cGroup, aData, ele_, nAdd_, aInfo, n, aOpr_

   IF ! Empty( ::cGroup )
      aGroup := hb_ATokens( Upper( ::cGroup ), "," )
      FOR EACH cGroup IN aGroup
         cGroup := AllTrim( cGroup )
         IF AScan( ::aFields, {|e| e == cGroup } ) == 0
            ::cMsg := "Group By field is not included in SELECT clause!"
            RETURN .F.
         ENDIF
      NEXT

      ele_:= {}
      FOR EACH cGroup IN aGroup
         IF ( n := AScan( ::aInfo, {|e_| e_[ 1 ] == cGroup } ) ) > 0
            AAdd( ele_, n )
         ENDIF
      NEXT
      nAdd_:= {} ; aOpr_:= {}
      FOR EACH aInfo IN ::aInfo
         IF aInfo[ 5 ] $ "SUM,AVG,MIN,MAX,COUNT"
            AAdd( nAdd_, aInfo:__enumIndex() )
            AAdd( aOpr_, aInfo[ 5 ] )
         ENDIF
      NEXT
      //
      aData := __hbqtAProcessUnique( ::aData, ele_, nAdd_, aOpr_ )

      ::aData := aData
   ELSE
      ele_:= { Len( ::aInfo ) }
      nAdd_:= {} ; aOpr_:= {}
      FOR EACH aInfo IN ::aInfo
         IF aInfo[ 5 ] $ "SUM,AVG,MIN,MAX,COUNT"
            AAdd( nAdd_, aInfo:__enumIndex() )
            AAdd( aOpr_, aInfo[ 5 ] )
         ENDIF
      NEXT
      aData := __hbqtAProcessUnique( ::aData, ele_, nAdd_, aOpr_ )
      ::aData := aData
   ENDIF
   RETURN .T.


METHOD HbSQL:orderData( cOrderBy )
   LOCAL aOrder, cOrder, xTmp, nS, n, cE, nE, i, cFor, bFor, nLastOrder

   DEFAULT cOrderBy TO ::cOrder

   IF ! Empty( cOrderBy )
      cOrderBy := Upper( cOrderBy )
      aOrder := hb_ATokens( cOrderBy, "," )
      FOR EACH cOrder IN aOrder
         IF Right( cOrder, 4 ) == "-ASC"
            cOrder := Left( cOrder, Len( cOrder ) - 4 )
         ENDIF
         xTmp := Right( cOrder, 5 ) == "-DESC"
         IF xTmp
            cOrder := Left( cOrder, Len( cOrder ) - 5 )
         ENDIF
         nS := 1
         IF ( n := AScan( ::aInfo, {|e_| e_[ 1 ] == cOrder } ) ) > 0
            cFor := "e_[" + hb_ntos( n ) + "]" + iif( xTmp, ">", "<" ) +  "f_[" + hb_ntos( n ) + "]"
            bFor := &( "{|e_,f_| " + cFor + " }" )

            IF cOrder:__enumIndex() == 1
               ASort( ::aData, NIL, NIL, bFor )
            ELSE
               cE := ::aData[ nS, nLastOrder ]
               nE := 0
               DO WHILE .T.
                  FOR i := nS TO Len( ::aData )
                     IF ::aData[ i, nLastOrder ] != cE
                        ASort( ::aData, nS, nE, bFor )
                        cE := ::aData[ i, nLastOrder ]
                        nS := i
                        nE := 0
                        EXIT
                     ENDIF
                     nE++
                  NEXT
                  IF nE >= Len( ::aData )
                     EXIT
                  ENDIF
               ENDDO
               IF nS < Len( ::aData )
                  ASort( ::aData, nS, NIL, bFor )
               ENDIF
            ENDIF
            nLastOrder := n
         ENDIF
      NEXT
   ENDIF
   RETURN NIL


METHOD HbSQL:saveData()
   LOCAL xTmp, cPath, cName, cExt, aStruct, aField, x, s, s1
   LOCAL cTarget := "__TARGET__"
   LOCAL nArea := Select()
   LOCAL cDlm := ","

   IF ! Empty( ::cInto )
      aStruct := {}
      FOR EACH aField IN ::aInfo
         IF ! aField[ 1 ] == "_$B$_"
            AAdd( aStruct, { __normalizeFieldName( aField[ 1 ] ), aField[ 2 ], aField[ 3 ], aField[ 4 ] } )
         ENDIF
      NEXT

      hb_FNameSplit( ::cInto, @cPath, @cName, @cExt )

      SWITCH Lower( cExt )
      CASE ".csv"
      CASE ".xls"
         s := ""
         FOR EACH aField IN aStruct
            s += aField[ 1 ] + cDlm
         NEXT
         s := SubStr( s, 1, Len( s ) - 1 ) + Chr( 13 )+ Chr( 10 )
         FOR EACH xTmp IN ::aData
            s1 := ""
            FOR EACH aField IN aStruct
               s1 += __hbqtXtoS( xTmp[ aField:__enumIndex() ] ) + cDlm
            NEXT
            IF Right( s1, 1 ) == cDlm
               s1 := SubStr( s1, 1, Len( s1 ) - 1 )
            ENDIF
            s += s1 + Chr( 13 ) + Chr( 10 )
         NEXT
         hb_MemoWrit( ::cInto, s )
         EXIT
      OTHERWISE
         dbCreate( ::cInto, aStruct, "DBFCDX" )
         IF ! NetErr() .AND. hb_FileExists( ::cInto )
            USE ( ::cInto ) ALIAS ( cTarget ) EXCLUSIVE NEW VIA "DBFCDX"
            IF ! NetErr()
               FOR EACH xTmp IN ::aData
                  dbAppend()
                  FOR EACH x IN aStruct
                     FieldPut( x:__enumIndex(), xTmp[ x:__enumIndex() ] )
                  NEXT
               NEXT
               dbCommit()
            ENDIF
            dbCloseArea()
         ENDIF
         EXIT
      ENDSWITCH
   ENDIF
   Select( nArea )
   RETURN NIL


STATIC FUNCTION __normalizeFieldName( cName )
   cName := Upper( cName )
   cName := iif( Left( cName, 4 ) == "FUNC", SubStr( cName, 6 ), cName )

   cName := StrTran( cName, "(", "_" )
   cName := StrTran( cName, ")", "_" )
   cName := StrTran( cName, "*", "_" )
   cName := StrTran( cName, "+", "_" )
   cName := StrTran( cName, "-", "_" )
   cName := StrTran( cName, "/", "_" )
   cName := StrTran( cName, ",", "_" )
   cName := StrTran( cName, ",", "_" )

   cName := StrTran( cName, "____", "_" )
   cName := StrTran( cName, "___", "_" )
   cName := StrTran( cName, "__", "_" )
   DO WHILE .T.
      IF ! Left( cName, 1 ) == "_"
         EXIT
      ENDIF
      cName := SubStr( cName, 2 )
   ENDDO
   DO WHILE .T.
      IF ! Right( cName, 1 ) == "_"
         EXIT
      ENDIF
      cName := SubStr( cName, 1, Len( cName ) - 1 )
   ENDDO
   RETURN cName


METHOD HbSQL:parseWhere()
   LOCAL xTmp, nWhere, n, nField, cValue

   IF ! Empty( ::cWhere )
      IF ! ::pullWheres()
         RETURN ::closeAndAlert( ::cMsg )
      ENDIF

      IF ! Empty( ::aWhere )
         nWhere := 0
         IF ! Empty( ::aTags )
            FOR EACH xTmp IN ::aWhere
               IF xTmp[ 3 ] == "=" .OR. xTmp[ 3 ] == "LIKE"
                  n := Len( xTmp[ 1 ] )
                  IF ( ::nIndex := AScan( ::aTags, {|e| Left( e, n ) == xTmp[ 1 ] } ) ) > 0
                     dbSetOrder( ::nIndex )
                     nWhere := xTmp:__enumIndex()
                     ::cSearch := xTmp[ 2 ]
                     IF Left( ::cSearch, 1 ) == '"'
                        ::cSearch := SubStr( ::cSearch, 2, Len( ::cSearch ) - 2 )
                     ENDIF
                     IF Right( ::cSearch, 1 ) == "%"
                        ::cSearch := Left( ::cSearch, Len( ::cSearch ) - 1 )
                        ::cSearchType := "="
                     ELSE
                        ::cSearchType := "=="
                     ENDIF
                     xTmp[ 4 ] := ::cSearch
                     EXIT
                  ENDIF
               ENDIF
            NEXT
         ENDIF
         //
         ::cFor := ""
         FOR EACH xTmp IN ::aWhere
            n := xTmp:__enumIndex()
            IF n != nWhere       // we already processed it as seek field
               nField := AScan( ::aStruct, {|e_| e_[ 1 ] == xTmp[ 1 ] } )
               cValue := xTmp[ 2 ]
               IF Left( cValue, 1 ) == '"'
                  cValue := SubStr( cValue, 2, Len( cValue ) - 2 )
               ENDIF
               xTmp[ 2 ] := cValue
               SWITCH Left( ::aStruct[ nField, 2 ], 1 )
               CASE "C"
                  cValue := '"' + cValue + '"'
                  EXIT
               CASE "D"
                  cValue := StrTran( cValue, "-", "" )
                  cValue := "StoD('" + cValue + "')"
                  EXIT
               CASE "N"
                  cValue := Val( cValue )
                  cValue := hb_ntos( cValue )
                  EXIT
               ENDSWITCH
               xTmp[ 2 ] := cValue
               xTmp[ 5 ] := nField
               //                                                                operator                             value
               ::cFor += "fieldget(" + hb_ntos( nField ) + ") " + iif( xTmp[ 3 ] == "LIKE", "=", xTmp[ 3 ] ) + " " + xTmp[ 2 ] + " .AND. "
            ENDIF
         NEXT
         IF Right( ::cFor,7 ) == " .AND. "
            ::cFor := Left( ::cFor, Len( ::cFor ) - 7 )
         ENDIF
         IF ! Empty( ::cFor )
            ::bFor := &( "{|| " + ::cFor + "}" )
         ENDIF
      ENDIF
   ENDIF
   RETURN .T.


METHOD HbSQL:pullWheres()
   LOCAL n, cClone, cField, cWhere
   LOCAL a_:={}

   cClone := StrTran( ::cWhere, " and ", " AND " )
   DO WHILE .T.
      IF ( n := At( " AND ", cClone ) ) > 0
         AAdd( a_, AllTrim( SubStr( cClone, 1, n - 1 ) ) )
         cClone := SubStr( cClone, n + 5 )
      ELSE
         EXIT
      ENDIF
   ENDDO
   IF ! Empty( cClone )
      AAdd( a_, cClone )
   ENDIF

   FOR EACH cWhere IN a_
      cWhere := StrTran( cWhere, " like ", " LIKE " )

      DO CASE
      CASE At( ">=", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, ">=" ) )
      CASE At( "<=", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "<=" ) )
      CASE At( "!=", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "!=" ) )
      CASE At( "<>", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "<>" ) )
      CASE At( "=", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "=" ) )
      CASE At( ">", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, ">" ) )
      CASE At( "<", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "<" ) )
      CASE At( "LIKE", cWhere ) > 0
         AAdd( ::aWhere, ::pullKeyValueOperator( cWhere, "LIKE" ) )
      ENDCASE
   NEXT

   FOR EACH a_ IN ::aWhere
      IF ! HB_ISARRAY( a_ )
         ::cMsg := "WHERE clause - mal-formed!"
         RETURN .F.
      ENDIF
      cField := a_[ 1 ]
      IF AScan( ::aStruct, {|e_| e_[ 1 ] == cField } ) == 0
         ::cMsg := "WHERE clause - field does not exists!"
         RETURN .F.
      ENDIF
   NEXT
   RETURN .T.


METHOD HbSQL:pullIndexes()
   LOCAL n, xTmp

   FOR n := 1 TO 50
      IF ( xTmp := ( ::cAlias )->( IndexKey( n ) ) ) == ""
         EXIT
      ENDIF
      AAdd( ::aTags, Upper( xTmp ) )
   NEXT
   RETURN Self


METHOD HbSQL:openTable()
   LOCAL lTableExists, n

   IF Empty( ::cFrom )
      Alert( "FROM clause missing!" ) ; RETURN .F.
   ENDIF
   IF ( n := At( "|", ::cFrom ) ) > 0
      ::cDriver := SubStr( ::cFrom, 1, n - 1 )
      ::cTable := SubStr( ::cFrom, n + 1 )
   ELSE
      ::cDriver := "DBFCDX"
      ::cTable := ::cFrom
   ENDIF
   hb_FNameSplit( ::cTable, @::cPath, @::cName, @::cExt )

   SWITCH Upper( ::cDriver )
   CASE "DBFCDX"
   CASE "DBFNTX"
   CASE "DBFNSX"
   CASE "ADS"
      IF Empty( ::cExt )
         ::cTable := ::cTable + ".dbf"
      ENDIF
      lTableExists := hb_FileExists( ::cTable )
      EXIT
   CASE "CACHERDD"
      lTableExists := .T.
      EXIT
   ENDSWITCH

   IF ! lTableExists
      Alert( "Table;" + ::cTable + ";" + "does not exists!" )
      RETURN .F.
   ENDIF

   USE ( ::cTable ) VIA ( ::cDriver ) Alias ( ::cAlias ) SHARED NEW
   IF NetErr()
      Alert( "Some error in opening ;" + ::cTable )
      RETURN .F.
   ENDIF
   ::aStruct:= dbStruct()
   AEval( ::aStruct, {|e_| e_[ 2 ] := Left( e_[ 2 ], 1 ) } )
   RETURN .T.


METHOD HbSQL:closeAndAlert( cAlert )
   IF Select( ::cAlias ) > 0
      Select( ::cAlias )
      dbCloseArea()
   ENDIF
   RETURN Alert( cAlert ) == 99                    // always return false


METHOD HbSQL:pullKeyValueOperator( cWhere, cOperator )
   LOCAL cField, cValue
   LOCAL n := hb_At( cOperator, cWhere )
   IF n > 0
      cField := Upper( AllTrim( SubStr( cWhere, 1, n - 1 ) ) )
      cValue := AllTrim( SubStr( cWhere, n + Len( cOperator ) ) )
      RETURN { cField, cValue, cOperator, NIL, NIL, NIL }
   ENDIF
   RETURN NIL


METHOD HbSQL:browseData()
   LOCAL aField, nColumns, nDTCols
   LOCAL aStr := {}

   nColumns := 0
   FOR EACH aField IN ::aInfo
      IF aField[ 1 ] != "_$B$_"
         AAdd( aStr, { aField[ 1 ], aField[ 2 ], aField[ 3 ], aField[ 4 ] } )
         nColumns += Max( aField[ 3 ], Len( aField[ 1 ] ) )
      ENDIF
   NEXT
   nColumns += ( 3 * Len( ::aInfo ) ) + 3
   nDTCols := hb_gtInfo( HB_GTI_DESKTOPCOLS )
   SetMode( 25, Max( 80, Min( nColumns, nDTCols ) ) )
   //
   hb_gtInfo( HB_GTI_SCREENHEIGHT, hb_gtInfo( HB_GTI_SCREENHEIGHT ) + 1 )

   __browseData( ::aData, aStr )
   RETURN NIL

