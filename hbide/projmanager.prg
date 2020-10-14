/*
 * $Id: projmanager.prg 446 2017-02-14 22:01:12Z bedipritpal $
 */

/*
 * Copyright 2009-2015 Pritpal Bedi <bedipritpal@hotmail.com>
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
 *                  Pritpal Bedi <bedipritpal@hotmail.com>
 *                               03Jan2010
 */
/*----------------------------------------------------------------------*/

#include "hbtoqt.ch"
#include "hbqtstd.ch"
#include "hbqtgui.ch"
#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"


/*----------------------------------------------------------------------*/
//                         CLASS IdeSelectSource
/*----------------------------------------------------------------------*/

CLASS IdeSelectSource

   DATA   oUI
   DATA   cPath
   DATA   aSrcSelected                            INIT {}
   DATA   aSrc3rd                                 INIT {}
   DATA   aExt                                    INIT {}
   DATA   lOK                                     INIT .F.
   DATA   cHbp                                    INIT ""
   DATA   cType                                   INIT "Executable"
   DATA   cGT                                     INIT ""
   DATA   lShared                                 INIT .F.
   DATA   lFullStatic                             INIT .F.
   DATA   lHbQt                                   INIT .F.
   DATA   lTrace                                  INIT .F.
   DATA   lInfo                                   INIT .F.
   DATA   lInc                                    INIT .F.
   DATA   lGui                                    INIT .F.
   DATA   lMt                                     INIT .F.
   DATA   lA                                      INIT .F.
   DATA   lB                                      INIT .F.
   DATA   lEs                                     INIT .F.
   DATA   lG                                      INIT .F.
   DATA   lM                                      INIT .F.
   DATA   lN                                      INIT .F.
   DATA   lV                                      INIT .F.
   DATA   lW                                      INIT .F.
   DATA   cES                                     INIT ""
   DATA   cG                                      INIT ""
   DATA   cM                                      INIT ""
   DATA   cW                                      INIT ""

   METHOD new()
   METHOD create()
   METHOD buildUI()
   METHOD loadSources( cPathFile )
   METHOD toggleSelection( lSelect )
   METHOD selectSources( cExt )
   METHOD unSelectSources( cExt )
   METHOD pullData()

   ENDCLASS


METHOD IdeSelectSource:new()
   RETURN Self


METHOD IdeSelectSource:create()
   LOCAL nRes

   ::buildUI()
   WITH OBJECT ::oUI
      nRes := :oWidget:exec()                     /* Display on the Screen */
      IF nRes == 1                                /* Only IF OK is clicked */
         ::pullData()
         ::lOk := .T.
      ENDIF
      :oWidget:setParent( QWidget() )
   ENDWITH
   RETURN Self


METHOD IdeSelectSource:pullData()
   LOCAL i, cSrc

   ::cHbp  := ::oUI:editHbp:text()
   ::cType := ::oUI:comboType:currentText()

   FOR i := 0 TO ::oUI:treeSources:topLevelItemCount() - 1
      IF ::oUI:treeSources:topLevelItem( i ):checkState( 0 ) == Qt_Checked
         cSrc := hbide_prepareSourceForHbp( ::oUI:treeSources:topLevelItem( i ):text( 0 ) )
         IF Left( cSrc, 2 ) == "-3"
            AAdd( ::aSrc3rd, cSrc )
         ELSE
            AAdd( ::aSrcSelected, cSrc )
         ENDIF

      ENDIF
   NEXT

   ::cGT            := ::oUI:comboGT      :currentText()
   ::lShared        := ::oUI:chkShared    :isChecked()
   ::lFullStatic    := ::oUI:chkFullStatic:isChecked()
   ::lHbQt          := ::oUI:chkHbQt      :isChecked()
   ::lTrace         := ::oUI:chkTrace     :isChecked()
   ::lInfo          := ::oUI:chkInfo      :isChecked()
   ::lInc           := ::oUI:chkInc       :isChecked()
   ::lGui           := ::oUI:chkGui       :isChecked()
   ::lMt            := ::oUI:chkMt        :isChecked()
   ::lA             := ::oUI:chkA         :isChecked()
   ::lB             := ::oUI:chkB         :isChecked()
   ::lEs            := ::oUI:chkEs        :isChecked()
   ::lG             := ::oUI:chkG         :isChecked()
   ::lM             := ::oUI:chkM         :isChecked()
   ::lN             := ::oUI:chkN         :isChecked()
   ::lV             := ::oUI:chkV         :isChecked()
   ::lW             := ::oUI:chkW         :isChecked()
   ::cES            := ::oUI:editES       :text()
   ::cG             := ::oUI:editG        :text()
   ::cM             := ::oUI:editM        :text()
   ::cW             := ::oUI:editW        :text()
   RETURN Self


METHOD IdeSelectSource:toggleSelection( lSelect )
   LOCAL i, oItm

   FOR i := 0 TO ::oUI:treeSources:topLevelItemCount() - 1
      oItm := ::oUI:treeSources:topLevelItem( i )
      oItm:setCheckState( 0, iif( lSelect, Qt_Checked, Qt_Unchecked ) )
   NEXT
   RETURN Self


METHOD IdeSelectSource:selectSources( cExt )
   LOCAL i, oItm

   FOR i := 0 TO ::oUI:treeSources:topLevelItemCount() - 1
      oItm := ::oUI:treeSources:topLevelItem( i )
      IF Lower( hb_FNameExt( oItm:text( 0 ) ) ) == cExt
         oItm:setCheckState( 0, Qt_Checked )
      ENDIF
   NEXT
   RETURN Self


METHOD IdeSelectSource:unSelectSources( cExt )
   LOCAL i, oItm

   FOR i := 0 TO ::oUI:treeSources:topLevelItemCount() - 1
      oItm := ::oUI:treeSources:topLevelItem( i )
      IF Lower( hb_FNameExt( oItm:text( 0 ) ) ) == cExt
         oItm:setCheckState( 0, Qt_Unchecked )
      ENDIF
   NEXT
   RETURN Self


METHOD IdeSelectSource:loadSources( cPathFile )
   LOCAL lOk, aDir, aSrc, cSrc, cExt, oItm, a_, cPath

   ::oUI:treeSources:clear()
   ::oUI:comboSelect:clear()
   ::oUI:comboUnSelect:clear()

   ::oUI:treeSources:headerItem():setText( 0, "..." )

   ::aExt := {}

   hb_FNameSplit( cPathFile, @cPath )

   lOk := !( " " $ cPathFile ) .AND. Lower( hb_FNameExt( cPathFile ) ) == ".hbp" .AND. ! hb_FileExists( cPathFile ) .AND. hb_DirExists( cPath )
   ::oUI:btnOK:setEnabled( lOk )
   IF ! lOk
      RETURN Self
   ENDIF

   aSrc := {}
   aDir := Directory( cPath + "*.*" )
   IF ! Empty( aDir )
      FOR EACH a_ IN aDir
         IF a_[ 1 ] == "." .OR. a_[ 1 ] == ".."
            // Nothing TO do
         ELSEIF a_[ 5 ] == "D"
            // later
         ELSE
            cExt := Lower( hb_FNameExt( a_[ 1 ] ) )
            IF ! Empty( cExt ) .AND. cExt $ ".h,.c,.cpp,.prg,.hb,.rc,.res,.hbm,.hbc,.qrc,.ui,.hbp,.ch"
               AAdd( aSrc, a_[ 1 ] )
               IF AScan( ::aExt, {|e| e == cExt } ) == 0
                  AAdd( ::aExt, cExt )
               ENDIF
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF Empty( aSrc )
      RETURN Self
   ENDIF
   ASort( aSrc, , , {|e, f| Lower( hb_FNameExt( e ) ) + Lower( hb_FNameName( e ) ) <  Lower( hb_FNameExt( f ) ) + Lower( hb_FNameName( f ) ) } )

   FOR EACH cExt IN ::aExt
      ::oUI:comboSelect:addItem( cExt )
      ::oUI:comboUnSelect:addItem( cExt )
   NEXT

   FOR EACH cSrc IN aSrc
      cExt := Lower( hb_FNameExt( cSrc ) )
      WITH OBJECT oItm := QTreeWidgetItem()
         :setFlags( Qt_ItemIsEnabled + Qt_ItemIsSelectable + Qt_ItemIsUserCheckable )
         :setText( 0, cSrc )
         :setToolTip( 0, hbide_pathNormalized( cPath + cSrc ) )
         ::oUI:treeSources:addTopLevelItem( oItm )
         :setCheckState( 0, Qt_Checked )
         IF  ! ( cExt == ".h" ) .AND. ( cExt $ ".hbc,.hbp,.hbm" )
            :setCheckState( 0, Qt_Unchecked )
         ENDIF
      ENDWITH
   NEXT

   ::oUI:treeSources:headerItem():setText( 0, cPath )
   ::oUI:treeSources:headerItem():setForeGround( 0, QBrush( QColor( 0,0,255 ) ) )
   ::cPath := cPath
   RETURN Self


METHOD IdeSelectSource:buildUI()

   WITH OBJECT ::oUI := hbide_getUI( "SelectSources" )
      :comboType:addItem( "Executable" )
      :comboType:addItem( "Library" )
      :comboType:addItem( "Dll" )
      :comboType:setCurrentIndex( 0 )

      :comboSelect  :connect( "currentIndexChanged(QString)", {|cExt| ::selectSources( cExt ) } )
      :comboUnSelect:connect( "currentIndexChanged(QString)", {|cExt| ::unSelectSources( cExt ) } )

      :btnOK    :connect( "clicked()", {|| ::oUI:oWidget:done( 1 ) } )
      :btnCancel:connect( "clicked()", {|| ::oUI:oWidget:done( 0 ) } )

      :checkSelect:connect( "stateChanged(int)", {|iState|  ::toggleSelection( iState == 2 ) } )

      WITH OBJECT :comboGT
         : addItem( "gtWIN" )
         : addItem( "gtWVT" )
         : addItem( "gtWVG" )
         : addItem( "gtCGI" )
         : addItem( "gtCRS" )
         : addItem( "gtDOS" )
         : addItem( "gtGUI" )
         : addItem( "gtOS2" )
         : addItem( "gtPCA" )
         : addItem( "gtSLN" )
         : addItem( "gtSTD" )
         : addItem( "gtTRM" )
         : addItem( "gtXWC" )

         : setCurrentIndex( 0 )
      ENDWITH

      :btnHbp:setIcon( QIcon( hbide_image( "folder" ) ) )

      :btnHbp:connect( "clicked()", {|| hbide_fetchProject( :editHbp ) } )
      :editHbp:connect( "textChanged(QString)", {|cPath| ::loadSources( cPath ) } )
      :editHbp:setText( hbide_getNextProject( hbide_setWorkingProjectFolder() ) )
   ENDWITH
   RETURN Self

/*----------------------------------------------------------------------*/
//                             Class IdeSource
/*----------------------------------------------------------------------*/

CLASS IdeSource

   DATA  original
   DATA  normalized
   DATA  filter
   DATA  path
   DATA  file
   DATA  ext
   DATA  projPath

   METHOD new( cSource )

   ENDCLASS


METHOD IdeSource:new( cSource )
   LOCAL cFilt, cPathFile, cPath, cFile, cExt

   cSource := hbide_pathToOSPath( cSource )

   hbide_parseHbpFilter( cSource, @cFilt, @cPathFile )
   hb_fNameSplit( cPathFile, @cPath, @cFile, @cExt )

   //::original   := cSource
   ::original   := cPathFile
   ::normalized := hbide_pathNormalized( cSource, .t. )
   ::filter     := cFilt
   ::path       := hbide_pathNormalized( cPath, .t. )
   ::file       := cFile
   //::ext        := lower( cExt )
   ::ext        := cExt
   RETURN Self

/*----------------------------------------------------------------------*/
//                             Class IdeProject
/*----------------------------------------------------------------------*/

CLASS IdeProject

   DATA   aProjProps                              INIT {}
   DATA   fileName                                INIT ""
   DATA   normalizedName                          INIT ""
   DATA   type                                    INIT "Executable"
   DATA   title                                   INIT ""
   DATA   location                                INIT hb_dirBase() + "projects"
   DATA   destination                             INIT ""
   DATA   outputName                              INIT ""
   DATA   backup                                  INIT ""
   DATA   launchParams                            INIT ""
   DATA   launchProgram                           INIT ""
   DATA   wrkDirectory                            INIT ""
   DATA   isXhb                                   INIT .f.
   DATA   isXpp                                   INIT .f.
   DATA   isClp                                   INIT .f.
   DATA   hbpFlags                                INIT {}
   DATA   sources                                 INIT {}
   DATA   dotHbp                                  INIT ""
   DATA   compilers                               INIT ""
   DATA   cPathHbMk2
   DATA   hSources                                INIT {=>}
   DATA   hPaths                                  INIT {=>}
   DATA   lPathAbs                                INIT .F.  // Lets try relative paths first . xhp and hbp will be relative anyway
   DATA   projPath                                INIT ""

   METHOD new( oIDE, aProps )

   ENDCLASS


METHOD IdeProject:new( oIDE, aProps )
   LOCAL b_, a_, oSource, cSource,  aDir, cPath, cExt

   IF HB_ISARRAY( aProps ) .AND. !empty( aProps )
      ::aProjProps := aProps

      b_:= aProps
      a_:= b_[ PRJ_PRP_PROPERTIES, 2 ]

      ::type           := a_[ PRJ_PRP_TYPE      ]
      ::title          := a_[ PRJ_PRP_TITLE     ]
      ::location       := ""                        /* See below */
      ::wrkDirectory   := a_[ PRJ_PRP_WRKFOLDER ]
      ::destination    := a_[ PRJ_PRP_DSTFOLDER ]
      ::outputName     := a_[ PRJ_PRP_OUTPUT    ]
      ::launchParams   := a_[ PRJ_PRP_LPARAMS   ]
      ::launchProgram  := a_[ PRJ_PRP_LPROGRAM  ]
      ::backup         := a_[ PRJ_PRP_BACKUP    ]
      ::isXhb          := a_[ PRJ_PRP_XHB       ] == "YES"
      ::isXpp          := a_[ PRJ_PRP_XPP       ] == "YES"
      ::isClp          := a_[ PRJ_PRP_CLP       ] == "YES"

      ::projPath       := oIde:oPM:getProjectPathFromTitle( ::title )
      IF empty( ::projPath )
         ::projPath := hb_dirBase()               /* In case of new project */
      ENDIF
      ::location       := ::projPath

      ::hbpFlags       := aclone( b_[ PRJ_PRP_FLAGS   , 2 ] )
      ::sources        := aclone( b_[ PRJ_PRP_SOURCES , 2 ] )
      ::dotHbp         := ""
      ::compilers      := ""

      ::cPathHbMk2 := oIde:oINI:getHbmk2File()

      FOR EACH cSource IN ::sources
         IF ! ( Left( cSource, 1 ) $ "-$" )
            cSource := hbide_syncProjPath( ::projPath, cSource )
            hb_FNameSplit( cSource, @cPath, , @cExt )

            FOR EACH aDir IN Directory( hbide_pathToOSpath( cSource ) )
               oSource := IdeSource():new( cPath + aDir[ 1 ] )
               oSource:projPath := ::projPath
               ::hSources[ oSource:normalized ] := oSource
               ::hPaths[ oSource:path ] := NIL
            NEXT
         ENDIF
      NEXT
   ENDIF
   RETURN Self

/*----------------------------------------------------------------------*/
//                            IdeProjectManager
/*----------------------------------------------------------------------*/

CLASS IdeProjManager INHERIT IdeObject

   DATA   cargo
   DATA   cSaveTo
   DATA   aPrjProps                               INIT {}
   DATA   nStarted                                INIT 0
   DATA   lLaunch                                 INIT .F.
   DATA   cProjectInProcess                       INIT ""
   DATA   cPPO                                    INIT ""
   DATA   lPPO                                    INIT .F.
   DATA   oProject
   DATA   cBatch
   DATA   oProcess
   DATA   lSaveOK                                 INIT .F.
   DATA   cProjFileName                           INIT ""
   DATA   lNew                                    INIT .F.
   DATA   lFetch                                  INIT .T.
   DATA   lUpdateTree                             INIT .F.
   DATA   cIfError                                INIT NIL
   DATA   oSelSrc
   DATA   oEdit
   DATA   oTheme
   DATA   oHiliter
   DATA   nProgValue                              INIT 0

   METHOD new( oIDE )
   METHOD create( oIDE )
   METHOD destroy()

   METHOD populate()
   METHOD loadProperties( cProjFileName, lNew, lFetch, lUpdateTree )
   METHOD fetchProperties()
   METHOD getProperties()
   METHOD sortSources( cMode )
   METHOD save( lCanClose, lUpdateTree )
   METHOD updateHbp( iIndex )
   METHOD addSources()
   METHOD addSourcesToProject( aFiles )

   METHOD selectAProject()
   METHOD setCurrentProject( cProjectName )
   METHOD selectCurrentProject()

   METHOD getCurrentProject( lAlert )
   METHOD getCurrentProjectTitle()
   METHOD getProjectProperties( cProjectTitle )

   METHOD getProjectByFile( cProjectFile )
   METHOD getProjectByTitle( cProjectTitle )
   METHOD getProjectsTitleList()

   METHOD getProjectFileNameFromTitle( cProjectTitle )
   METHOD getProjectTypeFromTitle( cProjectTitle )
   METHOD getProjectPathFromTitle( cProjectTitle )
   METHOD getSourcesByProjectTitle( cProjectTitle )

   METHOD removeProject( cProjectTitle )
   METHOD closeProject( cProjectTitle )
   METHOD promptForPath( oEditPath, cTitle, cObjFileName )
   METHOD buildSource( lExecutable )
   METHOD buildProject( cProject, lLaunch, lRebuild, lPPO, lViaQt, cWrkEnviron, lDebug )
   METHOD getCurrentExeName( cProject )
   METHOD launchDebug( cProject, cExe, cCmd, qStr, cWrkDir )
   METHOD launchProject( cProject, cExe, cWrkEnviron, lDebug )
   METHOD showOutput( cOutput, mp2, oProcess )
   METHOD finished( nExitCode, nExitStatus, oProcess, cWrkEnviron, lDebug )
   METHOD isValidProjectLocation( lTell )
   METHOD setProjectLocation( cPath )
   METHOD buildInterface()
   METHOD pullHbpData( cHbp )
   METHOD synchronizeAlienProject( cProjFileName )
   METHOD outputText( cText )
   METHOD runAsScript()
   METHOD insertHeader( aHdr, aHbp )
   METHOD stripHeader( aHbp )
   METHOD moveLine( nDirection )
   METHOD loadSelectedSources()
   METHOD addSourceToArray( aSrc, aTgt, cExt )

   ENDCLASS


METHOD IdeProjManager:new( oIDE )
   ::oIDE := oIDE
   RETURN Self


METHOD IdeProjManager:create( oIDE )
   DEFAULT oIDE TO ::oIDE
   ::oIDE := oIDE
   RETURN Self


METHOD IdeProjManager:destroy()

   IF !empty( ::oUI )
      ::oUI:buttonCn          :disconnect( "clicked()" )
      ::oUI:buttonSave        :disconnect( "clicked()" )
      ::oUI:buttonSaveExit    :disconnect( "clicked()" )
      ::oUI:buttonSelect      :disconnect( "clicked()" )
      ::oUI:buttonUp          :disconnect( "clicked()" )
      ::oUI:buttonDown        :disconnect( "clicked()" )
   // ::oUI:buttonSort        :disconnect( "clicked()" )
   // ::oUI:buttonSortZA      :disconnect( "clicked()" )
   // ::oUI:buttonSortOrg     :disconnect( "clicked()" )
   // ::oUI:tabWidget         :disconnect( "currentChanged(int)" )
      ::oUI:buttonChoosePrjLoc:disconnect( "clicked()" )
      ::oUI:buttonChooseWd    :disconnect( "clicked()" )
      ::oUI:buttonChooseDest  :disconnect( "clicked()" )
      ::oUI:buttonBackup      :disconnect( "clicked()" )
      ::oUI:editPrjLoctn      :disconnect( "textChanged(QString)" )

      ::oUI:destroy()
   ENDIF

   IF !empty( ::aPrjProps )
      ::aPrjProps[ 1,1 ] := NIL
      ::aPrjProps[ 1,2 ] := NIL
      ::aPrjProps[ 1   ] := NIL
      ::aPrjProps[ 2,1 ] := NIL
      ::aPrjProps[ 2,2 ] := NIL
      ::aPrjProps[ 2   ] := NIL
      ::aPrjProps[ 3,1 ] := NIL
      ::aPrjProps[ 3,2 ] := NIL
      ::aPrjProps[ 3   ] := NIL
      ::aPrjProps[ 4,1 ] := NIL
      ::aPrjProps[ 4,2 ] := NIL
      ::aPrjProps[ 4   ] := NIL
      ::aPrjProps[ 5   ] := NIL

      ::aPrjProps := NIL
   ENDIF
   RETURN Self


METHOD IdeProjManager:populate()
   LOCAL cProject

   FOR EACH cProject IN ::oINI:aProjFiles
      ::loadProperties( cProject, .f., .f., .T. )
   NEXT
   RETURN Self


METHOD IdeProjManager:getProperties()
   LOCAL cTmp, n

   cTmp := ::getCurrentProject()
   IF ( n := ascan( ::aProjects, {|e_| e_[ 3, PRJ_PRP_PROPERTIES, 2, PRJ_PRP_TITLE ] == cTmp } ) ) > 0
      ::loadProperties( ::aProjects[ n, 1 ], .f., .t., .t. )
   ENDIF
   RETURN Self


METHOD IdeProjManager:loadProperties( cProjFileName, lNew, lFetch, lUpdateTree )
   LOCAL nAlready, cProjPath, cPath, cName, cExt, aTypes

   DEFAULT cProjFileName TO ""
   DEFAULT lNew          TO .F.
   DEFAULT lFetch        TO .T.
   DEFAULT lUpdateTree   TO .F.

   ::cProjFileName  := cProjFileName
   ::lNew           := lNew
   ::lFetch         := lFetch
   ::lUpdateTree    := lUpdateTree

   ::aPrjProps      := {}
   ::cSaveTo        := ""
   ::oProject       := NIL

   IF lNew
      lFetch := .t.
   ELSE
      IF empty( cProjFileName )
         aTypes := { { "Harbour Make Projects", "*.hbp" } , ;
                     { "xMate Projects"       , "*.xhp" } , ;
                     { "xBuild Projects"      , "*.xbp" } }

         IF Empty( cProjFileName := hbide_fetchAFile( ::oDlg, "Open Project...", aTypes, ::oIde:cLastFileOpenPath ) )
            RETURN Self
         ENDIF
         hb_FNameSplit( cProjFileName, @cPath )
         ::oIde:cLastFileOpenPath := cPath

         cProjFileName := ::synchronizeAlienProject( cProjFileName )
         ::oDockPT:show()
      ENDIF
      IF empty( cProjFileName )
         RETURN Self
      ENDIF
   ENDIF

   cProjFileName := hbide_pathToOSPath( cProjFileName )

   ::oIde:oPropertiesDock:setWindowTitle( cProjFileName )

   nAlready := ascan( ::aProjects, {|e_| hb_FileMatch( e_[ 1 ], hbide_pathNormalized( cProjFileName ) ) } )

   IF !empty( cProjFileName ) .AND. hb_fileExists( cProjFileName )
      ::aPrjProps  := ::pullHbpData( hbide_pathToOSPath( cProjFileName ) )
   ENDIF

   ::oSelSrc := NIL

   IF lFetch
      ::oPropertiesDock:hide()
      QApplication():processEvents()

      /* Access/Assign via this object */
      ::oProject := IdeProject():new( ::oIDE, ::aPrjProps )

      IF lNew
         ::oSelSrc := IdeSelectSource():new():create()
         IF ! ::oSelSrc:lOk
            RETURN Self
         ENDIF

         hb_FNameSplit( ::oSelSrc:cHbp, @cPath, @cName, @cExt )

         cProjFileName         := cPath + cName + cExt
         cPath                 := hbide_pathAppendLastSlash( cPath )
         cProjPath             := cPath
         ::oProject:title      := Upper( SubStr( cName,1,1 ) ) + SubStr( cName, 2 )
         ::oProject:outputName := cName

         hbide_SetWrkFolderLast( cProjPath )
      ENDIF

      IF ! Empty( cProjPath )
         ::oProject:location := hbide_pathNormalized( cProjPath, .f. )
         ::oProject:projPath := ::oProject:location
      ENDIF

      ::oPropertiesDock:show()
   ELSE
      IF ! Empty( ::aPrjProps )
         IF nAlready == 0
            aadd( ::oIDE:aProjects, { hbide_pathNormalized( cProjFileName ), cProjFileName, aclone( ::aPrjProps ) } )
            IF lUpdateTree
               ::oIDE:updateProjectTree( ::aPrjProps )
            ENDIF
            hbide_mnuAddFileToMRU( ::oIDE, cProjFileName, "recent_projects" )
         ELSE
            ::aProjects[ nAlready, 3 ] := aclone( ::aPrjProps )
            IF lUpdateTree
               ::oIDE:updateProjectTree( ::aPrjProps )
            ENDIF
         ENDIF
      ENDIF

      ::oHM:refresh()  /* Rearrange Projects Data */
   ENDIF
   ::oIde:oPropertiesDock:setWindowTitle( cProjFileName )
   RETURN Self


//  Without user-interface
//
METHOD IdeProjManager:pullHbpData( cHbp )
   LOCAL n, n1, s, cKey, cVal, aOptns, aFiles, c3rd, nL, aData, cHome, cOutName, cType
   LOCAL aPrp := { ;
            "hbide_type="              , ;
            "hbide_title="             , ;
            "hbide_location="          , ;
            "hbide_workingfolder="     , ;
            "hbide_destinationfolder=" , ;
            "hbide_output="            , ;
            "hbide_launchparams="      , ;
            "hbide_launchprogram="     , ;
            "hbide_backupfolder="      , ;
            "hbide_xhb="               , ;
            "hbide_xpp="               , ;
            "hbide_clp="               , ;
            "hbide_launchim="            ;
         }

   LOCAL a1_0 := afill( array( PRJ_PRP_PRP_VRBLS ), "" )
   LOCAL a1_1 := {}
   LOCAL a2_0 := {}
   LOCAL a2_1 := {}
   LOCAL a3_0 := {}
   LOCAL a3_1 := {}
   LOCAL a4_0 := {}
   LOCAL a4_1 := {}
   LOCAL a3rd := {}

   hb_fNameSplit( cHbp, @cHome, @cOutName )
   cHome  := hbide_pathStripLastSlash( cHome )

   c3rd   := "-3rd="
   nL     := Len( c3rd )
   aData  := hbide_fetchHbpData( cHbp )
   aOptns := aData[ 1 ]
   aFiles := aData[ 2 ]

   FOR EACH s IN aFiles
      s := hbide_stripRoot( cHome, s )
   NEXT

   IF ( n := ascan( aOptns, {|e| lower( e ) $ "-hbexe,-hblib,-hbdyn" } ) ) > 0
      cType := lower( aOptns[ n ] )
      cType := iif( cType == "-hblib", "Lib", iif( cType == "-hbdyn", "Dll", "Executable" ) )
   ELSE
      cType := "Executable"
   ENDIF

   /* Separate HbIDE specific flags */
   FOR EACH s IN aOptns
      IF ( n := at( c3rd, s ) ) > 0
         IF ( n1 := hb_at( " ", s, n ) ) > 0
            aadd( a3rd, substr( s, n + nL, n1 - n - nL ) )
            s := substr( s, 1, n - 1 ) + substr( s, n1 )
         ELSE
            aadd( a3rd, substr( s, n + nL ) )
            s := substr( s, 1, n - 1 )
         ENDIF
      ENDIF
   NEXT

   /* PRJ_PRP_PROPERTIES */
   FOR EACH s IN a3rd
      IF ( n := at( "=", s ) ) > 0
         cKey := alltrim( substr( s, 1, n ) )
         cVal := alltrim( substr( s, n + 1 ) )

         IF ( n := ascan( aPrp, {|e| e == cKey } ) ) > 0
            a1_0[ n ] := hbide_amp2space( cVal )
         ENDIF
      ENDIF
   NEXT

   a1_0[ PRJ_PRP_TYPE     ] := iif( empty( a1_0[ PRJ_PRP_TYPE  ] ), cType   , a1_0[ PRJ_PRP_TYPE  ] )
   a1_0[ PRJ_PRP_TITLE    ] := iif( empty( a1_0[ PRJ_PRP_TITLE ] ), cOutName, a1_0[ PRJ_PRP_TITLE ] )
   a1_0[ PRJ_PRP_OUTPUT   ] := cOutName
   a1_0[ PRJ_PRP_LOCATION ] := hbide_pathNormalized( cHome )

   /* PRJ_PRP_FLAGS */
   FOR EACH s IN aOptns
      IF !empty( s )
         aadd( a2_0, s )
      ENDIF
   NEXT

   /* PRJ_PRP_SOURCES */
   FOR EACH s IN aFiles
      aadd( a3_0, s )
   NEXT

   /* Check sources which are not compilable but make-up source list */
   FOR EACH s IN a3rd
      IF "hbide_file=" == lower( left( s, 11 ) )
         aadd( a3_0, hbide_stripRoot( cHome, alltrim( substr( s, 12 ) ) ) )
      ENDIF
   NEXT

   /* Properties */
   FOR EACH s IN a1_0
      aadd( a1_1, s )
   NEXT

   /* Flags */
   IF !empty( a2_0 )
      FOR EACH s IN a2_0
         aadd( a2_1, s )
      NEXT
   ENDIF

   /* Sources */
   IF !empty( a3_0 )
      FOR EACH s IN a3_0
         IF !( "#" == left( s,1 ) ) .and. !empty( s )
            aadd( a3_1, hbide_stripRoot( cHome, hbide_stripFilter( s ) ) )
         ENDIF
      NEXT
   ENDIF
   RETURN { { a1_0, a1_1 }, { a2_0, a2_1 }, { a3_0, a3_1 }, { a4_0, a4_1 }, hbide_readSource( cHbp ) }


METHOD IdeProjManager:save( lCanClose, lUpdateTree )
   LOCAL a_, lOk, txt_, nAlready
   LOCAL c3rd := "-3rd="
   LOCAL hdr_:= {}

   DEFAULT lUpdateTree TO .F.

   * Validate certain parameters before continuing ... (vailtom)

   IF Empty( ::oUI:editPrjTitle:text() )
      ::oUI:editPrjTitle:setText( ::oUI:editOutName:text() )
   ENDIF

   IF Empty( ::oUI:editOutName:text() )
      MsgBox( 'Invalid Output FileName' )
      ::oUI:editOutName:setFocus()
      RETURN .F.
   ENDIF

   /* This must be valid, we cannot skip */
   IF ! hbide_isValidPath( ::oUI:editPrjLoctn:text(), 'Project Location' )
      ::oUI:editPrjLoctn:setFocus()
      RETURN .F.
   ENDIF

   txt_:= {}
   //
   aadd( hdr_, c3rd + "hbide_version="              + "1.0" )
   //
   IF ::oUI:comboPrjType:currentIndex() != 0
      aadd( hdr_, c3rd + "hbide_type="              + { "Executable", "Lib", "Dll" }[ ::oUI:comboPrjType:currentIndex() + 1 ] )
   ENDIF
   IF ! Empty( ::oUI:editPrjTitle    :text() )
      aadd( hdr_, c3rd + "hbide_title="             + hbide_space2amp( ::oUI:editPrjTitle    :text() ) )
   ENDIF
   IF ! Empty( ::oUI:editWrkFolder   :text() )
      aadd( hdr_, c3rd + "hbide_workingfolder="     + hbide_space2amp( ::oUI:editWrkFolder   :text() ) )
   ENDIF
   IF ! Empty( ::oUI:editDstFolder   :text() )
      aadd( hdr_, c3rd + "hbide_destinationfolder=" + hbide_space2amp( ::oUI:editDstFolder   :text() ) )
   ENDIF
   IF ! Empty( ::oUI:editOutName     :text() )
      aadd( hdr_, c3rd + "hbide_output="            + hbide_space2amp( ::oUI:editOutName     :text() ) )
   ENDIF
   IF ! Empty( ::oUI:editLaunchParams:text() )
      aadd( hdr_, c3rd + "hbide_launchparams="      + hbide_space2amp( ::oUI:editLaunchParams:text() ) )
   ENDIF
   IF ! Empty( ::oUI:editLaunchExe   :text() )
      aadd( hdr_, c3rd + "hbide_launchprogram="     + hbide_space2amp( ::oUI:editLaunchExe   :text() ) )
   ENDIF
   IF ! Empty( ::oUI:editBackup      :text() )
      aadd( hdr_, c3rd + "hbide_backupfolder="      + hbide_space2amp( ::oUI:editBackup      :text() ) )
   ENDIF
   IF ::oUI:checkXhb:isChecked()
      aadd( hdr_, c3rd + "hbide_xhb="               + iif( ::oUI:checkXhb:isChecked(), "YES", "NO" )   )
   ENDIF
   IF ::oUI:checkXpp:isChecked()
      aadd( hdr_, c3rd + "hbide_xpp="               + iif( ::oUI:checkXpp:isChecked(), "YES", "NO" )   )
   ENDIF
   IF ::oUI:checkClp:isChecked()
      aadd( hdr_, c3rd + "hbide_clp="               + iif( ::oUI:checkClp:isChecked(), "YES", "NO" )   )
   ENDIF

   a_:= hbide_synchronizeForHbp( hbide_memoToArray( ::oUI:editSources:toPlainText() ) )
   a_:= ::insertHeader( hdr_, a_ )
   aeval( a_, {|e| aadd( txt_, e ) } )
   aadd( txt_, " " )

   ::cSaveTo := ::oUI:editPrjLoctn:text() + ::pathSep + ::oUI:editOutName:text() + ".hbp"

   ::cSaveTo := hbide_pathToOSPath( ::cSaveTo )

   IF ( lOk := hbide_createTarget( ::cSaveTo, txt_ ) )
      ::aPrjProps := ::pullHbpData( hbide_pathToOSPath( ::cSaveTo ) )

      IF ( nAlready := ascan( ::aProjects, {|e_| hb_FileMatch( e_[ 1 ], hbide_pathNormalized( ::cSaveTo ) ) } ) ) == 0
         aadd( ::oIDE:aProjects, { hbide_pathNormalized( ::cSaveTo ), ::cSaveTo, aclone( ::aPrjProps ) } )
         IF lUpdateTree
            ::oIDE:updateProjectTree( ::aPrjProps )
         ENDIF
         hbide_mnuAddFileToMRU( ::oIDE, ::cSaveTo, "recent_projects" )
      ELSE
         ::aProjects[ nAlready, 3 ] := aclone( ::aPrjProps )
         IF lUpdateTree
            ::oIDE:updateProjectTree( ::aPrjProps )
         ENDIF
      ENDIF

      ::oHM:refresh()  /* Rearrange Projects Data */
   ELSE
      MsgBox( 'Error saving project file: ' + ::cSaveTo, 'Error saving project ...' )
   ENDIF
   IF lCanClose .AND. lOk
      ::oPropertiesDock:hide()
   ENDIF
   IF lOk
      ::oDockPT:show()
   ENDIF
   RETURN lOk


METHOD IdeProjManager:insertHeader( aHdr, aHbp )
   LOCAL txt_:={}

   aadd( txt_, "#" )
   aadd( txt_, "# $" + "Id" + "$" )
   aadd( txt_, "#" )
   aadd( txt_, "" )
   aeval( aHdr, {|e| aadd( txt_, e ) } )
   aadd( txt_, "" )
   aeval( aHbp, {|e| aadd( txt_, e ) } )
   aadd( txt_, "" )
   RETURN txt_


METHOD IdeProjManager:stripHeader( aHbp )
   LOCAL nStart, n, s
   LOCAL a_:= {}

   FOR EACH s IN aHbp
      n := s:__enumIndex()
      s := alltrim( s )
      IF left( s, 1 ) == "#" .AND. n <= 3
         nStart := n
         LOOP
      ENDIF
      IF empty( s )
         LOOP
      ENDIF
      IF "-3rd=hbide_file" $ s
         nStart := n
         EXIT
      ENDIF
      IF ! ( "-3rd=hbide_" $ s )
         nStart := n
         EXIT
      ENDIF
   NEXT

   IF ! empty( nStart )
      FOR EACH s IN aHbp
         IF s:__enumIndex() < nStart
            LOOP
         ENDIF
         aadd( a_, s )
      NEXT
   ELSE
      RETURN aHbp
   ENDIF
   RETURN a_


METHOD IdeProjManager:updateHbp( iIndex )
   LOCAL txt_

   IF iIndex != 3
      RETURN NIL
   ENDIF
   txt_:= hbide_synchronizeForHbp( hb_ATokens( ::oUI:editSources:toPlainText(), _EOL ) )
   ::oUI:editHbp:setPlainText( hbide_arrayToMemo( txt_ ) )
   RETURN txt_


METHOD IdeProjManager:fetchProperties()

   IF empty( ::oProject )
      ::oProject := IdeProject():new( ::oIDE, ::aPrjProps )
   ENDIF
   IF empty( ::oUI )
      ::buildInterface()
   ENDIF
   IF empty( ::aPrjProps )
      WITH OBJECT ::oUI
         :comboPrjType    :setCurrentIndex( 0 )

         :editPrjTitle    :setText( ::oProject:title )
         :editPrjLoctn    :setText( hbide_pathNormalized( ::oProject:location, .F. ) )
         :editDstFolder   :setText( "" )
         :editBackup      :setText( "" )
         :editOutName     :setText( ::oProject:outputName )

         :editLaunchParams:setText( "" )
         :editLaunchExe   :setText( "" )
         :editWrkFolder   :setText( "" )
         :editHbp         :setPlainText( "" )

         :oWidget         :setWindowTitle( iif( Empty( ::oProject:title ), 'New Project...', 'Properties for "' + ::oUI:editPrjTitle:Text() + '"' ) )

         :editSources     :setPlainText( "" )
      ENDWITH
      IF HB_ISOBJECT( ::oSelSrc )
         ::loadSelectedSources()
         // Save the project file, no ?
         // ::oUI:buttonSave:click()
      ENDIF

   ELSE
      WITH OBJECT ::oUI
         DO CASE
         CASE empty( ::aPrjProps )
            :comboPrjType:setCurrentIndex( 0 )
         CASE ::aPrjProps[ PRJ_PRP_PROPERTIES, 2, E_qPrjType ] == "Lib"
            :comboPrjType:setCurrentIndex( 1 )
         CASE ::aPrjProps[ PRJ_PRP_PROPERTIES, 2, E_qPrjType ] == "Dll"
            :comboPrjType:setCurrentIndex( 2 )
         OTHERWISE
            :comboPrjType:setCurrentIndex( 0 )
         ENDCASE

         :editPrjTitle    :setText( ::oProject:title        )
         :editPrjLoctn    :setText( ::oProject:location     )
         :editDstFolder   :setText( ::oProject:destination  )
         :editOutName     :setText( ::oProject:outputName   )
         :editBackup      :setText( ::oProject:backup       )

         :checkXhb        :setChecked( ::oProject:isXhb )
         :checkXpp        :setChecked( ::oProject:isXpp )
         :checkClp        :setChecked( ::oProject:isClp )

         :editFlags       :setPlainText( hbide_arrayToMemo( ::aPrjProps[ PRJ_PRP_FLAGS   , 1 ] ) )
         :editSources     :setPlainText( hbide_arrayToMemo( ::stripHeader( ::aPrjProps[ 5 ] ) ) )

         :editLaunchParams:setText( ::oProject:launchParams )
         :editLaunchExe   :setText( ::oProject:launchProgram )
         :editWrkFolder   :setText( ::oProject:wrkDirectory )

         :editHbp         :setPlainText( "" )

         :oWidget         :setWindowTitle( 'Properties for "' + ::oUI:editPrjTitle:Text() + '"' )
      ENDWITH
   ENDIF
   RETURN Self


METHOD IdeProjManager:loadSelectedSources()
   LOCAL aMemo := {}, cMemo := ""
   LOCAL oSel := ::oSelSrc
   LOCAL aHbc := {}

   AAdd( aMemo, "#    hbmk2 Flags" )
   AAdd( aMemo, "#" )
   AAdd( aMemo, iif( oSel:cType == "Dll", "-hbdyn", iif( oSel:cType == "Library", "-hblib", "-hbexe" ) ) )
   AAdd( aMemo, "" )
   IF oSel:lShared     ; AAdd( aMemo, "-shared"        ) ; ENDIF
   IF oSel:lFullStatic ; AAdd( aMemo, "-fullstatic"    ) ; ENDIF
   IF oSel:lTrace      ; AAdd( aMemo, "-trace"         ) ; ENDIF
   IF oSel:lInfo       ; AAdd( aMemo, "-info"          ) ; ENDIF
   IF oSel:lInc        ; AAdd( aMemo, "-inc"           ) ; ENDIF
   IF oSel:lGui        ; AAdd( aMemo, "-gui"           ) ; ENDIF
   IF oSel:lMt         ; AAdd( aMemo, "-mt"            ) ; ENDIF
   AAdd( aMemo, "" )
   IF oSel:lA          ; AAdd( aMemo, "-a"             ) ; ENDIF
   IF oSel:lB          ; AAdd( aMemo, "-b"             ) ; ENDIF
   IF oSel:lEs         ; AAdd( aMemo, "-es" + oSel:cES ) ; ENDIF
   IF oSel:lG          ; AAdd( aMemo, "-g"  + oSel:cG  ) ; ENDIF
   IF oSel:lM          ; AAdd( aMemo, "-m"  + oSel:cM  ) ; ENDIF
   IF oSel:lN          ; AAdd( aMemo, "-n"             ) ; ENDIF
   IF oSel:lV          ; AAdd( aMemo, "-v"             ) ; ENDIF
   IF oSel:lW          ; AAdd( aMemo, "-w"  + oSel:cW  ) ; ENDIF

   AAdd( aMemo, "" )
   AAdd( aMemo, "" )
   AAdd( aMemo, "#    GT Requested " )
   AAdd( aMemo, "#" )
   AAdd( aMemo, "-" + Lower( oSel:cGT ) )

   AAdd( aHbc, "" )
   AAdd( aHbc, "" )
   AAdd( aHbc, "#    Detected .hbc Components " )
   AAdd( aHbc, "#" )
   IF oSel:lHbQt
      AAdd( aHbc, "hbqt.hbc" )
      AAdd( aHbc, "hbqtwidgets.hbc" )
   ENDIF
   IF oSel:cGT == "gtWVG"
      AAdd( aHbc, "gtwvg.hbc" )
   ENDIF
   IF Len( aHbc ) > 4
      AEval( aHbc, {|e| AAdd( aMemo, e ) } )
   ENDIF

   AAdd( aMemo, "" )
   AAdd( aMemo, "" )
   AAdd( aMemo, "#    Compilable Sources " )
   AAdd( aMemo, "#" )

   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".hbc" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".hbp" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".hbm" )

   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".obj" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".o"   )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".c"   )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".cpp" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".prg" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".rc"  )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".res" )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".ui"  )
   ::addSourceToArray( oSel:aSrcSelected, @aMemo, ".qrc" )

   AAdd( aMemo, "" )
   AAdd( aMemo, "" )
   AAdd( aMemo, "#    Other Files " )
   AAdd( aMemo, "#" )
   AEval( oSel:aSrc3rd, {|e| AAdd( aMemo, e ) } )
   AAdd( aMemo, "" )

   AEval( aMemo, {|e| cMemo += e + hb_eol() } )

   // Populate the interface
   //
   WITH OBJECT ::oUI
      :comboPrjType:setCurrentIndex( iif( oSel:cType == "Dll", 2, iif( oSel:cType == "Library", 1, 0 ) ) )
      :editSources:setPlainText( cMemo )
   ENDWITH
   RETURN Self


METHOD IdeProjManager:addSourceToArray( aSrc, aTgt, cExt )
   LOCAL cSrc

   IF AScan( aSrc, {|e| Lower( hb_FNameExt( e ) ) == cExt } ) > 0
      AAdd( aTgt, "#" )
      AAdd( aTgt, "#    " + cExt )
      AAdd( aTgt, "#" )
      FOR EACH cSrc IN aSrc
         IF Lower( hb_FNameExt( cSrc ) ) == cExt
            AAdd( aTgt, cSrc )
         ENDIF
      NEXT
   ENDIF
   RETURN Self


METHOD IdeProjManager:buildInterface()
   LOCAL cLukupPng := hbide_image( "folder" )

   ::oUI := hbide_getUI( "projectpropertiesex" )
   ::oPropertiesDock:oWidget:setWidget( ::oUI:oWidget )

   WITH OBJECT ::oUI
      :comboPrjType      :addItem( "Executable" )
      :comboPrjType      :addItem( "Library"    )
      :comboPrjType      :addItem( "Dll"        )

      :buttonChoosePrjLoc:setIcon( QIcon( cLukupPng ) )
      :buttonChooseWd    :setIcon( QIcon( cLukupPng ) )
      :buttonChooseDest  :setIcon( QIcon( cLukupPng ) )
      :buttonBackup      :setIcon( QIcon( cLukupPng ) )

      :buttonSelect      :setIcon( QIcon( hbide_image( "open"           ) ) )
      :buttonUp          :setIcon( QIcon( hbide_image( "dc_up"          ) ) )
      :buttonDown        :setIcon( QIcon( hbide_image( "dc_down"        ) ) )

      :buttonSort        :setIcon( QIcon( hbide_image( "sort"           ) ) )
      :buttonSortZA      :setIcon( QIcon( hbide_image( "sortdescend"    ) ) )
      :buttonSortOrg     :setIcon( QIcon( hbide_image( "invertcase"     ) ) )
      :buttonDupLine     :setIcon( QIcon( __hbqtImage( "duplicate-line" ) ) )
      :buttonDeleteLine  :setIcon( QIcon( __hbqtImage( "delete-line"    ) ) )
      :buttonUnDo        :setIcon( QIcon( hbide_image( "undo"           ) ) )
      :buttonReDo        :setIcon( QIcon( hbide_image( "redo"           ) ) )

      :buttonSort        :hide()
      :buttonSortZA      :hide()
      :buttonSortOrg     :hide()

      :buttonCn          :connect( "clicked()", {|| ::lSaveOK := .f., ::oPropertiesDock:hide() } )
      :buttonSave        :connect( "clicked()", {|| ::lSaveOK := .t., ::save( .F., .T. )       } )
      :buttonSaveExit    :connect( "clicked()", {|| ::lSaveOK := .t., ::save( .T., .T. )       } )

      :buttonChoosePrjLoc:connect( "clicked()", {|| ::PromptForPath( ::oUI:editPrjLoctn , 'Choose Project Location...'   ) } )
      :buttonChooseWd    :connect( "clicked()", {|| ::PromptForPath( ::oUI:editWrkFolder, 'Choose Working Folder...'     ) } )
      :buttonChooseDest  :connect( "clicked()", {|| ::PromptForPath( ::oUI:editDstFolder, 'Choose Destination Folder...' ) } )
      :buttonBackup      :connect( "clicked()", {|| ::PromptForPath( ::oUI:editBackup   , 'Choose Backup Folder...'      ) } )
      :editPrjLoctn      :connect( "textChanged(QString)", {|cPath| ::setProjectLocation( cPath ) } )

      // provide some muscles to the editor
      WITH OBJECT ::oEdit := HbQtEditor():new()
         :qEdit := ::oUI:editSources
         :create()
      // :setFont( QFont( "Courier", 10 ) )       // does not work - CSS is installed on QDockWidget - so install CSS onto it.
         :qEdit:setStyleSheet( 'font: 10pt "Courier";' )
      ENDWITH
      :buttonSelect      :connect( "clicked()", {|| ::addSources()               } )
      :buttonUp          :connect( "clicked()", {|| ::oEdit:moveLine( -1 )       } )
      :buttonDown        :connect( "clicked()", {|| ::oEdit:moveLine( +1 )       } )
      :buttonDupLine     :connect( "clicked()", {|| ::oEdit:duplicateLine()      } )
      :buttonDeleteLine  :connect( "clicked()", {|| ::oEdit:deleteLine()         } )
      :buttonUnDo        :connect( "clicked()", {|| ::oEdit:undo()               } )
      :buttonReDo        :connect( "clicked()", {|| ::oEdit:redo()               } )
      :editFind          :connect( "returnPressed()", {|v| v := ::oUI:editFind:text(), iif( Empty( v ), .T., ::oEdit:find( v ) ) } )

   ENDWITH

   WITH OBJECT ::oUI:oWidget
      :setAcceptDrops( .t. )
      :connect( QEvent_DragEnter, {|p| p:acceptProposedAction(), .F. } )
      :connect( QEvent_DragMove , {|p| p:acceptProposedAction(), .F. } )
      :connect( QEvent_Drop     , {|p|
                                          LOCAL qList, i, qUrl
                                          LOCAL qMime := p:mimeData()
                                          LOCAL aFiles := {}
                                          IF qMime:hasUrls()
                                             qList := qMime:urls()
                                             FOR i := 0 TO qList:size() - 1
                                                qUrl := qList:at( i )
                                                IF hbide_isCompilerSource( qUrl:toLocalFile() )
                                                   AAdd( aFiles, qUrl:toLocalFile() )
                                                ENDIF
                                             NEXT
                                             IF ! Empty( aFiles )
                                                ::addSourcesToProject( aFiles )
                                             ENDIF
                                             p:setDropAction( Qt_CopyAction )
                                             p:accept()
                                          ENDIF
                                          RETURN .F.
                                     } )
   ENDWITH
   RETURN Self


METHOD IdeProjManager:synchronizeAlienProject( cProjFileName )
   LOCAL cPath, cFile, cExt, cHbp
   LOCAL cExeHbMk2, oProcess, cCmd

   hb_fNameSplit( cProjFileName, @cPath, @cFile, @cExt )
   IF lower( cExt ) == ".hbp"              /* Nothing to do */
      RETURN cProjFileName
   ENDIF

   IF !( lower( cExt ) $ ".xhp|.xbp" )          /* Not a valid alien project file */
      RETURN ""
   ENDIF

   cHbp := cPath + cFile + ".hbp"
   IF hb_fileExists( cHbp )
      IF ! hbide_getYesNo( "A .hbp with converted name already exists, overwrite?", "", "Project exists" )
         RETURN ""
      ENDIF
   ENDIF

   cExeHbMk2 := ::oINI:getHbmk2File()

   SWITCH lower( cExt )
   CASE ".xhp"
      cCmd := cExeHbMk2 + " -xhp=" + cProjFileName
      EXIT
   CASE ".xbp"
      cCmd := cExeHbMk2 + " -xbp=" + cProjFileName
      EXIT
   CASE "???"
      cCmd := cExeHbMk2 + " -hbmake=" + cProjFileName
      EXIT
   ENDSWITCH

   oProcess := QProcess()
   oProcess:start( cCmd )
   oProcess:waitForFinished()
   RETURN cHbp


METHOD IdeProjManager:sortSources( cMode )
   LOCAL a_, cTyp, s, d_, n
   LOCAL aSrc := { ".prg", ".hb", ".ch", ".c", ".cpp", ".h", ".obj", ".o", ".lib", ".a", ".rc", ".res", ".ui", ".qrc" }
   LOCAL aTxt := { {}    , {}   , {}   , {}  , {}    , {}  , {}    , {}  , {}    , {}  , {}   , {}    , {}   , {}     }
   LOCAL aRst := {}

   a_:= hbide_memoToArray( ::oUI:editSources:toPlainText() )

   IF     cMode == "az"
      asort( a_, , , {|e,f| lower( hbide_stripFilter( e ) ) < lower( hbide_stripFilter( f ) ) } )
   ELSEIF cMode == "za"
      asort( a_, , , {|e,f| lower( hbide_stripFilter( f ) ) < lower( hbide_stripFilter( e ) ) } )
   ELSEIF cMode == "org"
      asort( a_, , , {|e,f| lower( hbide_stripFilter( e ) ) < lower( hbide_stripFilter( f ) ) } )

      FOR EACH s IN a_
         s := alltrim( s )
         IF !( left( s, 1 ) == "#" )
            cTyp := hbide_sourceType( s )

            IF ( n := ascan( aSrc, {|e| cTyp == e } ) ) > 0
               aadd( aTxt[ n ], s )
            ELSE
               aadd( aRst, s )
            ENDIF
         ENDIF
      NEXT

      a_:= {}
      FOR EACH d_ IN aTxt
         IF !empty( d_ )
            aadd( a_, " #" )
            aadd( a_, " #" + aSrc[ d_:__enumIndex() ] )
            aadd( a_, " #" )
            FOR EACH s IN d_
               aadd( a_, s )
            NEXT
         ENDIF
      NEXT
      IF !empty( aRst )
         aadd( a_, " #" )
         aadd( a_, " #" + "Unrecognized..." )
         aadd( a_, " #" )
         FOR EACH s IN aRst
            aadd( a_, s )
         NEXT
      ENDIF
   ENDIF

   ::oUI:editSources:clear()
   ::oUI:editSources:setPlainText( hbide_arrayToMemo( a_ ) )
   RETURN Self


METHOD IdeProjManager:setProjectLocation( cPath )

   IF ! hb_dirExists( cPath )
      ::oUI:editPrjLoctn:setStyleSheet( "background-color: rgba( 240,120,120,255 );" )
      ::oUI:editSources:setEnabled( .f. )
      ::oUI:buttonSelect:setEnabled( .f. )
   ELSE
      ::oProject:location := cPath
      ::oUI:editPrjLoctn:setStyleSheet( "" )
      ::oUI:editSources:setEnabled( .T. )
      ::oUI:buttonSelect:setEnabled( .T. )
   ENDIF
   RETURN Self


METHOD IdeProjManager:isValidProjectLocation( lTell )
   LOCAL lOk := .f.

   IF empty( ::oUI:editPrjLoctn:text() )
      IF lTell
         MsgBox( "Please supply 'Project Location' first" )
      ENDIF
   ELSEIF ! hb_dirExists( ::oUI:editPrjLoctn:text() )
      IF lTell
         MsgBox( "Please ensure 'Project Location' is correct" )
      ENDIF
   ELSE
      lOk := .t.
   ENDIF
   RETURN lOk


METHOD IdeProjManager:moveLine( nDirection )
   ::oUI:editSources:hbMoveLine( nDirection )
   RETURN Self


METHOD IdeProjManager:addSourcesToProject( aFiles )
   LOCAL a_, cFile, cHome

   a_:= hbide_memoToArray( ::oUI:editSources:toPlainText() )
   cHome := ::oUI:editPrjLoctn:text()
   FOR EACH cFile IN aFiles
      cFile := hbide_prepareSourceForHbp( hbide_stripRoot( cHome, cFile ) )
      IF ascan( a_, cFile ) == 0
         aadd( a_, cFile )
      ENDIF
   NEXT
   ::oUI:editSources:setPlainText( hbide_arrayToMemo( a_ ) )
   RETURN Self


METHOD IdeProjManager:addSources()
   LOCAL aFiles

   IF ::isValidProjectLocation( .t. )
      IF ! empty( aFiles := ::oSM:selectSource( "openmany", , , ::oUI:editPrjLoctn:text() ) )
         ::addSourcesToProject( aFiles )
      ENDIF
   ENDIF
   RETURN Self


/* Set current project for build - vailtom
 * 26/12/2009 - 02:19:38
 */
METHOD IdeProjManager:setCurrentProject( cProjectName )
   LOCAL aPrjProps, n, oItem
   LOCAL cOldProject := ::cWrkProject
   LOCAL lValid      := .T.

   IF Empty( cProjectName )
      ::oIDE:cWrkProject := ''

   ELSEIF ( n := ascan( ::aProjects, {|e_| e_[ 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ] == cProjectName } ) ) > 0
      aPrjProps     := ::aProjects[ n, 3 ]
      ::oIDE:cWrkProject := aPrjProps[ PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ]
   ELSE
      lValid := .F.
   ENDIF

   IF lValid
      IF !Empty( ::oSBar )
         ::oDK:setStatusText( SB_PNL_PROJECT, ::cWrkProject )
      ENDIF

      ::oIDE:updateTitleBar()

      /* Reset Old Color */
      IF !empty( cOldProject )
         IF !empty( oItem := hbide_findProjTreeItem( ::oIDE, cOldProject, "Project Name" ) )
            oItem:oWidget:setForeground( 0, QBrush( QColor( 0,0,0 ) ) )
         ENDIF
      ENDIF
      /* Set New Color */
      IF !empty( ::cWrkProject )
         IF !empty( oItem := hbide_findProjTreeItem( ::oIDE, ::cWrkProject, "Project Name" ) )
            oItem:oWidget:setForeground( 0, QBrush( QColor( 255,0,0 ) ) )
            ::oProjTree:oWidget:setCurrentItem( oItem:oWidget )
         ENDIF
         ::loadProperties( ::getProjectFileNameFromTitle( ::cWrkProject ), .f., .f., .f. )
      ENDIF
   ENDIF
   RETURN cOldProject


METHOD IdeProjManager:getCurrentProjectTitle()

   IF Empty( ::aProjects )
      RETURN ""
   ENDIF
   IF ! Empty( ::cWrkProject )
      RETURN ::cWrkProject
   ENDIF
   IF Len( ::aProjects ) == 1
      ::setCurrentProject( ::aProjects[ 1, 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ] )
      RETURN ::aProjects[ 1, 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ]
   ENDIF
   RETURN ""


METHOD IdeProjManager:getCurrentProject( lAlert )

   DEFAULT lAlert TO .t.

   IF !Empty( ::cWrkProject )
      RETURN ::cWrkProject
   ENDIF

   IF Empty( ::aProjects )
      IF lAlert
         MsgBox( "No Projects Available" )
      ENDIF
      RETURN ""
   ENDIF
   IF Len( ::aProjects ) == 1
      ::setCurrentProject( ::aProjects[ 1, 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ] )
      RETURN ::aProjects[ 1, 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ]
   ENDIF
   RETURN ::selectCurrentProject()


METHOD IdeProjManager:selectAProject()
   LOCAL cProjectTitle := ""
   LOCAL oDlg, nRes, p, t

   IF Empty( ::aProjects )
      RETURN ""
   ENDIF

   oDlg := hbide_getUI( "selectproject", ::oDlg:oWidget )

   FOR EACH p IN ::aProjects
      IF !empty( t := p[ 3, PRJ_PRP_PROPERTIES, 2, E_oPrjTtl ] )
         oDlg:cbProjects:addItem( t )
      ENDIF
   NEXT

   oDlg:btnCancel:connect( "clicked()", {|| oDlg:oWidget:done( 0 ) } )
   oDlg:btnOk    :connect( "clicked()", {|| oDlg:done( 1 ) } )

   nRes := oDlg:exec()
   IF nRes == 1
      cProjectTitle := oDlg:cbProjects:currentText()
   ENDIF

   oDlg:oWidget:setParent( QWidget() )
   RETURN cProjectTitle


METHOD IdeProjManager:selectCurrentProject()
   LOCAL cProjectTitle

   IF Empty( cProjectTitle := ::selectAProject() )
      MsgBox( "No Projects Available or Selected" )
      RETURN ::cWrkProject
   ENDIF

   ::setCurrentProject( cProjectTitle )
   RETURN ::cWrkProject


METHOD IdeProjManager:getProjectsTitleList()
   LOCAL a_, aList := {}

   FOR EACH a_ IN ::aProjects
      aadd( aList, a_[ 3, PRJ_PRP_PROPERTIES, 2, PRJ_PRP_TITLE ] )
   NEXT
   RETURN aList


METHOD IdeProjManager:getProjectProperties( cProjectTitle )
   LOCAL n

   IF ( n := ascan( ::aProjects, {|e_, x| x := e_[ 3 ], x[ 1, 2, PRJ_PRP_TITLE ] == cProjectTitle } ) ) > 0
      RETURN ::aProjects[ n, 3 ]
   ENDIF
   RETURN {}


METHOD IdeProjManager:getProjectByFile( cProjectFile )
   LOCAL n, aProj

   cProjectFile := hbide_pathNormalized( cProjectFile )
   IF ( n := ascan( ::aProjects, {|e_| hb_FileMatch( e_[ 1 ], cProjectFile ) } ) ) > 0
      aProj := ::aProjects[ n ]
   ENDIF
   RETURN IdeProject():new( ::oIDE, aProj )


METHOD IdeProjManager:getProjectTypeFromTitle( cProjectTitle )
   LOCAL n, cType := ""

   IF ( n := ascan( ::aProjects, {|e_, x| x := e_[ 3 ], x[ 1, 2, PRJ_PRP_TITLE ] == cProjectTitle } ) ) > 0
      cType := ::aProjects[ n, 3, PRJ_PRP_PROPERTIES, 1, PRJ_PRP_TYPE ]
   ENDIF
   RETURN cType


METHOD IdeProjManager:getProjectPathFromTitle( cProjectTitle )
   LOCAL cPath
   hb_fNameSplit( ::getProjectFileNameFromTitle( cProjectTitle ), @cPath )
   RETURN cPath


METHOD IdeProjManager:getProjectFileNameFromTitle( cProjectTitle )
   LOCAL n, cProjFileName := ""

   IF ( n := ascan( ::aProjects, {|e_, x| x := e_[ 3 ], x[ 1, 2, PRJ_PRP_TITLE ] == cProjectTitle } ) ) > 0
      cProjFileName := ::aProjects[ n, 2 ]
   ENDIF
   RETURN cProjFileName


METHOD IdeProjManager:getSourcesByProjectTitle( cProjectTitle )
   LOCAL n, aProj

   IF ( n := ascan( ::aProjects, {|e_, x| x := e_[ 3 ], x[ 1, 2, PRJ_PRP_TITLE ] == cProjectTitle } ) ) > 0
      aProj := ::aProjects[ n, 3 ]
      RETURN aProj[ PRJ_PRP_SOURCES, 2 ] /* 2 == parsed sources */
   ENDIF
   RETURN {}


METHOD IdeProjManager:getProjectByTitle( cProjectTitle )
   LOCAL n, aProj

   IF ( n := ascan( ::aProjects, {|e_, x| x := e_[ 3 ], x[ 1, 2, PRJ_PRP_TITLE ] == cProjectTitle } ) ) > 0
      aProj := ::aProjects[ n, 3 ]
   ENDIF
   RETURN IdeProject():new( ::oIDE, aProj )


METHOD IdeProjManager:removeProject( cProjectTitle )
   LOCAL cProjFileName, nPos

   IF Empty( cProjectTitle )
      IF Empty( cProjectTitle := ::selectAProject() )
         MsgBox( "No Projects Available or Selected" )
         RETURN Self
      ENDIF
   ENDIF
   IF !empty( cProjFileName := ::getProjectFileNameFromTitle( cProjectTitle ) )
      ::closeProject( cProjectTitle )
      nPos := ascan( ::aProjects, {|e_| e_[ 2 ] == cProjFileName } )
      IF nPos > 0
         hb_adel( ::aProjects, nPos, .T. )
         ::oINI:save()
      ENDIF
   ENDIF
   RETURN Self


METHOD IdeProjManager:closeProject( cProjectTitle )
   LOCAL oProject, aProp

   IF Empty( ::aProjects )
      RETURN Self
   ENDIF

   aProp := ::getProjectProperties( cProjectTitle )
   oProject := IdeProject():new( ::oIDE, aProp )
   IF empty( oProject:title )
      RETURN Self
   ENDIF

   ::oIDE:removeProjectTree( aProp )
   ::setCurrentProject( '' )
   RETURN Self


/* Prompt for user to select a existing folder
 * 25/12/2009 - 19:03:09 - vailtom
 */
METHOD IdeProjManager:promptForPath( oEditPath, cTitle, cObjFileName )
   LOCAL cTemp, cPath, cFile

   IF HB_ISOBJECT( ::oProject )
      cTemp := oEditPath:Text()
   ELSE
      cTemp := ""
   ENDIF

   IF !HB_ISSTRING( cObjFileName )
      cPath := hbide_fetchADir( ::oDlg, cTitle, cTemp )

   ELSE
      cTemp := hbide_fetchAFile( ::oDlg, cTitle, { { "Harbour IDE Projects", "*.hbp" } }, cTemp )
      IF !Empty( cTemp )
         hb_fNameSplit( hbide_pathNormalized( cTemp, .f. ), @cPath, @cFile )
         oEditPath:setText( cFile )
      ENDIF
   ENDIF

   IF !Empty( cPath )
      IF Right( cPath, 1 ) $ '/\'
         cPath := Left( cPath, Len( cPath ) - 1 )
      ENDIF
      oEditPath:setText( cPath )
   ENDIF
   oEditPath:setFocus()
   RETURN Self


METHOD IdeProjManager:showOutput( cOutput, mp2, oProcess )
   LOCAL cIfError

   HB_SYMBOL_UNUSED( mp2 )
   HB_SYMBOL_UNUSED( oProcess )

   ::nProgValue++
   IF ::nProgValue > 20
      ::nProgValue := 1
   ENDIF
   ::oProgBar:setValue( ::nProgValue )

   cIfError := hbide_convertBuildStatusMsgToHtml( cOutput, ::oOutputResult:oWidget )
   IF ! empty( cIfError ) //.AND. empty( ::cIfError )
      ::cIfError := cIfError
   ENDIF
   RETURN Self


METHOD IdeProjManager:buildSource( lExecutable )
   LOCAL oEdit, cTmp, cExeHbMk2, cCmd, cC, cCmdParams, cBuf
   LOCAL cbRed    := "<font color=blue>", ceRed := "</font>"
   LOCAL lRebuild := .T.
   LOCAL aHbp     := {}

   ::lPPO              := .t.
   ::lLaunch           := lExecutable
   ::cProjectInProcess := NIL

   IF !empty( oEdit := ::oEM:getEditorCurrent() )
      IF ! hbide_isSourcePRG( oEdit:source() )
         MsgBox( 'Operation not supported for this file type: "' + oEdit:source() + '"' )
         RETURN Self
      ENDIF
   ELSE
      MsgBox( "No active editing source available !" )
      RETURN Self
   ENDIF
   IF ::oINI:lSaveSourceWhenComp
      ::oSM:saveNamedSource( oEdit:source() )
   ENDIF

   ::cargo := oEdit

   aadd( aHbp, "-q"         )
   aadd( aHbp, "-trace"     )
   aadd( aHbp, "-info"      )
   aadd( aHbp, "-lang=en"   )
   aadd( aHbp, "-width=0"   )
   aadd( aHbp, "-rebuild"   )
   IF lExecutable
      aadd( aHbp, "-hbexe"  )
   ELSE
      aadd( aHbp, "-s"      )
   ENDIF
   aadd( aHbp, hbide_pathToOSPath( oEdit:source() ) )

   ::oDockB2:show()
   ::oOutputResult:oWidget:clear()

   ::outputText( hbide_outputLine() )
   cTmp := "Project [ " + oEdit:source()              + " ]    " + ;
           "Launch [ "  + iif( ::lLaunch, 'Yes', 'No' ) + " ]    " + ;
           "Rebuild [ " + iif( lRebuild , 'Yes', 'No' ) + " ]    " + ;
           "Started [ " + time() + " ]"
   ::outputText( cTmp )
   ::outputText( hbide_outputLine() )

   ::oIDE:oEV := IdeEnvironments():new():create( ::oIDE )
   ::cBatch   := ::oEV:prepareBatch( ::cWrkEnvironment )
   aeval( ::oEV:getHbmk2Commands( ::cWrkEnvironment ), {|e| aadd( aHbp, e ) } )

   cExeHbMk2  := "hbmk2"

   cCmdParams := hbide_array2cmdParams( aHbp )

   ::oProcess := HbpProcess():new()
   //
   ::oProcess:output      := {|cOut, mp2, oHbp| ::showOutput( cOut,mp2,oHbp ) }
   ::oProcess:finished    := {|nEC , nES, oHbp| ::finished( nEC, nES, oHbp, ::cWrkEnvironment ) }
   ::oProcess:workingPath := hbide_pathToOSPath( oEdit:cPath )
   //
   cCmd := hbide_getShellCommand()
   cC   := iif( hbide_getOS() == "nix", "", "/C " )

   IF hb_fileExists( ::cBatch )
      cBuf := memoread( ::cBatch )
      cBuf += hb_eol() + cExeHbMk2 + " " + cCmdParams + hb_eol()
      hb_memowrit( ::cBatch, cBuf )
   ENDIF
   //
   ::outputText( cbRed + "Batch File " + iif( hb_fileExists( ::cBatch ), " Exists", " : doesn't Exist" ) + " => " + ceRed + trim( ::cBatch ) )
   ::outputText( cbRed + "Batch File Contents => " + ceRed )
   ::outputText( memoread( ::cBatch ) )
   ::outputText( cbRed + "Command => " + ceRed + cCmd )
   ::outputText( cbRed + "Arguments => " + ceRed + cC + ::cBatch )
   ::outputText( hbide_outputLine() )
   //
   ::oProcess:addArg( cC + ::cBatch )
   ::oProcess:start( cCmd )
   RETURN Self


METHOD IdeProjManager:buildProject( cProject, lLaunch, lRebuild, lPPO, lViaQt, cWrkEnviron, lDebug )
   LOCAL cHbpPath, oEdit, cHbpFN, cTmp, cExeHbMk2, aHbp, cCmd, cC, oSource, cCmdParams, cBuf, n, aHbpData
   LOCAL cbRed := "<font color=blue>", ceRed := "</font>"
   LOCAL oProcess, cBatch

   DEFAULT lLaunch     TO .F.
   DEFAULT lRebuild    TO .F.
   DEFAULT lPPO        TO .F.
   DEFAULT lViaQt      TO .F.
   DEFAULT cWrkEnviron TO ::cWrkEnvironment
   DEFAULT lDebug      TO .F.

   aHbp                := {}
   ::lPPO              := lPPO
   ::lLaunch           := lLaunch
   ::cProjectInProcess := cProject

   IF ::lPPO .AND. empty( ::oEM:getEditCurrent() )
      MsgBox( 'No source available to be compiled !' )
      RETURN Self
   ENDIF
   IF empty( cProject )
      cProject := ::getCurrentProject( .f. )
   ENDIF
   IF empty( cProject ) .AND. ! ::lPPO
      RETURN Self
   ENDIF
   IF ::lPPO
      lRebuild := .t.
   ENDIF

   ::setCurrentProject( cProject )

   /* Make Macros happy */
   hbide_setProjectTitle( cProject )

   ::oProject := ::getProjectByTitle( cProject )
   IF ::oINI:lSaveSourceWhenComp
      FOR EACH oSource IN ::oProject:hSources
         ::oSM:saveNamedSource( oSource:original )
      NEXT
   ENDIF

   cHbpFN   := hbide_pathFile( ::oProject:location, iif( empty( ::oProject:outputName ), "_temp", ::oProject:outputName ) )
   cHbpPath := cHbpFN + iif( ::lPPO, "_tmp", "" ) + ".hbp"
   aHbpData := ::pullHbpData( cHbpPath )

   IF ! ::lPPO
      IF     ::oProject:type == "Lib"
         aadd( aHbp, "-hblib" )
      ELSEIF ::oProject:type == "Dll"
      // aadd( aHbp, "-hbdynvm" )  /* Better if is provided as a flag -hbdyn  or   -hbdynvm */
      ENDIF
   ENDIF

   IF ::oProject:isXhb
      aadd( aHbp, "-xhb" )
   ENDIF
   aadd( aHbp, "-q"          )
   aadd( aHbp, "-trace"      )
   aadd( aHbp, "-info"       )
   aadd( aHbp, "-lang=en"    )
   aadd( aHbp, "-width=512"  )
   IF lRebuild
      aadd( aHbp, "-rebuild" )
   ENDIF
   IF ::lPPO
      IF !empty( oEdit := ::oEM:getEditorCurrent() )
         IF hbide_isSourcePRG( oEdit:source() )
            aadd( aHbp, "-s"     )
            aadd( aHbp, "-p"     )
            aadd( aHbp, "-hbraw" )

            // TODO: We have to test if the current file is part of a project, and we
            // pull your settings, even though this is not the active project - vailtom
            aadd( aHbp, hbide_pathToOSPath( oEdit:source() ) )

            ::cPPO := hbide_pathFile( oEdit:cPath, oEdit:cFile + '.ppo' )
            FErase( ::cPPO )
         ELSE
            MsgBox( 'Operation not supported for this file type: "' + oEdit:source() + '"' )
            RETURN Self
         ENDIF
         lViaQt := .t.   /* Donot know why it fails with Qt */
      ENDIF
   ENDIF

   //::oDockB2:show()
   ::oOutputResult:oWidget:clear()

   IF .F.
      ::outputText( 'Error saving: ' + cHbpPath )

   ELSE
      ::outputText( hbide_outputLine() )
      cTmp := "Project [ " + cProject                     + " ]    " + ;
              "Launch [ "  + iif( lLaunch , 'Yes', 'No' ) + " ]    " + ;
              "Rebuild [ " + iif( lRebuild, 'Yes', 'No' ) + " ]    " + ;
              "Started [ " + time() + " ]"
      ::outputText( cTmp )
      ::outputText( hbide_outputLine() )

      ::oIDE:oEV := IdeEnvironments():new():create( ::oIDE )
      cBatch   := ::oEV:prepareBatch( cWrkEnviron, lDebug )
      aeval( ::oEV:getHbmk2Commands( cWrkEnviron ), {|e| aadd( aHbp, e ) } )
      IF lDebug
         aadd( aHbp, "-b"         )
         aadd( aHbp, "-inc"       )
         aadd( aHbp, "-lhwgdebug" )
         aadd( aHbp, "-D__HBIDE_DEBUG__" )
         IF ( n := AScan( aHbpData[ 2,1 ], {|e| Lower( Left( LTrim( e ), 9 ) ) == "-workdir=" } ) ) == 0
            AAdd( aHbp, "-workdir=.hbmk/${hb_plat}/${hb_comp}/debug" )
         ELSE
            AAdd( aHbp, hbide_pathStripLastSlash( aHbpData[ 2,1,n ] ) + "/" + "debug" )
         ENDIF
      ENDIF

      cExeHbMk2  := ::oINI:getHbmk2File()
      cCmdParams := hbide_array2cmdParams( aHbp )

      oProcess := HbpProcess():new()

      ::nProgValue := 0
      ::oProgBar:show()
      ::oProgBar:setValue( ::nProgValue )
      //
      oProcess:output      := {|cOut, mp2, oHbp| ::showOutput( cOut,mp2,oHbp ) }
      oProcess:finished    := {|nEC , nES, oHbp| FErase( cBatch ), ::finished( nEC, nES, oHbp, cWrkEnviron, lDebug ) }
      oProcess:workingPath := hbide_pathToOSPath( ::oProject:location )
      //
      cCmd := hbide_getShellCommand()
      cC   := iif( hbide_getOS() == "nix", "", "/C " )

      IF hb_fileExists( cBatch )
         cBuf := memoread( cBatch )
         cBuf += hb_eol() + cExeHbMk2 + " " + cHbpPath + cCmdParams + hb_eol()
         hb_memowrit( cBatch, cBuf )
      ENDIF
      //
      ::outputText( cbRed + "Batch File " + iif( hb_fileExists( cBatch ), " Exists", " : doesn't Exist" ) + " => " + ceRed + trim( cBatch ) )
      ::outputText( cbRed + "Batch File Contents => " + ceRed )
      ::outputText( memoread( cBatch ) )
      ::outputText( cbRed + "Command   => " + ceRed + cCmd )
      ::outputText( cbRed + "Arguments => " + ceRed + cC + cBatch )
      ::outputText( hbide_outputLine() )
      //
      oProcess:addArg( cC + cBatch )
      oProcess:start( cCmd )
   ENDIF
   RETURN Self


METHOD IdeProjManager:finished( nExitCode, nExitStatus, oProcess, cWrkEnviron, lDebug )
   LOCAL cTmp, n, n1, cTkn, cExe, qDoc, qCursor

   HB_SYMBOL_UNUSED( oProcess )

   DEFAULT cWrkEnviron TO ::cWrkEnvironment

   ::outputText( hbide_outputLine() )
   cTmp := "Exit Code [ " + hb_ntos( nExitCode ) + " ]    Exit Status [ " + hb_ntos( nExitStatus ) + " ]    " +;
           "Finished at [ " + time() + " ]    Done in [ " + hb_ntos( seconds() - oProcess:started ) + " Secs ]"
   ::outputText( cTmp )
   ::outputText( hbide_outputLine() )

   IF ! empty( ::cIfError )
      ::oOutputResult:selStart := 0
      ::oOutputResult:find( ::cIfError )
      ::oOutputResult:selBold  := .T.

      qDoc := ::oOutputResult:document()
      FOR n := 0 TO qDoc:blockCount() - 1
         IF ::cIfError == qDoc:findBlockByNumber( n ):text()
            qCursor := qDoc:find( ::cIfError )
            ::oOutputResult:setTextCursor( qCursor )
            EXIT
         ENDIF
      NEXT
   ENDIF

   QApplication():processEvents()

   cTmp := ::oOutputResult:oWidget:toPlainText()
   cExe := ""
   IF empty( cExe )
      cTkn := "hbmk2: Linking... "
      IF ( n := at( cTkn, cTmp ) ) > 0
         n1   := hb_at( Chr( 10 ), cTmp, n + Len( cTkn ) )
         cExe := StrTran( substr( cTmp, n + Len( cTkn ), n1 - n - len( cTkn ) ), Chr( 13 ) )
      ENDIF
   ENDIF
   IF empty( cExe )
      cTkn := "hbmk2: Target up to date: "
      IF ( n := at( cTkn, cTmp ) ) > 0
         n1   := hb_at( Chr( 10 ), cTmp, n + Len( cTkn ) )
         cExe := StrTran( substr( cTmp, n + Len( cTkn ), n1 - n - len( cTkn ) ), Chr( 13 ) )
      ENDIF
   ENDIF

   IF HB_ISOBJECT( ::cargo )
      cExe := hb_PathJoin( hbide_pathToOSPath( ::cargo:cPath ), cExe )
   ELSE
      cExe := hb_PathJoin( hbide_pathToOSPath( iif( HB_ISOBJECT( ::oProject ), ::oProject:location, "" ) ), cExe )
   ENDIF
   ::outputText( "[..." + cExe + "..]" )

   IF !empty( cExe )
      hb_fNameSplit( cExe, @cTmp )
      hbide_setProjectOutputPath( cTmp )
   ENDIF

   ::oProgBar:setValue( 0 )
   ::oProgBar:hide()

   IF ::lLaunch
      ::outputText( " " )
      IF empty( cExe )
         ::outputText( "<font color=red>" + "Executable could not been detected from linker output!" + "</font>" )
      ELSE
         cExe := alltrim( cExe )
         ::outputText( "<font color=blue>" + "Detected executable => " + cExe + "</font>" )
      ENDIF
      ::outputText( " " )
      IF nExitCode == 0
         ::launchProject( ::cProjectInProcess, cExe, cWrkEnviron, lDebug )
      ELSE
         ::outputText( "Sorry, cannot launch project because of errors..." )
      ENDIF
   ENDIF
   IF ::lPPO .AND. hb_FileExists( ::cPPO )
      ::editSource( ::cPPO )
   ENDIF

   IF ! ( nExitCode == 0 )
      ::oDockB2:show()
   ENDIF

   //::cIfError := NIL
   ::oOutputResult:ensureCursorVisible()
   IF !empty( qCursor )
      qCursor:clearSelection()
      ::oOutputResult:setTextCursor( qCursor )
   ENDIF
   RETURN Self


METHOD IdeProjManager:launchProject( cProject, cExe, cWrkEnviron, lDebug )
   LOCAL cTargetFN, oProject, cPath, a_, cParam
   LOCAL qStr, cC, cCmd, cBuf, cBatch, qProcess

   DEFAULT lDebug TO .F.

   IF empty( cProject )
      cProject := ::oPM:getCurrentProject( .f. )
   ENDIF
   IF !empty( cProject )
      oProject  := ::getProjectByTitle( cProject )
   ENDIF

   IF empty( cExe ) .AND. !empty( oProject )
      cTargetFN := hbide_pathFile( oProject:destination, iif( empty( oProject:outputName ), "_temp", oProject:outputName ) )
#ifdef __PLATFORM__WINDOWS
      IF oProject:type == "Executable"
         cTargetFN += '.exe'
      ENDIF
#endif
      IF ! hb_FileExists( cTargetFN )
         cTargetFN := oProject:launchProgram
      ENDIF
   ELSE
      cTargetFN := cExe
   ENDIF
   IF empty( cTargetFN )
      cTargetFN := ""
   ENDIF
   cTargetFN := hbide_pathToOSPath( cTargetFN )

   IF ! hb_FileExists( cTargetFN )
      ::oDockB2:show()
      ::outputText( "Launch error: file not found - " + cTargetFN )

   ELSEIF empty( oProject ) .OR. oProject:type == "Executable"
      ::outputText( "Launching Application [ " + cTargetFN + " ]" )
      QApplication():processEvents()

      IF ::oINI:lExtBuildLaunch

         ::oIDE:oEV := IdeEnvironments():new():create( ::oIDE )
         cBatch     := ::oEV:prepareBatch( cWrkEnviron )
         cCmd       := hbide_getShellCommand()
         cC         := iif( hbide_getOS() == "nix", "", "/C " )
         IF hb_fileExists( cBatch )
            cBuf := memoread( cBatch )
            cBuf += hb_eol() + iif( hbide_getOS() == "nix", "", "start " ) + cTargetFN + " "
            IF ! empty( oProject ) .AND. ! empty( oProject:launchParams )
               cBuf += oProject:launchParams
            ENDIF
            cBuf += hb_eol()
            hb_memowrit( cBatch, cBuf )
         ENDIF

         qStr := QStringList()
         hb_fNameSplit( cTargetFN, @cPath )
         IF ! Empty( cC )
            qStr:append( cC )
         ENDIF
         qStr:append( cBatch )

         IF lDebug
            ::launchDebug( cProject, cExe, cCmd, qStr, hbide_pathToOSPath( iif( Empty( oProject ), cPath, oProject:wrkDirectory ) ) )
         ELSE
            qProcess := QProcess()
            WITH OBJECT qProcess
               :startDetached( cCmd, qStr, hbide_pathToOSPath( iif( Empty( oProject ), cPath, oProject:wrkDirectory ) ) )
               :waitForStarted( 30000 )
            ENDWITH
            qProcess := NIL
         ENDIF
         //FErase( cBatch )                       /* Seems this breaks the execution on some meachines - clean system temp folder manually and periodically */
      ELSE                                        /* Kept it just for reference - may be switchable through .ini */
         qStr := QStringList()
         IF ! Empty( oProject )
            IF ! Empty( oProject:launchParams )
               a_:= hb_ATokens( oProject:launchParams, " " )
               FOR EACH cParam IN a_
                  IF ! Empty( cParam )
                     qStr:append( AllTrim( cParam ) )
                  ENDIF
               NEXT
            ENDIF
            IF lDebug
               ::launchDebug( cProject, cTargetFN, cTargetFN, qStr, hbide_pathToOSPath( oProject:wrkDirectory ) )
            ELSE
               QProcess():startDetached( cTargetFN, qStr, hbide_pathToOSPath( oProject:wrkDirectory ) )
            ENDIF
         ELSE
            hb_fNameSplit( cTargetFN, @cPath )
            QProcess():startDetached( cTargetFN, qStr, hbide_pathToOSPath( cPath ) )
         ENDIF
      ENDIF
   ELSE
      ::outputText( "Launching application [ " + cTargetFN + " ] ( not applicable )." )
   ENDIF
   RETURN Self


METHOD IdeProjManager:launchDebug( cProject, cExe, cCmd, qStr, cWrkDir )

   IF empty( cProject )
      cProject := ::getCurrentProjectTitle()
   ENDIF
   IF Empty( cProject )
      ::outputText( "No active project found !" )
      RETURN .F.
   ENDIF
   ::oDockB2:show()

   DEFAULT cExe TO ::getCurrentExeName( cProject )          // should never happen
   IF ! hb_FileExists( cExe )
      ::outputText( "Launch error: executable not found !" )
      RETURN .F.
   ENDIF

   WITH OBJECT ::oIde:oDebugger
      :clear()
      :cCurrentProject := cProject
      ::outputText( "Launching with Debugger : " + cExe )
      :start( cExe, cCmd, qStr, cWrkDir )
   ENDWITH
   RETURN .T.


METHOD IdeProjManager:getCurrentExeName( cProject )
   LOCAL cTargetFN, oProject

   IF empty( cProject )
      cProject := ::getCurrentProjectTitle()
   ENDIF
   IF !empty( cProject )
      oProject  := ::getProjectByTitle( cProject )
   ELSE
      RETURN ""
   ENDIF

   IF !empty( oProject )
      cTargetFN := hbide_pathFile( oProject:destination, iif( empty( oProject:outputName ), "_temp", oProject:outputName ) )
#ifdef __PLATFORM__WINDOWS
      IF oProject:type == "Executable"
         cTargetFN += '.exe'
      ENDIF
#endif
      IF ! hb_FileExists( cTargetFN )
         cTargetFN := oProject:launchProgram
      ENDIF
   ELSE
      RETURN ""
   ENDIF
   IF empty( cTargetFN )
      cTargetFN := ""
   ENDIF
   cTargetFN := hbide_pathToOSPath( cTargetFN )
   RETURN cTargetFN


METHOD IdeProjManager:runAsScript()
   LOCAL oEdit, cFlags, cInclude

   cFlags := "-n "
   IF ! Empty( ::oINI:aIncludePaths ) .AND. HB_ISARRAY( ::oINI:aIncludePaths )
      FOR EACH cInclude IN ::oINI:aIncludePaths
         IF ! Empty( cInclude )
            cFlags += "-i" + hbide_pathStripLastSlash( hbide_pathToOSPath( AllTrim( cInclude ) ) ) + " "
         ENDIF
      NEXT
   ENDIF
   IF !empty( oEdit := ::oEM:getEditorCurrent() )
      hbide_runAScript( oEdit:qEdit:toPlainText(), AllTrim( cFlags ) )
   ENDIF
   RETURN Self


METHOD IdeProjManager:outputText( cText )
   ::oOutputResult:oWidget:append( hbide_iterate( "<font color=black>" + cText + "</font>" ) )
   ::oOutputResult:oWidget:ensureCursorVisible()
   QApplication():processEvents()
   RETURN Self

/*----------------------------------------------------------------------*/

STATIC FUNCTION hbide_getNextProject( cFolder )
   LOCAL aDir, aPrj
   LOCAL nNext := 0

   aDir := Directory( cFolder + "prj0*.hbp" )
   FOR EACH aPrj IN aDir
       nNext := Max( nNext, Val( SubStr( aPrj[ 1 ], 4, At( ".", aPrj[ 1 ] ) - 4 ) ) )
   NEXT
   RETURN cFolder + "prj" + StrZero( nNext+1, 5 ) + ".hbp"


STATIC FUNCTION hbide_fetchProject( oEditHbp )
   LOCAL cProjPath, cPath, cName, cExt

   IF ! Empty( cProjPath := hbide_fetchAFile( hbide_setIde():oDlg, "Create a Harbour Project", { { "Project File", ".hbp" } }, oEditHbp:text(), "hbp" ) )
      hb_FNameSplit( cProjPath, @cPath, @cName, @cExt )
      hbide_setWorkingProjectFolder( cPath )
      IF Empty( cExt )
         cExt := ".hbp"
      ENDIF
      cProjPath := cPath + cName + cExt
      oEditHbp:setText( cProjPath )
      IF hb_FileExists( cProjPath )
         Alert( cProjPath + " already exists, provide unique name !" )
         RETURN NIL
      ENDIF
   ENDIF
   RETURN NIL


STATIC FUNCTION hbide_setWorkingProjectFolder( cFolder )
   LOCAL l_cFolder
   STATIC s_cFolder

   IF Empty( s_cFolder )
      s_cFolder := hb_DirBase() + "projects" + hb_ps()
   ENDIF
   l_cFolder := s_cFolder
   IF HB_ISSTRING( cFolder )
      s_cFolder := cFolder
   ENDIF
   RETURN l_cFolder
