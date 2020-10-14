/*
 * $Id: saveload.prg 426 2016-10-20 00:14:06Z bedipritpal $
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
 *                  Pritpal Bedi <bedipritpal@hotmail.com>
 *                               28Dec2009
 */
/*----------------------------------------------------------------------*/

#include "hbide.ch"
#include "common.ch"
#include "fileio.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"


#define INI_SECTIONS_COUNT                        14
#define INI_HBIDE_VRBLS                           30


#define __buttonAddTextext_clicked__              2001
#define __buttonDelTextext_clicked__              2002
#define __buttonKeyAdd_clicked__                  2003
#define __buttonKeyDel_clicked__                  2004
#define __buttonKeyUp_clicked__                   2005
#define __buttonKeyDown_clicked__                 2006
#define __buttonSelFont_clicked__                 2007
#define __buttonClose_clicked__                   2008
#define __buttonOk_clicked__                      2009
#define __buttonCancel_clicked__                  2010
#define __treeWidget_itemSelectionChanged__       2011
#define __comboStyle_currentIndexChanged__        2012
#define __checkAnimated_stateChanged__            2013
#define __checkHilightLine_stateChanged__         2014
#define __checkHorzRuler_stateChanged__           2015
#define __checkLineNumbers_stateChanged__         2016
#define __checkShowLeftToolbar_stateChanged__     2017
#define __checkShowTopToolbar_stateChanged__      2018
#define __sliderValue_changed__                   2019
#define __radioSection_clicked__                  2020
#define __buttonThmAdd_clicked__                  2021
#define __buttonThmDel_clicked__                  2022
#define __buttonThmApp_clicked__                  2023
#define __buttonThmSav_clicked__                  2024
#define __listThemes_currentRowChanged__          2025
#define __buttonHrbRoot_clicked__                 2026
#define __buttonHbmk2_clicked__                   2027
#define __buttonEnv_clicked__                     2028
#define __buttonResources_clicked__               2029
#define __buttonTemp_clicked__                    2030
#define __buttonShortcuts_clicked__               2031
#define __buttonSnippets_clicked__                2032
#define __buttonThemes_clicked__                  2033
#define __buttonViewIni_clicked__                 2034
#define __buttonViewEnv_clicked__                 2035
#define __buttonViewSnippets_clicked__            2036
#define __buttonViewThemes_clicked__              2037
#define __buttonDictPath_clicked__                2038
#define __comboTabsShape_currentIndexChanged__    2039
#define __comboLeftTabPos_currentIndexChanged__   2040
#define __comboTopTabPos_currentIndexChanged__    2041
#define __comboRightTabPos_currentIndexChanged__  2042
#define __comboBottomTabPos_currentIndexChanged__ 2043
#define __comboTBSize_currentIndexChanged__       2044
#define __buttonVSSExe_clicked__                  2045
#define __buttonVSSDatabase_clicked__             2046
#define __buttonEditorX_clicked__                 2047
#define __buttonEditorSaveAs_clicked__            2048
#define __buttonEditorSave_clicked__              2049
#define __buttonEditorClose_clicked__             2050
#define __tableVar_keyPress__                     2051
#define __listDictNames_currentRowChanged__       2052
#define __btnDictColorText_clicked__              2053
#define __btnDictColorBack_clicked__              2054
#define __checkDictToPrg_stateChanged__           2056
#define __checkDictToC_stateChanged__             2057
#define __checkDictToCpp_stateChanged__           2058
#define __checkDictToCh_stateChanged__            2059
#define __checkDictToH_stateChanged__             2060
#define __checkDictToIni_stateChanged__           2061
#define __checkDictToTxt_stateChanged__           2062
#define __checkDictToHbp_stateChanged__           2063
#define __checkDictActive_stateChanged__          2064
#define __checkDictCaseSens_stateChanged__        2065
#define __checkDictBold_stateChanged__            2066
#define __checkDictItalic_stateChanged__          2067
#define __checkDictULine_stateChanged__           2068
#define __checkDictColorText_stateChanged__       2069
#define __checkDictColorBack_stateChanged__       2070
#define __radioDictConvNone_clicked__             2071
#define __radioDictToLower_clicked__              2072
#define __radioDictToUpper_clicked__              2073
#define __radioDictAsIn_clicked__                 2074
#define __buttonDictAdd_clicked__                 2075
#define __buttonDictDelete_clicked__              2076
#define __checkShowSelToolbar_stateChanged__      2077
#define __listIncludePaths_currentRowChanged__    2078
#define __buttonIncludePathsAdd_clicked__         2079
#define __buttonIncludePathsDel_clicked__         2080
#define __listSourcePaths_currentRowChanged__     2081
#define __buttonSourcePathsAdd_clicked__          2082
#define __buttonSourcePathsDel_clicked__          2083


/*----------------------------------------------------------------------*/
//
//                            Class IdeINI
//
/*----------------------------------------------------------------------*/

CLASS IdeINI INHERIT IdeObject

   DATA   aINI                                    INIT  {}

   DATA   cDebuggerState                          INIT  ""

   DATA   cMainWindowGeometry                     INIT  ""
   DATA   cGotoDialogGeometry                     INIT  ""
   DATA   cFindDialogGeometry                     INIT  ""
   DATA   cToolsDialogGeometry                    INIT  ""
   DATA   cSetupDialogGeometry                    INIT  ""
   DATA   cShortcutsDialogGeometry                INIT  ""
   DATA   cDbStructDialogGeometry                 INIT  ""
   DATA   cTablesDialogGeometry                   INIT  ""
   DATA   cChangelogDialogGeometry                INIT  ""
   DATA   cStatsDialogGeometry                    INIT  ""
   //
   DATA   cRecentTabIndex                         INIT  ""
   //
   DATA   cIdeTheme                               INIT  ""
   DATA   cIdeAnimated                            INIT  ""
   //
   DATA   cPathHrbRoot                            INIT  ""
   DATA   cPathHbmk2                              INIT  ""
   DATA   cPathResources                          INIT  ""
   DATA   cPathTemp                               INIT  ""
   DATA   cPathEnv                                INIT  ""
   DATA   cPathShortcuts                          INIT  ""
   DATA   cPathSnippets                           INIT  ""
   DATA   cPathThemes                             INIT  ""

   DATA   cVSSExe                                 INIT  ""
   DATA   cVSSDatabase                            INIT  ""

   DATA   cCurrentProject                         INIT  ""
   DATA   cCurrentTheme                           INIT  ""
   DATA   cCurrentCodec                           INIT  ""
   DATA   cCurrentEnvironment                     INIT  ""
   DATA   cCurrentFind                            INIT  ""
   DATA   cCurrentFolderFind                      INIT  ""
   DATA   cCurrentReplace                         INIT  ""
   DATA   cCurrentView                            INIT  ""
   //
   DATA   cTextFileExtensions                     INIT  ".c,.cpp,.prg,.h,.ch,.txt,.log,.ini,.env,.ppo,.qtp,.hb," + ;
                                                        ".cc,.hbc,.hbp,.hbm,.xml,.bat,.sh,.rc,.ui,.uic,.bak,.fmg,.qth,.qrc"
   DATA   aProjFiles                              INIT  {}
   DATA   aFiles                                  INIT  {}
   DATA   aFind                                   INIT  {}
   DATA   aReplace                                INIT  {}
   DATA   aRecentProjects                         INIT  {}
   DATA   aRecentFiles                            INIT  {}
   DATA   aFolders                                INIT  {}
   DATA   aViews                                  INIT  {}
   DATA   aTaggedProjects                         INIT  {}
   DATA   aTools                                  INIT  {}
   DATA   aUserToolbars                           INIT  {}
   DATA   aKeywords                               INIT  {}
   DATA   aDbuPanelNames                          INIT  {}
   DATA   aDbuPanelsInfo                          INIT  {}
   DATA   aDictionaries                           INIT  {}
   DATA   aLogTitle                               INIT  {}
   DATA   aLogSources                             INIT  {}
   DATA   aIncludePaths                           INIT  {}
   DATA   aSourcePaths                            INIT  {}

   DATA   cFontName                               INIT  "Courier"
   DATA   nPointSize                              INIT  10
   DATA   cLineEndingMode                         INIT  ""

   DATA   lTrimTrailingBlanks                     INIT  .f.
   DATA   lSaveSourceWhenComp                     INIT  .t.
   DATA   lConvTabToSpcWhenLoading                INIT  .f.

   DATA   lSupressHbKWordsToUpper                 INIT  .f.
   DATA   lReturnAsBeginKeyword                   INIT  .f.
   DATA   lAutoIndent                             INIT  .t.
   DATA   lSmartIndent                            INIT  .t.
   DATA   lTabToSpcInEdits                        INIT  .t.
 //DATA   nTabSpaces                              INIT  ::oIde:nTabSpaces
   DATA   nIndentSpaces                           INIT  3
   DATA   lSelToolbar                             INIT  .T.
   DATA   lSplitVertical                          INIT  .F.

   DATA   nTmpBkpPrd                              INIT  60
   DATA   cBkpPath                                INIT  ""
   DATA   cBkpSuffix                              INIT  ".bkp"

   DATA   lCompletionWithArgs                     INIT  .t.
   DATA   lCompleteArgumented                     INIT  .f.

   DATA   aAppThemes                              INIT  {}
   DATA   lEditsMdi                               INIT  .t.

   DATA   lShowEditsLeftToolbar                   INIT  .t.
   DATA   lShowEditsTopToolbar                    INIT  .t.

   DATA   nDocksTabShape                          INIT  QTabWidget_Triangular
   DATA   nDocksLeftTabPos                        INIT  QTabWidget_South
   DATA   nDocksTopTabPos                         INIT  QTabWidget_South
   DATA   nDocksBottomTabPos                      INIT  QTabWidget_South
   DATA   nDocksRightTabPos                       INIT  QTabWidget_South

   DATA   cChangeLog                              INIT  ""
   DATA   cUserChangeLog                          INIT  ""

   DATA   lShowHideDocks                          INIT  .t.
   DATA   nEditsViewStyle                         INIT  0
   DATA   cToolbarSize                            INIT  "12"

   DATA   nPanelsTabPosition                      INIT 0
   DATA   nPanelsTabShape                         INIT 1

   DATA   lISClosing                              INIT .T.
   DATA   lISIf                                   INIT .T.
   DATA   lISFor                                  INIT .T.
   DATA   lISDoWhile                              INIT .T.
   DATA   lISDoCase                               INIT .T.
   DATA   lISSwitch                               INIT .T.
   DATA   lISElse                                 INIT .F.
   DATA   lISCaseOWise                            INIT .F.
   DATA   lISSwitchOWise                          INIT .F.
   DATA   lISExitSameLine                         INIT .F.
   DATA   nISCaseCases                            INIT 3
   DATA   nISSwitchCases                          INIT 3
   DATA   lISClosingP                             INIT .F.
   DATA   lISSpaceP                               INIT .F.
   DATA   lISCodeBlock                            INIT .T.
   DATA   lISOperator                             INIT .F.
   DATA   lISAlignAssign                          INIT .F.
   DATA   lISFmtLine                              INIT .F.
   DATA   lISEmbrace                              INIT .F.
   DATA   lISLocal                                INIT .T.
   DATA   lISReturn                               INIT .T.
   DATA   lISSeparator                            INIT .T.
   DATA   lISDocs                                 INIT .F.
   DATA   lISFunction                             INIT .T.
   DATA   lISClass                                INIT .T.
   DATA   cISData                                 INIT "VAR"
   DATA   cISMethods                              INIT "new"
   DATA   cISFormat                               INIT "class:method"

   DATA   lTabRemoveExt                           INIT .F.
   DATA   lTabAddClose                            INIT .F.
   DATA   nToolWindowColumns                      INIT 17
   DATA   lExtBuildLaunch                         INIT .F.

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD load( cHbideIni )
   METHOD save( cHbideIni )

   METHOD getIniPath()
   METHOD getResourcesPath()
   METHOD getTempPath()
   METHOD getHarbourPath()
   METHOD getIniFile()
   METHOD getEnvFile()
   METHOD getHbmk2File()
   METHOD getSnippetsFile()
   METHOD getShortcutsFile()
   METHOD getThemesFile()
   METHOD showHideDocks()

   ENDCLASS


METHOD IdeINI:new( oIde )
   ::oIde := oIde
   RETURN Self


METHOD IdeINI:destroy()
   RETURN NIL


METHOD IdeINI:create( oIde )
   DEFAULT oIde TO ::oIde
   ::oIde := oIde
   RETURN Self


METHOD IdeINI:getINIPath()
   LOCAL cPath
   hb_fNameSplit( ::oIde:cProjIni, @cPath )
   RETURN cPath


METHOD IdeINI:getResourcesPath()
   LOCAL cPath := iif( empty( ::cPathResources ), ::getINIPath(), ::cPathResources )
   RETURN iif( empty( cPath ), cPath, hbide_pathToOSPath( hbide_pathAppendLastSlash( cPath ) ) )


METHOD IdeINI:getHarbourPath()
   LOCAL cPath := ::cPathHrbRoot

   IF empty( cPath )
      IF empty( cPath := hb_getEnv( "HB_INSTALL_PREFIX" ) ) /* This covers Harbour developers */
         hb_fNameSplit( hb_dirBase(), @cPath )              /* This covers USERS of nightly builds */
         IF ! hb_fileExists( cPath + "harbour.exe" )
            IF ! hb_fileExists( cPath + "harbour" )
               cPath := ""
            ENDIF
         ENDIF
         IF ! empty( cPath )
            cPath := hbide_pathAppendLastSlash( cPath ) + ".." + hb_ps()
         ENDIF
      ENDIF
   ENDIF
   ::cPathHrbRoot := iif( empty( cPath ), "", hbide_pathToOSPath( hbide_pathAppendLastSlash( cPath ) ) )

   RETURN ::cPathHrbRoot


METHOD IdeINI:getTempPath()
   RETURN hbide_pathToOSPath( ::cPathTemp )


METHOD IdeINI:getINIFile()
   RETURN hbide_pathToOSPath( hbide_pathFile( ::getINIPath(), "hbide.ini" ) )


METHOD IdeINI:getHbmk2File()
   LOCAL cFile

   IF empty( ::cPathHbmk2 )
      IF empty( cFile := hb_getenv( "HBIDE_DIR_HBMK2" ) )
         cFile := "hbmk2"
      ELSE
         cFile := hbide_pathFile( cFile, "hbmk2" )
      ENDIF
   ELSE
      cFile := ::cPathHbmk2
   ENDIF

   RETURN hbide_pathToOSPath( cFile )


METHOD IdeINI:getEnvFile()
   RETURN hbide_pathToOSPath( iif( empty( ::cPathEnv ), hbide_pathFile( ::getINIPath(), "hbide.skl" ), ::cPathEnv ) )


METHOD IdeINI:getSnippetsFile()
   RETURN hbide_pathToOSPath( iif( empty( ::cPathSnippets ), hbide_pathFile( ::getINIPath(), "hbide.skl" ), ::cPathSnippets ) )


METHOD IdeINI:getShortcutsFile()
   RETURN hbide_pathToOSPath( iif( empty( ::cPathShortcuts ), hbide_pathFile( ::getINIPath(), "hbide.scu" ), ::cPathShortcuts ) )


METHOD IdeINI:getThemesFile()
   RETURN hbide_pathToOSPath( iif( empty( ::cPathThemes ), hbide_pathFile( ::getINIPath(), "hbide.hbt" ), ::cPathThemes ) )


METHOD IdeINI:showHideDocks()

   IF ::lShowHideDocks  /* Assumed visible, hide all */
      hbide_saveSettings( ::oIde, "tempsettings.ide" )
      ::oDK:hideAllDocks()
   ELSE
      hbide_restSettings( ::oIde, "tempsettings.ide" )
   ENDIF

   ::lShowHideDocks := ! ::lShowHideDocks

   RETURN Self


METHOD IdeINI:save( cHbideIni )
   LOCAL j, nTab, pTab, n, txt_, oEdit, nTabs, nn, a_, s, qLst, k

   DEFAULT cHbideIni TO ::oIde:cProjIni

   IF ::oIde:nRunMode != HBIDE_RUN_MODE_INI
      RETURN Nil
   ENDIF

   IF ! ::lShowHideDocks
      ::showHideDocks()
      ::lShowHideDocks := .f.
   ENDIF

   txt_:= {}

   aadd( txt_, "[HBIDE]" )
   aadd( txt_, " " )
   //
   aadd( txt_, "MainWindowGeometry"        + "=" +   hbide_posAndSize( ::oDlg:oWidget )                 )
   aadd( txt_, "GotoDialogGeometry"        + "=" +   ::cGotoDialogGeometry                              )
   aadd( txt_, "FindDialogGeometry"        + "=" +   ::cFindDialogGeometry                              )
   aadd( txt_, "ToolsDialogGeometry"       + "=" +   ::cToolsDialogGeometry                             )
   aadd( txt_, "ShortcutsDialogGeometry"   + "=" +   ::cShortcutsDialogGeometry                         )
   aadd( txt_, "SetupDialogGeometry"       + "=" +   ::cSetupDialogGeometry                             )
   aadd( txt_, "DbStructDialogGeometry"    + "=" +   ::cDbStructDialogGeometry                          )
   aadd( txt_, "TablesDialogGeometry"      + "=" +   ::cTablesDialogGeometry                            )
   aadd( txt_, "ChangelogDialogGeometry"   + "=" +   ::cChangelogDialogGeometry                         )
   aadd( txt_, "StatsDialogGeometry"       + "=" +   ::cStatsDialogGeometry                             )
   //
   aadd( txt_, "CurrentLineHighlightMode"  + "=" +   iif( ::lCurrentLineHighlightEnabled, "YES", "NO" ) )
   aadd( txt_, "LineNumbersDisplayMode"    + "=" +   iif( ::lLineNumbersVisible, "YES", "NO" )          )
   aadd( txt_, "HorzRulerDisplayMode"      + "=" +   iif( ::lHorzRulerVisible, "YES", "NO" )            )
   //
   aadd( txt_, "RecentTabIndex"            + "=" +   hb_ntos( ::qTabWidget:currentIndex() )             )
   //
   aadd( txt_, "IdeTheme"                  + "=" +   ::cIdeTheme                                        )
   aadd( txt_, "IdeAnimated"               + "=" +   ::cIdeAnimated                                     )
   //
   aadd( txt_, "PathHrbRoot"               + "=" +   ::cPathHrbRoot                                     )
   aadd( txt_, "PathMk2"                   + "=" +   ::cPathHbMk2                                       )
   aadd( txt_, "PathResources"             + "=" +   ::cPathResources                                   )
   aadd( txt_, "PathTemp"                  + "=" +   ::cPathTemp                                        )
   aadd( txt_, "PathEnv"                   + "=" +   ::cPathEnv                                         )
   aadd( txt_, "PathShortcuts"             + "=" +   ::cPathShortcuts                                   )
   aadd( txt_, "PathSnippets"              + "=" +   ::cPathSnippets                                    )
   aadd( txt_, "PathThemes"                + "=" +   ::cPathThemes                                      )
   //
   aadd( txt_, "CurrentProject"            + "=" +   ::oIde:cWrkProject                                 )
   aadd( txt_, "CurrentTheme"              + "=" +   ::oIde:cWrkTheme                                   )
   aadd( txt_, "CurrentCodec"              + "=" +   ::oIde:cWrkCodec                                   )
   aadd( txt_, "CurrentEnvironment"        + "=" +   ::oIde:cWrkEnvironment                             )
   aadd( txt_, "CurrentFind"               + "=" +   ::oIde:cWrkFind                                    )
   aadd( txt_, "CurrentFolderFind"         + "=" +   ::oIde:cWrkFolderFind                              )
   aadd( txt_, "CurrentReplace"            + "=" +   ::oIde:cWrkReplace                                 )
   aadd( txt_, "CurrentView"               + "=" +   ::oIde:cWrkView                                    )
   aadd( txt_, "TextFileExtensions"        + "=" +   ::cTextFileExtensions                              )
   //
   aadd( txt_, "FontName"                  + "=" +   ::cFontName                                        )
   aadd( txt_, "PointSize"                 + "=" +   hb_ntos( ::nPointSize )                            )
   aadd( txt_, "LineEndingMode"            + "=" +   ::cLineEndingMode                                  )
// aadd( txt_, ""        + "=" +   ::c                             )
   //
   aadd( txt_, " " )
   aadd( txt_, "TrimTrailingBlanks"        + "=" +   iif( ::lTrimTrailingBlanks     , "YES", "NO" )     )
   aadd( txt_, "SaveSourceWhenComp"        + "=" +   iif( ::lSaveSourceWhenComp     , "YES", "NO" )     )
   aadd( txt_, "SupressHbKWordsToUpper"    + "=" +   iif( ::lSupressHbKWordsToUpper , "YES", "NO" )     )
   aadd( txt_, "ReturnAsBeginKeyword"      + "=" +   iif( ::lReturnAsBeginKeyword   , "YES", "NO" )     )
   aadd( txt_, "ConvTabToSpcWhenLoading"   + "=" +   iif( ::lConvTabToSpcWhenLoading, "YES", "NO" )     )
   aadd( txt_, "AutoIndent"                + "=" +   iif( ::lAutoIndent             , "YES", "NO" )     )
   aadd( txt_, "SmartIndent"               + "=" +   iif( ::lSmartIndent            , "YES", "NO" )     )
   aadd( txt_, "TabToSpcInEdits"           + "=" +   iif( ::lTabToSpcInEdits        , "YES", "NO" )     )
   aadd( txt_, "TabSpaces"                 + "=" +   hb_ntos( ::oIde:nTabSpaces )                       )
   aadd( txt_, "IndentSpaces"              + "=" +   hb_ntos( ::nIndentSpaces )                         )
   aadd( txt_, "TmpBkpPrd"                 + "=" +   hb_ntos( ::nTmpBkpPrd )                            )
   aadd( txt_, "BkpPath"                   + "=" +   ::cBkpPath                                         )
   aadd( txt_, "BkpSuffix"                 + "=" +   ::cBkpSuffix                                       )
   aadd( txt_, "CodeListWithArgs"          + "=" +   iif( ::lCompletionWithArgs     , "YES", "NO" )     )
   aadd( txt_, "CompletionWithArgs"        + "=" +   iif( ::lCompleteArgumented     , "YES", "NO" )     )
   aadd( txt_, "EditsMdi"                  + "=" +   iif( ::lEditsMdi               , "YES", "NO" )     )
   //
   aadd( txt_, "ShowEditsLeftToolbar"      + "=" +   iif( ::lShowEditsLeftToolbar   , "YES", "NO" )     )
   aadd( txt_, "ShowEditsTopToolbar"       + "=" +   iif( ::lShowEditsTopToolbar    , "YES", "NO" )     )
   aadd( txt_, "DocksTabShape"             + "=" +   hb_ntos( ::nDocksTabShape )                        )
   aadd( txt_, "DocksLeftTabPos"           + "=" +   hb_ntos( ::nDocksLeftTabPos )                      )
   aadd( txt_, "DocksTopTabPos"            + "=" +   hb_ntos( ::nDocksTopTabPos )                       )
   aadd( txt_, "DocksBottomTabPos"         + "=" +   hb_ntos( ::nDocksRightTabPos )                     )
   aadd( txt_, "DocksRightTabPos"          + "=" +   hb_ntos( ::nDocksBottomTabPos )                    )
   aadd( txt_, "ShowHideDocks"             + "=" +   iif( ::lShowHideDocks          , "YES", "NO" )     )
   aadd( txt_, "ChangeLog"                 + "=" +   ::cChangeLog                                       )
   aadd( txt_, "UserChangeLog"             + "=" +   ::cUserChangeLog                                   )
   aadd( txt_, "VSSExe"                    + "=" +   ::cVSSExe                                          )
   aadd( txt_, "VSSDatabase"               + "=" +   ::cVSSDatabase                                     )
   aadd( txt_, "EditsViewStyle"            + "=" +   hb_ntos( ::nEditsViewStyle )                       )
   aadd( txt_, "ToolbarSize"               + "=" +   ::cToolbarSize                                     )
   aadd( txt_, "PanelsTabPosition"         + "=" +   hb_ntos( ::nPanelsTabPosition )                    )
   aadd( txt_, "PanelsTabShape"            + "=" +   hb_ntos( ::nPanelsTabShape )                       )

   aadd( txt_, "SplitVertical"             + "=" +   iif( ::lSplitVertical         , "YES", "NO" )     )

   aadd( txt_, "ISClosing"                 + "=" +   iif( ::lISClosing             , "YES", "NO" )      )
   aadd( txt_, "ISIf"                      + "=" +   iif( ::lISIf                  , "YES", "NO" )      )
   aadd( txt_, "ISFor"                     + "=" +   iif( ::lISFor                 , "YES", "NO" )      )
   aadd( txt_, "ISDoWhile"                 + "=" +   iif( ::lISDoWhile             , "YES", "NO" )      )
   aadd( txt_, "ISDoCase"                  + "=" +   iif( ::lISDoCase              , "YES", "NO" )      )
   aadd( txt_, "ISSwitch"                  + "=" +   iif( ::lISSwitch              , "YES", "NO" )      )
   aadd( txt_, "ISElse"                    + "=" +   iif( ::lISElse                , "YES", "NO" )      )
   aadd( txt_, "ISCaseOWise"               + "=" +   iif( ::lISCaseOWise           , "YES", "NO" )      )
   aadd( txt_, "ISSwitchOWise"             + "=" +   iif( ::lISSwitchOWise         , "YES", "NO" )      )
   aadd( txt_, "ISExitSameLine"            + "=" +   iif( ::lISExitSameLine        , "YES", "NO" )      )
   aadd( txt_, "ISCaseCases"               + "=" +   hb_ntos( ::nISCaseCases  )                         )
   aadd( txt_, "ISSwitchCases"             + "=" +   hb_ntos( ::nISSwitchCases )                        )
   aadd( txt_, "ISClosingP"                + "=" +   iif( ::lISClosingP            , "YES", "NO" )      )
   aadd( txt_, "ISSpaceP"                  + "=" +   iif( ::lISSpaceP              , "YES", "NO" )      )
   aadd( txt_, "ISCodeBlock"               + "=" +   iif( ::lISCodeBlock           , "YES", "NO" )      )
   aadd( txt_, "ISOperator"                + "=" +   iif( ::lISOperator            , "YES", "NO" )      )
   aadd( txt_, "ISAlignAssign"             + "=" +   iif( ::lISAlignAssign         , "YES", "NO" )      )
   AAdd( txt_, "ISFmtLine"                 + "=" +   iif( ::lISFmtLine             , "YES", "NO" )      )
   AAdd( txt_, "ISEmbrace"                 + "=" +   iif( ::lISEmbrace             , "YES", "NO" )      )
   AAdd( txt_, "ISLocal"                   + "=" +   iif( ::lISLocal               , "YES", "NO" )      )
   AAdd( txt_, "ISReturn"                  + "=" +   iif( ::lISReturn              , "YES", "NO" )      )
   AAdd( txt_, "ISSeparator"               + "=" +   iif( ::lISSeparator           , "YES", "NO" )      )
   AAdd( txt_, "ISDocs"                    + "=" +   iif( ::lISDocs                , "YES", "NO" )      )
   AAdd( txt_, "ISFunction"                + "=" +   iif( ::lISFunction            , "YES", "NO" )      )
   AAdd( txt_, "ISClass"                   + "=" +   iif( ::lISClass               , "YES", "NO" )      )
   AAdd( txt_, "ISData"                    + "=" +   ::cISData     )
   AAdd( txt_, "ISMethods"                 + "=" +   ::cISMethods  )
   AAdd( txt_, "ISFormat"                  + "=" +   ::cISFormat   )
   //
   AAdd( txt_, "SelToolbar"                + "=" +   iif( ::lSelToolbar            , "YES", "NO" )      )
   AAdd( txt_, "TabRemoveExt"              + "=" +   iif( ::lTabRemoveExt          , "YES", "NO" )      )
   AAdd( txt_, "TabAddClose"               + "=" +   iif( ::lTabAddClose           , "YES", "NO" )      )
   aadd( txt_, "ToolWindowColumns"         + "=" +   hb_ntos( ::nToolWindowColumns )                    )
   aadd( txt_, "ExtBuildLaunch"            + "=" +   iif( ::lExtBuildLaunch        , "YES", "NO" )      )
   aadd( txt_, "DebuggerState"             + "=" +   ::oIde:oDebugger:getUIState()                      )

   aadd( txt_, "" )
   aadd( txt_, "[PROJECTS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::oIde:aProjects )
      aadd( txt_, "project_" + hb_ntos( n ) + "=" + hbide_pathNormalized( ::oIde:aProjects[ n, 2 ], .f. ) )
   NEXT
   aadd( txt_, " " )

   /*-------------------   FILES   -------------------*/
   aadd( txt_, "[FILES]" )
   aadd( txt_, " " )
   qLst := ::oStackedWidget:oWidget:subWindowList( QMdiArea_StackingOrder )  /* The order tabs are visible */
   nn := 0
   FOR k := 1 TO qLst:count()
#if 0
      cView := qLst:at( k - 1 ):objectName()
      ascan( ::oDK:aViewsInfo, {|e_| e_[ 1 ] == cView } )          /* Not successful, QMdiArea has no method to determine the tab order */
#else
      j := k
#endif
      ::oIde:lClosing := .t.
      ::oDK:setView( ::oIde:aViews[ j ]:oWidget:objectName() )

      nTabs := ::oIde:qTabWidget:count()
      FOR n := 1 TO nTabs
         pTab  := ::oIde:qTabWidget:widget( n - 1 )
         nTab  := ascan( ::oIde:aTabs, {|e_| hbqt_IsEqual( e_[ 1 ]:oWidget, pTab ) } )
         IF nTab > 0
            oEdit := ::oIde:aTabs[ nTab, TAB_OEDITOR ]

            IF !Empty( oEdit:source() ) .AND. !( ".ppo" == lower( oEdit:cExt ) )
               IF oEdit:lLoaded
                  aadd( txt_, "file_" + hb_ntos( ++nn ) + "=" + hbide_getEditInfoAsString( oEdit ) )

               ELSE
                  aadd( txt_, "file_" + hb_ntos( ++nn ) + "=" + hbide_pathNormalized( oEdit:source(), .f. ) + "," + ;
                              hb_ntos( oEdit:nPos  ) +  ","  + ;
                              hb_ntos( oEdit:nHPos ) +  ","  + ;
                              hb_ntos( oEdit:nVPos ) +  ","  + ;
                              oEdit:cTheme           +  ","  + ;
                              oEdit:cView            +  ","  + ;
                              hbide_nArray2string( oEdit:oEdit:aBookMarks ) +  "," + ;
                              oEdit:cCodePage        +  ","  + ;
                              oEdit:extras() )
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[FIND]" )
   aadd( txt_, " " )
   FOR n := 1 TO Min( 20, Len( ::aFind ) )
      aadd( txt_, "find_" + hb_ntos( n ) + "=" + ::aFind[ n ] )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[REPLACE]" )
   aadd( txt_, " " )
   FOR n := 1 TO Min( 20, Len( ::aReplace ) )
      aadd( txt_, "replace_" + hb_ntos( n ) + "=" + ::aReplace[ n ] )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[RECENTFILES]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aRecentFiles )
      aadd( txt_, "recentfile_" + hb_ntos( n ) + "=" + hbide_pathNormalized( ::aRecentFiles[ n ], .f. ) )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[RECENTPROJECTS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aRecentProjects )
      aadd( txt_, "recentproject_" + hb_ntos( n ) + "=" + hbide_pathNormalized( ::aRecentProjects[ n ], .f. ) )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[FOLDERS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aFolders )
      aadd( txt_, "folder_" + hb_ntos( n ) + "=" + hbide_pathNormalized( ::aFolders[ n ], .f. ) )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[VIEWS]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oDK:getEditorPanelsInfo()
      aadd( txt_, "view_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[TAGGEDPROJECTS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aTaggedProjects )
      aadd( txt_, "taggedproject_" + hb_ntos( n ) + "=" + ::aTaggedProjects[ n ] )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[TOOLS]" )
   aadd( txt_, " " )
   FOR EACH a_ IN ::aTools
      aadd( txt_, "tool_" + hb_ntos( a_:__enumIndex() ) + "=" + hbide_array2string( a_, "," ) )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[USERTOOLBARS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aUserToolbars )
      aadd( txt_, "usertoolbars_" + hb_ntos( n ) + "=" + hbide_array2string( ::aUserToolbars[ n ], "," ) )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[KEYWORDS]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aKeywords )
      aadd( txt_, "keyword_" + hb_ntos( n ) + "=" + hbide_array2string( ::aKeywords[ n ], "~" ) )
   NEXT
   aadd( txt_, " " )
#if 0
   aadd( txt_, "[DBUPANELS]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oBM:oDbu:getPanelNames()
      aadd( txt_, "dbupanel_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[DBUPANELSINFO]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oBM:oDbu:getPanelsInfo()
      aadd( txt_, "dbupanelinfo_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )
#endif
   aadd( txt_, "[APPTHEMES]" )
   aadd( txt_, " " )
   FOR EACH s IN ::aAppThemes
      aadd( txt_, "apptheme_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[DICTIONARIES]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oIde:aUserDict  // aDictionaries
      aadd( txt_, "dictionary_" + hb_ntos( s:__enumIndex() ) + "=" + s:toString() )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[INCLUDEPATHS]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oINI:aIncludePaths
      aadd( txt_, "includepaths_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[SOURCEPATHS]" )
   aadd( txt_, " " )
   FOR EACH s IN ::oINI:aSourcePaths
      aadd( txt_, "sourcepaths_" + hb_ntos( s:__enumIndex() ) + "=" + s )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[LOGTITLE]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aLogTitle )
      aadd( txt_, "logtitle_" + hb_ntos( n ) + "=" + ::aLogTitle[ n ] )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[LOGSOURCES]" )
   aadd( txt_, " " )
   FOR n := 1 TO Len( ::aLogSources )
      aadd( txt_, "logsources_" + hb_ntos( n ) + "=" + ::aLogSources[ n ] )
   NEXT
   aadd( txt_, " " )

   aadd( txt_, "[General]" )
   aadd( txt_, " " )

   hbide_createTarget( ::oIde:cProjIni, txt_ )

   RETURN hbide_saveSettings( ::oIde )


METHOD IdeINI:load( cHbideIni )
   LOCAL aElem, s, nPart, cKey, cVal, a_

   ::oIde:cProjIni := hbide_getIniPath( cHbideIni )

   IF hb_FileExists( ::oIde:cProjIni )
      aElem := hbide_readSource( ::oIde:cProjIni )

      FOR EACH s IN aElem

         s := alltrim( s )
         IF !empty( s )
            SWITCH Upper( s )

            CASE "[GENERAL]"
               nPart := "INI_GENERAL"
               EXIT
            CASE "[HBIDE]"
               nPart := "INI_HBIDE"
               EXIT
            CASE "[PROJECTS]"
               nPart := "INI_PROJECTS"
               EXIT
            CASE "[FILES]"
               nPart := "INI_FILES"
               EXIT
            CASE "[FIND]"
               nPart := "INI_FIND"
               EXIT
            CASE "[REPLACE]"
               nPart := "INI_REPLACE"
               EXIT
            CASE "[RECENTFILES]"
               nPart := "INI_RECENTFILES"
               EXIT
            CASE "[RECENTPROJECTS]"
               nPart := "INI_RECENTPROJECTS"
               EXIT
            CASE "[FOLDERS]"
               nPart := "INI_FOLDERS"
               EXIT
            CASE "[VIEWS]"
               nPart := "INI_VIEWS"
               EXIT
            CASE "[TAGGEDPROJECTS]"
               nPart := "INI_TAGGEDPROJECTS"
               EXIT
            CASE "[TOOLS]"
               nPart := "INI_TOOLS"
               EXIT
            CASE "[USERTOOLBARS]"
               nPart := "INI_USERTOOLBARS"
               EXIT
            CASE "[KEYWORDS]"
               nPart := "INI_KEYWORDS"
               EXIT
            CASE "[DBUPANELS]"
               nPart := "INI_DBUPANELS"
               EXIT
            CASE "[DBUPANELSINFO]"
               nPart := "INI_DBUPANELSINFO"
               EXIT
            CASE "[APPTHEMES]"
               nPart := "INI_APPTHEMES"
               EXIT
            CASE "[DICTIONARIES]"
               nPart := "INI_DICTIONARIES"
               EXIT
            CASE "[INCLUDEPATHS]"
               nPart := "INI_INCLUDEPATHS"
               EXIT
            CASE "[SOURCEPATHS]"
               nPart := "INI_SOURCEPATHS"
               EXIT
            CASE "[LOGTITLE]"
               nPart := "INI_LOGTITLE"
               EXIT
            CASE "[LOGSOURCES]"
               nPart := "INI_LOGSOURCES"
               EXIT
            OTHERWISE
               DO CASE
               CASE Left( s, 1 ) $ '#['
                  * Nothing todo!

               CASE nPart == "INI_GENERAL"
                  * Qt Setttings, do nothing.

               CASE nPart == "INI_HBIDE"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )

                     SWITCH cKey

                     CASE "MainWindowGeometry"          ; ::cMainWindowGeometry               := cVal ; EXIT
                     CASE "GotoDialogGeometry"          ; ::cGotoDialogGeometry               := cVal ; EXIT
                     CASE "FindDialogGeometry"          ; ::cFindDialogGeometry               := cVal ; EXIT
                     CASE "ToolsDialogGeometry"         ; ::cToolsDialogGeometry              := cVal ; EXIT
                     CASE "SetupDialogGeometry"         ; ::cSetupDialogGeometry              := cVal ; EXIT
                     CASE "ShortcutsDialogGeometry"     ; ::cShortcutsDialogGeometry          := cVal ; EXIT
                     CASE "DbStructDialogGeometry"      ; ::cDbStructDialogGeometry           := cVal ; EXIT
                     CASE "TablesDialogGeometry"        ; ::cTablesDialogGeometry             := cVal ; EXIT
                     CASE "ChangelogDialogGeometry"     ; ::cChangelogDialogGeometry          := cVal ; EXIT
                     CASE "StatsDialogGeometry"         ; ::cStatsDialogGeometry              := cVal ; EXIT
                     //
                     CASE "CurrentLineHighlightMode"    ; ::oIde:lCurrentLineHighlightEnabled := !( cVal == "NO" ); EXIT
                     CASE "LineNumbersDisplayMode"      ; ::oIde:lLineNumbersVisible          := !( cVal == "NO" ); EXIT
                     CASE "HorzRulerDisplayMode"        ; ::oIde:lHorzRulerVisible            := !( cVal == "NO" ); EXIT
                     //
                     CASE "RecentTabIndex"              ; ::cRecentTabIndex                   := cVal ; EXIT
                     //
                     CASE "IdeTheme"                    ; ::cIdeTheme                         := cVal ; EXIT
                     CASE "IdeAnimated"                 ; ::cIdeAnimated                      := cVal ; EXIT
                     //
                     CASE "PathHrbRoot"                 ; ::cPathHrbRoot                      := cVal ; EXIT
                     CASE "PathMk2"                     ; ::cPathHbMk2                        := cVal ; EXIT
                     CASE "PathResources"               ; ::cPathResources                    := cVal ; EXIT
                     CASE "PathTemp"                    ; ::cPathTemp                         := cVal ; EXIT
                     CASE "PathEnv"                     ; ::cPathEnv                          := cVal ; EXIT
                     CASE "PathShortcuts"               ; ::cPathShortcuts                    := cVal ; EXIT
                     CASE "PathSnippets"                ; ::cPathSnippets                     := cVal ; EXIT
                     CASE "PathThemes"                  ; ::cPathThemes                       := cVal ; EXIT
                     //
                     CASE "CurrentProject"              ; ::oIde:cWrkProject                  := cVal ; EXIT
                     CASE "CurrentTheme"                ; ::oIde:cWrkTheme                    := cVal ; EXIT
                     CASE "CurrentCodec"                ; ::oIde:cWrkCodec                    := cVal ; EXIT
                     CASE "CurrentEnvironment"          ; ::oIde:cWrkEnvironment              := cVal ; EXIT
                     CASE "CurrentFind"                 ; ::oIde:cWrkFind                     := cVal ; EXIT
                     CASE "CurrentFolderFind"           ; ::oIde:cWrkFolderFind               := cVal ; EXIT
                     CASE "CurrentReplace"              ; ::oIde:cWrkReplace                  := cVal ; EXIT
                     CASE "CurrentView"                 ; ::oIde:cWrkView                     := cVal ; EXIT
                     CASE "TextFileExtensions"          ; ::cTextFileExtensions               := cVal ; EXIT
                     //
                     CASE "FontName"                    ; ::cFontName                         := cVal ; EXIT
                     CASE "PointSize"                   ; ::nPointSize                        := val( cVal ); EXIT
                     CASE "LineEndingMode"              ; ::cLineEndingMode                   := cVal ; EXIT
                     //
                     CASE "TrimTrailingBlanks"          ; ::lTrimTrailingBlanks               := !( cVal == "NO" ) ; EXIT
                     CASE "SaveSourceWhenComp"          ; ::lSaveSourceWhenComp               := !( cVal == "NO" ) ; EXIT
                     CASE "SupressHbKWordsToUpper"      ; ::lSupressHbKWordsToUpper           := !( cVal == "NO" ) ; EXIT
                     CASE "ReturnAsBeginKeyword"        ; ::lReturnAsBeginKeyword             := !( cVal == "NO" ) ; EXIT
                     CASE "ConvTabToSpcWhenLoading"     ; ::lConvTabToSpcWhenLoading          := !( cVal == "NO" ) ; EXIT
                     CASE "AutoIndent"                  ; ::lAutoIndent                       := !( cVal == "NO" ) ; EXIT
                     CASE "SmartIndent"                 ; ::lSmartIndent                      := !( cVal == "NO" ) ; EXIT
                     CASE "TabToSpcInEdits"             ; ::lTabToSpcInEdits                  := !( cVal == "NO" ) ; EXIT
                     CASE "TabSpaces"                   ; ::oIde:nTabSpaces                   := val( cVal )  ; EXIT
                     CASE "IndentSpaces"                ; ::nIndentSpaces                     := val( cVal )  ; EXIT
                     CASE "TmpBkpPrd"                   ; ::nTmpBkpPrd                        := val( cVal )  ; EXIT
                     CASE "BkpPath"                     ; ::cBkpPath                          := cVal ; EXIT
                     CASE "BkpSuffix"                   ; ::cBkpSuffix                        := cVal ; EXIT
                     CASE "CodeListWithArgs"            ; ::lCompletionWithArgs               := !( cVal == "NO" ) ; EXIT
                     CASE "CompletionWithArgs"          ; ::lCompleteArgumented               := !( cVal == "NO" ) ; EXIT
                     CASE "EditsMdi"                    ; ::lEditsMdi                         := !( cVal == "NO" ) ; EXIT

                     CASE "ShowEditsLeftToolbar"        ; ::lShowEditsLeftToolbar             := !( cVal == "NO" ) ; EXIT
                     CASE "ShowEditsTopToolbar"         ; ::lShowEditsTopToolbar              := !( cVal == "NO" ) ; EXIT
                     CASE "DocksTabShape"               ; ::nDocksTabShape                    := val( cVal )  ; EXIT
                     CASE "DocksLeftTabPos"             ; ::nDocksLeftTabPos                  := val( cVal )  ; EXIT
                     CASE "DocksTopTabPos"              ; ::nDocksTopTabPos                   := val( cVal )  ; EXIT
                     CASE "DocksBottomTabPos"           ; ::nDocksRightTabPos                 := val( cVal )  ; EXIT
                     CASE "DocksRightTabPos"            ; ::nDocksBottomTabPos                := val( cVal )  ; EXIT
                     CASE "ShowHideDocks"               ; ::lShowHideDocks                    := !( cVal == "NO" ) ; EXIT
                     CASE "ChangeLog"                   ; ::cChangeLog                        := cVal ; EXIT
                     CASE "UserChangeLog"               ; ::cUserChangeLog                    := cVal ; EXIT
                     //
                     CASE "VSSExe"                      ; ::cVSSExe                           := cVal ; EXIT
                     CASE "VSSDatabase"                 ; ::cVSSDatabase                      := cVal ; EXIT
                     CASE "EditsViewStyle"              ; ::nEditsViewStyle                   := val( cVal ); EXIT
                     CASE "ToolbarSize"                 ; ::cToolbarSize                      := cVal ; EXIT
                     CASE "PanelsTabPosition"           ; ::nPanelsTabPosition                := val( cVal ); EXIT
                     CASE "PanelsTabShape"              ; ::nPanelsTabShape                   := val( cVal ); EXIT

                     CASE "ISClosing"                   ; ::lISClosing                        := !( cVal == "NO" ) ; EXIT
                     CASE "ISIf"                        ; ::lISIf                             := !( cVal == "NO" ) ; EXIT
                     CASE "ISFor"                       ; ::lISFor                            := !( cVal == "NO" ) ; EXIT
                     CASE "ISDoWhile"                   ; ::lISDoWhile                        := !( cVal == "NO" ) ; EXIT
                     CASE "ISDoCase"                    ; ::lISDoCase                         := !( cVal == "NO" ) ; EXIT
                     CASE "ISSwitch"                    ; ::lISSwitch                         := !( cVal == "NO" ) ; EXIT
                     CASE "ISElse"                      ; ::lISElse                           := !( cVal == "NO" ) ; EXIT
                     CASE "ISCaseOWise"                 ; ::lISCaseOWise                      := !( cVal == "NO" ) ; EXIT
                     CASE "ISSwitchOWise"               ; ::lISSwitchOWise                    := !( cVal == "NO" ) ; EXIT
                     CASE "ISExitSameLine"              ; ::lISExitSameLine                   := !( cVal == "NO" ) ; EXIT
                     CASE "ISCaseCases"                 ; ::nISCaseCases                      := val( cVal )       ; EXIT
                     CASE "ISSwitchCases"               ; ::nISSwitchCases                    := val( cVal )       ; EXIT
                     CASE "ISClosingP"                  ; ::lISClosingP                       := !( cVal == "NO" ) ; EXIT
                     CASE "ISSpaceP"                    ; ::lISSpaceP                         := !( cVal == "NO" ) ; EXIT
                     CASE "ISCodeBlock"                 ; ::lISCodeBlock                      := !( cVal == "NO" ) ; EXIT
                     CASE "ISOperator"                  ; ::lISOperator                       := !( cVal == "NO" ) ; EXIT
                     CASE "ISAlignAssign"               ; ::lISAlignAssign                    := !( cVal == "NO" ) ; EXIT
                     CASE "ISFmtLine"                   ; ::lISFmtLine                        := !( cVal == "NO" ) ; EXIT
                     CASE "ISEmbrace"                   ; ::lISEmbrace                        := !( cVal == "NO" ) ; EXIT
                     CASE "ISLocal"                     ; ::lISLocal                          := !( cVal == "NO" ) ; EXIT
                     CASE "ISReturn"                    ; ::lISReturn                         := !( cVal == "NO" ) ; EXIT
                     CASE "ISSeparator"                 ; ::lISSeparator                      := !( cVal == "NO" ) ; EXIT
                     CASE "ISDocs"                      ; ::lISDocs                           := !( cVal == "NO" ) ; EXIT
                     CASE "ISFunction"                  ; ::lISFunction                       := !( cVal == "NO" ) ; EXIT
                     CASE "ISClass"                     ; ::lISClass                          := !( cVal == "NO" ) ; EXIT
                     CASE "ISData"                      ; ::cISData                           := cVal              ; EXIT
                     CASE "ISMethods"                   ; ::cISMethods                        := cVal              ; EXIT
                     CASE "ISFormat"                    ; ::cISFormat                         := cVal              ; EXIT
                     //
                     CASE "SelToolbar"                  ; ::lSelToolbar                       := !( cVal == "NO" ) ; EXIT
                     CASE "TabRemoveExt"                ; ::lTabRemoveExt                     := !( cVal == "NO" ) ; EXIT
                     CASE "TabAddClose"                 ; ::lTabAddClose                      := !( cVal == "NO" ) ; EXIT
                     CASE "ToolWindowColumns"           ; ::nToolWindowColumns                := val( cVal )       ; EXIT
                     CASE "ExtBuildLaunch"              ; ::lExtBuildLaunch                   := !( cVal == "NO" ) ; EXIT
                     CASE "DebuggerState"               ; ::cDebuggerState                    := cVal              ; EXIT
                     //
                     CASE "SplitVertical"               ; ::lSplitVertical                    := ( cVal == "YES" ) ; EXIT
                     //
                     ENDSWITCH
                  ENDIF

               CASE nPart == "INI_PROJECTS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aProjFiles, cVal )
                  ENDIF

               CASE nPart == "INI_FILES"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     a_:= hbide_parseSourceComponents( cVal )
                     IF !Empty( a_[ 1 ] )
                        aadd( ::aFiles, a_ )
                     ENDIF
                  ENDIF

               CASE nPart == "INI_FIND"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aFind, cVal )
                  ENDIF

               CASE nPart == "INI_REPLACE"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aReplace, cVal )
                  ENDIF

               CASE nPart == "INI_RECENTPROJECTS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     IF Len( ::aRecentProjects ) < 25
                        cVal := hbide_pathNormalized( cVal, .f. )
                        IF aScan( ::aRecentProjects, {|e| hb_FileMatch( hbide_pathNormalized( e, .f. ), cVal ) } ) == 0
                           AAdd( ::aRecentProjects, cVal )
                        ENDIF
                     ENDIF
                  ENDIF

               CASE nPart == "INI_RECENTFILES"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     IF Len( ::aRecentFiles ) < 25
                        cVal := hbide_pathNormalized( cVal, .f. )
                        IF aScan( ::aRecentFiles, {|e| hb_FileMatch( hbide_pathNormalized( e, .f. ), cVal ) } ) == 0
                           AAdd( ::aRecentFiles, cVal )
                        ENDIF
                     ENDIF
                  ENDIF

               CASE nPart == "INI_FOLDERS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aFolders, cVal )
                  ENDIF

               CASE nPart == "INI_VIEWS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aViews, cVal )
                  ENDIF

               CASE nPart == "INI_TAGGEDPROJECTS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd(::aTaggedProjects, cVal )
                  ENDIF

               CASE nPart == "INI_TOOLS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aTools, hbide_parseToolComponents( cVal ) )
                  ENDIF

               CASE nPart == "INI_USERTOOLBARS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aUserToolbars, hbide_parseUserToolbarComponents( cVal ) )
                  ENDIF

               CASE nPart == "INI_KEYWORDS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aKeywords, hbide_parseKeywordsComponents( cVal ) )
                  ENDIF

               CASE nPart == "INI_DBUPANELS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aDbuPanelNames, cVal )
                  ENDIF

               CASE nPart == "INI_DBUPANELSINFO"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aDbuPanelsInfo, cVal )
                  ENDIF

               CASE nPart == "INI_APPTHEMES"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aAppThemes, cVal )
                  ENDIF

               CASE nPart == "INI_DICTIONARIES"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aDictionaries, cVal )
                  ENDIF

               CASE nPart == "INI_INCLUDEPATHS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aIncludePaths, cVal )
                  ENDIF

               CASE nPart == "INI_SOURCEPATHS"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aSourcePaths, cVal )
                  ENDIF

               CASE nPart == "INI_LOGTITLE"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aLogTitle, cVal )
                  ENDIF

               CASE nPart == "INI_LOGSOURCES"
                  IF hbide_parseKeyValPair( s, @cKey, @cVal )
                     aadd( ::aLogSources, cVal )
                  ENDIF

               ENDCASE
               EXIT
            ENDSWITCH
          ENDIF
      NEXT
   ENDIF

   ::lEditsMdi := .t.  /* Enabled Permanently - scheduled to be removed by next commit */

   RETURN Self


FUNCTION hbide_saveSettings( oIde, cFile )
   LOCAL cPath

   DEFAULT cFile TO "settings.ide"

   hb_fNameSplit( oIde:cProjIni, @cPath )
   hbqt_QMainWindow_saveSettings( cPath + cFile, "hbidesettings", oIde:oDlg:oWidget )

   RETURN nil


FUNCTION hbide_restSettings( oIde, cFile )
   LOCAL cPath

   DEFAULT cFile TO "settings.ide"

   hb_fNameSplit( oIde:cProjIni, @cPath )
   hbqt_QMainWindow_restSettings( cPath + cFile, "hbidesettings", oIde:oDlg:oWidget )

   RETURN nil


FUNCTION hbide_getEditInfoAsString( oEdit )
   LOCAL qHScr   := oEdit:qEdit:horizontalScrollBar()
   LOCAL qVScr   := oEdit:qEdit:verticalScrollBar()
   LOCAL qCursor := oEdit:qEdit:textCursor()
   LOCAL cBMarks := hbide_nArray2string( oEdit:oEdit:aBookMarks )

   RETURN hbide_pathNormalized( oEdit:source(), .f. ) +  ","  + ;
                          hb_ntos( qCursor:position() ) +  ","  + ;
                          hb_ntos( qHScr:value()      ) +  ","  + ;
                          hb_ntos( qVScr:value()      ) +  ","  + ;
                          oEdit:cTheme                  +  ","  + ;
                          oEdit:cView                   +  ","  + ;
                          cBMarks                       +  ","  + ;
                          oEdit:cCodePage               +  ","  + ;
                          oEdit:extras()


FUNCTION hbide_getIniPath( cHbideIni )
   LOCAL cPath, cIni

   IF empty( cHbideIni )
      IF ! hb_FileExists( cIni := hb_dirBase() + "hbide.ini" )
      #if defined( __PLATFORM__WINDOWS )
         cPath := hb_DirSepAdd( GetEnv( "APPDATA" ) ) + "hbide\"
      #elif defined( __PLATFORM__UNIX )
         cPath := hb_DirSepAdd( GetEnv( "HOME" ) ) + ".hbide/"
      #elif defined( __PLATFORM__OS2 )
         cPath := hb_DirSepAdd( GetEnv( "HOME" ) ) + ".hbide/"
      #endif
         IF ! hb_dirExists( cPath )
            hb_DirCreate( cPath )
         ENDIF
         cIni := cPath + "hbide.ini"
      ENDIF
   ELSE
      cIni := cHbideIni
   ENDIF

   RETURN cIni


FUNCTION hbide_loadSkltns( oIde, cPathSkltns )
   LOCAL s, n, cSkltn, cCode

   IF empty( cPathSkltns )
      cPathSkltns := oIde:oINI:getSnippetsFile()
   ENDIF

   IF hb_fileExists( cPathSkltns )
      s := hb_memoread( cPathSkltns )

      DO WHILE .t.
         IF ( n := at( "<", s ) ) == 0
            EXIT
         ENDIF
         s := substr( s, n + 1 )
         IF ( n := at( ">", s ) ) == 0
            EXIT
         ENDIF
         cSkltn := substr( s, 1, n - 1 )
         s := substr( s, n + 1 )
         IF ( n := at( "</" + cSkltn + ">", s ) ) > 0
            cCode := substr( s, 1, n - 1 )
            cCode := alltrim( cCode )
            IF left( cCode, 1 ) $ chr( 13 ) + chr( 10 )
               cCode := substr( cCode, 2 )
            ENDIF
            IF left( cCode, 1 ) $ chr( 13 ) + chr( 10 )
               cCode := substr( cCode, 2 )
            ENDIF
            IF right( cCode, 1 ) $ chr( 13 ) + chr( 10 )
               cCode := substr( cCode, 1, Len( cCode ) - 1 )
            ENDIF
            IF right( cCode, 1 ) $ chr( 13 ) + chr( 10 )
               cCode := substr( cCode, 1, Len( cCode ) - 1 )
            ENDIF

            aadd( oIde:aSkltns, { cSkltn, cCode } )
            s := substr( s, n + Len( "</" + cSkltn + ">" ) )
         ELSE
            EXIT
         ENDIF
      ENDDO
   ENDIF

   RETURN NIL


FUNCTION hbide_saveSkltns( oIde )
   LOCAL a_, txt_:= {}

   FOR EACH a_ IN oIde:aSkltns
      aadd( txt_, "<" + a_[ 1 ] + ">" )
      aeval( hbide_memoToArray( a_[ 2 ] ), {|e| aadd( txt_, e ) } )
      aadd( txt_, "</" + a_[ 1 ] + ">" )
      aadd( txt_, "" )
   NEXT

   RETURN hbide_createTarget( oIde:oINI:getSnippetsFile(), txt_ )


FUNCTION hbide_loadShortcuts( oIde, cFileShortcuts )
   LOCAL a_:= {}

   IF empty( cFileShortcuts )
      cFileShortcuts := oIde:oINI:getShortcutsFile()
   ENDIF
   IF hb_fileExists( cFileShortcuts )
      a_:= hb_deSerialize( hb_memoread( cFileShortcuts ) )
   ENDIF

   RETURN a_


FUNCTION hbide_saveShortcuts( oIde, a_, cFileShortcuts )

   IF empty( cFileShortcuts )
      cFileShortcuts := oIde:oINI:getShortcutsFile()
   ENDIF
   hb_memowrit( cFileShortcuts, hb_serialize( a_ ) )

   RETURN hb_fileExists( cFileShortcuts )


FUNCTION hbide_loadHarbourProtos( oIde )

   HB_SYMBOL_UNUSED( oIde )

   RETURN NIL //hbide_harbourProtos()


FUNCTION hbide_saveHarbourProtos( oIde, aProto )
   LOCAL cFile := hb_dirBase() + "idehbprotos.prg"
   LOCAL txt_  := {}
   LOCAL cTxt  := ""

   HB_SYMBOL_UNUSED( oIde )

   aadd( txt_, "/*"                                                                            )
   aadd( txt_, " * $Id: saveload.prg 426 2016-10-20 00:14:06Z bedipritpal $"                 )
   aadd( txt_, " */"                                                                           )
   aadd( txt_, ""                                                                              )
   aadd( txt_, "/* -------------------------------------------------------------------- */"    )
   aadd( txt_, "/* WARNING: Automatically generated source file. DO NOT EDIT!           */"    )
   aadd( txt_, "/*          Instead, edit corresponding .qth file,                      */"    )
   aadd( txt_, "/*          or the generator tool itself, and run regenarate.           */"    )
   aadd( txt_, "/* -------------------------------------------------------------------- */"    )
   aadd( txt_, " " )

   aadd( txt_, "" )
   aadd( txt_, "FUNCTION hbide_harbourProtos()" )
   aadd( txt_, "   LOCAL aProto := {}" )
   aadd( txt_, "" )
   aeval( aProto, {|e| aadd( txt_, '   aadd( aProto, "' + strtran( e, '"', "'" ) + '" )' ) } )
   aadd( txt_, "" )
   aadd( txt_, "   RETURN aProto" )
   aadd( txt_, "" )


   aeval( txt_, {|e| cTxt += e + chr( 13 ) + chr( 10 ) } )

   hb_memoWrit( cFile, cTxt )

   RETURN hb_fileExists( cFile )

/*----------------------------------------------------------------------*/
//
//                             Class IdeSetup
//
/*----------------------------------------------------------------------*/

CLASS IdeSetup INHERIT IdeObject

   DATA   oINI
   DATA   qOrgPalette
   DATA   aItems                                  INIT {}
   DATA   aTree                                   INIT { "General", "Intelli-sense", "Selections", "Miscellaneous", "Paths", "Variables", "Dictionaries", "Themes", "Formatting", "VSS", "Projects" }
   DATA   aStyles                                 INIT { "cleanlooks", "windows", "windowsxp", ;
                                                         "windowsvista", "cde", "motif", "plastique", "macintosh" }
   DATA   aKeyItems                               INIT {}

   DATA   nCurThemeSlot                           INIT 0
   DATA   aHilighters                             INIT {}
   DATA   aTBSize                                 INIT { "8","9","10","11","12","13","14","15","16","17","18","19","20" }

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD show()
   METHOD execEvent( nEvent, p, p1 )
   METHOD buildTree()
   METHOD setSystemStyle( cStyle )
   METHOD setBaseColor()
   METHOD connectSlots()
   METHOD setIcons()
   METHOD populate()
   METHOD retrieve()
   METHOD eol()
   METHOD buildKeywords()
   METHOD populateKeyTableRow( nRow, cTxtCol1, cTxtCol2 )
   METHOD populateThemeColors( nSlot, aRGB )
   METHOD pullThemeColors( nSlot )
   METHOD fetchThemeColorsString( nSlot )
   METHOD pushThemeColors( nTheme )
   METHOD pushThemesData()
   METHOD getThemeData( nTheme )
   METHOD viewIt( cFileName, lSaveAs, lSave, lReadOnly, lApplyHiliter )
   METHOD uiDictionaries()
   METHOD uiIncludePaths()
   METHOD uiSourcePaths()

   ENDCLASS


METHOD IdeSetup:new( oIde )
   ::oIde := oIde
   RETURN Self


METHOD IdeSetup:create( oIde )
   DEFAULT oIde TO ::oIde
   ::oIde := oIde
   ::oINI := ::oIde:oINI
   RETURN Self


METHOD IdeSetup:destroy()

   IF !empty( ::oUI )
      ::oUI:destroy()
   ENDIF

   RETURN Self


METHOD IdeSetup:eol()
   RETURN iif( ::oINI:cLineEndingMode == "CRLF", hb_eol(), iif( ::oINI:cLineEndingMode == "CR", chr( 13 ), ;
                                                         iif( ::oINI:cLineEndingMode == "LF", chr( 10 ), hb_eol() ) ) )

METHOD IdeSetup:setIcons()

   ::oUI:buttonAddTextExt    : setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
   ::oUI:buttonDelTextExt    : setIcon( QIcon( hbide_image( "dc_delete" ) ) )

   ::oUI:buttonKeyAdd        : setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
   ::oUI:buttonKeyDel        : setIcon( QIcon( hbide_image( "dc_delete" ) ) )
   ::oUI:buttonKeyUp         : setIcon( QIcon( hbide_image( "dc_up"     ) ) )
   ::oUI:buttonKeyDown       : setIcon( QIcon( hbide_image( "dc_down"   ) ) )

   /* Paths */
   ::oUI:buttonPathHrbRoot   : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathHbmk2     : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathEnv       : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathResources : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathTemp      : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathShortcuts : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathSnippets  : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonPathThemes    : setIcon( QIcon( hbide_image( "open"      ) ) )

   ::oUI:buttonViewIni       : setIcon( QIcon( hbide_image( "file-open" ) ) )
   ::oUI:buttonViewEnv       : setIcon( QIcon( hbide_image( "file-open" ) ) )
   ::oUI:buttonViewSnippets  : setIcon( QIcon( hbide_image( "file-open" ) ) )
   ::oUI:buttonViewThemes    : setIcon( QIcon( hbide_image( "file-open" ) ) )

   ::oUI:buttonSelFont       : setIcon( QIcon( hbide_image( "font"      ) ) )

   ::oUI:buttonThmAdd        : setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
   ::oUI:buttonThmDel        : setIcon( QIcon( hbide_image( "dc_delete" ) ) )
   ::oUI:buttonThmApp        : setIcon( QIcon( hbide_image( "copy"      ) ) )
   ::oUI:buttonThmSav        : setIcon( QIcon( hbide_image( "save"      ) ) )

   /* VSS */
   ::oUI:buttonVSSExe        : setIcon( QIcon( hbide_image( "open"      ) ) )
   ::oUI:buttonVSSDatabase   : setIcon( QIcon( hbide_image( "open"      ) ) )

   RETURN Self


METHOD IdeSetup:connectSlots()

   ::oUI:buttonAddTextExt    :connect( "clicked()"               , {| | ::execEvent( __buttonAddTextext_clicked__                       ) } )
   ::oUI:buttonDelTextExt    :connect( "clicked()"               , {| | ::execEvent( __buttonDelTextext_clicked__                       ) } )

   ::oUI:buttonKeyAdd        :connect( "clicked()"               , {| | ::execEvent( __buttonKeyAdd_clicked__                           ) } )
   ::oUI:buttonKeyDel        :connect( "clicked()"               , {| | ::execEvent( __buttonKeyDel_clicked__                           ) } )
   ::oUI:buttonKeyUp         :connect( "clicked()"               , {| | ::execEvent( __buttonKeyUp_clicked__                            ) } )
   ::oUI:buttonKeyDown       :connect( "clicked()"               , {| | ::execEvent( __buttonKeyDown_clicked__                          ) } )

   ::oUI:buttonSelFont       :connect( "clicked()"               , {| | ::execEvent( __buttonSelFont_clicked__                          ) } )
   ::oUI:editPointSize       :connect( "textEdited(QString)"     , {|s| ::oINI:nPointSize := Val( s )                                     } )

   ::oUI:buttonClose         :connect( "clicked()"               , {| | ::execEvent( __buttonClose_clicked__                            ) } )
   ::oUI:buttonOk            :connect( "clicked()"               , {| | ::execEvent( __buttonOk_clicked__                               ) } )
   ::oUI:buttonCancel        :connect( "clicked()"               , {| | ::execEvent( __buttonCancel_clicked__                           ) } )
   ::oUI:treeWidget          :connect( "itemSelectionChanged()"  , {| | ::execEvent( __treeWidget_itemSelectionChanged__                ) } )
   ::oUI:comboStyle          :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboStyle_currentIndexChanged__       , i       ) } )

   ::oUI:checkAnimated       :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkAnimated_stateChanged__           , i       ) } )

   ::oUI:checkHilightLine    :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkHilightLine_stateChanged__        , i       ) } )
   ::oUI:checkHorzRuler      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkHorzRuler_stateChanged__          , i       ) } )
   ::oUI:checkLineNumbers    :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkLineNumbers_stateChanged__        , i       ) } )
   ::oUI:checkShowLeftToolbar:connect( "stateChanged(int)"       , {|i| ::execEvent( __checkShowLeftToolbar_stateChanged__    , i       ) } )
   ::oUI:checkShowTopToolbar :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkShowTopToolbar_stateChanged__     , i       ) } )
   ::oUI:checkShowSelToolbar :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkShowSelToolbar_stateChanged__     , i       ) } )

   ::oUI:sliderRed           :connect( "valueChanged(int)"       , {|i| ::execEvent( __sliderValue_changed__                  , i, "R"  ) } )
   ::oUI:sliderGreen         :connect( "valueChanged(int)"       , {|i| ::execEvent( __sliderValue_changed__                  , i, "G"  ) } )
   ::oUI:sliderBlue          :connect( "valueChanged(int)"       , {|i| ::execEvent( __sliderValue_changed__                  , i, "B"  ) } )

   ::oUI:radioSec1           :connect( "clicked()"               , {| | ::execEvent( __radioSection_clicked__                 , 1       ) } )
   ::oUI:radioSec2           :connect( "clicked()"               , {| | ::execEvent( __radioSection_clicked__                 , 2       ) } )
   ::oUI:radioSec3           :connect( "clicked()"               , {| | ::execEvent( __radioSection_clicked__                 , 3       ) } )
   ::oUI:radioSec4           :connect( "clicked()"               , {| | ::execEvent( __radioSection_clicked__                 , 4       ) } )
   ::oUI:radioSec5           :connect( "clicked()"               , {| | ::execEvent( __radioSection_clicked__                 , 5       ) } )

   ::oUI:buttonThmAdd        :connect( "clicked()"               , {| | ::execEvent( __buttonThmAdd_clicked__                           ) } )
   ::oUI:buttonThmDel        :connect( "clicked()"               , {| | ::execEvent( __buttonThmDel_clicked__                           ) } )
   ::oUI:buttonThmApp        :connect( "clicked()"               , {| | ::execEvent( __buttonThmApp_clicked__                           ) } )
   ::oUI:buttonThmSav        :connect( "clicked()"               , {| | ::execEvent( __buttonThmSav_clicked__                           ) } )

   ::oUI:listThemes          :connect( "currentRowChanged(int)"  , {|i| ::execEvent( __listThemes_currentRowChanged__         , i       ) } )

   ::oUI:buttonPathHrbRoot   :connect( "clicked()"               , {| | ::execEvent( __buttonHrbRoot_clicked__                          ) } )
   ::oUI:buttonPathHbmk2     :connect( "clicked()"               , {| | ::execEvent( __buttonHbmk2_clicked__                            ) } )
   ::oUI:buttonPathEnv       :connect( "clicked()"               , {| | ::execEvent( __buttonEnv_clicked__                              ) } )
   ::oUI:buttonPathResources :connect( "clicked()"               , {| | ::execEvent( __buttonResources_clicked__                        ) } )
   ::oUI:buttonPathTemp      :connect( "clicked()"               , {| | ::execEvent( __buttonTemp_clicked__                             ) } )
   ::oUI:buttonPathShortcuts :connect( "clicked()"               , {| | ::execEvent( __buttonShortcuts_clicked__                        ) } )
   ::oUI:buttonPathSnippets  :connect( "clicked()"               , {| | ::execEvent( __buttonSnippets_clicked__                         ) } )
   ::oUI:buttonPathThemes    :connect( "clicked()"               , {| | ::execEvent( __buttonThemes_clicked__                           ) } )

   ::oUI:buttonViewIni       :connect( "clicked()"               , {| | ::execEvent( __buttonViewIni_clicked__                          ) } )
   ::oUI:buttonViewEnv       :connect( "clicked()"               , {| | ::execEvent( __buttonViewEnv_clicked__                          ) } )
   ::oUI:buttonViewSnippets  :connect( "clicked()"               , {| | ::execEvent( __buttonViewSnippets_clicked__                     ) } )
   ::oUI:buttonViewThemes    :connect( "clicked()"               , {| | ::execEvent( __buttonViewThemes_clicked__                       ) } )

   ::oUI:comboTabsShape      :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboTabsShape_currentIndexChanged__   , i       ) } )
   ::oUI:comboLeftTabPos     :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboLeftTabPos_currentIndexChanged__  , i       ) } )
   ::oUI:comboTopTabPos      :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboTopTabPos_currentIndexChanged__   , i       ) } )
   ::oUI:comboRightTabPos    :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboRightTabPos_currentIndexChanged__ , i       ) } )
   ::oUI:comboBottomTabPos   :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboBottomTabPos_currentIndexChanged__, i       ) } )
   ::oUI:comboTBSize         :connect( "currentIndexChanged(int)", {|i| ::execEvent( __comboTBSize_currentIndexChanged__      , i       ) } )

   ::oUI:buttonVSSExe        :connect( "clicked()"               , {| | ::execEvent( __buttonVSSExe_clicked__                           ) } )
   ::oUI:buttonVSSDatabase   :connect( "clicked()"               , {| | ::execEvent( __buttonVSSDatabase_clicked__                      ) } )

   ::oUI:tableVar            :connect( "itemActivated(QTableWidgetItem*)", {|p| ::execEvent( __tableVar_keyPress__, p                   ) } )

   /* User Dictionaries */
   ::oUI:listDictNames       :connect( "currentRowChanged(int)"  , {|i| ::execEvent( __listDictNames_currentRowChanged__      , i       ) } )
// ::oUI:listDictNames       :connect( "currentItemChanged(QListWidgetItem*,QListWidgetItem*)"  , {|p,p1| ::execEvent( __listDictNames_currentRowChanged__ , p,p1       ) } )
   ::oUI:btnDictColorText    :connect( "clicked()"               , {| | ::execEvent( __btnDictColorText_clicked__                       ) } )
   ::oUI:btnDictColorBack    :connect( "clicked()"               , {| | ::execEvent( __btnDictColorBack_clicked__                       ) } )
   ::oUI:buttonDictAdd       :connect( "clicked()"               , {| | ::execEvent( __buttonDictAdd_clicked__                          ) } )
   ::oUI:buttonDictDelete    :connect( "clicked()"               , {| | ::execEvent( __buttonDictDelete_clicked__                       ) } )

   ::oUI:listSourcePaths     :connect( "currentRowChanged(int)"  , {|i| ::execEvent( __listSourcePaths_currentRowChanged__ , i          ) } )
   ::oUI:btnSourcePathsAdd   :connect( "clicked()"               , {| | ::execEvent( __buttonSourcePathsAdd_clicked__                   ) } )
   ::oUI:btnSourcePathsDel   :connect( "clicked()"               , {| | ::execEvent( __buttonSourcePathsDel_clicked__                   ) } )

   ::oUI:listIncludePaths    :connect( "currentRowChanged(int)"  , {|i| ::execEvent( __listIncludePaths_currentRowChanged__, i          ) } )
   ::oUI:btnIncludePathsAdd  :connect( "clicked()"               , {| | ::execEvent( __buttonIncludePathsAdd_clicked__                  ) } )
   ::oUI:btnIncludePathsDel  :connect( "clicked()"               , {| | ::execEvent( __buttonIncludePathsDel_clicked__                  ) } )

   ::oUI:checkDictActive     :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictActive_stateChanged__   , i             ) } )
   ::oUI:checkDictToPrg      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToPrg_stateChanged__    , i             ) } )
   ::oUI:checkDictToC        :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToC_stateChanged__      , i             ) } )
   ::oUI:checkDictToCpp      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToCpp_stateChanged__    , i             ) } )
   ::oUI:checkDictToCh       :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToCh_stateChanged__     , i             ) } )
   ::oUI:checkDictToH        :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToH_stateChanged__      , i             ) } )
   ::oUI:checkDictToIni      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToIni_stateChanged__    , i             ) } )
   ::oUI:checkDictToTxt      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToTxt_stateChanged__    , i             ) } )
   ::oUI:checkDictToHbp      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictToHbp_stateChanged__    , i             ) } )
   ::oUI:checkDictCaseSens   :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictCaseSens_stateChanged__ , i             ) } )
   ::oUI:checkDictBold       :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictBold_stateChanged__     , i             ) } )
   ::oUI:checkDictItalic     :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictItalic_stateChanged__   , i             ) } )
   ::oUI:checkDictULine      :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictULine_stateChanged__    , i             ) } )
   ::oUI:checkDictColorText  :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictColorText_stateChanged__, i             ) } )
   ::oUI:checkDictColorBack  :connect( "stateChanged(int)"       , {|i| ::execEvent( __checkDictColorBack_stateChanged__, i             ) } )
   ::oUI:radioDictConvNone   :connect( "clicked()"               , {| | ::execEvent( __radioDictConvNone_clicked__                      ) } )
   ::oUI:radioDictToLower    :connect( "clicked()"               , {| | ::execEvent( __radioDictToLower_clicked__                       ) } )
   ::oUI:radioDictToUpper    :connect( "clicked()"               , {| | ::execEvent( __radioDictToUpper_clicked__                       ) } )
   ::oUI:radioDictAsIn       :connect( "clicked()"               , {| | ::execEvent( __radioDictAsIn_clicked__                          ) } )
   ::oUI:chkExtBuildLaunch   :connect( "stateChanged(int)"       , {|i| ::oINI:lExtBuildLaunch := ( i == 2 )                              } )

   ::oUI:checkSplitVertical  :connect( "stateChanged(int)"       , {|i| ::oINI:lSplitVertical := ( i == 2 )                               } )

   RETURN Self


METHOD IdeSetup:retrieve()
   LOCAL a_, i, s, qItm

   ::oINI:cLineEndingMode          := iif( ::oUI:radioLineEndCRLF : isChecked(), "CRLF", ;
                                      iif( ::oUI:radioLineEndCR   : isChecked(), "CR"  , ;
                                      iif( ::oUI:radioLineEndLF   : isChecked(), "LF"  , ;
                                      iif( ::oUI:radioLineEndOS   : isChecked(), "OS"  , ;
                                      iif( ::oUI:radioLineEndAuto : isChecked(), "AUTO", "CRLF" ) ) ) ) )

   ::oINI:lTrimTrailingBlanks      := ::oUI:checkTrimTrailingBlanks      : isChecked()
   ::oINI:lSaveSourceWhenComp      := ::oUI:checkSaveSourceWhenComp      : isChecked()
   ::oINI:lSupressHbKWordsToUpper  := ::oUI:checkSupressHbKWordsToUpper  : isChecked()
   ::oINI:lReturnAsBeginKeyword    := ::oUI:checkReturnAsBeginKeyword    : isChecked()
   ::oINI:lConvTabToSpcWhenLoading := ::oUI:checkConvTabToSpcWhenLoading : isChecked()
   ::oINI:lTabToSpcInEdits         := ::oUI:checkTabToSpcInEdits         : isChecked()
   ::oINI:lAutoIndent              := ::oUI:checkAutoIndent              : isChecked()
   ::oINI:lSmartIndent             := ::oUI:checkSmartIndent             : isChecked()
   ::oIde:nTabSpaces               := val( ::oUI:editTabSpaces           : text() )
   ::oINI:nIndentSpaces            := val( ::oUI:editIndentSpaces        : text() )
   ::oINI:lEditsMdi                := ::oUI:checkEditsMdi                : isChecked()
   ::oINI:lSelToolbar              := ::oUI:checkShowSelToolbar          : isChecked()

   ::oINI:aKeywords := {}
   FOR EACH a_ IN ::aKeyItems
      aadd( ::oINI:aKeywords, { alltrim( ::aKeyItems[ a_:__enumIndex(),1 ]:text() ), alltrim( ::aKeyItems[ a_:__enumIndex(),2 ]:text() ) } )
   NEXT

   s := ""
   FOR i := 1 TO ::oUI:listTextExt:count()
      qItm := ::oUI:listTextExt:item( i - 1 )
      s += "." + qItm:text() + ","
   NEXT
   s := substr( s, 1, Len( s ) - 1 )
   ::oINI:cTextFileExtensions := s

   ::oINI:nTmpBkpPrd               := val( ::oUI:editTmpBkpPrd : text() )
   ::oINI:cBkpPath                 := ::oUI:editBkpPath        : text()
   ::oINI:cBkpSuffix               := ::oUI:editBkpSuffix      : text()
   ::oINI:lCompletionWithArgs      := ::oUI:checkListlWithArgs : isChecked()
   ::oINI:lCompleteArgumented      := ::oUI:checkCmplInclArgs  : isChecked()

   /* Paths */
   ::oINI:cPathHrbRoot             := ::oUI:editPathHrbRoot    : text()
   ::oINI:cPathHbMk2               := ::oUI:editPathHbMk2      : text()
   ::oINI:cPathResources           := ::oUI:editPathResources  : text()
   ::oINI:cPathTemp                := ::oUI:editPathTemp       : text()
   ::oINI:cPathEnv                 := ::oUI:editPathEnv        : text()
   ::oINI:cPathShortcuts           := ::oUI:editPathShortcuts  : text()
   ::oINI:cPathSnippets            := ::oUI:editPathSnippets   : text()
   ::oINI:cPathThemes              := ::oUI:editPathThemes     : text()

   /* Intelli-sense */
   ::oINI:lISClosing               := ::oUI:grpISClosing       : isChecked()
   ::oINI:lISIf                    := ::oUI:chkISIf            : isChecked()
   ::oINI:lISFor                   := ::oUI:chkISFor           : isChecked()
   ::oINI:lISDoWhile               := ::oUI:chkISDoWhile       : isChecked()
   ::oINI:lISDoCase                := ::oUI:chkISDoCase        : isChecked()
   ::oINI:lISSwitch                := ::oUI:chkISSwitch        : isChecked()
   ::oINI:lISElse                  := ::oUI:chkISElse          : isChecked()
   ::oINI:lISCaseOWise             := ::oUI:chkISCaseOWise     : isChecked()
   ::oINI:lISSwitchOWise           := ::oUI:chkISSwitchOWise   : isChecked()
   ::oINI:lISExitSameLine          := ::oUI:chkISExitSameLine  : isChecked()
   ::oINI:nISCaseCases             := ::oUI:spinISCaseCases    : value()
   ::oINI:nISSwitchCases           := ::oUI:spinISSwitchCases  : value()
   ::oINI:lISClosingP              := ::oUI:chkISClosingP      : isChecked()
   ::oINI:lISSpaceP                := ::oUI:chkISSpaceP        : isChecked()
   ::oINI:lISCodeBlock             := ::oUI:chkISCodeBlock     : isChecked()
   ::oINI:lISOperator              := ::oUI:chkISOperator      : isChecked()
   ::oINI:lISAlignAssign           := ::oUI:chkISAlignAssign   : isChecked()
   ::oINI:lISFmtLine               := ::oUI:chkISFmtLine       : isChecked()
   ::oINI:lISEmbrace               := ::oUI:ChkISEmbrace       : isChecked()
   ::oINI:lISLocal                 := ::oUI:chkISLocal         : isChecked()
   ::oINI:lISReturn                := ::oUI:chkISReturn        : isChecked()
   ::oINI:lISSeparator             := ::oUI:chkISSeparator     : isChecked()
   ::oINI:lISDocs                  := ::oUI:chkISDocs          : isChecked()
   ::oINI:lISFunction              := ::oUI:grpISFunction      : isChecked()
   ::oINI:lISClass                 := ::oUI:grpISClass         : isChecked()
   ::oINI:cISData                  := ::oUI:comboISData        : currentText()
   ::oINI:cISMethods               := ::oUI:comboISMethods     : currentText()
   ::oINI:cISFormat                := ::oUI:comboISFormat      : currentText()
   ::oINI:lTabRemoveExt            := ::oUI:chkTabRemoveExt    : isChecked()
   ::oINI:lTabAddClose             := ::oUI:chkTabAddClose     : isChecked()
   ::oINI:lExtBuildLaunch          := ::oUI:chkExtBuildLaunch  : isChecked()

   ::oINI:lSplitVertical           := ::oUI:checkSplitVertical : isChecked()

   RETURN Self


METHOD IdeSetup:populate()
   LOCAL s, a_

   ::oUI:checkAnimated                : setChecked( val( ::oINI:cIdeAnimated ) > 0      )

   ::oUI:checkHilightLine             : setChecked( ::oIde:lCurrentLineHighlightEnabled )
   ::oUI:checkHorzRuler               : setChecked( ::oIde:lHorzRulerVisible            )
   ::oUI:checkLineNumbers             : setChecked( ::oIde:lLineNumbersVisible          )
   ::oUI:checkShowLeftToolbar         : setChecked( ::oINI:lShowEditsLeftToolbar        )
   ::oUI:checkShowTopToolbar          : setChecked( ::oINI:lShowEditsTopToolbar         )

   /* Line Ending Mode */
   s := ::oINI:cLineEndingMode
   //
   ::oUI:radioLineEndCRLF             : setChecked( s == "CRLF" .OR. empty( s )         )
   ::oUI:radioLineEndCR               : setChecked( s == "CR"                           )
   ::oUI:radioLineEndLF               : setChecked( s == "LF"                           )
   ::oUI:radioLineEndOS               : setChecked( s == "OS"                           )
   ::oUI:radioLineEndAuto             : setChecked( s == "AUTO"                         )

   ::oUI:checkTrimTrailingBlanks      : setChecked( ::oINI:lTrimTrailingBlanks          )
   ::oUI:checkSaveSourceWhenComp      : setChecked( ::oINI:lSaveSourceWhenComp          )
   ::oUI:checkSupressHbKWordsToUpper  : setChecked( ::oINI:lSupressHbKWordsToUpper      )
   ::oUI:checkReturnAsBeginKeyword    : setChecked( ::oINI:lReturnAsBeginKeyword        )
   ::oUI:checkConvTabToSpcWhenLoading : setChecked( ::oINI:lConvTabToSpcWhenLoading     )
   ::oUI:checkTabToSpcInEdits         : setChecked( ::oINI:lTabToSpcInEdits             )
   ::oUI:checkAutoIndent              : setChecked( ::oINI:lAutoIndent                  )
   ::oUI:checkSmartIndent             : setChecked( ::oINI:lSmartIndent                 )
   ::oUI:editTabSpaces                : setText( hb_ntos( ::oIde:nTabSpaces    )        )
   ::oUI:editIndentSpaces             : setText( hb_ntos( ::oINI:nIndentSpaces )        )
   ::oUI:checkEditsMdi                : setChecked( ::oINI:lEditsMdi                    )
   ::oUI:checkShowSelToolbar          : setChecked( ::oINI:lSelToolbar                  )

   /* Paths */
   ::oUI:editPathIni                  : setText( ::oIde:cProjIni                        )
   //
   ::oUI:editPathHrbRoot              : setText( ::oINI:cPathHrbRoot                    )
   ::oUI:editPathHbMk2                : setText( ::oINI:cPathHbMk2                      )
   ::oUI:editPathResources            : setText( ::oINI:cPathResources                  )
   ::oUI:editPathTemp                 : setText( ::oINI:cPathTemp                       )
   ::oUI:editPathEnv                  : setText( ::oINI:cPathEnv                        )
   ::oUI:editPathShortcuts            : setText( ::oINI:cPathShortcuts                  )
   ::oUI:editPathSnippets             : setText( ::oINI:cPathSnippets                   )
   ::oUI:editPathThemes               : setText( ::oINI:cPathThemes                     )

   /* Variables */
   ::oUI:tableVar:clearContents()
   ::aKeyItems := {}
   FOR EACH a_ IN ::oINI:aKeywords
      ::populateKeyTableRow( a_:__enumIndex(), a_[ 1 ], a_[ 2 ] )
   NEXT

   ::oUI:listTextExt:clear()
   a_:= hb_atokens( ::oINI:cTextFileExtensions, ",." )
   FOR EACH s IN a_
      ::oUI:listTextExt:addItem( strtran( s, "." ) )
   NEXT
   ::oUI:listTextExt:setSortingEnabled( .t. )
   ::oUI:listTextExt:sortItems()

   ::oUI:editTmpBkpPrd      : setText( hb_ntos( ::oINI:nTmpBkpPrd ) )
   ::oUI:editBkpPath        : setText( ::oINI:cBkpPath   )
   ::oUI:editBkpSuffix      : setText( ::oINI:cBkpSuffix )

   /* Selections - Code Completion */
   ::oUI:checkListlWithArgs : setChecked( ::oINI:lCompletionWithArgs )
   ::oUI:checkCmplInclArgs  : setChecked( ::oINI:lCompleteArgumented )

   /* Themes */
   ::oUI:sliderRed:setMinimum( 0 )
   ::oUI:sliderRed:setMaximum( 255 )

   ::oUI:sliderGreen:setMinimum( 0 )
   ::oUI:sliderGreen:setMaximum( 255 )

   ::oUI:sliderBlue:setMinimum( 0 )
   ::oUI:sliderBlue:setMaximum( 255 )

   ::oUI:editSec1:setText( "0" )
   ::oUI:editSec5:setText( "1" )

   ::oUI:editSec1:setReadOnly( .t. )
   ::oUI:editSec5:setReadOnly( .t. )

   /* Dock Widgets */
   ::oUI:comboTabsShape     : setCurrentIndex( ::oINI:nDocksTabShape     )
   ::oUI:comboLeftTabPos    : setCurrentIndex( ::oINI:nDocksLeftTabPos   )
   ::oUI:comboTopTabPos     : setCurrentIndex( ::oINI:nDocksTopTabPos    )
   ::oUI:comboRightTabPos   : setCurrentIndex( ::oINI:nDocksRightTabPos  )
   ::oUI:comboBottomTabPos  : setCurrentIndex( ::oINI:nDocksBottomTabPos )

   ::oUI:editVSSExe         : setText( ::oINI:cVSSExe      )
   ::oUI:editVSSDatabase    : setText( ::oINI:cVSSDatabase )

   /* Intelli-sense */
   ::oUI:grpISClosing       : setChecked( ::oINI:lISClosing      )
   ::oUI:chkISIf            : setChecked( ::oINI:lISIf           )
   ::oUI:chkISFor           : setChecked( ::oINI:lISFor          )
   ::oUI:chkISDoWhile       : setChecked( ::oINI:lISDoWhile      )
   ::oUI:chkISDoCase        : setChecked( ::oINI:lISDoCase       )
   ::oUI:chkISSwitch        : setChecked( ::oINI:lISSwitch       )
   ::oUI:chkISElse          : setChecked( ::oINI:lISElse         )
   ::oUI:chkISCaseOWise     : setChecked( ::oINI:lISCaseOWise    )
   ::oUI:chkISSwitchOWise   : setChecked( ::oINI:lISSwitchOWise  )
   ::oUI:chkISExitSameLine  : setChecked( ::oINI:lISExitSameLine )
   ::oUI:spinISCaseCases    : setValue(   ::oINI:nISCaseCases    )
   ::oUI:spinISSwitchCases  : setValue(   ::oINI:nISSwitchCases  )
   ::oUI:chkISClosingP      : setChecked( ::oINI:lISClosingP     )
   ::oUI:chkISSpaceP        : setChecked( ::oINI:lISSpaceP       )
   ::oUI:chkISCodeBlock     : setChecked( ::oINI:lISCodeBlock    )
   ::oUI:chkISOperator      : setChecked( ::oINI:lISOperator     )
   ::oUI:chkISAlignAssign   : setChecked( ::oINI:lISAlignAssign  )
   ::oUI:chkISFmtLine       : setChecked( ::oINI:lISFmtLine      )
   ::oUI:chkISEmbrace       : setChecked( ::oINI:lISEmbrace      )
   ::oUI:chkISLocal         : setChecked( ::oINI:lISLocal        )
   ::oUI:chkISReturn        : setChecked( ::oINI:lISReturn       )
   ::oUI:chkISSeparator     : setChecked( ::oINI:lISSeparator    )
   ::oUI:chkISDocs          : setChecked( ::oINI:lISDocs         )
   ::oUI:grpISFunction      : setChecked( ::oINI:lISFunction     )
   ::oUI:grpISClass         : setChecked( ::oINI:lISClass        )
   ::oUI:comboISData        : setCurrentIndex( iif( ::oINI:cISData == "VAR", 0, 1 ) )
   ::oUI:comboISMethods     : setCurrentIndex( AScan( { "new", "new;create", "new;create;destroy" }, {|e| e == ::oINI:cISMethods } ) - 1 )
   ::oUI:comboISFormat      : setCurrentIndex( iif( ::oINI:cISFormat == "class:method", 0, 1 ) )

   ::oUI:chkTabRemoveExt    : setChecked( ::oINI:lTabRemoveExt   )
   ::oUI:chkTabAddClose     : setChecked( ::oINI:lTabAddClose    )
   ::oUI:chkTabAddClose     : setChecked( ::oINI:lTabAddClose    )
   ::oUI:chkExtBuildLaunch  : setChecked( ::oINI:lExtBuildLaunch )

   ::oUI:checkSplitVertical : setChecked( ::oINI:lSplitVertical  )

   ::connectSlots()

   ::pushThemesData()

   ::uiIncludePaths()
   ::uiSourcePaths()

   RETURN Self


METHOD IdeSetup:show()
   LOCAL cStyle

   IF empty( ::oUI )

      ::oUI := hbide_getUI( "setup", ::oDlg:oWidget )

      ::oUI:setWindowFlags( Qt_Sheet )

      ::oUI:setMaximumWidth( ::oUI:width() )
      ::oUI:setMinimumWidth( ::oUI:width() )
      ::oUI:setMaximumHeight( ::oUI:height() )
      ::oUI:setMinimumHeight( ::oUI:height() )

      ::buildTree()
      ::buildKeywords()

      /* Dock Widgets */
      ::oUI:comboTabsShape:addItem( "Rounded" )
      ::oUI:comboTabsShape:addItem( "Triangular" )

      ::oUI:comboLeftTabPos:addItem( "Top"    )
      ::oUI:comboLeftTabPos:addItem( "Bottom" )
      ::oUI:comboLeftTabPos:addItem( "Left"   )
      ::oUI:comboLeftTabPos:addItem( "Right"  )

      ::oUI:comboTopTabPos:addItem( "Top"    )
      ::oUI:comboTopTabPos:addItem( "Bottom" )
      ::oUI:comboTopTabPos:addItem( "Left"   )
      ::oUI:comboTopTabPos:addItem( "Right"  )

      ::oUI:comboBottomTabPos:addItem( "Top"    )
      ::oUI:comboBottomTabPos:addItem( "Bottom" )
      ::oUI:comboBottomTabPos:addItem( "Left"   )
      ::oUI:comboBottomTabPos:addItem( "Right"  )

      ::oUI:comboRightTabPos:addItem( "Top"    )
      ::oUI:comboRightTabPos:addItem( "Bottom" )
      ::oUI:comboRightTabPos:addItem( "Left"   )
      ::oUI:comboRightTabPos:addItem( "Right"  )

      ::oUI:editFontName:setText( ::oINI:cFontName )
      ::oUI:editPointSize:setText( hb_ntos( ::oINI:nPointSize ) )

      FOR EACH cStyle IN ::aStyles
         ::oUI:comboStyle:addItem( cStyle )
      NEXT
      ::oUI:comboStyle:setCurrentIndex( ascan( ::aStyles, {|e| e == ::oINI:cIdeTheme } ) - 1 )

      aeval( ::aTBSize, {|e| ::oUI:comboTBSize:addItem( e ) } )
      ::oUI:comboTBSize:setCurrentIndex( ascan( ::aTBSize, {|e| e == ::oINI:cToolbarSize } ) - 1 )

      /* Intelli-sense */
      ::oUI:comboISData    : addItem( "VAR" )
      ::oUI:comboISData    : addItem( "DATA" )

      ::oUI:comboISMethods : addItem( "new" )
      ::oUI:comboISMethods : addItem( "new;create" )
      ::oUI:comboISMethods : addItem( "new;create;destroy" )

      ::oUI:comboISFormat  : addItem( "class:method" )
      ::oUI:comboISFormat  : addItem( "method CLASS class" )

      ::setIcons()
      ::connectSlots()

      ::oUI:stackedWidget:setCurrentIndex( 8 )
      ::oUI:stackedWidget:setCurrentIndex( 0 )
      ::oUI:hide()
   ENDIF

   ::populate()
   ::oIde:setPosByIniEx( ::oUI:oWidget, ::oINI:cSetupDialogGeometry )
   ::oUI:show()

   RETURN Self


METHOD IdeSetup:execEvent( nEvent, p, p1 )
   LOCAL qItem, nIndex, qFontDlg, qFont, nOK, nRow, b_, q0, q1, nCol, w0, w1
   LOCAL aRGB, nSlot, qFrame, aGrad, n, cCSS, cTheme, cPath, cBuffer, cFile, oDict

   HB_SYMBOL_UNUSED( p1 )

   IF ::lQuitting
      RETURN Self
   ENDIF

   SWITCH nEvent

   CASE __buttonSelFont_clicked__
      qFont := QFont( ::oINI:cFontName, ::oINI:nPointSize )
      qFont:setFixedPitch( .t. )
      qFontDlg := QFontDialog()
      qFontDlg:setCurrentFont( qFont )
      nOK := qFontDlg:exec()
      IF nOK == 1
         qFont := qFontDlg:currentFont()

         ::oUI:editFontName:setText( qFont:family() )
         ::oUI:editPointSize:setText( hb_ntos( qFont:pointSize() ) )

         ::oINI:cFontName  := ::oUI:editFontName:text()
         ::oINI:nPointSize := val( ::oUI:editPointSize:text() )
      ENDIF
      EXIT

   CASE __checkAnimated_stateChanged__
      ::oDK:animateComponents( iif( p == 0, 0, 1 ) )
      EXIT

   CASE __checkHilightLine_stateChanged__
      ::oIde:lCurrentLineHighlightEnabled := ( p == 2 )
      ::oEM:toggleCurrentLineHighlightMode( ::oIde:lCurrentLineHighlightEnabled )
      EXIT

   CASE __checkHorzRuler_stateChanged__
      ::oIde:lHorzRulerVisible := ( p == 2 )
      ::oEM:toggleHorzRuler( ::oIde:lHorzRulerVisible )
      EXIT

   CASE __checkLineNumbers_stateChanged__
      ::oIde:lLineNumbersVisible := ( p == 2 )
      ::oEM:toggleLineNumbers( ::oIde:lLineNumbersVisible )
      EXIT

   CASE __checkShowSelToolbar_stateChanged__
      ::oINI:lSelToolbar := ( p != 0 )
      EXIT

   CASE __checkShowTopToolbar_stateChanged__
      IF p == 2
         ::oAC:qMdiToolbar:show()
      ELSE
         ::oAC:qMdiToolbar:hide()
      ENDIF
      ::oINI:lShowEditsTopToolbar := ::oAC:qMdiToolbar:oWidget:isVisible()
      EXIT

   CASE __checkShowLeftToolbar_stateChanged__
      IF p == 2
         ::oAC:qMdiToolbarL:show()
      ELSE
         ::oAC:qMdiToolbarL:hide()
      ENDIF
      ::oINI:lShowEditsLeftToolbar := ::oAC:qMdiToolbarL:oWidget:isVisible()
      EXIT

   CASE __treeWidget_itemSelectionChanged__
      qItem  := ::oUI:treeWidget:currentItem()
      IF ( nIndex := ascan( ::aTree, qItem:text( 0 ) ) ) > 0
         ::oUI:stackedWidget:setCurrentIndex( nIndex - 1 )
         IF nIndex == 7 /* Dictionaries */
            ::uiDictionaries()
         ENDIF
      ENDIF
      EXIT

   CASE __buttonCancel_clicked__
      ::oIde:oINI:cSetupDialogGeometry := hbide_posAndSize( ::oUI:oWidget )
      ::oUI:done( 0 )
      EXIT

   CASE __buttonClose_clicked__
   CASE __buttonOk_clicked__
      ::oIde:oINI:cSetupDialogGeometry := hbide_posAndSize( ::oUI:oWidget )
      ::retrieve()
      ::oUI:done( 1 )
      EXIT

   CASE __comboStyle_currentIndexChanged__
      IF ( nIndex := ::oUI:comboStyle:currentIndex() ) > -1
         ::oINI:cIdeTheme := ::aStyles[ nIndex + 1 ]
         ::setSystemStyle( ::aStyles[ nIndex + 1 ] )
      ENDIF
      EXIT

   CASE __buttonAddTextext_clicked__
      q0 := hbide_fetchAString( ::oUI:oWidget, "", "Text File Extension" )
      IF !empty( q0 )
         ::oUI:listTextExt:addItem( lower( strtran( q0, "." ) ) )
      ENDIF
      EXIT

   CASE __buttonDelTextext_clicked__
      IF ::oUI:listTextExt:currentRow() >= 0
         ::oUI:listTextExt:takeItem( ::oUI:listTextExt:currentRow() )
      ENDIF
      EXIT

   CASE __buttonKeyAdd_clicked__
      ::populateKeyTableRow( Len( ::aKeyItems ) + 1, "", "" )
      ::oUI:tableVar:setCurrentItem( ::aKeyItems[ Len( ::aKeyItems ), 1 ] )
      EXIT

   CASE __buttonKeyDel_clicked__
      IF ( nRow := ::oUI:tableVar:currentRow() ) >= 0
         ::oUI:tableVar:removeRow( nRow )
         hb_adel( ::aKeyItems     , nRow + 1, .t. )
         hb_adel( ::oINI:aKeywords, nRow + 1, .t. )
      ENDIF
      EXIT

   CASE __buttonKeyUp_clicked__
      IF ( nRow := ::oUI:tableVar:currentRow() ) >= 1
         nCol := ::oUI:tableVar:currentColumn()

         b_ := ::aKeyItems[ nRow+1 ]
         q0 := QTableWidgetItem(); q0:setText( b_[ 1 ]:text() )
         q1 := QTableWidgetItem(); q1:setText( b_[ 2 ]:text() )

         b_ := ::aKeyItems[ nRow+0 ]
         w0 := QTableWidgetItem(); w0:setText( b_[ 1 ]:text() )
         w1 := QTableWidgetItem(); w1:setText( b_[ 2 ]:text() )

         ::oUI:tableVar:setItem( nRow-0, 0, w0 )
         ::oUI:tableVar:setItem( nRow-0, 1, w1 )

         ::oUI:tableVar:setItem( nRow-1, 0, q0 )
         ::oUI:tableVar:setItem( nRow-1, 1, q1 )

         ::aKeyItems[ nRow+1 ] := { w0,w1 }
         ::aKeyItems[ nRow+0 ] := { q0,q1 }

         ::oUI:tableVar:setCurrentItem( iif( nCol == 0, q0, q1 ) )
      ENDIF
      EXIT

   CASE __buttonKeyDown_clicked__
      nRow := ::oUI:tableVar:currentRow()
      IF nRow >= 0 .AND. nRow + 1 < Len( ::aKeyItems )

         nCol := ::oUI:tableVar:currentColumn()

         b_ := ::aKeyItems[ nRow + 1 ]
         q0 := QTableWidgetItem(); q0:setText( b_[ 1 ]:text() )
         q1 := QTableWidgetItem(); q1:setText( b_[ 2 ]:text() )

         b_ := ::aKeyItems[ nRow + 2 ]
         w0 := QTableWidgetItem(); w0:setText( b_[ 1 ]:text() )
         w1 := QTableWidgetItem(); w1:setText( b_[ 2 ]:text() )

         ::oUI:tableVar:setItem( nRow, 0, w0 )
         ::oUI:tableVar:setItem( nRow, 1, w1 )

         ::oUI:tableVar:setItem( nRow+1, 0, q0 )
         ::oUI:tableVar:setItem( nRow+1, 1, q1 )

         ::aKeyItems[ nRow + 1 ] := { w0,w1 }
         ::aKeyItems[ nRow + 2 ] := { q0,q1 }

         ::oUI:tableVar:setCurrentItem( iif( nCol == 0, q0, q1 ) )
      ENDIF
      EXIT

   CASE __tableVar_keyPress__
      IF ( nRow := ::oUI:tableVar:currentRow() ) >= 0
         HB_TRACE( HB_TR_DEBUG, "RECEIVING ENTER KEY" )
         ::oUI:tableVar:editItem( p )
         HB_SYMBOL_UNUSED( nRow )
         #if 0
         IF ::oUI:tableVar:currentColumn() == 0
            ::oUI:tableVar:setCurrentCell( ::oUI:tableVar:currentRow(), 1 )
         ENDIF
         #endif
      ENDIF

   CASE __radioSection_clicked__
      ::nCurThemeSlot := p
      IF empty( aRGB := ::pullThemeColors( p ) )
         aRGB := { 0,0,0 }
      ENDIF
      ::oUI:sliderRed   : setValue( aRGB[ 1 ] )
      ::oUI:sliderGreen : setValue( aRGB[ 2 ] )
      ::oUI:sliderBlue  : setValue( aRGB[ 3 ] )
      EXIT

   CASE __sliderValue_changed__
      nSlot := ::nCurThemeSlot

      IF nSlot > 0
         qFrame := { ::oUI:frameSec1, ::oUI:frameSec2, ::oUI:frameSec3, ::oUI:frameSec4, ::oUI:frameSec5 }[ nSlot ]
         aRGB   := { ::oUI:sliderRed:value(), ::oUI:sliderGreen:value(), ::oUI:sliderBlue:value() }
         ::populateThemeColors( nSlot, aRGB )
         qFrame:setStyleSheet( "background-color: " + hbide_rgbString( aRGB ) + ";" )
      ENDIF

      aGrad := {}
      FOR nSlot := 1 TO 5
         n  := val( { ::oUI:editSec1, ::oUI:editSec2, ::oUI:editSec3, ::oUI:editSec4, ::oUI:editSec5 }[ nSlot ]:text() )

         IF !empty( aRGB := ::pullThemeColors( nSlot ) )
            aadd( aGrad, { n, aRGB[ 1 ], aRGB[ 2 ], aRGB[ 3 ] } )
         ENDIF
      NEXT
      IF !empty( aGrad )
         cCSS := 'background-color: qlineargradient(x1:0, y1:0, x2:1, y2:0, ' + hbide_buildGradientString( aGrad ) + ");"
         ::oUI:frameHorz:setStyleSheet( cCSS )
         cCSS := 'background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, ' + hbide_buildGradientString( aGrad ) + ");"
         ::oUI:frameVert:setStyleSheet( cCSS )
      ENDIF
      EXIT

   CASE __listThemes_currentRowChanged__
      ::pushThemeColors( p + 1 )
      EXIT
   CASE __buttonThmAdd_clicked__
      IF !empty( cTheme := hbide_fetchAString( ::oDlg:oWidget, cTheme, "Name the Theme", "New Theme" ) )
         aadd( ::oINI:aAppThemes, cTheme + "," + ::fetchThemeColorsString() )
         qItem := QListWidgetItem()
         qItem:setText( cTheme )
         //::oUI:listThemes:addItem_1( qItem )
         ::oUI:listThemes:addItem( qItem )
         ::oUI:listThemes:setCurrentRow( Len( ::oINI:aAppThemes ) - 1 )
      ENDIF
      EXIT
   CASE __buttonThmApp_clicked__
      IF ( n := ::oUI:listThemes:currentRow() ) > -1
         hbide_setAppTheme( ::getThemeData( n + 1 ) )
         ::oDK:animateComponents( HBIDE_ANIMATION_GRADIENT )
      ENDIF
      EXIT
   CASE __buttonThmDel_clicked__
      EXIT
   CASE __buttonThmSav_clicked__
      IF ( n := ::oUI:listThemes:currentRow() ) > -1
         ::oINI:aAppThemes[ n + 1 ] := ::oUI:listThemes:currentItem():text() + "," + ;
                                       ::fetchThemeColorsString()
      ENDIF
      EXIT
   CASE __buttonVSSExe_clicked__
      IF ! empty( cPath := hbide_fetchADir( ::oDlg, "Visual SourceSafe Installation Path", ::oINI:cVSSExe ) )
         ::oINI:cVSSExe := cPath
         ::oUI:editVSSExe:setText( hbide_pathStripLastSlash( cPath ) )
      ENDIF
      EXIT
   CASE __buttonVSSDatabase_clicked__
      IF ! empty( cPath := hbide_fetchADir( ::oDlg, "Visual SourceSafe Database Path", ::oINI:cVSSDatabase ) )
         ::oINI:cVSSDatabase := cPath
         ::oUI:editVSSDatabase:setText( hbide_pathStripLastSlash( cPath ) )
      ENDIF
      EXIT
   CASE __buttonHrbRoot_clicked__
      IF ! empty( cPath := hbide_fetchADir( ::oDlg, "Harbour's Root Path", ::oINI:cPathHrbRoot ) )
         ::oINI:cPathHrbRoot := cPath
         ::oUI:editPathHrbRoot:setText( hbide_pathStripLastSlash( cPath ) )
      ENDIF
      EXIT
   CASE __buttonHbmk2_clicked__
      IF !empty( cPath := hbide_fetchAFile( ::oDlg, "Location of hbmk2", ;
                                                       { { "Harbour Make - hbmk2", "*" } }, ::oINI:cPathHbMk2 ) )
         ::oINI:cPathhbMk2 := cPath
         ::oUI:editPathHbMk2:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonEnv_clicked__
      IF !empty( cPath := hbide_fetchAFile( ::oDlg, "Environment Definitions File ( .env )", ;
                                                       { { "Environment Files", "*.env" } }, ::oINI:getEnvFile() ) )
         ::oINI:cPathEnv := cPath
         ::oUI:editPathEnv:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonResources_clicked__
      IF ! empty( cPath := hbide_fetchADir( ::oDlg, "Location of Resources ( Plugins, Dialogs, Images, Scripts )", ::oINI:getResourcesPath() ) )
         ::oINI:cPathResources := cPath
         ::oUI:editPathResources:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonTemp_clicked__
      IF ! empty( cPath := hbide_fetchADir( ::oDlg, "Location for Temporary and Transitory Files", ::oINI:getTempPath() ) )
         ::oINI:cPathTemp := cPath
         ::oUI:editPathTemp:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonShortcuts_clicked__
      IF !empty( cPath := hbide_fetchAFile( ::oDlg, "Keyboard Mapping Definitions File ( .scu )", ;
                                                       { { "Keyboard Mappings", "*.scu" } }, ::oINI:getShortcutsFile() ) )
         ::oINI:cPathShortcuts := cPath
         ::oUI:editPathShortcuts:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonSnippets_clicked__
      IF !empty( cPath := hbide_fetchAFile( ::oDlg, "Code Snippets File ( .skl )", ;
                                                       { { "Code Snippets", "*.skl" } }, ::oINI:getSnippetsFile() ) )
         ::oINI:cPathSnippets := cPath
         ::oUI:editPathSnippets:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonThemes_clicked__
      IF !empty( cPath := hbide_fetchAFile( ::oDlg, "Syntax Highlighting Theme File ( .hbt )", ;
                                                       { { "Syntax Theme", "*.hbt" } }, ::oINI:getThemesFile() ) )
         ::oINI:cPathThemes := cPath
         ::oUI:editPathThemes:setText( cPath )
      ENDIF
      EXIT
   CASE __buttonViewIni_clicked__
      ::viewIt( ::oINI:getIniFile(), .t., .f., .f., .f. ) /* FileName, shouldSaveAs, shouldSave, shouldReadOnly, applyHiliter */
      EXIT
   CASE __buttonViewEnv_clicked__
      ::viewIt( ::oINI:getEnvFile(), .t., .t., .f., .f. )
      EXIT
   CASE __buttonViewSnippets_clicked__
      ::viewIt( ::oINI:getSnippetsFile(), .t., .t., .f., .t. )
      EXIT
   CASE __buttonViewThemes_clicked__
      ::viewIt( ::oINI:getThemesFile(), .t., .t., .f., .f. )
      EXIT

   CASE __buttonEditorSaveAs_clicked__
      IF ! empty( cBuffer := p:plainText:toPlainText() )
         IF ! empty( cPath := hbide_saveAFile( ::oDlg, "Save: " + p1, NIL, p1 ) )
            hb_memowrit( cPath, cBuffer )
         ENDIF
      ENDIF
      EXIT
   CASE __buttonEditorSave_clicked__
      IF ! empty( cBuffer := p:plainText:toPlainText() )
         hb_memowrit( p1, cBuffer )
      ENDIF
      EXIT
   CASE __buttonEditorClose_clicked__
   CASE __buttonEditorX_clicked__
      p:oWidget:disconnect( QEvent_Close )
      p:buttonSaveAs:disconnect( "clicked()"  )
      p:buttonSave:disconnect( "clicked()"  )
      p:buttonClose:disconnect( "clicked()"  )
      p:close()
      p:setParent( QWidget() )    /* Must Destroy It */
      EXIT
   /* Docking Widgets */
   CASE __comboTabsShape_currentIndexChanged__
      ::oINI:nDocksTabShape := p
      ::oDlg:setTabShape( ::oINI:nDocksTabShape )
      EXIT
   CASE __comboLeftTabPos_currentIndexChanged__
      ::oINI:nDocksLeftTabPos := p
      ::oDlg:setTabPosition( Qt_LeftDockWidgetArea  , ::oINI:nDocksLeftTabPos   )
      EXIT
   CASE __comboTopTabPos_currentIndexChanged__
      ::oINI:nDocksTopTabPos := p
      ::oDlg:setTabPosition( Qt_TopDockWidgetArea   , ::oINI:nDocksTopTabPos    )
      EXIT
   CASE __comboRightTabPos_currentIndexChanged__
      ::oINI:nDocksRightTabPos := p
      ::oDlg:setTabPosition( Qt_RightDockWidgetArea , ::oINI:nDocksRightTabPos  )
      EXIT
   CASE __comboBottomTabPos_currentIndexChanged__
      ::oINI:nDocksBottomTabPos := p
      ::oDlg:setTabPosition( Qt_BottomDockWidgetArea, ::oINI:nDocksBottomTabPos )
      EXIT
   CASE __comboTBSize_currentIndexChanged__
      ::oINI:cToolbarSize := ::oUI:comboTBSize:currentText()
      // ::oDK:setToolbarSize( val( ::oINI:cToolbarSize ) )  /* Functionality Discontinued */
      EXIT

   /* Dictionaries */
   CASE __btnDictColorBack_clicked__
      p := ::oUI:listDictNames:currentRow()
      IF p >= 0 .AND. p < Len( ::oIde:aUserDict )
         ::oIde:aUserDict[ p + 1 ]:execColorDialog( ::oUI, "back" )
      ENDIF
      EXIT
   CASE __btnDictColorText_clicked__
      p := ::oUI:listDictNames:currentRow()
      IF p >= 0 .AND. p < Len( ::oIde:aUserDict )
         ::oIde:aUserDict[ p + 1 ]:execColorDialog( ::oUI, "text" )
      ENDIF
      EXIT
   CASE __listDictNames_currentRowChanged__
      IF p >= 0 .AND. p < Len( ::oIde:aUserDict )
         ::oIde:aUserDict[ p + 1 ]:populateUI( ::oUI )
      ENDIF
      EXIT
   CASE __checkDictActive_stateChanged__
   CASE __checkDictToPrg_stateChanged__
   CASE __checkDictToC_stateChanged__
   CASE __checkDictToCpp_stateChanged__
   CASE __checkDictToCh_stateChanged__
   CASE __checkDictToH_stateChanged__
   CASE __checkDictToIni_stateChanged__
   CASE __checkDictToTxt_stateChanged__
   CASE __checkDictToHbp_stateChanged__
   CASE __checkDictCaseSens_stateChanged__
   CASE __checkDictBold_stateChanged__
   CASE __checkDictItalic_stateChanged__
   CASE __checkDictULine_stateChanged__
   CASE __checkDictColorText_stateChanged__
   CASE __checkDictColorBack_stateChanged__
      nRow := ::oUI:listDictNames:currentRow()
      IF nRow >= 0 .AND. nRow < Len( ::oIde:aUserDict )
         ::oIde:aUserDict[ nRow + 1 ]:checkStateChanged( ::oUI, nEvent, p )
      ENDIF
      EXIT
   CASE __radioDictConvNone_clicked__
   CASE __radioDictToLower_clicked__
   CASE __radioDictToUpper_clicked__
   CASE __radioDictAsIn_clicked__
      p := ::oUI:listDictNames:currentRow()
      IF p >= 0 .AND. p < Len( ::oIde:aUserDict )
         ::oIde:aUserDict[ p + 1 ]:radioButtonClicked( ::oUI, nEvent )
      ENDIF
      EXIT
   CASE __buttonDictDelete_clicked__
      p := ::oUI:listDictNames:currentRow()
      IF p >= 0 .AND. p < Len( ::oIde:aUserDict )
         hb_ADel( ::oIde:aUserDict, p + 1, .T. )
         ::uiDictionaries()
         ::oUI:listDictNames:setCurrentRow( Min( Len( ::oIde:aUserDict ) - 1, p ) )
      ENDIF
      EXIT
   CASE __buttonDictAdd_clicked__
      cFile := hbide_fetchAFile( ::oDlg, "Open a Dictionary", ;
                                 { { "HBX Files"       , "*.hbx" }, ;
                                   { "HbIDE .tag Files", "*.tag" }, ;
                                   { "Text Files"      , "*.txt" }, ;
                                   { "Dictionary Files", "*.dic" }, ;
                                   { "All Files"       , "*"     } }      /*, cDftDir, cDftSuffix, lAllowMulti*/ )
      IF ! Empty( cFile )
         oDict := IdeDictionary():new( ::oIde ):create()
         oDict:load( cFile )
         aadd( ::oIde:aUserDict, oDict )
         ::uiDictionaries()
         ::oUI:listDictNames:setCurrentRow( Len( ::oIde:aUserDict ) - 1 )
      ENDIF
      EXIT
   CASE __buttonIncludePathsDel_clicked__
      p := ::oUI:listIncludePaths:currentRow()
      IF p >= 0 .AND. p < Len( ::oINI:aIncludePaths )
         hb_ADel( ::oINI:aIncludePaths, p + 1, .T. )
         ::uiIncludePaths()
         ::oUI:listIncludePaths:setCurrentRow( Min( Len( ::oINI:aIncludePaths ) - 1, p ) )
      ENDIF
      EXIT
   CASE __buttonIncludePathsAdd_clicked__
      cFile := hbide_fetchADir( ::oDlg, "Select an Include Path", ::cLastFileOpenPath )
      IF ! Empty( cFile )
         ::oIde:cLastFileOpenPath := cFile
         AAdd( ::oINI:aIncludePaths, hbide_pathNormalized( hbide_pathAppendLastSlash( cFile ) ) )
         ::uiIncludePaths()
         ::oUI:listIncludePaths:setCurrentRow( Len( ::oINI:aIncludePaths ) - 1 )
      ENDIF
      EXIT
   CASE __buttonSourcePathsDel_clicked__
      p := ::oUI:listSourcePaths:currentRow()
      IF p >= 0 .AND. p < Len( ::oINI:aSourcePaths )
         hb_ADel( ::oINI:aSourcePaths, p + 1, .T. )
         ::uiSourcePaths()
         ::oUI:listSourcePaths:setCurrentRow( Min( Len( ::oINI:aSourcePaths ) - 1, p ) )
      ENDIF
      EXIT
   CASE __buttonSourcePathsAdd_clicked__
      cFile := hbide_fetchADir( ::oDlg, "Select a Source Path", ::cLastFileOpenPath )
      IF ! Empty( cFile )
         ::oIde:cLastFileOpenPath := cFile
         AAdd( ::oINI:aSourcePaths, hbide_pathNormalized( hbide_pathAppendLastSlash( cFile ) ) )
         ::uiSourcePaths()
         ::oUI:listSourcePaths:setCurrentRow( Len( ::oINI:aSourcePaths ) - 1 )
      ENDIF
      EXIT
   ENDSWITCH

   RETURN Self


METHOD IdeSetup:uiDictionaries()
   LOCAL oDict, nRow

   nRow := ::oUI:listDictNames:currentRow()
   ::oUI:listDictNames:clear()
   ::oUI:listDictNames:setCurrentRow( -1 )
   FOR EACH oDict IN ::oIde:aUserDict
      ::oUI:listDictNames:addItem( oDict:cFilename )
   NEXT
   ::oUI:listDictNames:setCurrentRow( Max( nRow, 0 ) )

   RETURN NIL


METHOD IdeSetup:uiIncludePaths()
   LOCAL cDict, nRow
   LOCAL oList := ::oUI:listIncludePaths

   nRow := oList:currentRow()
   oList:clear()
   oList:setCurrentRow( -1 )
   FOR EACH cDict IN ::oINI:aIncludePaths
      oList:addItem( cDict )
   NEXT
   oList:setCurrentRow( Max( nRow, 0 ) )

   RETURN NIL


METHOD IdeSetup:uiSourcePaths()
   LOCAL cDict, nRow
   LOCAL oList := ::oUI:listSourcePaths

   nRow := oList:currentRow()
   oList:clear()
   oList:setCurrentRow( -1 )
   FOR EACH cDict IN ::oINI:aSourcePaths
      oList:addItem( cDict )
   NEXT
   oList:setCurrentRow( Max( nRow, 0 ) )

   RETURN NIL


METHOD IdeSetup:viewIt( cFileName, lSaveAs, lSave, lReadOnly, lApplyHiliter )
   LOCAL oUI

   oUI := hbide_getUI( "editor", ::oUI:oWidget )
   oUI:setWindowFlags( Qt_Sheet + Qt_CustomizeWindowHint + Qt_WindowTitleHint + Qt_WindowContextHelpButtonHint )

   oUI:plainText:setReadOnly( lReadOnly )
   oUI:buttonSaveAs:setEnabled( lSaveAs )
   oUI:buttonSave:setEnabled( lSave )

   oUI:plainText:setLineWrapMode( QPlainTextEdit_NoWrap )

   oUI:plainText:setPlainText( hb_memoRead( cFileName ) )
   oUI:plainText:setFont( ::oIde:oFont:oWidget )
   IF lApplyHiliter
      aadd( ::aHilighters, ::oTH:setSyntaxHilighting( oUI:plainText, "Bare Minimum" ) )
   ENDIF

   oUI:oWidget     :connect( QEvent_Close, {|| ::execEvent( __buttonEditorX_clicked__     , oUI            ) } )
   oUI:buttonSaveAs:connect( "clicked()" , {|| ::execEvent( __buttonEditorSaveAs_clicked__, oUI, cFileName ) } )
   oUI:buttonSave  :connect( "clicked()" , {|| ::execEvent( __buttonEditorSave_clicked__  , oUI, cFileName ) } )
   oUI:buttonClose :connect( "clicked()" , {|| ::execEvent( __buttonEditorClose_clicked__ , oUI            ) } )

   oUI:show()

   RETURN Self


METHOD IdeSetup:pushThemesData()
   LOCAL s, a_, qItem

   IF ::nCurThemeSlot == 0
      FOR EACH s IN ::oINI:aAppThemes
         a_:= hb_aTokens( s, "," )
         qItem := QListWidgetItem()
         qItem:setText( a_[ 1 ] )
         //::oUI:listThemes:addItem_1( qItem )
         ::oUI:listThemes:addItem( qItem )
         ::pushThemeColors( s:__enumIndex() )
      NEXT
   ENDIF
   IF !empty( ::oINI:aAppThemes )
      ::oUI:listThemes:setCurrentRow( -1 )
      ::oUI:listThemes:setCurrentRow( Len( ::oINI:aAppThemes ) - 1 )
      ::oUI:listThemes:setCurrentRow( 0 )
   ENDIF
   ::oUI:radioSec1:click()

   RETURN Self


METHOD IdeSetup:getThemeData( nTheme )
   LOCAL a_, i, aTheme := {}

   IF nTheme >= 1 .AND. nTheme <= Len( ::oINI:aAppThemes )
      a_:= hbide_parseThemeComponent( ::oINI:aAppThemes[ nTheme ] )

      FOR i := 2 TO 6
         IF !empty( a_[ i ] )
            aadd( aTheme, a_[ i ] )
         ENDIF
      NEXT
   ENDIF

   RETURN aTheme


METHOD IdeSetup:pushThemeColors( nTheme )
   LOCAL n, a_, i, aRGB, nSlot

   IF nTheme >= 1 .AND. nTheme <= Len( ::oINI:aAppThemes )
      a_:= hb_aTokens( ::oINI:aAppThemes[ nTheme ], "," )
      aSize( a_, 6 )
      DEFAULT a_[ 1 ] TO ""
      DEFAULT a_[ 2 ] TO ""
      DEFAULT a_[ 3 ] TO ""
      DEFAULT a_[ 4 ] TO ""
      DEFAULT a_[ 5 ] TO ""
      DEFAULT a_[ 6 ] TO ""

      FOR i := 2 TO 6
         nSlot := i - 1
         IF !empty( a_[ i ] )
            aRGB := hb_aTokens( a_[ i ], " " )
            FOR EACH n IN aRGB
               n := val( n )
            NEXT
            { ::oUI:editSec1, ::oUI:editSec2, ::oUI:editSec3, ::oUI:editSec4, ::oUI:editSec5 }[ nSlot ]:setText( hb_ntos( aRGB[ 1 ] ) )

            ::populateThemeColors( nSlot, { aRGB[ 2 ], aRGB[ 3 ], aRGB[ 4 ] } )
         ENDIF
      NEXT
      { ::oUI:radioSec1, ::oUI:radioSec2, ::oUI:radioSec3, ::oUI:radioSec4, ::oUI:radioSec5 }[ nSlot ]:click()
   ENDIF

   RETURN Self


METHOD IdeSetup:populateThemeColors( nSlot, aRGB )
   LOCAL qFrame

   { ::oUI:editR1, ::oUI:editR2, ::oUI:editR3, ::oUI:editR4, ::oUI:editR5 }[ nSlot ]:setText( hb_ntos( aRGB[ 1 ] ) )
   { ::oUI:editG1, ::oUI:editG2, ::oUI:editG3, ::oUI:editG4, ::oUI:editG5 }[ nSlot ]:setText( hb_ntos( aRGB[ 2 ] ) )
   { ::oUI:editB1, ::oUI:editB2, ::oUI:editB3, ::oUI:editB4, ::oUI:editB5 }[ nSlot ]:setText( hb_ntos( aRGB[ 3 ] ) )

   qFrame := { ::oUI:frameSec1, ::oUI:frameSec2, ::oUI:frameSec3, ::oUI:frameSec4, ::oUI:frameSec5 }[ nSlot ]
   qFrame:setStyleSheet( "background-color: " + hbide_rgbString( aRGB ) + ";" )

   RETURN Self


METHOD IdeSetup:fetchThemeColorsString( nSlot )
   LOCAL s := ""

   IF empty( nSlot )
      FOR nSlot := 1 TO 5
         s += { ::oUI:editSec1, ::oUI:editSec2, ::oUI:editSec3, ::oUI:editSec4, ::oUI:editSec5 }[ nSlot ]:text() + " "

         s += { ::oUI:editR1, ::oUI:editR2, ::oUI:editR3, ::oUI:editR4, ::oUI:editR5 }[ nSlot ]:text() + " "
         s += { ::oUI:editG1, ::oUI:editG2, ::oUI:editG3, ::oUI:editG4, ::oUI:editG5 }[ nSlot ]:text() + " "
         s += { ::oUI:editB1, ::oUI:editB2, ::oUI:editB3, ::oUI:editB4, ::oUI:editB5 }[ nSlot ]:text()

         s += ","
      NEXT
   ELSE

   ENDIF

   RETURN s


METHOD IdeSetup:pullThemeColors( nSlot )
   LOCAL aRGB := {}

   IF !empty( { ::oUI:editSec1, ::oUI:editSec2, ::oUI:editSec3, ::oUI:editSec4, ::oUI:editSec5 }[ nSlot ]:text() )
      aadd( aRGB, val( { ::oUI:editR1, ::oUI:editR2, ::oUI:editR3, ::oUI:editR4, ::oUI:editR5 }[ nSlot ]:text() ) )
      aadd( aRGB, val( { ::oUI:editG1, ::oUI:editG2, ::oUI:editG3, ::oUI:editG4, ::oUI:editG5 }[ nSlot ]:text() ) )
      aadd( aRGB, val( { ::oUI:editB1, ::oUI:editB2, ::oUI:editB3, ::oUI:editB4, ::oUI:editB5 }[ nSlot ]:text() ) )
   ENDIF

   RETURN aRGB


METHOD IdeSetup:populateKeyTableRow( nRow, cTxtCol1, cTxtCol2 )
   LOCAL lAppend := Len( ::aKeyItems ) < nRow
   LOCAL q0, q1

   IF lAppend
      ::oUI:tableVar:setRowCount( nRow )

      q0 := QTableWidgetItem()
      q0:setText( cTxtCol1 )
      ::oUI:tableVar:setItem( nRow-1, 0, q0 )

      q1 := QTableWidgetItem()
      q1:setText( cTxtCol2 )
      ::oUI:tableVar:setItem( nRow-1, 1, q1 )

      aadd( ::aKeyItems, { q0, q1 } )

      ::oUI:tableVar:setRowHeight( nRow-1, 16 )

   ELSE
      ::aKeyItems[ nRow, 1 ]:setText( cTxtCol1 )
      ::aKeyItems[ nRow, 2 ]:setText( cTxtCol2 )

   ENDIF

   RETURN Self


METHOD IdeSetup:buildKeywords()
   LOCAL hdr_:= { { "Keyword", 100 }, { "Value", 230 } }
   LOCAL oTbl, n, qItm

   oTbl := ::oUI:tableVar

   oTbl:verticalHeader():hide()
   oTbl:horizontalHeader():setStretchLastSection( .t. )

   oTbl:setAlternatingRowColors( .t. )
   oTbl:setColumnCount( Len( hdr_ ) )
   oTbl:setShowGrid( .t. )
   FOR n := 1 TO Len( hdr_ )
      qItm := QTableWidgetItem()
      qItm:setText( hdr_[ n,1 ] )
      oTbl:setHorizontalHeaderItem( n-1, qItm )
      oTbl:setColumnWidth( n-1, hdr_[ n,2 ] )
   NEXT

   RETURN Self


METHOD IdeSetup:buildTree()
   LOCAL oRoot, oChild, s

   ::oUI:treeWidget:setHeaderHidden( .t. )
   ::oUI:treeWidget:setIconSize( QSize( 12,12 ) )
   ::oUI:treeWidget:setIndentation( 12 )

   oRoot := QTreeWidgetItem()
   oRoot:setText( 0, "Parts" )
   oRoot:setToolTip( 0, "Parts" )

   ::oUI:treeWidget:addTopLevelItem( oRoot )

   aadd( ::aItems, oRoot )

   FOR EACH s IN ::aTree
      oChild := QTreeWidgetItem()
      oChild:setText( 0, s )
      oChild:setToolTip( 0, s )
      oRoot:addChild( oChild )
      aadd( ::aItems, oChild )
   NEXT

   oRoot:setExpanded( .t. )
   ::oUI:treeWidget:setCurrentItem( ::aItems[ 2 ] ) /* General */

   RETURN Self


METHOD IdeSetup:setSystemStyle( cStyle )
   LOCAL qFactory

   IF !empty( cStyle )
      qFactory := QStyleFactory()
      QApplication():setStyle( qFactory:create( cStyle ) )
   ENDIF

   RETURN Self


METHOD IdeSetup:setBaseColor()
   #if 0
   LOCAL qPalette, oApp, qBrush, qColor

   oApp := QApplication()

   ::qOrgPalette := oApp:palette()

   qColor := QColor( Qt_red )
   qBrush := QBrush( qColor )

   qPalette := oApp:palette()
   qPalette:setBrush( QPalette_Window, qBrush )
   qPalette:setColor( QPalette_Window, qColor )
   qPalette:setColor( QPalette_Base, qColor )

   oApp:setPalette( qPalette )
   #endif
   RETURN Self

/*----------------------------------------------------------------------*/

FUNCTION hbide_saveEnvironment( oIde, cFile )
   LOCAL cPath, cExt, oSettings

   DEFAULT cFile TO "settings.ide"

   cFile := lower( cFile )
   hb_fNameSplit( cFile, @cPath, @cFile, @cExt )
   IF empty( cExt )
      cExt := ".ide"
   ENDIF
   IF lower( cExt ) != ".ide"
      RETURN NIL
   ENDIF
   IF empty( cPath )
      cPath := oIde:oINI:getINIPath()
   ENDIF

   oSettings := QSettings( cPath + cFile + cExt, QSettings_IniFormat )
   oSettings:setValue( "hbidesettings", QVariant( oIde:oDlg:oWidget:saveState() ) )

   RETURN NIL


FUNCTION hbide_restEnvironment( oIde, cFile )
   LOCAL cPath, cExt, oSettings

   DEFAULT cFile TO "settings.ide"

   cFile := lower( cFile )
   hb_fNameSplit( cFile, @cPath, @cFile, @cExt )
   IF empty( cExt )
      cExt := ".ide"
   ENDIF
   IF lower( cExt ) != ".ide"
      RETURN NIL
   ENDIF
   IF empty( cPath )
      cPath := oIde:oINI:getINIPath()
   ENDIF

   oSettings := QSettings( cPath + cFile + cExt, QSettings_IniFormat )
   oIde:oDlg:oWidget:restoreState( oSettings:value( "hbidesettings" ):toByteArray() )

   RETURN NIL


FUNCTION hbide_restEnvironment_byResource( oIde, cFile )
   LOCAL oSettings := QSettings( ":/env/" + cFile + ".ide", QSettings_IniFormat )

   oIde:oDlg:oWidget:restoreState( oSettings:value( "hbidesettings" ):toByteArray() )

   RETURN NIL


FUNCTION hbide_getFileContentsFromResource( cFile )
   RETURN QResource( ":/" + cFile ):data()

