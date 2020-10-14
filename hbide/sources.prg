/*
 * $Id: sources.prg 426 2016-10-20 00:14:06Z bedipritpal $
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
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*
 *                                EkOnkar
 *                          ( The LORD is ONE )
 *
 *                            Harbour-Qt IDE
 *
 *                  Pritpal Bedi <bedipritpal@hotmail.com>
 *                               09Jan2010
 */
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/

#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"
#include "hbide.ch"

/*----------------------------------------------------------------------*/

CLASS IdeSourcesManager INHERIT IdeObject

   DATA   oFileWatcher

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD loadSources()
   METHOD saveSource( nTab, lCancel, lAs )
   METHOD saveNamedSource( cSource )
   METHOD editSource( cSourceFile, nPos, nHPos, nVPos, cTheme, cView, lAlert, lVisible, aBookMarks, cCodePage, cExtras )
   METHOD closeSource( nTab, lCanCancel, lCanceled, lAsk )
   METHOD closeAllSources( lCanCancel )
   METHOD closeAllOthers( nTab )
   METHOD saveAllSources()
   METHOD saveAndExit()
   METHOD revertSource( nTab )
   METHOD openSource()
   METHOD selectSource( cMode, cFile, cTitle, cDftPath )
   METHOD requestSourceReload( cSource )

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:new( oIde )

   ::oIde := oIde

   ::oFileWatcher := QFileSystemWatcher()
   ::oFileWatcher:connect( "fileChanged(QString)", {|cSource| ::requestSourceReload( cSource ) } )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:destroy()

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:create( oIde )

   DEFAULT oIde TO ::oIde

   ::oIde := oIde

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:requestSourceReload( cSource )

   IF ::oEM:isOpen( cSource )  /* Only watch which are already open */
      IF hbide_getYesNo( cSource + " has been changed by some external process!", "Want to re-load it again ?", "File Changed Notification!" )
         ::oEM:reLoad( cSource )
      ENDIF
      ::oEM:setSourceVisible( cSource ) /* Should the changed file be brrought to focus? I think no. */
   ENDIF

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:loadSources()
   LOCAL a_

   IF ! empty( ::oIni:aFiles )
      FOR EACH a_ IN ::oIni:aFiles
         /*            File     nPos     nVPos    nHPos    cTheme  cView lAlert lVisible, aBookMarks */
         ::editSource( a_[ 1 ], a_[ 2 ], a_[ 3 ], a_[ 4 ], a_[ 5 ], a_[ 6 ], .t., .f., a_[ 7 ], a_[ 8 ], a_[ 9 ] )
      NEXT
   ELSE
      ::editSource( "default.prg" )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:saveNamedSource( cSource )
   LOCAL lSaved, oEditor, a_, cBuffer

   cSource := hbide_pathNormalized( cSource, .t. )

   FOR EACH a_ IN ::aTabs
      oEditor := a_[ TAB_OEDITOR ]
      IF HB_ISOBJECT( oEditor )
         IF hb_FileMatch( hbide_pathNormalized( oEditor:source(), .t. ), cSource )
            IF oEditor:lLoaded
               IF oEditor:document():isModified()
                  ::oIde:setCodePage( oEditor:cCodePage )

                  cBuffer := oEditor:prepareBufferToSave( oEditor:qEdit:toPlainText() )

                  ::oFileWatcher:removePath( cSource )

                  IF ( lSaved := hb_memowrit( hbide_pathToOSPath( cSource ), cBuffer ) )
                     oEditor:document():setModified( .f. )
                     oEditor:setTabImage()
                  ENDIF

                  ::oFileWatcher:addPath( cSource )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   NEXT

   RETURN lSaved

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:editSource( cSourceFile, nPos, nHPos, nVPos, cTheme, cView, lAlert, lVisible, aBookMarks, cCodePage, cExtras )
   LOCAL lNew

   DEFAULT lAlert   TO .T.
   DEFAULT lVisible TO .T.

   IF ( lNew := empty( cSourceFile ) )
      cSourceFile := hbide_saveAFile( ::oDlg, "Provide source filename", /*aFltr*/, hbide_SetWrkFolderLast(), /*cDftSuffix*/ )
      IF empty( cSourceFile )
         RETURN Self
      ENDIF
      hbide_SetWrkFolderLast( cSourceFile )
   ENDIF

   IF ! ( cSourceFile == "default.prg" )
      IF !Empty( cSourceFile )
         IF !( hbide_isValidText( cSourceFile ) )
            MsgBox( 'File type unknown or unsupported: ' + cSourceFile )
            RETURN .f.
         ELSEIF ! lNew .AND. ! hb_FileExists( cSourceFile )
            MsgBox( 'File not found: ' + cSourceFile )
            RETURN .f.
         ENDIF
         IF ::oEM:isOpen( cSourceFile )
            IF lAlert
               IF hbide_getYesNo( cSourceFile + " is already open.", "Want to re-load it again ?", "File Open Info!" )
                  ::oEM:reLoad( cSourceFile )
               ENDIF
            ENDIF
            ::oEM:setSourceVisible( cSourceFile )
            RETURN .t.
         ENDIF
      ENDIF
   ENDIF

   DEFAULT nPos  TO 0
   DEFAULT nHPos TO 0
   DEFAULT nVPos TO 0

   IF hb_FileExists( cSourceFile )
      ::oFileWatcher:addPath( cSourceFile )
   ENDIF

   ::oEM:buildEditor( cSourceFile, nPos, nHPos, nVPos, cTheme, cView, aBookMarks, cCodePage, cExtras )
   IF lVisible
      ::oEM:setSourceVisible( cSourceFile )
   ENDIF

   IF ! Empty( cSourceFile ) .AND. ! ( cSourceFile == "default.prg" ) .AND. ! hbide_isSourcePPO( cSourceFile )
      hbide_mnuAddFileToMRU( Self, cSourceFile, "recent_files" )
   ENDIF

   RETURN .t.

/*----------------------------------------------------------------------*/
/*
 *   Save selected Tab on harddisk and return .T. if successfull!
 */
METHOD IdeSourcesManager:saveSource( nTab, lCancel, lAs )
   LOCAL oEditor, lNew, cBuffer, qDocument, nIndex, cSource, cFileTemp
   LOCAL cFileToSave, cPath, cFile, cExt, cNewFile, oItem

   DEFAULT nTab TO ::oEM:getTabCurrent()
   DEFAULT lAs  TO .F.

   lCancel := .F.

   IF ! Empty( oEditor := ::oEM:getEditorByTabPosition( nTab ) )
      nIndex  := ::qTabWidget:indexOf( oEditor:oTab:oWidget )
      cSource := oEditor:source()

      IF cSource == "default.prg"
         lAs := .t.
      ENDIF

      IF lAs .OR. Empty( cSource ) .OR. ( oEditor:lLoaded .AND. oEditor:document():isModified() )

         lNew := Empty( cSource ) .OR. lAs
         IF lNew
            cNewFile := ::selectSource( 'save', ;
                                       iif( ! Empty( cSource ), cSource, hb_dirBase() + "projects" + hb_ps() ),;
                                              "Save " + oEditor:oTab:caption + " as..." )
            IF Empty( cNewFile )
               // will check later what decision to take
               RETURN .f.
            ENDIF
            IF hb_FileMatch( hbide_pathNormalized( cNewFile ), hbide_pathNormalized( cSource ) )
               lNew := .f.
            ENDIF
         ENDIF

         cFileToSave := iif( lNew, cNewFile, cSource )
         qDocument := oEditor:document()

         ::oIde:setCodePage( oEditor:cCodePage )
         cBuffer := oEditor:prepareBufferToSave( oEditor:oEdit:widget():toPlainText() )
         //
         IF hb_FileExists( cFileToSave )
            ::oFileWatcher:removePath( cFileToSave )
         ENDIF
         IF ! hb_memowrit( cFileToSave, cBuffer )
            MsgBox( "Error saving the file " + oEditor:source() + ".",, 'Error saving file!' )
            lCancel := .T.
            RETURN .F.
         ENDIF
         IF hb_FileExists( cFileToSave )
            ::oFileWatcher:addPath( cFileToSave )
         ENDIF

         hb_fNameSplit( cFileToSave, @cPath, @cFile, @cExt )

         IF lNew
            oEditor:setSource( cFileToSave )

            oEditor:oTab:Caption := cFile + cExt
            oEditor:updateTitleBar()

            ::qTabWidget:setTabText( nIndex, cFile + cExt )
            ::qTabWidget:setTabTooltip( nIndex, cFileToSave )

            IF empty( cSource )
               /* The file is not populated in editors tree. Inject */
               ::oEM:addSourceInTree( oEditor:source() )
            ELSEIF lAs
               /* Rename the existing nodes in tree */
               IF !empty( oItem := hbide_findProjTreeItem( ::oIde, oEditor:source(), "Opened Source" ) )
                  oItem:oWidget:caption := cFile + cExt
               ENDIF
            ENDIF
         ENDIF

         qDocument:setModified( .f. )
         ::oIde:aSources := { oEditor:source() }
         ::createTags()
         ::updateFuncList()
         ::qTabWidget:setTabIcon( nIndex, QIcon( ::resPath + "tabunmodified.png" ) )
         ::oDK:setStatusText( SB_PNL_MODIFIED, " " )

         cFileTemp := hbide_pathToOSPath( oEditor:cPath + oEditor:cFile + oEditor:cExt + ".tmp" )
         ferase( cFileTemp )

         IF left( lower( cFile ), 4 ) == "cls_"
            ::oUiS:reloadIfOpen( lower( cPath ) + lower( substr( cFile, 5 ) ) + ".ui" )
         ENDIF
      ENDIF
   ENDIF

   RETURN .T.

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:closeSource( nTab, lCanCancel, lCanceled, lAsk )
   LOCAL lSave, n, oEditor

   DEFAULT nTab TO ::oEM:getTabCurrent()
   DEFAULT lAsk TO .t.

   IF !empty( oEditor := ::oEM:getEditorByTabPosition( nTab ) )

      DEFAULT lCanCancel TO .F.
      lCanceled := .F.

      IF !( oEditor:document():isModified() ) /* File has not changed, ignore the question to User */
         lSave := .F.

      ELSEIF lCanCancel
         n := hbide_getYesNoCancel( oEditor:oTab:caption, "has been modified, save this source?", 'Save?' )
         IF ( lCanceled := ( n == QMessageBox_Cancel ) )
            RETURN .F.
         ENDIF
         lSave := ( n == QMessageBox_Yes )

      ELSE
         IF lAsk
            lSave := hbide_getYesNo( oEditor:oTab:caption, "has been modified, save this source?", 'Save?' )
         ELSE
            lSave := .t.
         ENDIF
      ENDIF

      IF lSave .AND. ! ::saveSource( nTab, @lCanceled )
         IF lCanCancel
            RETURN .F.
         ENDIF
      ENDIF

      oEditor:destroy()
      ::oIde:updateTitleBar()
   ENDIF

   RETURN .T.

/*----------------------------------------------------------------------*/
/*
 * Close all opened files.
 * 02/01/2010 - 15:31:44
 */
METHOD IdeSourcesManager:closeAllSources( lCanCancel )
   LOCAL lCanceled
   LOCAL i := 0

   DEFAULT lCanCancel TO .t.

   DO WHILE ( ++i <= Len( ::aTabs ) )

       IF ::closeSource( i, lCanCancel, @lCanceled )
          i --
          LOOP
       ENDIF

       IF lCanceled
          RETURN .F.
       ENDIF
   ENDDO

   RETURN .T.

/*----------------------------------------------------------------------*/
/*
 * Close all opened files except current.
 * 02/01/2010 - 15:47:19 - vailtom
 */
METHOD IdeSourcesManager:closeAllOthers( nTab )
   LOCAL lCanceled
   LOCAL oEdit
   LOCAL nID

   DEFAULT nTab TO ::oEM:getTabCurrent()

   IF empty( oEdit := ::oEM:getEditorByTabPosition( nTab ) )
      RETURN .F.
   ENDIF

   nID  := oEdit:nID
   nTab := 0

 * Finally now we will close all tabs.
   DO WHILE ( ++nTab <= Len( ::aTabs ) )

       oEdit := ::oEM:getEditorByTabPosition( nTab )

       IF empty( oEdit ) .OR. oEdit:nID == nID
          LOOP
       ENDIF

       IF ::closeSource( nTab, .T., @lCanceled )
          nTab --
          LOOP
       ENDIF

       IF lCanceled
          RETURN .F.
       ENDIF
   ENDDO

   RETURN .T.

/*----------------------------------------------------------------------*/
/*
 * Save all opened files...
 * 01/01/2010 - 22:44:36 - vailtom
 */
METHOD IdeSourcesManager:saveAllSources()
   LOCAL n

   FOR n := 1 TO Len( ::aTabs )
      ::saveSource( n )
   NEXT

   RETURN Self

/*----------------------------------------------------------------------*/
/*
 * Save current file and exits HBIDE
 * 02/01/2010 - 18:45:06 - vailtom
 */
METHOD IdeSourcesManager:saveAndExit()

   IF ::saveSource()
      ::execAction( "Exit" )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/
/*
 * Revert current file to a previous saved file.
 * 02/01/2010 - 19:45:34
 */
METHOD IdeSourcesManager:revertSource( nTab )
   LOCAL oEditor

   DEFAULT nTab TO ::oEM:getTabCurrent()

   IF empty( oEditor := ::oEM:getEditorByTabPosition( nTab ) )
      RETURN .F.
   ENDIF

   IF !( oEditor:qDocument:isModified() )
      * File has not changed, ignore the question to User
   ELSE
      IF !hbide_getYesNo( 'Revert ' + oEditor:oTab:Caption + '?',  ;
                    'The file ' + oEditor:source() + ' has changed. '+;
                    'Discard current changes and revert contents to the previously saved on disk?', 'Revert file?' )
         RETURN Self
      ENDIF
   ENDIF

   oEditor:qEdit:setPlainText( hb_memoRead( oEditor:source() ) )
   oEditor:qEdit:ensureCursorVisible()
   ::manageFocusInEditor()

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:openSource()
   LOCAL aSrc, cSource

   IF !empty( aSrc := ::selectSource( "openmany" ) )
      FOR EACH cSource IN aSrc
         ::editSource( cSource )
      NEXT
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD IdeSourcesManager:selectSource( cMode, cFile, cTitle, cDftPath )
   LOCAL oDlg, aFltr := {}

   DEFAULT cDftPath TO ::cLastFileOpenPath

   AAdd( aFltr, { "PRG Sources"    , "*.prg" } )
   AAdd( aFltr, { "Harbour Scripts", "*.hb"  } )
   AAdd( aFltr, { "C Sources"      , "*.c"   } )
   AAdd( aFltr, { "CPP Sources"    , "*.cpp" } )
   AAdd( aFltr, { "H Headers"      , "*.h"   } )
   AAdd( aFltr, { "CH Headers"     , "*.ch"  } )
   AAdd( aFltr, { "UI Files"       , "*.ui"  } )
   AAdd( aFltr, { "QRC Files"      , "*.qrc" } )
   AAdd( aFltr, { "HBC Files"      , "*.hbc" } )
   AAdd( aFltr, { "All Files"      , "*.*"   } )

   oDlg := XbpFileDialog():new():create( ::oDlg, , { 10,10 } )

   IF cMode == "open"
      oDlg:title       := "Select a Source File"
      oDlg:center      := .t.
      oDlg:fileFilters := aFltr

      cFile := oDlg:open( cDftPath, , .f. )
      IF !empty( cFile )
         ::oIde:cLastFileOpenPath := cFile
      ENDIF

   ELSEIF cMode == "openmany"
      oDlg:title       := "Select Source(s)"
      oDlg:center      := .t.
      oDlg:defExtension:= 'prg'
      oDlg:fileFilters := aFltr

      cFile := oDlg:open( cDftPath, , .t. )
      IF !empty( cFile ) .AND. !empty( cFile[ 1 ] )
         ::oIde:cLastFileOpenPath := cFile[ 1 ]
      ENDIF

   ELSEIF cMode == "save"
      oDlg:title       := iif( !HB_ISSTRING( cTitle ), "Save as...", cTitle )
      oDlg:center      := .t.
      oDlg:defExtension:= 'prg'
      oDlg:fileFilters := aFltr
      cFile := oDlg:saveAs( cFile )

   ELSE
      oDlg:title       := "Save this Database"
      oDlg:fileFilters := { { "Database Files", "*.dbf" } }
      oDlg:quit        := {|| MsgBox( "Quitting the Dialog" ), 1 }
      cFile := oDlg:saveAs( "myfile.dbf" )
      IF !empty( cFile )
         HB_TRACE( HB_TR_DEBUG, cFile )
      ENDIF

   ENDIF

   oDlg:destroy()

   RETURN cFile

/*----------------------------------------------------------------------*/
