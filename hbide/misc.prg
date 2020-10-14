/*
 * $Id: misc.prg 426 2016-10-20 00:14:06Z bedipritpal $
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
 *                               23Nov2009
 */
/*----------------------------------------------------------------------*/


#include "common.ch"
#include "fileio.ch"
#include "xbp.ch"
#include "hbide.ch"

#include "hbtoqt.ch"
#include "hbqtstd.ch"


#define __S2A( c )                                hb_aTokens( strtran( c, chr( 13 ) ), chr( 10 ) )


STATIC aRegList


PROCEDURE AppSys()
   RETURN


FUNCTION hbide_alert( ... )
   RETURN Alert( ... )


FUNCTION hbide_setIde( oIde )
   LOCAL oldIde
   STATIC ide
   oldIde := ide
   IF PCount() > 0
      ide := oIde
   ENDIF
   RETURN oldIde


FUNCTION hbide_setProjectOutputPath( cPath )
   LOCAL oldProjPath

   STATIC cProjPath := ""

   oldProjPath := cProjPath

   IF HB_ISSTRING( cPath )
      cProjPath := cPath
   ENDIF
   RETURN oldProjPath


FUNCTION hbide_setProjectTitle( cTitle )
   LOCAL oldProjTitle

   STATIC cProjTitle

   IF empty( cProjTitle )
      cProjTitle := hbide_setIde():oPM:getCurrentProjectTitle()
   ENDIF
   oldProjTitle := cProjTitle

   IF HB_ISSTRING( cTitle )
      cProjTitle := cTitle
   ENDIF
   RETURN oldProjTitle


FUNCTION hbide_execPopup( aPops, aqPos, qParent )
   LOCAL i, qPop, qPoint, qAct, cAct, xRet, a_, qSub, b_, qSub_:={}, qAct_:={}

   qPop := QMenu( iif( HB_ISOBJECT( qParent ), qParent, NIL ) )
   qPop:setStyleSheet( GetStyleSheet( "QMenuPop", hbide_setIde():nAnimantionMode ) )

   FOR i := 1 TO Len( aPops )
      IF empty( aPops[ i,1 ] )
         aadd( qAct_, qPop:addSeparator() )
      ELSE
         IF HB_ISOBJECT( aPops[ i, 1 ] )
            aadd( qAct_, qPop:addAction( aPops[ i, 1 ] ) )
         ELSEIF HB_ISARRAY( aPops[ i, 1 ] )     /* Sub-menu */
            qSub := QMenu( qPop )
            qSub:setStyleSheet( GetStyleSheet( "QMenuPop", hbide_setIde():nAnimantionMode ) )
            FOR EACH a_ IN aPops[ i, 1 ]
               qSub:addAction( a_[ 1 ] )
            NEXT
            qSub:setTitle( aPops[ i,2 ] )
            aadd( qAct_, qPop:addMenu( qSub ) )
            aadd( qSub_, qSub )
         ELSE
            aadd( qAct_, qPop:addAction( aPops[ i, 1 ] ) )
         ENDIF
      ENDIF
   NEXT

   IF HB_ISARRAY( aqPos )
      qPoint := QPoint( aqPos[ 1 ], aqPos[ 2 ] )
   ELSEIF HB_ISOBJECT( aqPos )
      qPoint := aqPos
   ENDIF

   cAct := ""
   IF __objGetClsName( qAct := qPop:exec( qPoint ) ) == "QACTION"
      IF valtype( cAct := qAct:text() ) == "C"
         FOR EACH a_ IN aPops
            IF HB_ISOBJECT( a_[ 1 ] )
               IF a_[ 1 ]:text() == cAct .AND. len( a_ ) >= 2
                  xRet := eval( aPops[ a_:__enumIndex(), 2 ] )
                  EXIT
               ENDIF
            ELSEIF HB_ISARRAY( a_[ 1 ] )
               FOR EACH b_ IN a_[ 1 ]
                  IF b_[ 1 ] == cAct
                     xRet := eval( b_[ 2 ], cAct )
                     EXIT
                  ENDIF
               NEXT
            ELSE
               IF a_[ 1 ] == cAct .AND. len( a_ ) >= 2
                  xRet := eval( aPops[ a_:__enumIndex(), 2 ], cAct )
                  EXIT
               ENDIF
            ENDIF
         NEXT
      ENDIF
   ENDIF
   qPop:setParent( QWidget() )
   HB_SYMBOL_UNUSED( xRet )
   RETURN cAct


FUNCTION hbide_menuAddSep( oMenu )
   oMenu:addItem( { NIL, NIL, XBPMENUBAR_MIS_SEPARATOR, NIL } )
   RETURN nil


FUNCTION hbide_createTarget( cFile, txt_ )
   LOCAL hHandle := fcreate( cFile )
   LOCAL cNewLine := hb_eol()

   IF hHandle != F_ERROR
      aeval( txt_, {| e | fWrite( hHandle, e + cNewLine ) } )
      fClose( hHandle )
   ENDIF
   RETURN hb_FileExists( cFile )


FUNCTION hbide_posAndSize( qWidget )
   RETURN hb_ntos( qWidget:x() )     + "," + hb_ntos( qWidget:y() )      + "," + ;
          hb_ntos( qWidget:width() ) + "," + hb_ntos( qWidget:height() ) + ","


FUNCTION hbide_showWarning( cMsg, cInfo, cTitle, qParent )
   LOCAL oMB, nRet

   DEFAULT cTitle  TO "Information"
   DEFAULT qParent TO SetAppWindow():oWidget

   oMB := QMessageBox( qParent )
   oMB:setText( cMsg )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Critical )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setWindowTitle( cTitle )

   nRet := oMB:exec()
   oMB:setParent( QWidget() )
   RETURN nRet


FUNCTION hbide_getYesNo( cMsg, cInfo, cTitle, qParent )
   LOCAL oMB, nRet

   DEFAULT cTitle  TO "Option Please!"
   DEFAULT qParent TO hbide_setIde():oDlg:oWidget

   oMB := QMessageBox( qParent )
   oMB:setText( "<b>"+ cMsg +"</b>" )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Information )
   oMB:setWindowTitle( cTitle )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setStandardButtons( QMessageBox_Yes + QMessageBox_No )

   hbide_setIde():oColorizeEffect:setEnabled( .T. )
   hbide_setIde():oDlg:oWidget:setGraphicsEffect( hbide_setIde():oColorizeEffect )
   nRet := oMB:exec()
   hbide_setIde():oColorizeEffect:setEnabled( .F. )

   oMB:setParent( QWidget() )
   RETURN nRet == QMessageBox_Yes


FUNCTION hbide_getYesNoCancel( cMsg, cInfo, cTitle )
   LOCAL oMB, nRet

   DEFAULT cTitle TO "Option Please!"

   oMB := QMessageBox( SetAppWindow():oWidget )
   oMB:setText( "<b>"+ cMsg +"</b>" )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Information )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setWindowTitle( cTitle )
   oMB:setStandardButtons( QMessageBox_Yes + QMessageBox_No + QMessageBox_Cancel )

   nRet := oMB:exec()
   oMB:setParent( QWidget() )
   RETURN nRet


FUNCTION hbide_fetchAFile( oWnd, cTitle, aFlt, cDftDir, cDftSuffix, lAllowMulti )
   LOCAL oDlg

   DEFAULT cTitle  TO "Please Select a File"
   DEFAULT aFlt    TO { { "All Files", "*" } }
   DEFAULT cDftDir TO hb_dirBase()
   DEFAULT lAllowMulti TO .f.

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title       := cTitle
   oDlg:center      := .t.
   oDlg:fileFilters := aFlt
   IF HB_ISSTRING( cDftSuffix )
      oDlg:oWidget:setDefaultSuffix( cDftSuffix )
   ENDIF
   oDlg:oWidget:setOption( QFileDialog_DontUseNativeDialog, .T. )
   RETURN oDlg:open( cDftDir, , lAllowMulti )


FUNCTION hbide_saveAFile( oWnd, cTitle, aFlt, cDftFile, cDftSuffix )
   LOCAL oDlg

   DEFAULT cTitle  TO "Please Select a File"

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title       := cTitle
   oDlg:center      := .t.
   oDlg:fileFilters := aFlt
   IF HB_ISSTRING( cDftSuffix )
      oDlg:oWidget:setDefaultSuffix( cDftSuffix )
   ENDIF
   oDlg:oWidget:setOption( QFileDialog_DontUseNativeDialog, .T. )
   RETURN oDlg:saveAs( cDftFile, .f., .t. )


/* Function to user select a existing folder
 * 25/12/2009 - 19:10:41 - vailtom
 */
FUNCTION hbide_fetchADir( oWnd, cTitle, cDftDir )
   LOCAL oDlg, cFile

   DEFAULT cTitle  TO "Please Select a Folder"
   DEFAULT cDftDir TO hb_dirBase()

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title  := cTitle
   oDlg:center := .t.
   oDlg:oWidget:setFileMode( 4 )

   cFile := oDlg:open( cDftDir, , .f. )
   oDlg:destroy()
   IF HB_ISSTRING( cFile )
      //cFile := strtran( cFile, "/", hb_ps() )
      RETURN cFile
   ENDIF
   RETURN ""


FUNCTION hbide_getEol( cBuffer )
   LOCAL cStyle

   IF     chr( 13 ) + chr( 10 ) $ cBuffer
      cStyle := chr( 13 ) + chr( 10 )
   ELSEIF chr( 13 ) $ cBuffer
      cStyle := chr( 13 )
   ELSEIF chr( 10 ) $ cBuffer
      cStyle := chr( 10 )
   ELSE
      cStyle := ""
   ENDIF
   RETURN cStyle


FUNCTION hbide_readSource( cTxtFile )
   LOCAL cFileBody := hb_MemoRead( cTxtFile )

   HB_TRACE( HB_TR_DEBUG, cFileBody )

   cFileBody := StrTran( cFileBody, Chr( 13 ) )
   RETURN hb_ATokens( cFileBody, Chr( 10 ) )


FUNCTION hbide_evalAsString( cExp )
   LOCAL cValue

   BEGIN SEQUENCE WITH {|| break() }
      cValue := Eval( hb_macroBlock( cExp ) )
   RECOVER
      cValue := cExp
   END SEQUENCE

   IF !HB_ISSTRING( cValue )
      cValue := ""
   ENDIF
   RETURN cValue


FUNCTION hbide_evalAsIs( cExp )
   LOCAL xValue

   BEGIN SEQUENCE WITH {|| break() }
      xValue := Eval( hb_macroBlock( cExp ) )
   RECOVER
      xValue := cExp
   END SEQUENCE
   RETURN xValue


FUNCTION hbide_setupMetaKeys( a_ )
   LOCAL s, n, cKey, cVal
   LOCAL a4_1 := {}

   FOR EACH s IN a_
      IF !( "#" == left( s,1 ) )
         IF ( n := at( "=", s ) ) > 0
            cKey := alltrim( substr( s, 1, n-1 ) )
            cVal := hbide_evalAsString( alltrim( substr( s, n+1 ) ) )
            aadd( a4_1, { "<"+ cKey +">", cVal } )
         ENDIF
      ENDIF
   NEXT
   RETURN a4_1


FUNCTION hbide_applyMetaData( s, a_ )
   LOCAL k

   IF ! Empty( a_ )
      FOR EACH k IN a_
         s := StrTran( s, hbide_pathNormalized( k[ 2 ], .f. ), k[ 1 ] )
      NEXT
   ENDIF
   RETURN s


FUNCTION hbide_parseWithMetaData( s, a_ )
   LOCAL k

   IF ! Empty( a_ )
      FOR EACH k IN a_ DESCEND
         s := StrTran( s, k[ 1 ], k[ 2 ] )
      NEXT
   ENDIF
   RETURN s


FUNCTION hbide_ar2delString( a_, cDlm )
   LOCAL s := ""

   aeval( a_, {|e| s += e + cDlm  } )
   RETURN substr( s, 1, Len( s ) - len( cDlm ) )


FUNCTION hbide_arrayToMemo( a_ )
   LOCAL s := ""

   aeval( a_, {|e| s += e + hb_eol() } )
   RETURN s += hb_eol()


FUNCTION hbide_arrayToMemoEx( a_ )
   LOCAL s := ""

   aeval( a_, {|e| s += e + hb_eol() } )
   RETURN substr( s, 1, Len( s ) - Len( hb_eol() ) )


FUNCTION hbide_arrayToMemoEx2( a_ )
   RETURN hbide_arrayToMemoEx( a_ )


FUNCTION hbide_convertHtmlDelimiters( s )

   s := StrTran( s, "&", "&amp;" )
   s := StrTran( s, "<", "&lt;" )
   s := StrTran( s, ">", "&gt;" )
   s := StrTran( s, '"', "&quot;" )
   RETURN s


FUNCTION hbide_arrayToMemoHtml( a_ )
   RETURN hbide_convertHtmlDelimiters( hbide_arrayToMemoEx( a_ ) )


FUNCTION hbide_memoToArray( s )
   LOCAL aLine := hb_ATokens( StrTran( RTrim( s ), Chr( 13 ) + Chr( 10 ), _EOL ), _EOL )
   LOCAL nNewSize := 0
   LOCAL line

   FOR EACH line IN aLine DESCEND
      IF ! Empty( line )
         nNewSize := line:__enumIndex()
         EXIT
      ENDIF
   NEXT
   ASize( aLine, nNewSize )
   RETURN aLine


FUNCTION hbide_isValidPath( cPath, cPathDescr )

   DEFAULT cPathDescr TO ''

   IF hb_dirExists( cPath )
      RETURN .T.
   ENDIF

   IF empty( cPathDescr )
      MsgBox( 'The specified path is invalid "' + cPath + '"' )
   ELSE
      //MsgBox( 'The specified path is invalid for ' + cPathDescr + ': "' + cPath + '"' )
      MsgBox( 'The specified path is invalid for : "' + cPath + '"', cPathDescr )
   ENDIF
   RETURN .F.


FUNCTION hbide_isValidText( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )
   RETURN lower( cExt ) $ hbide_setIde():oINI:cTextFileExtensions


FUNCTION hbide_isValidSource( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )
   RETURN lower( cExt ) $ ".c,.cpp,.prg,.res,.rc,.hb"


FUNCTION hbide_isSourcePPO( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )
   RETURN lower( cExt ) == ".ppo"


FUNCTION hbide_isSourcePRG( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )
   RETURN lower( cExt ) == ".prg"


FUNCTION hbide_sourceType( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )
   RETURN lower( cExt )


FUNCTION hbide_pathNormalized( cPath )
   RETURN strtran( cPath, "\", "/" )


FUNCTION hbide_pathFile( cPath, cFile )
   cPath := iif( right( cPath, 1 ) $ "\/", substr( cPath, 1, Len( cPath ) - 1 ), cPath )
   RETURN hbide_pathToOSPath( iif( empty( cPath ), cFile, cPath + "\" + cFile ) )


FUNCTION hbide_pathStripLastSlash( cPath )
   RETURN iif( right( cPath, 1 ) $ "\/", substr( cPath, 1, Len( cPath ) - 1 ), cPath )


FUNCTION hbide_pathAppendLastSlash( cPath )
   RETURN iif( right( cPath, 1 ) $ "\/", cPath, cPath + hb_ps() )


FUNCTION hbide_pathToOSPath( cPath )
   LOCAL n

   cPath := strtran( cPath, "//" , hb_ps() )
   cPath := strtran( cPath, "/"  , hb_ps() )
   cPath := strtran( cPath, "\\" , hb_ps() )
   cPath := strtran( cPath, "\"  , hb_ps() )

   IF ( n := at( ":", cPath ) ) > 0
      cPath := substr( cPath, 1, n - 1 ) + substr( cPath, n )
   ENDIF
   RETURN cPath


/* This function fills an array with the list of regular expressions that will
 * identify the errors messages retrieved from during the build process.
 * 29/12/2009 - 12:43:26 - vailtom
 */
#define MSG_TYPE_ERR                              1
#define MSG_TYPE_INFO                             2
#define MSG_TYPE_WARN                             3

#define CLR_MSG_ERR                               'red'
#define CLR_MSG_INFO                              'brown'
#define CLR_MSG_WARN                              'blue'

STATIC FUNCTION hbide_buildRegExpressList( aRegList )

   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".ch\("                         ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".CH\("                         ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".prg\("                        ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".PRG\("                        ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".*: warning.*"                 ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".*\) Warning W.*"              ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( "^Warning W([0-9]+).*"          ) } )

   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*: error.*"                   ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*\) Error E.*"                ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( "^Error E([0-9]+).*"            ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( "^Error: ."                     ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*:([0-9]+):([\w|\s]*)error.*" ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*:\(\.\w+\+.*\):.*"           ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*: fatal\s.*"                 ) } )

   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( ".*: note.*"                    ) } )
   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( ".*: In function '.*"           ) } )
   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( "^(\s*).*\s: see.*"             ) } )
   RETURN aRegList


/* Catch source file name & line error from an msg status from compiler result.
 * 29/12/2009 - 13:22:29 - vailtom
 */
FUNCTION hbide_parseFNfromStatusMsg( cText, cFileName, nLine, lValidText )
   LOCAL regLineN := hb_RegexComp( ".*(\(([0-9]+)\)|:([0-9]+):|\s([0-9]+):).*" )
   LOCAL aList, nPos, cLine, n

   DEFAULT lValidText TO .T.

   cFileName := ''
   nLine     := 0

   /* Xbase++ */
   IF "XBT" $ cText
      nPos      := at( "(", cText )
      n         := at( ")", cText )
      cFileName := substr( cText, 1, nPos - 1 )
      cLine     := substr( cText, nPos + 1, n - 1 - nPos )
      n         := at( ":", cLine )
      cLine     := substr( cLine, 1, n - 1 )
      nLine     := val( cLine )

      RETURN !empty( cFileName )
   ENDIF

   // Validate if current text is a error/warning/info message.
   // 29/12/2009 - 22:51:39 - vailtom
   IF lValidText
      nPos := aScan( aRegList, {| reg | !Empty( hb_RegEx( reg[ 2 ], cText ) ) } )
      IF ( nPos <= 0 )
         RETURN .F.
      ENDIF
   ENDIF

   aList := hb_RegEx( regLineN, cText )

   IF !Empty( aList )
      nLine := alltrim( aList[ 2 ] )
      cText := Substr( cText, 1, At( nLine, cText ) - 1 )
      cText := alltrim( cText ) + '('

      nLine := strtran( nLine, ":", "" )
      nLine := strtran( nLine, "(", "" )
      nLine := strtran( nLine, ")", "" )
      nLine := VAL( alltrim( nLine ) )
   ENDIF

   IF ( nPos := hb_At( '(', cText ) ) > 0
      cFileName := alltrim( Subst( cText, 1, nPos - 1 ) )
   ELSE
      IF ( nPos := At( 'referenced from', Lower( cText ) ) ) != 0
         cFileName := SubStr( cText, nPos + Len( 'referenced from' ) )
      ELSE
       * GCC & MSVC filename detect...
         IF Subst( cText, 2, 1 ) == ':'
            nPos := hb_At( ':', cText, 3 )
         ELSE
            nPos := hb_At( ':', cText )
         ENDIF
         IF nPos != 0
            cFileName := SubStr( cText, 1, nPos - 1 )
         ENDIF
      ENDIF
   ENDIF

   cFileName := strtran( cFileName, "(", "" )
   cFileName := strtran( cFileName, ")", "" )
   cFileName := alltrim( cFileName )
   cFileName := strtran( cFileName, "\\", "/" )
   cFileName := strtran( cFileName, "\" , "/" )

   IF ( nPos := Rat( ' ', cFileName ) ) != 0
      cFileName := SubStr( cFileName, nPos + 1 )
   ENDIF

   IF Subst( cFileName, 2, 1 ) == ':'
      nPos := hb_At( ':', cFileName, 3 )
   ELSE
      nPos := hb_At( ':', cFileName )
   ENDIF

   IF nPos != 0
      cFileName := SubStr( cFileName, 1, nPos - 1 )
   ENDIF

   cFileName := alltrim( cFileName )
   RETURN !Empty( cFileName )


/* This function parses compiler result and hightlight errors & warnings using
 * regular expressions. (vailtom)
 *
 * More about Qt Color names:
 * http://www.w3.org/TR/SVG/types.html#ColorKeywords
 *
 * 28/12/2009 - 16:17:37
 */
FUNCTION hbide_convertBuildStatusMsgToHtml( cText, oWidget )
   LOCAL aColors  := { CLR_MSG_ERR, CLR_MSG_INFO, CLR_MSG_WARN }
   LOCAL aLines, cIfError, cLine, nPos

   IF aRegList == NIL
      aRegList := {}
      hbide_BuildRegExpressList( aRegList )
   ENDIF

   cText := StrTran( cText, Chr( 13 ) + Chr( 10 ), Chr( 10 ) )
   cText := StrTran( cText, Chr( 13 )            , Chr( 10 ) )
   cText := StrTran( cText, Chr( 10 ) + Chr( 10 ), Chr( 10 ) )
   cText := StrTran( cText, "  ", " " )

   /* Convert some chars to valid HTML chars */
   cText := StrTran( cText, "<", "&lt;" )
   cText := StrTran( cText, ">", "&gt;" )
   aLines := hb_aTokens( cText, Chr( 10 ) )

   FOR EACH cLine IN aLines
      IF ! Empty( cLine )
         IF ( nPos := aScan( aRegList, {| reg | !Empty( hb_RegEx( reg[ 2 ], cLine ) ) } ) ) > 0
            IF aRegList[ nPos,1 ] == MSG_TYPE_ERR
               cIfError := cLine
            ENDIF
            cLine := '<font color=' + aColors[ aRegList[nPos,1] ] + '>' + cLine + '</font>'
         ELSEIF "XBT" $ cLine
            cLine := '<font color=' + aColors[ aRegList[nPos,1] ] + '>' + cLine + '</font>'
         ELSE
            cLine := "<font color=black>" + cLine + "</font>"
         ENDIF
      ENDIF
      oWidget:append( hbide_iterate( cLine ) )
   NEXT
   RETURN cIfError


FUNCTION hbide_iterate( cLine )
   RETURN "<font color=green>" + "[" + StrZero( Seconds(), 9, 3 ) + "] </font>" + cLine

FUNCTION hbide_filesToSources( aFiles )
   LOCAL aSrc := {}
   LOCAL s

   FOR EACH s IN aFiles
      IF hbide_isValidSource( s )
         aadd( aSrc, s )
      ENDIF
   NEXT
   RETURN aSrc


FUNCTION hbide_parseKeyValPair( s, cKey, cVal )
   LOCAL n, lYes := .f.

   IF ( n := at( "=", s ) ) > 0
      cKey := alltrim( substr( s, 1, n - 1 ) )
      cVal := alltrim( substr( s, n + 1 ) )
      lYes := ( !empty( cKey ) .and. !empty( cVal ) )
   ENDIF
   RETURN lYes


FUNCTION hbide_parseFilter( s, cKey, cVal )
   LOCAL n, n1, lYes := .f.

   IF ( n := at( "{", s ) ) > 0
      IF ( n1 := at( "}", s ) ) > 0
         cKey := alltrim( substr( s, n+1, n1-n-1 ) )
         cVal := alltrim( substr( s, n1+1 ) )
         lYes := .t.
      ENDIF
   ENDIF
   RETURN lYes


/* Return the next untitled filename available.
 * 01/01/2010 - 19:40:17 - vailtom
 */
FUNCTION hbide_getNextUntitled()
   STATIC s_nCount := 0
   RETURN ++s_nCount


/* Return the next TAB_ID or IDE_ID available.
 * 02/01/2010 - 10:47:16 - vailtom
 */
FUNCTION hbide_getNextUniqueID()
   STATIC s_nCount := 0

   IF s_nCount > 4294967295
      s_nCount := 0
   ENDIF
   RETURN ++s_nCount


FUNCTION hbide_getNextIDasString( cString )
   STATIC hIDs := {=>}

   IF ! hb_hHasKey( hIDs, cString )
      hIDs[ cString ] := 0
   ENDIF
   RETURN cString + "_" + hb_ntos( ++hIDs[ cString ] )


/* Check if cFilename has a extension... and add cDefaultExt if not exist.
 * 01/01/2010 - 20:48:10 - vailtom
 */
FUNCTION hbide_checkDefaultExtension( cFileName, cDefaultExt )
   LOCAL cPath, cFile, cExt

   hb_fNameSplit( cFileName, @cPath, @cFile, @cExt )
   IF Empty( cExt )
      cExt := cDefaultExt
   ENDIF
   RETURN cPath + hb_ps() + cFile + hb_ps() + cExt


function hbide_toString( x, lLineFeed, lInherited, lType, cFile, lForceLineFeed )
   LOCAL s := ''
   LOCAL t := valtype( x )
   LOCAL i, j

   DEFAULT lLineFeed      TO .T.
   DEFAULT lInherited     TO .F.
   DEFAULT lType          TO .F.
   DEFAULT cFile          TO ""
   DEFAULT lForceLineFeed TO .F.

   DO CASE
   CASE ( t == "C" )
      s := iif( lType, "[C]=", "" ) + '"' + x + '"'
   CASE ( t == "N" )
      s := iif( lType, "[N]=", "" ) + alltrim(str( x ))
   CASE ( t == "D" )
      s := iif( lType, "[D]=", "" ) + "ctod('"+ dtoc(x) +"')"
   CASE ( t == "L" )
      s := iif( lType, "[L]=", "" ) + iif( x, '.T.', '.F.' )
   CASE ( t == "M" )
      s := iif( lType, "[M]=", "" ) + '"' + x + '"'
   CASE ( t == "B" )
      s := iif( lType, "[B]=", "" ) + '{|| ... }'
   CASE ( t == "U" )
      s := iif( lType, "[U]=", "" ) + 'NIL'
   CASE ( t == "A" )
      s := iif( lType, "[A]=", "" ) + "{"
      IF Len( x ) == 0
         s += " "
      ELSE
         s += iif( valtype( x[1] ) == "A" .or. lForceLineFeed, hb_eol(), "" )
         j := Len( x )

         FOR i := 1 TO j
             s += iif( valtype( x[i] ) == "A", "  ", " " ) + iif( lForceLineFeed, " ", "" ) + hbide_toString( x[i], .F. )
             s += iif( i != j, ",", "" )
             IF lLineFeed
                IF !lInherited .and. ( valtype( x[i] ) == "A" .or. lForceLineFeed )
                   s += hb_eol()
                ENDIF
             ENDIF
         NEXT
      ENDIF
      s += iif( !lForceLineFeed, " ", "" ) + "}"

   CASE ( t == "O" )
      IF lInherited
         // E necessario linkar \harbour\lib\xhb.lib
         // s := iif( lType, "[O]=", "" ) + hb_dumpvar( x ) + iif( lLineFeed, hb_eol(), "" )
         s := '' + iif( lLineFeed, hb_eol(), "" )
      ELSE
//         s := iif( lType, "[O]=", "" ) + x:ClassName()+'():New()' + iif( lLineFeed, hb_eol(), "" )
         s := iif( lType, "[O]=", "" ) + x:ClassName() + iif( lLineFeed, hb_eol(), "" )
      ENDIF
   ENDCASE

   IF !empty( cFile )
      memowrit( cFile, s )
   ENDIF
   RETURN s


FUNCTION hbide_help( nOption )
   LOCAL txt_  := {}
   LOCAL tit_  := ''

   SWITCH nOption
   CASE 1
      tit_ := 'About HbIDE'
      AAdd( txt_, "<b>Harbour IDE ( HbIDE )</b>" )
      AAdd( txt_, "Developed by" )
      AAdd( txt_, "Pritpal Bedi ( bedipritpal@hotmail.com )" )
      AAdd( txt_, "" )
      AAdd( txt_, "built with:" )
      AAdd( txt_, "QtContribs " + " r " + __HBQT_REVISION__ )
      AAdd( txt_, HB_COMPILER() )
      AAdd( txt_, "Qt " + QT_VERSION_STR() )
      AAdd( txt_, "" )
      AAdd( txt_, "Visit the project website at:" )
      AAdd( txt_, "<a href='http://harbour-project.org/'>http://harbour-project.org/</a>" )
      AAdd( txt_, "<a href='http://hbide.vouch.info/'>http://hbide.vouch.info/</a>" )
      EXIT

   CASE 2
      tit_ := 'Mailing List'
      AAdd( txt_, "<b>Harbour Development Mailing List</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, "Please visit the home page:" )
      AAdd( txt_, "<a href='http://groups.google.com/group/harbour-devel/'>http://groups.google.com/group/harbour-devel/</a>" )
      AAdd( txt_, "" )
      AAdd( txt_, "<b>QtContribs Developers/Users Mailing List</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, "<a href='http://groups.google.com/group/qtcontribs/'>http://groups.google.com/group/qtcontribs/</a>" )
      EXIT

   CASE 3
      tit_ := 'Mailing List'
      AAdd( txt_, "<b>Harbour Users Mailing List</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, "Please visit the home page:" )
      AAdd( txt_, "<a href='http://groups.google.com/group/harbour-users/'>http://groups.google.com/group/harbour-users/</a>" )
      EXIT

   CASE 4
      tit_ := 'About Harbour'
      AAdd( txt_, "<b>About Harbour</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, '"Harbour is the Free Open Source Software implementation' )
      AAdd( txt_, 'of a multi-platform, multi-threading, object-oriented, scriptable' )
      AAdd( txt_, 'programming language, backwards compatible with Clipper/xBase.' )
      AAdd( txt_, 'Harbour consists of a compiler and runtime libraries with multiple' )
      AAdd( txt_, 'UI and database backends, its own make system and a large' )
      AAdd( txt_, 'collection of libraries and interfaces to many popular APIs."' )
      AAdd( txt_, "" )
      AAdd( txt_, "Get downloads, samples, contribs and much more at:" )
      AAdd( txt_, "<a href='http://harbour-project.org/'>http://harbour-project.org/</a>" )
      EXIT

   ENDSWITCH
   IF !Empty( txt_ )
      MsgBox( hbide_arrayToMemo( txt_ ), tit_ )
   ENDIF
   RETURN nil


FUNCTION hbide_getUniqueFuncName()
   LOCAL t, b, c, n

   t := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
   n := Len( t )
   b := ''
   DO WHILE Len( b ) != 10
      c := Substr( t, HB_RANDOMINT( 1, n ), 1 )

      IF !( c $ b )
         IF Empty( b ) .AND. IsDigit( c )
            LOOP
         ENDIF
         b += c
      ENDIF
   ENDDO
   b += '( '
   RETURN b


FUNCTION hbide_findProjTreeItem( oIde, cNodeText, cType )
   LOCAL oItem, a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == cType .AND. a_[ TRE_OITEM ]:caption == cNodeText
         oItem := a_[ TRE_OITEM ]
         EXIT
      ENDIF
   NEXT
   RETURN oItem


FUNCTION hbide_expandChildren( oIde, oItem )
   LOCAL a_

   oItem:expand( .t. )
   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_OPARENT ] == oItem
         a_[ TRE_OITEM ]:expand( .t. )
      ENDIF
   NEXT
   RETURN nil


FUNCTION hbide_collapseProjects( oIde )
   LOCAL a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == "Project Name"
         a_[ TRE_OITEM ]:expand( .f. )
      ENDIF
   NEXT
   RETURN nil


FUNCTION hbide_expandProjects( oIde )
   LOCAL a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == "Project Name"
         hbide_expandChildren( oIde, a_[ TRE_OITEM ] )
      ENDIF
   NEXT
   RETURN NIL


FUNCTION hbide_buildLinesLabel( nFrom, nTo, nW, nMax )
   LOCAL n, i, s := ""

   n := min( nMax, nTo - nFrom  )

   FOR i := 0 TO n
      IF ( ( nFrom + i ) % 10 ) == 0
         s += "<font color = red>" + padl( hb_ntos( nFrom + i ), nW ) + "</font><br />"
      ELSE
         //s += padl( hb_ntos( nFrom + i ), nW ) + hb_eol()
         s += padl( hb_ntos( nFrom + i ), nW ) + "<br />"
      ENDIF
   NEXT
   RETURN s


FUNCTION hbide_parseMacros( cP )
   LOCAL lHas, n, n1, cMacro

   IF !empty( cP )
      DO WHILE .t.
         lHas := .f.

         IF ( n := at( "${" , cP ) ) > 0
            IF ( n1 := at( "}" , cP ) ) > 0
               lHas    := .t.
               cMacro  := substr( cP, n + 2, n1 - n - 2 )
               cP      := substr( cP, 1, n - 1 ) + hbide_macro2value( cMacro ) + substr( cP, n1 + 1 )
            ENDIF
         ENDIF
         IF ! lHas
            EXIT
         ENDIF
      ENDDO
   ENDIF
   RETURN cP


FUNCTION hbide_macro2value( cMacro )
   LOCAL cVal, cMacroL, oEdit, cFile, cPath, cExt
   LOCAL oIde := hbide_setIDE()

   cMacro  := alltrim( cMacro )
   cMacroL := lower( cMacro )

   oEdit   := oIde:oEM:getEditorCurrent()
   IF ! Empty( oEdit )
      hb_fNameSplit( oEdit:source(), @cPath, @cFile, @cExt )
   ELSE
      cPath := ""; cFile := ""; cExt := ""
   ENDIF

   DO CASE
   CASE cMacroL == "source_fullname"
      cVal := hbide_pathToOSPath( cPath + cFile + cExt )

   CASE cMacroL == "source_path"
      cVal := hbide_pathToOSPath( cPath )

   CASE cMacroL == "source_fullname_less_ext"
      cVal := hbide_pathToOSPath( cPath + cFile )

   CASE cMacroL == "source_name"
      cVal := cFile + cExt

   CASE cMacroL == "source_name_less_ext"
      cVal := cFile

   CASE cMacroL == "source_ext"
      cVal := cExt

   CASE cMacroL == "project_title"
      cVal := hbide_setProjectTitle()

   CASE cMacroL == "project_path"
      cVal := oIde:oPM:getProjectPathFromTitle( hbide_setProjectTitle() )

   CASE cMacroL == "project_output_path"
      cVal := hbide_setProjectOutputPath()

   OTHERWISE
      cVal := hb_GetEnv( cMacro )

   ENDCASE
   RETURN cVal


FUNCTION hbide_getShellCommandsTempFile( aCmd )
   LOCAL cExt, fhnd, cCmdFileName, cCmdFile, tmp

#if   defined( __PLATFORM__WINDOWS )
   cExt      := ".bat"
#elif defined( __PLATFORM__OS2 )
   cExt      := ".cmd"
#elif defined( __PLATFORM__UNIX )
   cExt      := ".sh"
#endif

   IF ! Empty( cExt )
      cCmdFile := ""
      FOR EACH tmp IN aCmd
         tmp := hbide_parseMacros( tmp )
         cCmdFile += tmp + hb_eol()
      NEXT

      IF ( fhnd := hb_FTempCreateEx( @cCmdFileName, NIL, NIL, cExt ) ) != F_ERROR
         FWrite( fhnd, cCmdFile )
         FClose( fhnd )
      ENDIF
   ENDIF
   RETURN cCmdFileName


FUNCTION hbide_getShellCommand()
   LOCAL cShellCmd

#if   defined( __PLATFORM__WINDOWS )
   cShellCmd := hb_getenv( "COMSPEC" )
#elif defined( __PLATFORM__OS2 )
   cShellCmd := hb_getenv( "COMSPEC" )
#elif defined( __PLATFORM__UNIX )
   cShellCmd := hb_getenv( "SHELL" )
#endif
   RETURN cShellCmd


FUNCTION hbide_getOS()
   LOCAL cOS
#if   defined( __PLATFORM__WINDOWS )
   cOS := "win"
#elif defined( __PLATFORM__OS2 )
   cOS := "os"
#elif defined( __PLATFORM__UNIX )
   cOS := "nix"
#endif
   RETURN cOS


FUNCTION hbide_fetchADate( qParent, cTitle, cPrompt, dDefault )
   LOCAL qDate, oUI, nRet

   DEFAULT cTitle  TO "A Date Value"
   DEFAULT cPrompt TO "What"

   oUI := hbide_getUI( "fetchdate", qParent )

   oUI:setWindowTitle( cTitle )
   oUI:labelPrompt:setText( cPrompt )
   IF dDefault != NIL
      qDate := QDate()
      qDate:setYear( year( dDefault ) )
      qDate:setMonth( month( dDefault ) )
      qDate:setDay( day( dDefault ) )
      oUI:editDate:setDate( qDate )
   ENDIF

   oUI:buttonOk:connect( "clicked()", {|| oUI:done( 1 ) } )
   oUI:buttonCancel:connect( "clicked()", {|| oUI:done( 0 ) } )

   nRet := oUI:exec()

   oUI:buttonOk:disconnect( "clicked()" )
   oUI:buttonCancel:disconnect( "clicked()" )

   IF nRet == 1
      qDate := oUI:editDate:date()
      RETURN stod( strzero( qDate:year(), 4 ) + strzero( qDate:month(),2 ) + strzero( qDate:day(), 2 ) )
   ENDIF
   RETURN NIL


FUNCTION hbide_fetchAString( qParent, cDefault, cWhat, cTitle )
   LOCAL qGo, cText

   DEFAULT cDefault TO ""
   DEFAULT cWhat    TO ""
   DEFAULT cTitle   TO "A String Value"

   qGo := QInputDialog( qParent )
   qGo:setTextValue( cDefault )
   qGo:setLabelText( cWhat )
   qGo:setWindowTitle( cTitle )

   qGo:exec()
   cText := qGo:textValue()
   qGo:setParent( QWidget() )
   RETURN cText


/* Harbour Project source code:
 *
 * Copyright 2010 Viktor Szakats (harbour syenar.net)
 * www - http://harbour-project.org
 */
#define HBIDE_HBP_PTYPE_FILES                     "files"
#define HBIDE_HBP_PTYPE_OPTIONS                   "options"
#define HBIDE_HBP_PTYPE_HBIDEPARAMS               "hbideparams"

FUNCTION hbide_fetchHbpData( cHBPFileName )
   LOCAL aParamList := hbide_HBPGetParamList( cHBPFileName )

   RETURN  { hbide_HBPParamListFilter( aParamList, HBIDE_HBP_PTYPE_OPTIONS ), ;
             hbide_HBPParamListFilter( aParamList, HBIDE_HBP_PTYPE_FILES   )  }


FUNCTION hbide_HBPParamListFilter( aParams, nType )
   LOCAL aArray := {}
   LOCAL tmp
   LOCAL cParamNQ

   FOR EACH tmp IN aParams
      DO CASE
      CASE Lower( Left( tmp[ 1 ], 7 ) ) == "#hbide."
         IF nType == HBIDE_HBP_PTYPE_HBIDEPARAMS
            AAdd( aArray, tmp[ 1 ] )
         ENDIF
      CASE Left( tmp[ 1 ], 1 ) == "#"
         /* misc comment line, always skip */
      CASE Empty( tmp[ 1 ] )
         /* empty line, always skip */
      OTHERWISE
         cParamNQ := hbide_HBPStrStripQuote( tmp[ 1 ] )
         IF Left( cParamNQ, 1 ) == "-"
            /* in conformance with hbmk2, skip remaining hbmk2 parameters if -skip is found */
            IF Lower( cParamNQ ) == "-skip" .AND. ( nType == HBIDE_HBP_PTYPE_FILES .OR. nType == HBIDE_HBP_PTYPE_OPTIONS )
               EXIT
            ENDIF
            IF nType == HBIDE_HBP_PTYPE_OPTIONS
               AAdd( aArray, cParamNQ )
            ENDIF
         ELSE
            IF nType == HBIDE_HBP_PTYPE_FILES
               AAdd( aArray, cParamNQ )
            ENDIF
         ENDIF
      ENDCASE
   NEXT
   RETURN aArray


/* Load entire .hbp files, with empty lines and comments for
   further processing. [vszakats]
*/
FUNCTION hbide_HBPGetParamList( cFileName )
   LOCAL aParams := {}

   hbide_HBPLoad( aParams, cFileName )
   RETURN aParams


/* Recursive .hbp/.hbm files are not currently supported.
   It can be added, but it makes updating the options much more
   complicated. [vszakats]
*/
#define HBIDE_HBP_EOL                             Chr( 10 )

STATIC PROCEDURE hbide_HBPLoad( aParams, cFileName )
   LOCAL cFile, cLine, cParam, cParamNQ

   IF hb_FileExists( cFileName )
      cFile := MemoRead( cFileName ) /* NOTE: Intentionally using MemoRead() which handles EOF char. */

      IF ! hb_eol() == HBIDE_HBP_EOL
         cFile := StrTran( cFile, hb_eol(), HBIDE_HBP_EOL )
      ENDIF
      IF ! hb_eol() == Chr( 13 ) + Chr( 10 )
         cFile := StrTran( cFile, Chr( 13 ) + Chr( 10 ), HBIDE_HBP_EOL )
      ENDIF

      FOR EACH cLine IN hb_ATokens( cFile, HBIDE_HBP_EOL )
         IF Empty( cLine ) .OR. ;
            Left( cLine, 1 ) == "#"
            AAdd( aParams, { cLine, cFileName, cLine:__enumIndex() } )
         ELSE
            FOR EACH cParam IN hb_ATokens( cLine,, .T. )
               cParamNQ := hbide_HBPStrStripQuote( cParam )
               IF ! Empty( cParamNQ )
                  #if 0
                  DO CASE
                  CASE !( Left( cParamNQ, 1 ) == "-" ) .AND. Len( cParamNQ ) >= 1 .AND. Left( cParamNQ, 1 ) == "@" .AND. ;
                       !( Lower( hb_FNameExt( cParamNQ ) ) == ".clp" )
                     /* skip recurse */
                  CASE !( Left( cParamNQ, 1 ) == "-" ) .AND. ;
                       ( Lower( hb_FNameExt( cParamNQ ) ) == ".hbm" .OR. ;
                         Lower( hb_FNameExt( cParamNQ ) ) == ".hbp" )
                     /* skip recurse */
                  OTHERWISE
                     AAdd( aParams, { cParam, cFileName, cLine:__enumIndex() } )
                  ENDCASE
                  #endif
                  AAdd( aParams, { cParam, cFileName, cLine:__enumIndex() } )
               ENDIF
            NEXT
         ENDIF
      NEXT
   ENDIF
   RETURN


STATIC FUNCTION hbide_HBPStrStripQuote( cString )
   RETURN iif( Left( cString, 1 ) == '"' .AND. Right( cString, 1 ) == '"',;
             SubStr( cString, 2, Len( cString ) - 2 ),;
             cString )


FUNCTION hbide_parseHbpFilter( s, cFilt, cPath )
   LOCAL n, n1

   cFilt := ""
   cPath := s
   IF ( n := at( "{", s ) ) > 0
      IF ( n1 := at( "}", s ) ) > 0
         cFilt := substr( s, n + 1, n1 - n + 1 )
         cPath := alltrim( substr( s, n1 + 1 ) )
         RETURN .T.
      ENDIF
   ELSEIF ( n := At( "@", s ) ) > 0
      cFilt := "@"
      cPath := SubStr( s, 1, n-1 ) + SubStr( s, n+1 )
      RETURN .T.
   ENDIF
   RETURN .f.


FUNCTION hbide_outputLine( cLine, nOccur )

   DEFAULT cLine  TO "-"
   DEFAULT nOccur TO 100
   RETURN "<font color=lightgreen>" + replicate( cLine, nOccur ) + "</font>"


FUNCTION hbide_fetchSubPaths( aPaths, cRootPath, lSubs )
   LOCAL aDir, a_

   DEFAULT lSubs TO .t.

   IF !( right( cRootPath, 1 ) == hb_ps() )
      cRootPath += hb_ps()
   ENDIF
   cRootPath := hbide_pathToOSPath( cRootPath )

   aadd( aPaths, cRootPath )

   IF lSubs
      aDir := directory( cRootPath + "*", "D" )
      FOR EACH a_ IN aDir
         IF a_[ 5 ] == "D" .AND. !( left( a_[ 1 ], 1 ) == "." )
            hbide_fetchSubPaths( @aPaths, cRootPath + a_[ 1 ] )
         ENDIF
      NEXT
   ENDIF
   RETURN NIL


FUNCTION hbide_image( cName )
   DEFAULT cName TO ""
   RETURN hbide_pathToOsPath( ":/resources" + "/" + cName + ".png" )


FUNCTION hbide_uic( cName )
   LOCAL tmp
   DEFAULT cName TO ""
   tmp := hbide_pathToOsPath( hb_DirBase() + "resources" + "/" + cName + ".uic" )
   IF ! hb_FileExists( tmp )
      MsgBox( "Error: File " + tmp + " is missing. Please check your installation." )
      QUIT
   ENDIF
   RETURN tmp


FUNCTION hbide_ui( cName )
   LOCAL tmp
   DEFAULT cName TO ""
   tmp := hbide_pathToOsPath( hb_DirBase() + "resources" + "/" + cName + ".ui" )
   IF ! hb_FileExists( tmp )
      MsgBox( "Error: File " + tmp + " is missing. Please check your installation." )
      QUIT
   ENDIF
   RETURN tmp


FUNCTION hbide_isPrevParent( cRoot, cPath )
   LOCAL cLRoot, cLPath

   cLRoot := hbide_pathNormalized( cRoot, .t. )
   cLPath := hbide_pathNormalized( cPath, .t. )

   IF hb_FileMatch( left( cLPath, Len( cLRoot ) ), cLRoot )
      RETURN .t.
   ENDIF
   RETURN .f.


FUNCTION hbide_space2amp( cStr )
   RETURN strtran( cStr, " ", chr( 38 ) )


FUNCTION hbide_amp2space( cStr )
   RETURN strtran( cStr, chr( 38 ), " " )


FUNCTION hbide_stripFilter( cSrc )
   LOCAL n, n1

   DO WHILE .t.
      IF ( n := at( "{", cSrc ) ) == 0
         EXIT
      ENDIF
      IF ( n1 := at( "}", cSrc ) ) == 0
         EXIT
      ENDIF
      cSrc := substr( cSrc, 1, n - 1 ) + substr( cSrc, n1 + 1 )
   ENDDO
   RETURN cSrc


FUNCTION hbide_stripRoot( cRoot, cPath )
   LOCAL cLRoot, cLPath, cP

   IF !empty( cRoot ) .AND. ! ( right( cRoot, 1 ) $ "/\" )
      cRoot += "/"
   ENDIF

   cLRoot := hbide_pathNormalized( cRoot, .t. )
   cLPath := hbide_pathNormalized( cPath, .f. )
   IF hb_FileMatch( left( lower( cLPath ), Len( cLRoot ) ), cLRoot )
      cP := substr( cLPath, Len( cRoot ) + 1 )
      RETURN cP
   ENDIF
   RETURN cPath


FUNCTION hbide_syncRoot( cRoot, cPath )
   LOCAL cPth, cFile, cExt
   LOCAL cPathProc := hb_PathJoin( cPath, cRoot )

   hb_fNameSplit( cPath, @cPth, @cFile, @cExt )
   //HB_TRACE( HB_TR_DEBUG, "hbide_syncRoot( cRoot, cPath )", cPathProc, hbide_pathToOSpath( cPathProc + "/" + cFile + cExt ) )
   RETURN hbide_pathToOSpath( cPathProc + "/" + cFile + cExt )


FUNCTION hbide_array2cmdParams( aHbp )
   LOCAL cCmd := " "

   aeval( aHbp, {|e| cCmd += e + " " } )
   RETURN cCmd


FUNCTION hbide_syncProjPath( cRoot, cSource )

   IF !empty( cRoot ) .AND. ! ( right( cRoot, 1 ) $ "/\" )
      cRoot += "/"
   ENDIF
   IF left( cSource, 2 ) == ".."
      RETURN cRoot + cSource
   ELSEIF left( cSource, 1 ) $ "./\" .OR. substr( cSource, 2, 1 ) == ":"
      RETURN cSource
   ENDIF
   RETURN cRoot + cSource


FUNCTION hbide_popupBrwContextMenu( qTextBrowser, p )
   LOCAL aMenu := {}

   aadd( aMenu, { "Back"      , {|| qTextBrowser:backward()  } } )
   aadd( aMenu, { "Forward"   , {|| qTextBrowser:forward()   } } )
   aadd( aMenu, { "Home"      , {|| qTextBrowser:home()      } } )
   aadd( aMenu, { "" } )
   aadd( aMenu, { "Reload"    , {|| qTextBrowser:reload()    } } )
   aadd( aMenu, { "" } )
   aadd( aMenu, { "Select All", {|| qTextBrowser:selectAll() } } )
   aadd( aMenu, { "Copy"      , {|| qTextBrowser:copy()      } } )
   aadd( aMenu, { "Print"     , {|| NIL                      } } )

   RETURN hbide_execPopup( aMenu, qTextBrowser:mapToGlobal( QPoint( p ) ), qTextBrowser )


FUNCTION hbide_groupSources( cMode, a_ )
   LOCAL cTyp, s, d_, n
   LOCAL aSrc := { ".prg", ".hb", ".c", ".cpp", ".h", ".ch", ".hbp", ".hbc", ".rc", ".res", ".obj", ".o", ".lib", ".a" }
   LOCAL aTxt := { {}    , {}   , {}  , {}    , {}  , {}   , {}    , {}    , {}   , {}    , {}    , {}  , {}    , {}   }
   LOCAL aRst := {}

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
            FOR EACH s IN d_
               aadd( a_, s )
            NEXT
         ENDIF
      NEXT
      IF !empty( aRst )
         FOR EACH s IN aRst
            aadd( a_, s )
         NEXT
      ENDIF
   ENDIF
   RETURN a_


FUNCTION hbide_imageForProjectType( cType )
   cType := left( cType, 8 )
   RETURN iif( cType == "Lib", "fl_lib", iif( cType == "Dll", "fl_dll", "fl_exe" ) )


FUNCTION hbide_imageForFileType( cType )
   cType := lower( cType )
   SWITCH cType
   CASE ".exe"
      RETURN "fl_exe"
   CASE ".lib"
   CASE ".a"
      RETURN "fl_lib"
   CASE ".rc"
   CASE ".res"
      RETURN "source_res" //"fl_res"
   CASE ".hb"
   CASE ".prg"
      RETURN "source_prg" //"fl_prg"
   CASE ".c"
      RETURN "source_c"
   CASE ".cpp"
      RETURN "source_cpp" //"fl_c"
   CASE ".o"
   CASE ".obj"
      RETURN "source_o"   //"fl_obj"
   CASE ".hbp"
      RETURN "project"
   CASE ".hbc"
      RETURN "envconfig"
   CASE ".h"
   CASE ".ch"
      RETURN "source_h"
   OTHERWISE
      RETURN "source_unknown" //"fl_txt"
   ENDSWITCH
   RETURN NIL


FUNCTION hbide_array2string( a_, cDlm )
   LOCAL s := ""

   aeval( a_, {|e| s += e + cDlm } )
   RETURN s


FUNCTION hbide_nArray2string( a_ )
   LOCAL cString := ""
   LOCAL n

   FOR EACH n IN a_
      cString += hb_ntos( n )
      cString += " "
   NEXT
   RETURN cString


FUNCTION hbide_string2nArray( s )
   LOCAL b_, a_:= {}

   b_:= hb_atokens( s, " " )
   FOR EACH s IN b_
      s := alltrim( s )
      IF Len( s ) > 0
         aadd( a_, val( s ) )
      ENDIF
   NEXT
   RETURN a_


FUNCTION hbide_array2rect( a_ )
   RETURN QRect( a_[ 1 ], a_[ 2 ], a_[ 3 ], a_[ 4 ] )


FUNCTION hbide_parseSourceComponents( cCompositeSource )
   LOCAL a_

   a_:= hb_atokens( cCompositeSource, "," )
   asize( a_, 9 )
   DEFAULT a_[ 1 ] TO ""
   DEFAULT a_[ 2 ] TO ""
   DEFAULT a_[ 3 ] TO ""
   DEFAULT a_[ 4 ] TO ""
   DEFAULT a_[ 5 ] TO ""
   DEFAULT a_[ 6 ] TO "Main"
   DEFAULT a_[ 7 ] TO ""
   DEFAULT a_[ 8 ] TO ""
   DEFAULT a_[ 9 ] TO ""

   //
   a_[ 1 ] := alltrim( a_[ 1 ] )
   a_[ 2 ] := val( alltrim( a_[ 2 ] ) )
   a_[ 3 ] := val( alltrim( a_[ 3 ] ) )
   a_[ 4 ] := val( alltrim( a_[ 4 ] ) )
   a_[ 5 ] := alltrim( a_[ 5 ] )
   a_[ 6 ] := alltrim( a_[ 6 ] )
   a_[ 7 ] := hbide_string2nArray( a_[ 7 ] )
   a_[ 8 ] := alltrim( a_[ 8 ] )
   a_[ 9 ] := alltrim( a_[ 9 ] )
   RETURN a_


FUNCTION hbide_parseUserToolbarComponents( cCompositeTool )
   LOCAL a_

   a_:= hb_atokens( cCompositeTool, "," )
   asize( a_, 7 )
   DEFAULT a_[ 1 ] TO ""
   DEFAULT a_[ 2 ] TO ""
   DEFAULT a_[ 3 ] TO ""
   DEFAULT a_[ 4 ] TO ""
   DEFAULT a_[ 5 ] TO ""
   DEFAULT a_[ 6 ] TO ""
   DEFAULT a_[ 7 ] TO ""
   a_[ 1 ] := alltrim( a_[ 1 ] )
   a_[ 2 ] := alltrim( a_[ 2 ] )
   a_[ 3 ] := alltrim( a_[ 3 ] )
   a_[ 4 ] := alltrim( a_[ 4 ] )
   a_[ 5 ] := alltrim( a_[ 5 ] )
   a_[ 6 ] := alltrim( a_[ 6 ] )
   a_[ 7 ] := alltrim( a_[ 7 ] )
   RETURN a_


FUNCTION hbide_parseToolComponents( cCompositeTool )
   LOCAL a_

   a_:= hb_atokens( cCompositeTool, "," )
   asize( a_, 12 )
   DEFAULT a_[ 1 ] TO ""
   DEFAULT a_[ 2 ] TO ""
   DEFAULT a_[ 3 ] TO ""
   DEFAULT a_[ 4 ] TO ""
   DEFAULT a_[ 5 ] TO ""
   DEFAULT a_[ 6 ] TO ""
   DEFAULT a_[ 7 ] TO "-1"
   DEFAULT a_[ 8 ] TO "YES"
   DEFAULT a_[ 9 ] TO ""
   DEFAULT a_[10 ] TO ""
   DEFAULT a_[11 ] TO ""
   DEFAULT a_[12 ] TO ""
   a_[ 1 ] := alltrim( a_[ 1 ] )
   a_[ 2 ] := alltrim( a_[ 2 ] )
   a_[ 3 ] := alltrim( a_[ 3 ] )
   a_[ 4 ] := alltrim( a_[ 4 ] )
   a_[ 5 ] := alltrim( a_[ 5 ] )
   a_[ 6 ] := alltrim( a_[ 6 ] )
   a_[ 7 ] := alltrim( a_[ 7 ] )
   a_[ 8 ] := alltrim( a_[ 8 ] )
   a_[ 9 ] := alltrim( a_[ 9 ] )
   a_[10 ] := alltrim( a_[10 ] )
   a_[11 ] := alltrim( a_[11 ] )
   a_[12 ] := alltrim( a_[12 ] )
   RETURN a_


FUNCTION hbide_parseKeywordsComponents( cStr )
   LOCAL a_

   a_:= hb_atokens( cStr, "~" )
   asize( a_, 2 )
   DEFAULT a_[ 1 ] TO ""
   DEFAULT a_[ 2 ] TO ""
   a_[ 1 ] := alltrim( a_[ 1 ] )
   a_[ 2 ] := alltrim( a_[ 2 ] )
   RETURN a_


FUNCTION hbide_parseThemeComponent( cComponent )
   LOCAL i, a_, n

   a_:= hb_aTokens( cComponent, "," )

   aSize( a_, 6 )
   DEFAULT a_[ 1 ] TO ""
   DEFAULT a_[ 2 ] TO ""
   DEFAULT a_[ 3 ] TO ""
   DEFAULT a_[ 4 ] TO ""
   DEFAULT a_[ 5 ] TO ""
   DEFAULT a_[ 6 ] TO ""
   a_[ 1 ] := alltrim( a_[ 1 ] )
   a_[ 2 ] := alltrim( a_[ 2 ] )
   a_[ 3 ] := alltrim( a_[ 3 ] )
   a_[ 4 ] := alltrim( a_[ 4 ] )
   a_[ 5 ] := alltrim( a_[ 5 ] )
   a_[ 6 ] := alltrim( a_[ 6 ] )

   FOR i := 2 TO 6
      IF !empty( a_[ i ] )
         a_[ i ] := hb_aTokens( a_[ i ], " " )
         FOR EACH n IN a_[ i ]
            n := val( n )
         NEXT
      ELSE
         a_[ i ] := {}
      ENDIF
   NEXT
   RETURN a_


FUNCTION hbide_SetWrkFolderLast( cPathFile )
   LOCAL cPth, cOldPath

   STATIC cPath
   IF empty( cPath )
      cPath := hb_dirBase()
   ENDIF
   cOldPath := cPath

   IF HB_ISSTRING( cPathFile )
      hb_fNameSplit( cPathFile, @cPth )
      cPath := cPth
   ENDIF
   RETURN cOldPath


FUNCTION hbide_getUI( cUI, qParent )
   LOCAL oUI

   IF hbide_setIde():nModeUI == UI_MODE_FUNC
      SWITCH Lower( cUI )
      CASE "findinfilesex"       ; oUI :=  hbqtui_Findinfilesex( qParent )       ; EXIT
      CASE "updown"              ; oUI :=  hbqtui_UpDown( qParent )              ; EXIT
      CASE "updown_v"            ; oUI :=  hbqtui_UpDown_v( qParent )            ; EXIT
      CASE "searchreplace"       ; oUI :=  hbqtui_SearchReplace( qParent )       ; EXIT
      CASE "finddialog"          ; oUI :=  hbqtui_FindDialog( qParent )          ; EXIT
      CASE "environments"        ; oUI :=  hbqtui_Environments( qParent )        ; EXIT
      CASE "environ"             ; oUI :=  hbqtui_Environ( qParent )             ; EXIT
      CASE "shortcuts"           ; oUI :=  hbqtui_Shortcuts( qParent )           ; EXIT
      CASE "docwriter"           ; oUI :=  hbqtui_Docwriter( qParent )           ; EXIT
      CASE "toolsutilities"      ; oUI :=  hbqtui_Toolsutilities( qParent )      ; EXIT
      CASE "funclist"            ; oUI :=  hbqtui_Funclist( qParent )            ; EXIT
      CASE "docviewgenerator"    ; oUI :=  hbqtui_Docviewgenerator( qParent )    ; EXIT
      CASE "selectproject"       ; oUI :=  hbqtui_Selectproject( qParent )       ; EXIT
      CASE "projectpropertiesex" ; oUI :=  hbqtui_Projectpropertiesex( qParent ) ; EXIT
      CASE "selectionlist"       ; oUI :=  hbqtui_Selectionlist( qParent )       ; EXIT
      CASE "themesex"            ; oUI :=  hbqtui_Themesex( qParent )            ; EXIT
      CASE "setup"               ; oUI :=  hbqtui_Setup( qParent )               ; EXIT
      CASE "mainwindow"          ; oUI :=  hbqtui_Mainwindow( qParent )          ; EXIT
      CASE "skeletons"           ; oUI :=  hbqtui_Skeletons( qParent )           ; EXIT
      CASE "editor"              ; oUI :=  hbqtui_Editor( qParent )              ; EXIT
      CASE "fetchdate"           ; oUI :=  hbqtui_FetchDate( qParent )           ; EXIT
      CASE "format"              ; oUI :=  hbqtui_Format( qParent )              ; EXIT
      CASE "changelog"           ; oUI :=  hbqtui_Changelog( qParent )           ; EXIT
      CASE "functionsmap"        ; oUI :=  hbqtui_FunctionsMap( qParent )        ; EXIT
      CASE "selectsources"       ; oUI :=  hbqtui_SelectSources( qParent )       ; EXIT
      ENDSWITCH
      IF HB_ISOBJECT( oUI )
         oUI:setStyleSheet( 'font: 8pt "Arial";' )
      ENDIF
   ENDIF
   RETURN oUI


/* An interface component function which will be called by Reports Manager
   whenever a request is made. Application will supply the required info
   in this case it is hbIDE.
*/
FUNCTION app_image( cName )
   RETURN hbide_image( cName )


FUNCTION hbide_isCompilerSource( cSource, cIncList )
   LOCAL cExt, aExt

   DEFAULT cIncList TO ".c,.cpp,.prg,.hb,.rc,.res,.hbm,.hbc,.qrc,.ui,.hbp"

   aExt := hb_aTokens( Lower( cIncList ), "," )
   cExt := Lower( hb_FNameExt( AllTrim( cSource ) ) )
   RETURN AScan( aExt, {|e| cExt == e } ) > 0


FUNCTION hbide_prepareSourceForHbp( cSource )

   IF ! empty( cSource ) .AND. !( left( cSource,1 ) $ '-#"{' ) .AND. ! lower( left( cSource, 5 ) ) == "-3rd="
      IF ! hbide_isCompilerSource( cSource )
         RETURN "-3rd=hbide_file=" + cSource
      ENDIF
   ENDIF
   RETURN cSource


FUNCTION hbide_synchronizeForHbp( aHbp )
   LOCAL s
   LOCAL txt_:={}

   FOR EACH s IN aHbp
      aadd( txt_, hbide_prepareSourceForHbp( s ) )
   NEXT
   RETURN txt_


FUNCTION hbide_setClose( lYes )
   LOCAL yes
   STATIC sYes := .f.
   yes := sYes
   IF HB_ISLOGICAL( lYes )
      sYes := lYes
   ENDIF
   RETURN yes


FUNCTION hbide_setAdsAvailable( lYes )
   LOCAL yes
   STATIC sYes := .f.
   yes := sYes
   IF HB_ISLOGICAL( lYes )
      sYes := lYes
   ENDIF
   RETURN yes


FUNCTION hbide_getHbxFunctions( cBuffer )
   LOCAL pRegex
   LOCAL tmp
   LOCAL aDynamic := {}

   IF ! Empty( cBuffer ) .AND. ;
      ! Empty( pRegex := hb_regexComp( "^DYNAMIC ([a-zA-Z0-9_]*)$", .T., .T. ) )
      FOR EACH tmp IN hb_regexAll( pRegex, StrTran( cBuffer, Chr( 13 ) ),,,,, .T. )
         AAdd( aDynamic, tmp[ 2 ] )
      NEXT
   ENDIF
   RETURN aDynamic


FUNCTION hbide_identifierImage( cIdentifier )
   LOCAL cImage

   cIdentifier := Upper( cIdentifier )
   cImage := iif( "CLAS" $ cIdentifier, "dc_class", iif( "METH" $ cIdentifier, "dc_method", iif( "PROC" $ cIdentifier, "dc_procedure", "dc_function" ) ) )
   RETURN hbide_image( cImage )


FUNCTION hbide_getFuncObjectFromHash( hDoc )
   LOCAL oFunc

   oFunc := IdeDocFunction():new()

   IF "TEMPLATE" $ hDoc
      oFunc:cTemplate     :=        hDoc[ "TEMPLATE"     ]
   ENDIF
   IF "FUNCNAME" $ hDoc
      oFunc:cName         :=        hDoc[ "FUNCNAME"     ]
   ENDIF
   IF "NAME" $ hDoc
      oFunc:cName         :=        hDoc[ "NAME"         ]
   ENDIF
   IF "CATEGORY" $ hDoc
      oFunc:cCategory     :=        hDoc[ "CATEGORY"     ]
   ENDIF
   IF "SUBCATEGORY" $ hDoc
      oFunc:cSubCategory  :=        hDoc[ "SUBCATEGORY"  ]
   ENDIF
   IF "ONELINER" $ hDoc
      oFunc:cOneLiner     :=        hDoc[ "ONELINER"     ]
   ENDIF
   IF "SYNTAX" $ hDoc
      oFunc:aSyntax       := __S2A( hDoc[ "SYNTAX"       ] )
   ENDIF
   IF "ARGUMENTS" $ hDoc
      oFunc:aArguments    := __S2A( hDoc[ "ARGUMENTS"    ] )
   ENDIF
   IF "RETURNS" $ hDoc
      oFunc:aReturns      := __S2A( hDoc[ "RETURNS"      ] )
   ENDIF
   IF "DESCRIPTION" $ hDoc
      oFunc:aDescription  := __S2A( hDoc[ "DESCRIPTION"  ] )
   ENDIF
   IF "EXAMPLES" $ hDoc
      oFunc:aExamples     := __S2A( hDoc[ "EXAMPLES"     ] )
   ENDIF
   IF "FILES" $ hDoc
      oFunc:aFiles        := __S2A( hDoc[ "FILES"        ] )
   ENDIF
   IF "STATUS" $ hDoc
      oFunc:cStatus       :=        hDoc[ "STATUS"       ]
   ENDIF
   IF "COMPLIANCE" $ hDoc
      oFunc:cCompliance   :=        hDoc[ "COMPLIANCE"   ]
   ENDIF
   IF "PLATFORMS" $ hDoc
      oFunc:cPlatForms    :=        hDoc[ "PLATFORMS"    ]
   ENDIF
   IF "SEEALSO" $ hDoc
      oFunc:cSeeAlso      :=        hDoc[ "SEEALSO"      ]
   ENDIF
   IF "VERSION" $ hDoc
      oFunc:cVersion      :=        hDoc[ "VERSION"      ]
   ENDIF
   IF "INHERITS" $ hDoc
      oFunc:cInherits     :=        hDoc[ "INHERITS"     ]
   ENDIF
   IF "METHODS" $ hDoc
      oFunc:aMethods      := __S2A( hDoc[ "METHODS"      ] )
   ENDIF
   IF "EXTERNALLINK" $ hDoc
      oFunc:cExternalLink :=        hDoc[ "EXTERNALLINK" ]
   ENDIF
   RETURN oFunc


FUNCTION hbide_fetchASelection( aList )
   LOCAL oSL, oStrList, oStrModel, nDone, cChoice

   oSL := hbide_getUI( "selectionlist", hbide_setIde():oDlg:oWidget )

   oSL:setWindowTitle( "Select an Item" )

   oSL:listOptions :connect( "doubleClicked(QModelIndex)", {|p| selectionProc( 1, p, @cChoice, aList, oSL ) } )
   oSL:buttonOk    :connect( "clicked()"                 , {|p| selectionProc( 2, p, @cChoice, aList, oSL ) } )
   oSL:buttonCancel:connect( "clicked()"                 , {|p| selectionProc( 3, p, @cChoice, aList, oSL ) } )

   oStrList := QStringList()
   FOR EACH cChoice IN aList
      oStrList:append( cChoice )
   NEXT
   oStrModel := QStringListModel()
   oStrModel:setStringList( oStrList )

   oSL:listOptions:setModel( oStrModel )
   nDone := oSL:exec()
   oSL:setParent( QWidget() )
   RETURN iif( nDone == 1, cChoice, "" )


STATIC FUNCTION selectionProc( nMode, p, cChoice, aList, oSL )
   LOCAL qModalIndex

   DO CASE
   CASE nMode == 1
      cChoice := aList[ p:row() + 1 ]
      oSL:done( 1 )

   CASE nMode == 2
      qModalIndex := oSL:listOptions:currentIndex()
      cChoice := aList[ qModalIndex:row() + 1 ]
      oSL:done( 1 )

   CASE nMode == 3
      oSL:done( 0 )

   ENDCASE
   RETURN NIL


FUNCTION hbide_IsInCommentOrString( cText, nPos )
   LOCAL  nCmt

   IF ( nCmt := At( "//", cText ) ) > 0
      IF nPos > nCmt
         RETURN .T.
      ENDIF
   ENDIF
   IF ( nCmt := At( "/*", cText ) ) > 0
      IF nPos > nCmt
         DO WHILE .T.
            nCmt := hb_At( "*/", cText, nCmt )
            IF nCmt > 0 .AND. nPos < nCmt
               RETURN .T.
            ELSEIF nCmt > 0 .AND. nPos > nCmt
               nCmt := hb_At( "/*", cText, nCmt )
               IF nCmt == 0 .OR. nPos < nCmt
                  RETURN .F.
               ENDIF
            ELSE
               RETURN .F.
            ENDIF
         ENDDO
      ENDIF
   ENDIF
   RETURN hbide_IsInString( cText, nPos, 1 )


FUNCTION hbide_IsInString( cText, nPos, nStart, cQuote )
   LOCAL j, cTkn
   LOCAL lInString := .F.

   STATIC cAnyQuote  := '"' + "'"

   FOR j := nStart TO nPos-1          // check if string did not begin before it
       cTkn := substr( cText, j, 1 )
       IF cTkn $ cAnyQuote            // any quote characters present ?
          IF lInstring                // if we are already in string
             IF cTkn == cQuote        // is it a matching quote ?
                lInstring := .F.      // yes, we are no in string any more
             ENDIF
          ELSE                        // we are not in string yet
             cQuote    := cTkn        // this is the streing quote
             lInstring := .T.         // now we are in string
         ENDIF
      ENDIF
   NEXT
   RETURN lInString

#if 0
FUNCTION hbide_formatBrace( cText, cBraceO, cBraceC, nSpaces, lOuter )
   LOCAL i

   DEFAULT nSpaces TO 6
   DEFAULT lOuter  TO .F.

   IF .T.
      FOR i := nSpaces TO 1 STEP -1
         cText := StrTran( cText, cBraceO + Space( i ), cBraceO )
      NEXT
      IF lOuter
         FOR i := nSpaces TO 2 STEP -1
            cText := StrTran( cText, Space( i ) + cBraceO, cBraceO )
         NEXT
      ENDIF
      cText := StrTran( cText, cBraceO, cBraceO + Space( 1 ) )

      FOR i := nSpaces TO 1 STEP -1
         cText := StrTran( cText, Space( i ) + cBraceC, cBraceC )
      NEXT
      IF lOuter
         FOR i := nSpaces TO 2 STEP -1
            cText := StrTran( cText, cBraceC + Space( i ), cBraceC )
         NEXT
      ENDIF
      cText := StrTran( cText, cBraceC, Space( 1 ) + cBraceC )

      FOR i := nSpaces TO 1 STEP -1
         cText := StrTran( cText, cBraceO + Space( i ) + cBraceC, cBraceO + cBraceC )
      NEXT
   ENDIF
   RETURN cText


FUNCTION hbide_formatOperators( cText, aOprtrs, nSpaces )
   LOCAL i, cOprtr

   DEFAULT nSpaces TO 1

   FOR EACH cOprtr IN aOprtrs
      FOR i := nSpaces TO 1 STEP -1
         cText := StrTran( cText, Space( i ) + cOprtr, cOprtr )
         cText := StrTran( cText, cOprtr + Space( i ), cOprtr )
      NEXT
      cText := StrTran( cText, cOprtr, Space( 1 ) + cOprtr + Space( 1 ) )
   NEXT
   RETURN cText


FUNCTION hbide_formatCommas( cText, nSpaces )
   LOCAL i, cOprtr := ","

   DEFAULT nSpaces TO 1

   FOR i := nSpaces TO 1 STEP -1
      cText := StrTran( cText, cOprtr + Space( i ), cOprtr )
   NEXT
   RETURN StrTran( cText, cOprtr, cOprtr + Space( 1 ) )

#endif