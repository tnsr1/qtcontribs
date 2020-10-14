/*
 * $Id: misc.prg 475 2020-02-20 03:07:47Z bedipritpal $
 */

/*
 * Harbour Project source code:
 *
 *
 * Copyright 2012-2015 Pritpal Bedi <bedipritpal@hotmail.com>
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


#include "hbtoqt.ch"
#include "hbqtstd.ch"
#include "hbqtgui.ch"
#include "inkey.ch"
#include "fileio.ch"
#include "hbtrace.ch"
#include "common.ch"
#include "error.ch"


THREAD STATIC t_sets := {=>}
THREAD STATIC t_HbQtExec := {=>}

STATIC s_hHarbourFuncList := {=>}
STATIC s_hQtFuncList := {=>}
STATIC s_hUserFuncList := {=>}
STATIC s_timerSingleShot
STATIC s_aRegisteredBlocksForEventClose := {}
STATIC s_aRegisteredBlocksForOrientationChange := {}
STATIC s_primaryScreen
STATIC s_hbqtLogs


INIT PROCEDURE __initHbQtSets()
#ifdef __ANDROID__
   LOCAL oFont := QFont( "Droid Sans Mono", 10 )
#else
   LOCAL oFont := QFont( "Courier New", 10 )
#endif

   oFont:setFixedPitch( .T. )

   QResource():registerResource_1( hbqtres_hbqtwidgets() )

   t_sets[ _QSET_GETSFONT     ] := oFont
   t_sets[ _QSET_LINESPACING  ] := 6
   t_sets[ _QSET_NOMOUSABLE   ] := .F.
   t_sets[ _QSET_EDITSPADDING ] := 4

   hb_HCaseMatch( s_hHarbourFuncList, .F. )
   hb_HKeepOrder( s_hHarbourFuncList, .T. )

   __hbqtStackHarbourFuncList()

   s_hHarbourFuncList[ "HB_SYMBOL_UNUSED" ] := "HB_SYMBOL_UNUSED"

   hb_HCaseMatch( s_hQtFuncList, .F. )
   hb_HKeepOrder( s_hQtFuncList, .T. )

   __hbqtStackQtFuncList()

   hb_HCaseMatch( s_hUserFuncList, .F. )
   hb_HKeepOrder( s_hUserFuncList, .T. )
   RETURN


EXIT PROCEDURE __exitHbQtSets()
   t_sets := NIL
   RETURN


FUNCTION __hbqtRegisterForEventClose( bBlock )
   AAdd( s_aRegisteredBlocksForEventClose, bBlock )
   RETURN Len( s_aRegisteredBlocksForEventClose )


FUNCTION __hbqtBroadcastEventClose( oEvent )
   LOCAL bBlock, lHandled

   FOR EACH bBlock IN s_aRegisteredBlocksForEventClose DESCEND
      lHandled := Eval( bBlock, oEvent )
      IF HB_ISLOGICAL( lHandled ) .AND. lHandled
         oEvent:ignore()
         RETURN .T.
      ENDIF
   NEXT
   RETURN .F.


FUNCTION __hbqtManageEditEvents( oWidget )
   oWidget:connect( QEvent_KeyRelease, {|oEvent| __hbqtManageEditEventKeyRelease( oEvent, oWidget ) } )
   RETURN NIL

STATIC FUNCTION __hbqtManageEditEventKeyRelease( oEvent, oWidget )
   SWITCH oEvent:key()
   CASE Qt_Key_Return
      QApplication():postEvent( oWidget, QEvent( QEvent_CloseSoftwareInputPanel ) )
      RETURN .T.
   ENDSWITCH
   RETURN .F.


FUNCTION __hbqtImage( cName )
   RETURN ":/hbqt/resources" + "/" + cName + ".png"


FUNCTION __hbqtGetNextIdAsString( cString )
   STATIC hIDs := {=>}
   IF Empty( hIDs )
      hb_HCaseMatch( hIDs, .F. )
   ENDIF
   IF ! hb_hHasKey( hIDs, cString )
      hIDs[ cString ] := 0
   ELSE
      cString += "_" + hb_ntos( ++hIDs[ cString ] )
   ENDIF
   RETURN cString


FUNCTION __hbqtGetBlankValue( xValue )
   SWITCH ValType( xValue )
   CASE "C" ; RETURN Space( Len( xValue ) )
   CASE "N" ; RETURN 0
   CASE "D" ; RETURN CToD( "" )
   CASE "L" ; RETURN .F.
   ENDSWITCH
   RETURN ""


FUNCTION HbQtSet( nSet, xValue )
   LOCAL xOldValue := t_sets[ nSet ]

   SWITCH nSet
   CASE _QSET_EDITSPADDING
      IF HB_ISNUMERIC( xValue ) .AND. xValue >= 0
         t_sets[ _QSET_EDITSPADDING ] := xValue
      ENDIF
      EXIT
   CASE _QSET_GETSFONT
      IF __objGetClsName( xValue ) == "QFONT"
         t_sets[ _QSET_GETSFONT    ] := NIL
         t_sets[ _QSET_GETSFONT    ] := xValue
      ENDIF
      EXIT
   CASE _QSET_LINESPACING
      IF HB_ISNUMERIC( xValue ) .AND. xValue >= 0
         t_sets[ _QSET_LINESPACING ] := xValue
      ENDIF
      EXIT
   CASE _QSET_NOMOUSABLE
      IF HB_ISLOGICAL( xValue )
         t_sets[ _QSET_NOMOUSABLE ] := xValue
      ENDIF
      EXIT
   ENDSWITCH

   RETURN xOldValue


FUNCTION __hbqtRgbStringFromColors( aColors )
   LOCAL cFore := "", cBack := ""

   /* Clipper color string "W+/BG" */
   IF HB_ISCHAR( aColors )
      RETURN __hbqtCSSFromColorString( aColors )
   ELSEIF HB_ISNUMERIC( aColors )
      cFore := "#" + hb_ntos( aColors )
   /* { {12,12,12},{13,13,13} } */
   ELSEIF HB_ISARRAY( aColors ) .AND. Len( aColors ) == 2 .AND. HB_ISARRAY( aColors[ 1 ] ) .AND. HB_ISARRAY( aColors[ 2 ] )
      cFore := __hbqtRgbStringFromRGB( aColors[ 1 ] )
      cBack := __hbqtRgbStringFromRGB( aColors[ 2 ] )
   /* { "rgb(12,12,12)","rgb(13,13,13)" } */
   ELSEIF HB_ISARRAY( aColors ) .AND. Len( aColors ) == 2 .AND. HB_ISCHAR( aColors[ 1 ] ) .AND. HB_ISCHAR( aColors[ 2 ] )
      cFore := aColors[ 1 ]
      cBack := aColors[ 2 ]
   /* {r, g, b }*/
   ELSEIF HB_ISARRAY( aColors ) .AND. Len( aColors ) == 3
      cFore := __hbqtRgbStringFromRGB( aColors )
   ENDIF

   RETURN iif( Empty( cFore ), "", "color: " + cFore + ";" ) + iif( Empty( cBack ), "", "background-color: " + cBack + ";" )


FUNCTION __hbqtRgbStringFromRGB( aRgb )
   RETURN "rgb(" + hb_ntos( aRgb[ 1 ] ) + "," + hb_ntos( aRgb[ 2 ] ) + "," + hb_ntos( aRgb[ 3 ] ) + ")"


FUNCTION __hbqtRgbStringFromColorString( cToken, lExt )

   IF Upper( Left( cToken, 3 ) ) == "RGB"    /* rgb notation : rgb(200,12,201)/rgb(104,56,19) */
      RETURN cToken
   ENDIF
   IF Left( cToken, 1 ) == "#"               /* Hex notation : #fffccc/#da3f78 */
      RETURN cToken
   ENDIF

   SWITCH Upper( cToken )                    /* Clipper notation : W+/BG* */
   CASE "N"
      RETURN iif( lExt, "rgb( 198,198,198 )", "rgb( 0 ,0 ,0  )"   )
   CASE "B"
      RETURN iif( lExt, "rgb( 0,0,255 )"    , "rgb( 0,0,133 )"    )
   CASE "G"
      RETURN iif( lExt, "rgb( 96,255,96 )"  , "rgb( 0 ,133,0  )"  )
   CASE "BG"
      RETURN iif( lExt, "rgb( 96,255,255 )" , "rgb( 0 ,133,133 )" )
   CASE "R"
      RETURN iif( lExt, "rgb( 248,0,38 )"   , "rgb( 133,0 ,0  )"  )
   CASE "RB"
      RETURN iif( lExt, "rgb( 255,96,255 )" , "rgb( 133,0 ,133  " )
   CASE "GR"
      RETURN iif( lExt, "rgb( 255,255,0 )"  , "rgb( 133,133,0 )"  )
   CASE "W"
      RETURN iif( lExt, "rgb( 255,255,255 )", "rgb( 96,96,96 )"   )
   ENDSWITCH
   RETURN ""


FUNCTION __hbqtCSSFromColorString( cColor )
   LOCAL cCSS := ""
   LOCAL n, xFore, xBack, lExt, cCSSF, cCSSB

   IF ( n := At( "/", cColor ) ) > 0
      xFore := AllTrim( SubStr( cColor, 1, n-1 ) )
      xBack := AllTrim( SubStr( cColor, n+1 ) )
   ELSE
      xFore := AllTrim( cColor )
      xBack := ""
   ENDIF

   IF ! Empty( xFore )
      lExt := At( "+", xFore ) > 0
      xFore := StrTran( StrTran( xFore, "+" ), "*" )
      cCSSF := __hbqtRgbStringFromColorString( xFore, lExt )
   ENDIF
   IF ! Empty( xBack )
      lExt := "+" $ xBack .OR. "*" $ xBack
      xBack := StrTran( StrTran( xBack, "+" ), "*" )
      cCSSB := __hbqtRgbStringFromColorString( xBack, lExt )
   ENDIF
   IF ! Empty( cCSSF )
      cCSS := "color: " + cCSSF
   ENDIF
   IF ! Empty( cCSSB )
      cCSS += "; background-color: " + cCSSB
   ENDIF

   IF ! Empty( cCSS )
      cCSS += ";"
   ENDIF
   RETURN cCSS


FUNCTION __hbqtHbColorToQtValue( cColor, nRole )

   LOCAL lExt, cClr, n, xFore, xBack

   IF Empty( cColor )
      IF nRole == Qt_BackgroundRole
         RETURN Qt_white
      ELSE
         RETURN Qt_black
      ENDIF
   ENDIF

   cColor := Upper( cColor )

   IF ( n := At( "/", cColor ) ) > 0
      xFore := AllTrim( SubStr( cColor, 1, n-1 ) )
      xBack := AllTrim( SubStr( cColor, n+1 ) )
   ELSE
      xFore := AllTrim( cColor )
      xBack := ""
   ENDIF

   IF nRole == Qt_BackgroundRole
      lExt := "+" $ xBack .OR. "*" $ xBack
      cClr := StrTran( StrTran( xBack, "+" ), "*" )
   ELSEIF nRole == Qt_ForegroundRole
      lExt := "+" $ xFore .OR. "*" $ xFore
      cClr := StrTran( StrTran( xFore, "+" ), "*" )
   ENDIF

   SWITCH cClr
   CASE "N"
      RETURN iif( lExt, Qt_darkGray, Qt_black       )
   CASE "B"
      RETURN iif( lExt, Qt_blue    , Qt_darkBlue    )
   CASE "G"
      RETURN iif( lExt, Qt_green   , Qt_darkGreen   )
   CASE "BG"
      RETURN iif( lExt, Qt_cyan    , Qt_darkCyan    )
   CASE "R"
      RETURN iif( lExt, Qt_red     , Qt_darkRed     )
   CASE "RB"
      RETURN iif( lExt, Qt_magenta , Qt_darkMagenta )
   CASE "GR"
      RETURN iif( lExt, Qt_yellow  , Qt_darkYellow  )
   CASE "W"
      RETURN iif( lExt, Qt_white   , Qt_lightGray   )
   ENDSWITCH
   RETURN 0


FUNCTION __hbqtIsAndroid()
#ifdef __ANDROID__
   RETURN .T.
#else
   RETURN .F.
#endif


FUNCTION __hbqtIsMobile()
#ifdef __HBQTMOBILE__
   RETURN .T.
#else
   RETURN .F.
#endif


PROCEDURE __hbqtAppRefresh()
   IF HB_ISOBJECT( __hbqtAppWidget() )
      __hbqtAppWidget():hide()
      __hbqtAppWidget():show()
   ENDIF
   RETURN


FUNCTION HbQtExit( cUnique, lExit, lDelete )
   STATIC s_lExit := {=>}

   IF HB_ISLOGICAL( lDelete )
      hb_HDel( s_lExit, cUnique )
   ENDIF
   IF HB_ISLOGICAL( lExit )
      s_lExit[ cUnique ] := lExit
   ENDIF
   RETURN iif( hb_HHasKey( s_lExit, cUnique ), s_lExit[ cUnique ], .F. )


FUNCTION HbQtExec( cUnique, bBlock )
   LOCAL oEventLoop

   IF ! HB_ISBLOCK( bBlock )
      bBlock := {|| .T. }
   ENDIF

   oEventLoop := QEventLoop()
   DO WHILE .T.
      oEventLoop:processEvents( 0 )
      Eval( bBlock )
      IF HbQtExit( cUnique )
         HbQtExit( cUnique, NIL, .T. )
         EXIT
      ENDIF
   ENDDO
   oEventLoop:exit( 0 )
   RETURN NIL


FUNCTION HbQtExitX( pPtr )
   LOCAL oWidget, bBlock, oEventLoop

   IF hb_HHasKey( t_HbQtExec, pPtr )
      oWidget := t_HbQtExec[ pPtr ][ 1 ]
      bBlock := t_HbQtExec[ pPtr ][ 2 ]
      oEventLoop := t_HbQtExec[ pPtr ][ 3 ]
   ENDIF
   hb_HDel( t_HbQtExec, pPtr )
   IF HB_ISOBJECT( oEventLoop )
      oEventLoop:exit( 0 )
   ENDIF
   IF HB_ISBLOCK( bBlock )
      Eval( bBlock )
   ENDIF
   oWidget:setParent( QWidget() )
   oWidget := NIL
   oEventLoop := NIL
   RETURN NIL


FUNCTION HbQtExecX( oWidget, bBlock, lLocalLoop )
   LOCAL pPtr := oWidget:getPointer()
   LOCAL oEventLoop

   DEFAULT lLocalLoop TO .F.

   oWidget:connect( QEvent_Close, {|| HbQtExitX( pPtr ) } )
   oWidget:show()

   IF ! hb_HHasKey( t_HbQtExec, pPtr )
      t_HbQtExec[ pPtr ] := { oWidget, bBlock, @oEventLoop }
   ENDIF

   IF lLocalLoop
      oEventLoop := QEventLoop()
      oEventLoop:exec( 0 )
   ENDIF
   RETURN NIL


FUNCTION __hbqtUniqueString( cBaseStr )
   RETURN "A" + StrZero( hb_Random( 99999999 ), 8 ) + "_" + cBaseStr


PROCEDURE __hbqtWaitState( nSeconds, lExitIf )     // lExitIf must be passed by reference . no error checking
   LOCAL oApp := QApplication()
   LOCAL nSecs := Seconds()

   DEFAULT lExitIf TO .F.

   DO WHILE Abs( Seconds() - nSecs ) < nSeconds
      oApp:processEvents()
      IF lExitIf
         EXIT
      ENDIF
   ENDDO
   RETURN


FUNCTION __hbqtGetWindowFrameWidthHeight( oWnd )
   LOCAL oRectFG := oWnd:frameGeometry()
   LOCAL oRectG  := oWnd:geometry()

   RETURN { oRectFG:width() - oRectG:width(), oRectFG:height() - oRectG:height() }


FUNCTION __hbqtGetGlobalXYFromRowColumn( oWnd, nRow, nCol, oFont )  // => { nX, nY, nColWidth, nRowHeight }
   LOCAL oFM, nX, nY, oPos, nOH

   IF oWnd:font():fixedPitch()
      oFM  := QFontMetrics( oWnd:font() )
   ELSE
      __defaultNIL( @oFont , HbQtSet( _QSET_GETSFONT ) )
      oFM  := QFontMetrics( oFont )
   ENDIF

   nX   := ( oFM:averageCharWidth() * nCol ) + 6
   nOH  := oFM:height() + HbQtSet( _QSET_LINESPACING ) + HbQtSet( _QSET_EDITSPADDING )
   nY   := nOH * nRow
   oPos := oWnd:mapToGlobal( QPoint( nX, nY ) )

   RETURN { oPos:x(), oPos:y(), oFM:averageCharWidth(), nOH }


FUNCTION __hbqtGetXYFromRowColumn( oWnd, nRow, nCol, oFont )  // => { nX, nY, nColWidth, nRowHeight }
   LOCAL oFM, nX, nY, nOH

   IF oWnd:font():fixedPitch()
      oFM  := QFontMetrics( oWnd:font() )
   ELSE
      __defaultNIL( @oFont , HbQtSet( _QSET_GETSFONT ) )
      oFM  := QFontMetrics( oFont )
   ENDIF

   nX   := ( oFM:averageCharWidth() * nCol ) + 6
   nOH  := oFM:height() + HbQtSet( _QSET_LINESPACING ) + HbQtSet( _QSET_EDITSPADDING )
   nY   := nOH * nRow
   RETURN { nX, nY, oFM:averageCharWidth(), nOH }


FUNCTION __hbqtPositionWindowClientXY( oWnd, nX, nY )
   LOCAL a_:= __hbqtGetWindowFrameWidthHeight( oWnd )

   oWnd:move( nX - ( a_[ 1 ] / 2 ), nY - ( a_[ 2 ] - ( a_[ 1 ] / 2 ) ) )
   RETURN NIL


FUNCTION __hbqtWindowCenter( oParent, oChild )
   LOCAL a_:= __hbqtGetWindowFrameWidthHeight( oParent )
   LOCAL b_:= __hbqtGetWindowFrameWidthHeight( oChild )
   LOCAL nX := ( a_[ 1 ] - b_[ 1 ] ) / 2
   LOCAL nY := ( a_[ 2 ] - b_[ 2 ] ) / 2

   oChild:move( nX, nY )
   RETURN NIL


FUNCTION __hbqtGetADialogOnTopOf( oParent, nTop, nLeft, nBottom, nRight, cTitle, oFont, lResizable )
   LOCAL oDlg, aInfo, nX, nY, nW, nH, nFlags

   __defaultNIL( @lResizable, .T. )

   aInfo := __hbqtGetGlobalXYFromRowColumn( oParent, nTop, nLeft, oFont )
   nX := aInfo[ 1 ]; nY := aInfo[ 2 ]; nW := aInfo[ 3 ] * ( nRight - nLeft + 1 ) ; nH := aInfo[ 4 ] * ( nBottom - nTop + 1 )

   WITH OBJECT oDlg := QDialog( oParent )
      nFlags := Qt_Dialog + Qt_CustomizeWindowHint
      IF HB_ISCHAR( cTitle ) .AND. ! Empty( cTitle )
         nFlags += Qt_WindowTitleHint
         :setWindowTitle( cTitle )
      ENDIF
      :setWindowFlags( nFlags )
      IF HB_ISOBJECT( oFont )
         :setFont( oFont )
      ENDIF
      //
      // Initially, though not needed, but just in case
      :move( nX, nY )
      :resize( nW, nH )
      //
      :connect( QEvent_Close, {|| oDlg:setParent( QWidget() ) } )
      :connect( QEvent_Show , {|| __hbqtPositionWindowClientXY( oDlg, nX, nY ), iif( lResizable, NIL, __hbqtSetWindowFixedSized( oDlg ) ), .F. } )
   ENDWITH

   RETURN oDlg


FUNCTION __hbqtSetWindowFixedSized( oWnd )

   oWnd:setMaximumHeight( oWnd:height() )
   oWnd:setMaximumWidth( oWnd:width() )
   oWnd:setMinimumHeight( oWnd:height() )
   oWnd:setMinimumWidth( oWnd:width() )

   RETURN NIL


FUNCTION __hbqtSetLastKey( nKey )
   LOCAL l_nKey
   STATIC s_nKey := 0
   l_nKey := s_nKey
   IF HB_ISNUMERIC( nKey )
      s_nKey := nKey
   ENDIF
   RETURN l_nKey


FUNCTION __hbqtPixelsByDPI( nPixels, nBase, lDeviceRatio )
   LOCAL nDpi := QApplication():primaryScreen():logicalDotsPerInchY()

   DEFAULT nBase        TO 96
   DEFAULT lDeviceRatio TO .F.

   HB_SYMBOL_UNUSED( lDeviceRatio )
   RETURN Int( ( nDpi * nPixels / nBase ) * iif( lDeviceRatio, QApplication():primaryScreen():devicePixelRatio(), 1 ) )


FUNCTION __hbqtCssPX( nPixels, nBase, lDeviceRatio )
   RETURN LTrim( Str( __hbqtPixelsByDPI( nPixels, nBase, lDeviceRatio ) ) ) + "px;"


FUNCTION __hbqtHHasKey( hHash, xKey, xValue )     // <xValue> must be passed by reference
   IF HB_ISHASH( hHash ) .AND. hb_HHasKey( hHash, xKey )
      xValue := hHash[ xKey ]
      RETURN .T.
   ENDIF
   RETURN .F.


FUNCTION __hbqtLiteDebug( ... )
   LOCAL a_:= hb_AParams()
   LOCAL i, s

   s := ""
   FOR i := 1 TO Len( a_ )
      s += __hbqtXToS( a_[ i ] ) + ","
   NEXT
   __hbqtAppWidget():setWindowTitle( s )
   RETURN NIL


FUNCTION __hbqtXToS( xVrb )
   SWITCH ValType( xVrb )
   CASE "C" ; RETURN xVrb
   CASE "D" ; RETURN DToC( xVrb )
   CASE "N" ; RETURN LTrim( Str( xVrb ) )
   CASE "L" ; RETURN iif( xVrb, "Yes", "No" )
   CASE "A" ; RETURN hb_ValToExp( xVrb )
   CASE "B" ; RETURN "< block >"
   CASE "O" ; RETURN "< object >"
   ENDSWITCH
   RETURN ""


FUNCTION __hbqtStandardHash( cKey, xValue )
   LOCAL hHash := {=>}

   hb_HKeepOrder( hHash, .T. )
   hb_HCaseMatch( hHash, .F. )
   IF HB_ISSTRING( cKey ) .AND. ! Empty( cKey )
      hHash[ cKey ] := xValue
   ENDIF
   RETURN hHash


FUNCTION __hbqtLoadPixmapFromBuffer( cBuffer, cFormat )
   LOCAL oPixmap := QPixmap()
   DEFAULT cFormat TO "PNG"
   oPixmap:loadFromData( cBuffer, Len( cBuffer ), cFormat )
   RETURN oPixmap


FUNCTION  __hbqtIconFromBuffer( cBuffer )
   LOCAL oPixmap := QPixmap()
   oPixmap:loadFromData( cBuffer, Len( cBuffer ), "PNG" )
   RETURN QIcon( oPixmap )


FUNCTION __hbqtLoadResource( cResource )
   LOCAL cBuffer, oB, oFile

   oFile := QFile( cResource )
   IF oFile:open( QIODevice_ReadOnly )
      oB := oFile:readAll()
      cBuffer := oB:toBase64():data()
      oFile:close()
   ELSE
      cBuffer := ""
   ENDIF
   RETURN cBuffer


FUNCTION __hbqtLoadResourceAsBase64String( cResource )
   LOCAL cBuffer, oB, oFile

   oFile := QFile( ":/hbqt/resources/" + cResource )
   IF oFile:open( QIODevice_ReadOnly )
      oB := oFile:readAll()
      cBuffer := oB:toBase64():data()
      oFile:close()
   ELSE
      cBuffer := ""
   ENDIF
   RETURN cBuffer


FUNCTION __hbqtRgbaCssStr( aRgb )
   RETURN "rgba(" + hb_ntos( aRgb[ 1 ] ) + "," +  hb_ntos( aRgb[ 2 ] ) + "," + hb_ntos( aRgb[ 3 ] ) + ",255)"


FUNCTION __hbqtRgbaCssStrDarker( aRgb, nFactor )
   LOCAL oColor := QColor( aRgb[ 1 ], aRgb[ 2 ], aRgb[ 3 ] ):darker( nFactor )
   RETURN "rgba(" + hb_ntos( oColor:red() ) + "," +  hb_ntos( oColor:green() ) + "," + hb_ntos( oColor:blue() ) + ",255)"


#ifndef __HB_QT_MAJOR_VER_4__

FUNCTION __hbqtUndoScroller( oScrollableWidget )
   QScroller():scroller( oScrollableWidget ):ungrabGesture( oScrollableWidget )
   RETURN NIL


FUNCTION __hbqtApplyStandardScroller( oScrollableWidget )
   LOCAL oScrollerProperties
   LOCAL oScroller := QScroller():scroller( oScrollableWidget )

   WITH OBJECT oScrollerProperties := oScroller:scrollerProperties()
      :setScrollMetric( QScrollerProperties_OvershootDragDistanceFactor  , QVariant( 0 ) )
      :setScrollMetric( QScrollerProperties_OvershootScrollDistanceFactor, QVariant( 0 ) )
   ENDWITH
   oScroller:setScrollerProperties( oScrollerProperties )
   oScroller:grabGesture( oScrollableWidget, QScroller_LeftMouseButtonGesture )
   RETURN oScroller                               // in case to finetune other properties


FUNCTION __hbqtApplyTouchScroller( oScrollableWidget )
   LOCAL oScrollerProperties
   LOCAL oScroller := QScroller():scroller( oScrollableWidget )

   WITH OBJECT oScrollerProperties := oScroller:scrollerProperties()
      :setScrollMetric( QScrollerProperties_OvershootDragDistanceFactor  , QVariant( 0 ) )
      :setScrollMetric( QScrollerProperties_OvershootScrollDistanceFactor, QVariant( 0 ) )
   ENDWITH
   oScroller:setScrollerProperties( oScrollerProperties )
   oScroller:grabGesture( oScrollableWidget, QScroller_TouchGesture )
   RETURN oScroller
                               // in case to finetune other properties
#else

FUNCTION __hbqtUndoScroller( oScrollableWidget )
   HB_SYMBOL_UNUSED( oScrollableWidget )
   RETURN NIL


FUNCTION __hbqtApplyStandardScroller( oScrollableWidget )
   HB_SYMBOL_UNUSED( oScrollableWidget )
   RETURN NIL


FUNCTION __hbqtApplyTouchScroller( oScrollableWidget )
   HB_SYMBOL_UNUSED( oScrollableWidget )
   RETURN NIL

#endif __HB_QT_MAJOR_VER_4__

FUNCTION __hbqtGradientBrush( oColorStart, oColorStop, nType )
   LOCAL oGrad

   DEFAULT nType TO 0

   SWITCH nType
   CASE 0                              // default left-right {0,0},{1,0}
      oGrad := QLinearGradient( 0, 0, 100, 100 )
      EXIT
   CASE 1                              // top-down
      oGrad := QLinearGradient()
      EXIT
   ENDSWITCH

   WITH OBJECT oGrad
      :setColorAt( 0, oColorStart )
      :setColorAt( 1, oColorStop  )
   ENDWITH
   RETURN QBrush( oGrad )


FUNCTION __hbqtApplicationWidget()
   RETURN QApplication():topLevelAt( 0,0 )


FUNCTION __hbqtAppWidget( oWidget )
   STATIC s_oWidget
   LOCAL oldWidget := s_oWidget

   IF HB_ISOBJECT( oWidget )
      s_oWidget := oWidget
   ELSE
      IF PCount() == 1 .AND. oWidget == NIL
         s_oWidget := NIL
      ELSEIF Empty( oldWidget )
         oldWidget := __hbqtApplicationWidget()
      ENDIF
   ENDIF
   RETURN oldWidget


FUNCTION __hbqtTreeViewStyleSheet()
   LOCAL aCSS := {}
   LOCAL cCSS := ""
   //LOCAL cColorTreeBranch := "rgba( 255, 255, 220, 255 );"
   LOCAL cColorTreeBranch := "rgba( 180,180,180, 255 );"

   AAdd( aCSS, 'QTreeView {' )
   AAdd( aCSS, '    paint-alternating-row-colors-for-empty-area: true;' )
   AAdd( aCSS, '    show-decoration-selected: 1;' )
   AAdd( aCSS, '    font-size: '                 + __hbqtCssPX( 16 ) )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::item { ' )
   AAdd( aCSS, '    min-height: '                + __hbqtCssPX( 40 ) )
   AAdd( aCSS, '    border-right: 0.5px ; border-style: solid ; border-color: lightgray ;' )
   AAdd( aCSS, '    border-bottom: 0.5px ; border-style: solid ; border-color: lightgray ;' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::branch:has-children {' )
   AAdd( aCSS, '    background: ' + cColorTreeBranch )
   AAdd( aCSS, '    border-color: ' + cColorTreeBranch )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::item:has-children {' )
   AAdd( aCSS, '    background: ' + cColorTreeBranch )
   AAdd( aCSS, '    color: black;' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::branch:has-children:!has-siblings:closed,' )
   AAdd( aCSS, 'QTreeView::branch:closed:has-children:has-siblings {' )
   AAdd( aCSS, '    border-image: none;' )
   AAdd( aCSS, '    border-bottom: 0.5px ; border-style: solid ; border-color: lightgray ;' )
   AAdd( aCSS, '    image: url(:/hbqt/resources/branch-closed.png);' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::branch:open:has-children:!has-siblings,' )
   AAdd( aCSS, 'QTreeView::branch:open:has-children:has-siblings  {' )
   AAdd( aCSS, '    border-image: none;' )
   AAdd( aCSS, '    border-bottom: 0.5px ; border-style: solid ; border-color: lightgray ;' )
   AAdd( aCSS, '    image: url(:/hbqt/resources/branch-open.png);' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::item:selected:!active {' )
   AAdd( aCSS, '    background: qlineargradient(x1: 0, y1: 0, x2: 1, y2: 0, stop: 0 yellow, stop: 1 red);' )
   AAdd( aCSS, '    color: black;' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::item:pressed {' )
   AAdd( aCSS, '    background: white;' )
   AAdd( aCSS, '    color: black;' )
   AAdd( aCSS, '}' )
   AAdd( aCSS, 'QTreeView::item:selected:active {' )
   AAdd( aCSS, '    background: white;' )
   AAdd( aCSS, '    color: black;' )
   AAdd( aCSS, '}' )

   AEval( aCSS, {|e| cCSS += e + Chr( 13 )+Chr( 10 ) } )

   RETURN cCSS


FUNCTION HbQtActivateSilverLight( lActivate, xContent, oColor, lAnimate, aOpacity, oWidget, nDuration, bExecute )
   STATIC oSilverLight

   IF Empty( oSilverLight )
      oSilverLight := HbQtSilverLight():new():create( "Please Wait..." )
   ENDIF
   IF PCount() == 0
      RETURN oSilverLight:isActive()
   ENDIF
   IF oSilverLight:isActive()
      oSilverLight:deactivate()
   ENDIF
   IF lActivate
      oSilverLight:activate( xContent, oColor, lAnimate, aOpacity, oWidget, nDuration, bExecute )
   ELSE
      oSilverLight:deactivate()
   ENDIF

   RETURN NIL


FUNCTION __hbqtSetPosAndSizeByCParams( oWidget, cParams )
   LOCAL aRect

   IF ! Empty( cParams )
      aRect := hb_ATokens( cParams, "," )
      aeval( aRect, {|e,i| aRect[ i ] := val( e ) } )
      oWidget:move( aRect[ 1 ], aRect[ 2 ] )
      oWidget:resize( aRect[ 3 ], aRect[ 4 ] )
   ENDIF
   RETURN NIL


FUNCTION __hbqtSetPosByCParams( oWidget, cParams )
   LOCAL aRect

   IF ! Empty( cParams )
      aRect := hb_ATokens( cParams, "," )
      aeval( aRect, {|e,i| aRect[ i ] := val( e ) } )
      oWidget:move( aRect[ 1 ], aRect[ 2 ] )
   ENDIF
   RETURN NIL


FUNCTION __hbqtPosAndSizeAsCParams( oWidget )
   LOCAL cParams := ""
   IF HB_ISOBJECT( oWidget )
      cParams := hb_ntos( oWidget:x() ) + "," + hb_ntos( oWidget:y() ) + "," +hb_ntos( oWidget:width() ) + "," +hb_ntos( oWidget:height() )
   ENDIF
   RETURN cParams


FUNCTION __hbqtStyleConvert( cProperty, cnStyleOrValue )
   LOCAL cStyle
   LOCAL nValue

   STATIC hBrushStyles
   STATIC hPenStyles
   STATIC hCapStyles
   STATIC hJoinStyles

   IF Empty( hBrushStyles )
      hBrushStyles := __hbqtStandardHash()
      hPenStyles   := __hbqtStandardHash()
      hCapStyles   := __hbqtStandardHash()
      hJoinStyles  := __hbqtStandardHash()

      hBrushStyles[ "NoBrush"                ] := Qt_NoBrush
      hBrushStyles[ "SolidPattern"           ] := Qt_SolidPattern
      hBrushStyles[ "Dense1Pattern"          ] := Qt_Dense1Pattern
      hBrushStyles[ "Dense2Pattern"          ] := Qt_Dense2Pattern
      hBrushStyles[ "Dense3Pattern"          ] := Qt_Dense3Pattern
      hBrushStyles[ "Dense4Pattern"          ] := Qt_Dense4Pattern
      hBrushStyles[ "Dense5Pattern"          ] := Qt_Dense5Pattern
      hBrushStyles[ "Dense6Pattern"          ] := Qt_Dense6Pattern
      hBrushStyles[ "Dense7Pattern"          ] := Qt_Dense7Pattern
      hBrushStyles[ "HorPattern"             ] := Qt_HorPattern
      hBrushStyles[ "VerPattern"             ] := Qt_VerPattern
      hBrushStyles[ "CrossPattern"           ] := Qt_CrossPattern
      hBrushStyles[ "BDiagPattern"           ] := Qt_BDiagPattern
      hBrushStyles[ "FDiagPattern"           ] := Qt_FDiagPattern
      hBrushStyles[ "DiagCrossPattern"       ] := Qt_DiagCrossPattern
      hBrushStyles[ "LinearGradientPattern"  ] := Qt_LinearGradientPattern
      hBrushStyles[ "ConicalGradientPattern" ] := Qt_ConicalGradientPattern
      hBrushStyles[ "RadialGradientPattern"  ] := Qt_RadialGradientPattern
      hBrushStyles[ "TexturePattern"         ] := Qt_TexturePattern

      hPenStyles[ "NoPen"          ] := Qt_NoPen
      hPenStyles[ "SolidLine"      ] := Qt_SolidLine
      hPenStyles[ "DashLine"       ] := Qt_DashLine
      hPenStyles[ "DotLine"        ] := Qt_DotLine
      hPenStyles[ "DashDotLine"    ] := Qt_DashDotLine
      hPenStyles[ "DashDotDotLine" ] := Qt_DashDotDotLine

      hCapStyles[ "FlatCap"        ] := Qt_FlatCap
      hCapStyles[ "RoundCap"       ] := Qt_RoundCap
      hCapStyles[ "SquareCap"      ] := Qt_SquareCap

      hJoinStyles[ "BevelJoin"     ] := Qt_BevelJoin
      hJoinStyles[ "MiterJoin"     ] := Qt_MiterJoin
      hJoinStyles[ "RoundJoin"     ] := Qt_RoundJoin
      hJoinStyles[ "SvgMiterJoin"  ] := Qt_SvgMiterJoin
   ENDIF

   IF HB_ISSTRING( cnStyleOrValue )
      cStyle := cnStyleOrValue

      SWITCH Lower( cProperty )
      CASE "penstyle"  ; RETURN iif( hb_HHasKey( hPenStyles, cStyle ), hPenStyles[ cStyle ], Qt_SolidLine )
      CASE "capstyle"  ; RETURN iif( hb_HHasKey( hCapStyles, cStyle ), hCapStyles[ cStyle ], Qt_FlatCap )
      CASE "joinstyle" ; RETURN iif( hb_HHasKey( hJoinStyles, cStyle ), hJoinStyles[ cStyle ], Qt_BevelJoin )
      CASE "brushstyle"; RETURN iif( hb_HHasKey( hBrushStyles, cStyle ), hBrushStyles[ cStyle ], Qt_NoBrush )
      ENDSWITCH
   ELSE
      SWITCH Lower( cProperty )
      CASE "penstyle"
         FOR EACH nValue IN hPenStyles
            IF nValue == cnStyleOrValue
               RETURN nValue:__enumKey()
            ENDIF
         NEXT
         EXIT
      CASE "capstyle"
         FOR EACH nValue IN hCapStyles
            IF nValue == cnStyleOrValue
               RETURN nValue:__enumKey()
            ENDIF
         NEXT
         EXIT
      CASE "joinstyle"
         FOR EACH nValue IN hJoinStyles
            IF nValue == cnStyleOrValue
               RETURN nValue:__enumKey()
            ENDIF
         NEXT
         EXIT
      CASE "brushstyle"
         FOR EACH nValue IN hBrushStyles
            IF nValue == cnStyleOrValue
               RETURN nValue:__enumKey()
            ENDIF
         NEXT
         EXIT
      ENDSWITCH
   ENDIF

   RETURN iif( HB_ISSTRING( cnStyleOrValue ), -1, "" )


PROCEDURE __hbqtActivateTimerSingleShot( nMSeconds, bBlock )

   s_timerSingleShot := NIL
   WITH OBJECT s_timerSingleShot := QTimer()
      :setSingleShot( .T. )
      :setInterval( nMSeconds )
      :connect( "timeout()", bBlock )
      :start()
   ENDWITH
   RETURN


FUNCTION __hbqtLayoutWidgetInParent( oWidget, oParent )
   LOCAL oLayout

   IF HB_ISOBJECT( oParent ) .AND. ! ( oParent == __hbqtAppWidget() )
      IF Empty( oLayout := oParent:layout() )
         oLayout := QHBoxLayout()
         oParent:setLayout( oLayout )
         oLayout:addWidget( oWidget )
      ELSE
         SWITCH __objGetClsName( oLayout )
         CASE "QVBOXLAYOUT"
         CASE "QHBOXLAYOUT"
            oLayout:addWidget( oWidget )
            EXIT
         CASE "QGRIDLAYOUT"
            oLayout:addWidget( oWidget, 0, 0, 1, 1 )
            EXIT
         ENDSWITCH
      ENDIF
   ENDIF
   RETURN NIL

//--------------------------------------------------------------------//
//                        HbQt Logging Mechanism
//--------------------------------------------------------------------//

FUNCTION __hbqtLog( xLog )
   IF ! HB_ISOBJECT( s_hbqtLogs )
      s_hbqtLogs := HbQtLogs():new():create( __hbqtAppWidget() )
   ENDIF
   IF HB_ISOBJECT( s_hbqtLogs )
      s_hbqtLogs:logText( __hbqtXtoS( xLog ) )
   ENDIF
   RETURN NIL


FUNCTION __hbqtShowLog()
   IF HB_ISOBJECT( s_hbqtLogs )
      s_hbqtLogs:show()
   ENDIF
   RETURN NIL


FUNCTION __hbqtClearLog()
   IF HB_ISOBJECT( s_hbqtLogs )
      s_hbqtLogs:clear()
   ENDIF
   RETURN NIL

//--------------------------------------------------------------------//
//          Orientation Changes - Detection and Broadcasting
//--------------------------------------------------------------------//

FUNCTION __hbqtRegisterForOrientationChange( bBlock )

   IF HB_ISOBJECT( __hbqtAppWidget() )
      __hbqtAppWidget():connect( QEvent_Resize, {|| __hbqtBroadcastOrientationChanged() } )
   ENDIF
   AAdd( s_aRegisteredBlocksForOrientationChange, bBlock )
   RETURN Len( s_aRegisteredBlocksForOrientationChange )


PROCEDURE __hbqtBroadcastOrientationChanged( nOrientation )
   LOCAL bBlock

   FOR EACH bBlock IN s_aRegisteredBlocksForOrientationChange
      Eval( bBlock, nOrientation )
   NEXT
   RETURN

//--------------------------------------------------------------------//
//                Managed Function Lists for HbQtEditor
//--------------------------------------------------------------------//

STATIC FUNCTION __addInList( hHash, aList )
   LOCAL s

   FOR EACH s IN aList
      s := AllTrim( s )
      IF ! Empty( s )
         hHash[ s ] := s
      ENDIF
   NEXT
   RETURN NIL


PROCEDURE __hbqtStackHarbourFuncList( aFunctions )
   DEFAULT aFunctions TO  __hbqtPullHarbourFunctions( __getHarbourHbx() )
   __addInList( s_hHarbourFuncList, aFunctions )
   RETURN


PROCEDURE __hbqtStackQtFuncList( aFunctions )
   IF Empty( aFunctions )
      __addInList( s_hQtFuncList, __hbqtPullQtFunctions( __getQtCoreFilelist() ) )
      __addInList( s_hQtFuncList, __hbqtPullQtFunctions( __getQtGuiFilelist() ) )
      __addInList( s_hQtFuncList, __hbqtPullQtFunctions( __getQtNetworkFilelist() ) )
   ELSE
      __addInList( s_hQtFuncList, aFunctions )
   ENDIF
   RETURN


PROCEDURE __hbqtStackUserFuncList( aFunctions )
   __addInList( s_hUserFuncList, aFunctions )
   RETURN


FUNCTION __hbqtIsHarbourFunction( cWord, cCased )
   IF hb_HHasKey( s_hHarbourFuncList, cWord )
      cCased := s_hHarbourFuncList[ cWord ]
      RETURN .T.
   ENDIF
   RETURN .F.


FUNCTION __hbqtIsQtFunction( cWord, cCased )      // cCased sent by reference
   IF cWord $ s_hQtFuncList
      cCased := s_hQtFuncList[ cWord ]
      RETURN .T.
   ENDIF
   RETURN .F.


FUNCTION __hbqtIsUserFunction( cWord, cCased )
   IF cWord $ s_hUserFuncList
      cCased := s_hUserFuncList[ cWord ]
      RETURN .T.
   ENDIF
   RETURN .F.


/* Pulled from harbour/bin/find.hb and adopted for file as buffer */
STATIC FUNCTION __hbqtPullHarbourFunctions( cBuffer )
   LOCAL pRegex, tmp
   LOCAL aDynamic := {}

   IF ! Empty( cBuffer ) .AND. ;
      ! Empty( pRegex := hb_regexComp( "^DYNAMIC ([a-zA-Z0-9_]*)$", .T., .T. ) )
      FOR EACH tmp IN hb_regexAll( pRegex, StrTran( cBuffer, Chr( 13 ) ),,,,, .T. )
         AAdd( aDynamic, tmp[ 2 ] )
      NEXT
   ENDIF
   RETURN aDynamic


STATIC FUNCTION __hbqtPullQtFunctions( cBuffer )
   LOCAL pRegex, tmp
   LOCAL aDynamic := {}

   IF ! Empty( cBuffer ) .AND. ;
      ! Empty( pRegex := hb_regexComp( "^([a-zA-Z0-9_]*.qth)$", .T., .T. ) )
      FOR EACH tmp IN hb_regexAll( pRegex, StrTran( cBuffer, Chr( 13 ) ),,,,, .T. )
         AAdd( aDynamic, StrTran( tmp[ 1 ], ".qth" ) )
      NEXT
   ENDIF
   RETURN aDynamic


FUNCTION HbQtOpenFileDialog( cDefaultPath, cTitle, cFilter, lAllowMultiple, lCanCreate, aPos )
   LOCAL oWidget
   LOCAL cFiles := NIL
   LOCAL i, oList, nResult, cPath, cFile, cExt, qFocus, xRes, oFiles, aFilters

   WITH OBJECT oWidget := QFileDialog() // __hbqtAppWidget() )
      :setOption( QFileDialog_DontResolveSymlinks, .t. )
      :setAcceptMode( QFileDialog_AcceptOpen )
   ENDWITH

   DEFAULT lAllowMultiple TO .F.
   IF lAllowMultiple
      oWidget:setFileMode( QFileDialog_ExistingFiles )
   ENDIF
   IF HB_ISSTRING( cTitle )
      oWidget:setWindowTitle( cTitle )
   ENDIF
   IF HB_ISSTRING( cDefaultPath )
      hb_fNameSplit( cDefaultPath, @cPath, @cFile, @cExt )
      oWidget:setDirectory( cPath )
      IF ! Empty( cFile )
         oWidget:selectFile( cFile + cExt )
      ENDIF
   ENDIF

   IF Empty( cFilter )
      oWidget:setNameFilter( "All Files (*)" )
   ELSE
      aFilters := hb_ATokens( cFilter, ";" )
      oList := QStringList()
      FOR i := 1 TO Len( aFilters )
         oList:append( aFilters[ i ] )
      NEXT
      oWidget:setNameFilters( oList )
   ENDIF

   DEFAULT lCanCreate TO .F.
   IF ! lCanCreate
      oWidget:setOption( QFileDialog_ReadOnly, .T. )
   ENDIF

   IF HB_ISARRAY( aPos )
      oWidget:move( aPos[ 1 ], aPos[ 2 ] )
   ENDIF

   qFocus := QApplication():focusWidget()
   nResult := oWidget:exec()
   IF HB_ISOBJECT( qFocus )
      qFocus:setFocus( 0 )
   ENDIF

   IF nResult == QDialog_Accepted
      xRes := {}
      oFiles := oWidget:selectedFiles()
      FOR i := 1 TO oFiles:size()
         AAdd( xRes, oFiles:at( i-1 ) )
      NEXT
      IF ! lAllowMultiple
         xRes := xRes[ 1 ]
      ENDIF
   ENDIF

   oWidget:setParent( QWidget() )
   oWidget := NIL
   RETURN xRes


FUNCTION __hbqtTreeFindNode( oNode, cText )
   LOCAL i, oChild

   IF oNode:text( 0 ) == cText
      RETURN oNode
   ELSE
      FOR i := 0 TO oNode:childCount() - 1
         IF ! Empty( oChild := __hbqtTreeFindNode( oNode:child( i ), cText ) )
            RETURN oChild
         ENDIF
      NEXT
   ENDIF
   RETURN NIL


FUNCTION __hbqtTreeCollapseAll( oNode, lDirectChildrenOnly )
   LOCAL i

   DEFAULT lDirectChildrenOnly TO .F.

   FOR i := 0 TO oNode:childCount() - 1
      IF lDirectChildrenOnly
         oNode:child( i ):setExpanded( .F. )
      ELSE
         __hbqtTreeCollapseAll( oNode:child( i ) )
      ENDIF
   NEXT
   oNode:setExpanded( .F. )
   RETURN NIL


FUNCTION __hbqtTreeExpandAll( oNode, lDirectChildrenOnly )
   LOCAL i

   DEFAULT lDirectChildrenOnly TO .F.

   FOR i := 0 TO oNode:childCount() - 1
      IF lDirectChildrenOnly
         oNode:child( i ):setExpanded( .T. )
      ELSE
         __hbqtTreeExpandAll( oNode:child( i ) )
      ENDIF
   NEXT
   oNode:setExpanded( .T. )
   RETURN NIL


FUNCTION __hbqtExecPopup( aOptions, oPoint )
   LOCAL i, oMenu, oAct, cAct

   oMenu := QMenu()

   FOR i := 1 TO Len( aOptions )
      IF Empty( aOptions[ i ] )
         oMenu:addSeparator()
      ELSE
         oMenu:addAction( aOptions[ i ] )
      ENDIF
   NEXT
   IF __objGetClsName( oAct := oMenu:exec( oPoint ) ) == "QACTION"
      cAct := oAct:text()
   ENDIF
   RETURN cAct

//--------------------------------------------------------------------//

FUNCTION __hbqtAProcessUniqueEx( aData, ele_, add_, opr_, bFor )
   LOCAL d_, dd_
   LOCAL dat_:= {}

   dd_:= __aSortEle( AClone( aData ), ele_ )

   FOR EACH d_ IN dd_
      IF Eval( bFor, d_ )
         AAdd( dat_, d_ )
      ENDIF
   NEXT
   IF ! Empty( dat_ )
      dat_:= __hbqtAProcessUnique( dat_, ele_, add_, opr_ )
   ENDIF
   RETURN dat_


FUNCTION __hbqtAProcessUnique( dat_, ele_, nAdd_, aOpr_ )
   LOCAL i, v, v1, d_, nCounter
   LOCAL v_:= {}
   LOCAL dd_:= {}
   LOCAL sum_:= AFill( Array( Len( nAdd_ ) ), 0 )

   d_:= __aSortEle( AClone( dat_ ), ele_ )

   AEval( ele_, {|e| AAdd( v_, d_[ 1, e ] ) } )
   v := __aIndexCmp( v_ )
   nCounter := 0
   FOR i := 1 TO Len( d_ )
      v_:= {}
      AEval( ele_, {|e| AAdd( v_, d_[ i, e ] ) } )
      IF ! ( v == ( v1 := __aIndexCmp( v_ ) ) )
         __aAdjustForAvg( sum_, nCounter, aOpr_ )
         AAdd( dd_, d_[ i - 1 ] )
         AEval( nAdd_, {|e, j| dd_[ Len( dd_ ), e ] := sum_[ j ] } )
         sum_:= AFill( sum_, 0 )
         v := v1
         nCounter := 0
      ENDIF
      nCounter++
      __aApplyOperation( nAdd_, sum_, d_[ i ], nCounter, aOpr_ )
   NEXT
   __aAdjustForAvg( sum_, nCounter, aOpr_ )
   AAdd( dd_, d_[ i - 1 ] )
   AEval( nAdd_, {|e, j| dd_[ Len( dd_ ), e ] := sum_[ j ] } )
   RETURN dd_


STATIC FUNCTION __aAdjustForAvg( sum_, nCounter, aOpr_ )
   LOCAL j
   FOR j := 1 TO Len( aOpr_ )
      IF aOpr_[ j ] == "AVG"
         sum_[ j ] := sum_[ j ] / nCounter
      ENDIF
   NEXT
   RETURN NIL


STATIC FUNCTION __aApplyOperation( nAdd_, sum_, d_, nCounter, aOpr_ )
   LOCAL j

   FOR j := 1 TO Len( aOpr_ )
      SWITCH aOpr_[ j ]
      CASE "COUNT"
      CASE "SUM"
      CASE "AVG"
         sum_[ j ] += d_[ nAdd_[ j ] ]
         EXIT
      CASE "MIN"
         sum_[ j ] := iif( nCounter == 1, d_[ nAdd_[ j ] ], Min( sum_[ j ], d_[ nAdd_[ j ] ] ) )
         EXIT
      CASE "MAX"
         sum_[ j ] := Max( sum_[ j ], d_[ nAdd_[ j ] ] )
         EXIT
      ENDSWITCH
   NEXT
   RETURN NIL


STATIC FUNCTION __aSortEle( ddd_, ele_ )
   LOCAL i, s, j, k
   LOCAL dum_:= {}
   LOCAL dat_:= {}
   LOCAL nRecs := Len( ddd_ )
   LOCAL nEle := Len( ele_ )
   LOCAL typ_:= Array( nEle )

   AEval( ele_, {|e,i| typ_[ i ] := ValType( ddd_[ 1, e ] ) } )

   FOR i := 1 TO nRecs
       s := ""
       FOR j := 1 TO nEle
          k := ele_[ j ]
          SWITCH typ_[ j ]
          CASE "C" ; s += ddd_[ i, k ] ; EXIT
          CASE "D" ; s += DToS( ddd_[ i, k ] ) ; EXIT
          CASE "N" ; s += Str( ddd_[ i, k ], 17, 4 ) ; EXIT
          CASE "L" ; s += iif( ddd_[ i, k ], "T", "F" ) ; EXIT
          ENDSWITCH
       NEXT
       AAdd( dum_, { s, i } )
   NEXT

   ASort( dum_, NIL, NIL, {|e_, f_| e_[ 1 ] < f_[ 1 ] } )

   FOR i := 1 TO Len( dum_ )
      AAdd( dat_, ddd_[ dum_[ i, 2 ] ] )
   NEXT
   RETURN dat_


STATIC FUNCTION __aIndexCmp( a_ )
   LOCAL i
   LOCAL s := ''
   FOR i := 1 TO Len( a_ )
      s := __aIndexKey( s, a_[ i ] )
   NEXT
   RETURN s


STATIC FUNCTION __aIndexKey( s, v )
   SWITCH ValType( v )
   CASE "C" ; RETURN s += v
   CASE "N" ; RETURN s += Str( v, 17, 4 )
   CASE "D" ; RETURN s += DToS( v )
   CASE "L" ; RETURN s += iif( v, "T", "F" )
   ENDSWITCH
   RETURN s


FUNCTION __hbqtV( cVrb, xValue )
   LOCAL l_xValue

   STATIC hVrb := NIL
   IF hVrb == NIL
      hVrb := {=>}
      hb_HCaseMatch( hVrb, .F. )
   ENDIF
   IF HB_ISSTRING( cVrb )
      IF hb_HHasKey( hVrb, cVrb )
         l_xValue := hVrb[ cVrb ]
      ENDIF
      IF ! xValue == NIL
         hVrb[ cVrb ] := xValue
      ENDIF
   ENDIF
   RETURN l_xValue


FUNCTION __hbqtHashPullValue( hHash, cKey, xDefault )
   LOCAL xTmp, xTmp1, xRet

   IF HB_ISHASH( hHash )
      IF hb_HHasKey( hHash, cKey )
         RETURN hHash[ cKey ]
      ELSE
         FOR EACH xTmp IN hHash
            IF HB_ISHASH( xTmp )
               IF ! ( xRet := __hbqtHashPullValue( xTmp, cKey ) ) == NIL
                  RETURN xRet
               ENDIF
            ELSEIF HB_ISARRAY( xTmp )
               FOR EACH xTmp1 IN xTmp
                  IF HB_ISHASH( xTmp1 )
                     IF ! ( xRet := __hbqtHashPullValue( xTmp1, cKey ) ) == NIL
                        RETURN xRet
                     ENDIF
                  ENDIF
               NEXT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   RETURN xDefault


FUNCTION HbQtSetLogChannel( cLogFile, lPushAsDebugString )
   STATIC s_lPushAsDebugString := .F.
   STATIC s_cLogFile := ""
   LOCAL l_lPushAsDebugString := s_lPushAsDebugString
   LOCAL l_cLogFile := s_cLogFile

   IF PCount() > 0
      IF HB_ISLOGICAL( lPushAsDebugString )
         s_lPushAsDebugString := lPushAsDebugString
      ENDIF
      IF HB_ISSTRING( cLogFile ) .AND. ! Empty( cLogFile )
         s_cLogFile := cLogFile
      ENDIF
   ENDIF
   RETURN hb_Hash( "LogFile", l_cLogFile, "AsDebugString", l_lPushAsDebugString )


PROCEDURE HbQtLogAdd( ... )
   LOCAL xParam, nHandle, cExe, cFileName, s
   LOCAL hLog := HbQtSetLogChannel()

   cFileName := hLog[ "LogFile" ]

   s := ""
   FOR EACH xParam IN hb_AParams()
      SWITCH ValType( xParam )
      CASE "M"
      CASE "C" ; s += xParam                                 ; EXIT
      CASE "N" ; s += hb_ntos( xParam )                      ; EXIT
      CASE "L" ; s += iif( xParam, "TRUE", "FALSE" )         ; EXIT
      CASE "D" ; s += DToC( xParam )                         ; EXIT
      CASE "B" ; s += "{|| ... }"                            ; EXIT
      CASE "A" ; s += "{ " + hb_ntos( Len( xParam ) ) + " }" ; EXIT
      CASE "H" ; s += hb_jsonEncode( xParam, .T. )           ; EXIT
      CASE "O" ; s += "Object:" + xParam:className()         ; EXIT
      CASE "P" ; s += hb_ValToStr( xParam )                  ; EXIT
      CASE "S" ; s += hb_ValToStr( xParam )                  ; EXIT
      OTHERWISE
         s += "Unknown:" + ValType( xParam )
      ENDSWITCH
      s += "   "
   NEXT
   IF ! Empty( s )
      hb_FNameSplit( hb_ProgName(), , @cExe )
      s := ".     ." + DToC( Date() ) + "   " + Time() + "   " + Str( Seconds(), 9, 3 ) + "   " + cExe + "   " + ;
           ProcName( 1 ) + "   " + hb_ntos( ProcLine( 1 ) ) + hb_eol() + s + hb_eol()
   ENDIF
   IF ! Empty( s ) .AND. hLog[ "AsDebugString" ]
#ifndef __LINUX__
#ifndef __ANDROID__
      WAPI_OutputDebugString( s )
#endif
#endif
   ENDIF
   IF ! Empty( s ) .AND. ! Empty( cFileName )
      IF ( nHandle := FOpen( cFileName, FO_WRITE + FO_DENYNONE ) ) == F_ERROR
         nHandle := FCreate( cFileName, FC_NORMAL )
      ENDIF
      IF ! nHandle == F_ERROR
         fSeek( nHandle, 0, FS_END )
         fWrite( nHandle, s, Len( s ) )
         fClose( nHandle )
      ENDIF
   ENDIF
   RETURN

// Mindaugus - hbhttpd
//
FUNCTION HbQtGetErrorDesc( oErr )
   LOCAL cRet, nI, cI, aPar, nJ, xI

   cRet := "============================= ERRORLOG =============================" + hb_eol() + ;
      "Error      : " + oErr:subsystem + "/" + ErrDescCode( oErr:genCode ) + "(" + hb_ntos( oErr:genCode ) + ") " + ;
                                                                                   hb_ntos( oErr:subcode ) + hb_eol()
   IF ! Empty( oErr:filename );      cRet += "File       : " + oErr:filename + hb_eol()
   ENDIF
   IF ! Empty( oErr:description );   cRet += "Description: " + oErr:description + hb_eol()
   ENDIF
   IF ! Empty( oErr:operation );     cRet += "Operation  : " + oErr:operation + hb_eol()
   ENDIF
   IF ! Empty( oErr:osCode );        cRet += "OS error   : " + hb_ntos( oErr:osCode ) + hb_eol()
   ENDIF
   IF HB_ISARRAY( oErr:args )
      cRet += "Arguments  : " + hb_eol()
      AEval( oErr:args, {| X, Y | cRet += Str( Y, 3 ) + "        : " + hb_CStr( X ) + hb_eol() } )
   ENDIF
   cRet += hb_eol()

   cRet += "Stack      : " + hb_eol()
   nI := 2
#if 0
   DO WHILE ! Empty( ProcName( ++nI ) )
      cRet += "  " + ProcName( nI ) + "(" + hb_ntos( ProcLine( nI ) ) + ")" + hb_eol()
   ENDDO
#else
   DO WHILE ! Empty( ProcName( ++nI ) )
      cI := "  " + ProcName( nI ) + "(" + hb_ntos( ProcLine( nI ) ) + ")"
      cI := PadR( cI, Max( 32, Len( cI ) + 1 ) )
      cI += "("
      aPar := __dbgVMParLList( nI )
      FOR nJ := 1 TO Len( aPar )
         cI += cvt2str( aPar[ nJ ] )
         IF nJ < Len( aPar )
            cI += ", "
         ENDIF
      NEXT
      cI += ")"
      nJ := Len( aPar )
      DO WHILE ! HB_ISSYMBOL( xI := __dbgVMVarLGet( nI, ++nJ ) )
         cI += ", " + cvt2str( xI )
      ENDDO
      xI := NIL
      cRet += cI + hb_eol()
   ENDDO
#endif
   cRet += hb_eol()

   cRet += "Executable : " + hb_ProgName() + hb_eol()
   cRet += "Versions   : " + hb_eol()
   cRet += "  OS       : " + OS() + hb_eol()
   cRet += "  Harbour  : " + Version() + ", " + hb_BuildDate() + hb_eol()
   cRet += hb_eol()

   IF oErr:genCode != EG_MEM
      cRet += "DB Areas   : " + hb_eol()
      cRet += "  Current  : " + hb_ntos( Select() ) + "  " + Alias() + hb_eol()

      BEGIN SEQUENCE WITH {| o | Break( o ) }
         IF Used()
            cRet += "  Filter   : " + dbFilter() + hb_eol()
            cRet += "  Relation : " + dbRelation() + hb_eol()
            cRet += "  IndexExp : " + ordKey( ordSetFocus() ) + hb_eol()
            cRet += hb_eol()
            BEGIN SEQUENCE WITH {| o | Break( o ) }
               FOR nI := 1 TO FCount()
                  cRet += Str( nI, 6 ) + " " + PadR( FieldName( nI ), 14 ) + ": " + hb_ValToExp( FieldGet( nI ) ) + hb_eol()
               NEXT
            RECOVER
               cRet += "!!! Error reading database fields !!!" + hb_eol()
            END SEQUENCE
            cRet += hb_eol()
         ENDIF
      RECOVER
         cRet += "!!! Error accessing current workarea !!!" + hb_eol()
      END SEQUENCE

      FOR nI := 1 TO 250
         BEGIN SEQUENCE WITH {| o | Break( o ) }
            IF Used()
               dbSelectArea( nI )
               cRet += Str( nI, 3 ) + " " + rddName() + " " + PadR( Alias(), 15 ) + ;
                  Str( RecNo() ) + "/" + Str( LastRec() ) + ;
                  iif( Empty( ordSetFocus() ), "", " Index " + ordSetFocus() + "(" + hb_ntos( ordNumber() ) + ")" ) + hb_eol()
               dbCloseArea()
            ENDIF
         RECOVER
            cRet += "!!! Error accessing workarea number: " + Str( nI, 4 ) + "!!!" + hb_eol()
         END SEQUENCE
      NEXT
      cRet += hb_eol()
   ENDIF
   RETURN cRet


STATIC FUNCTION ErrDescCode( nCode )
   LOCAL cI := NIL

   IF nCode > 0 .AND. nCode <= 41
      cI := { ;
         "ARG"     , "BOUND"    , "STROVERFLOW", "NUMOVERFLOW", "ZERODIV" , "NUMERR"     , "SYNTAX"  , "COMPLEXITY" , ; //  1,  2,  3,  4,  5,  6,  7,  8
         NIL       , NIL        , "MEM"        , "NOFUNC"     , "NOMETHOD", "NOVAR"      , "NOALIAS" , "NOVARMETHOD", ; //  9, 10, 11, 12, 13, 14, 15, 16
         "BADALIAS", "DUPALIAS" , NIL          , "CREATE"     , "OPEN"    , "CLOSE"      , "READ"    , "WRITE"      , ; // 17, 18, 19, 20, 21, 22, 23, 24
         "PRINT"   , NIL        , NIL          , NIL          , NIL       , "UNSUPPORTED", "LIMIT"   , "CORRUPTION" , ; // 25, 26 - 29, 30, 31, 32
         "DATATYPE", "DATAWIDTH", "NOTABLE"    , "NOORDER"    , "SHARED"  , "UNLOCKED"   , "READONLY", "APPENDLOCK" , ; // 33, 34, 35, 36, 37, 38, 39, 40
         "LOCK"    }[ nCode ]                                                                                           // 41
   ENDIF
   RETURN iif( cI == NIL, "", "EG_" + cI )


STATIC FUNCTION cvt2str( xI, lLong )
   LOCAL cValtype, cI, xJ

   cValtype := ValType( xI )
   lLong := ! Empty( lLong )
   IF cValtype == "U"
      RETURN iif( lLong, "[U]:NIL", "NIL" )
   ELSEIF cValtype == "N"
      RETURN iif( lLong, "[N]:" + Str( xI ), hb_ntos( xI ) )
   ELSEIF cValtype $ "CM"
      IF Len( xI ) <= 260
         RETURN iif( lLong, "[" + cValtype + hb_ntos( Len( xI ) ) + "]:", "" ) + '"' + xI + '"'
      ELSE
         RETURN iif( lLong, "[" + cValtype + hb_ntos( Len( xI ) ) + "]:", "" ) + '"' + Left( xI, 100 ) + '"...'
      ENDIF
   ELSEIF cValtype == "A"
      RETURN "[A" + hb_ntos( Len( xI ) ) + "]"
   ELSEIF cValtype == "H"
      RETURN "[H" + hb_ntos( Len( xI ) ) + "]"
   ELSEIF cValtype == "O"
      cI := ""
      IF __objHasMsg( xI, "ID" )
         xJ := xI:ID
         IF ! HB_ISOBJECT( xJ )
            cI += ",ID=" + cvt2str( xJ )
         ENDIF
      ENDIF
      IF __objHasMsg( xI, "nID" )
         xJ := xI:nID
         IF ! HB_ISOBJECT( xJ )
            cI += ",NID=" + cvt2str( xJ )
         ENDIF
      ENDIF
      IF __objHasMsg( xI, "xValue" )
         xJ := xI:xValue
         IF ! HB_ISOBJECT( xJ )
            cI += ",XVALUE=" + cvt2str( xJ )
         ENDIF
      ENDIF
      RETURN "[O:" + xI:ClassName() + cI + "]"
   ELSEIF cValtype == "D"
      RETURN iif( lLong, "[D]:", "" ) + DToC( xI )
   ELSEIF cValtype == "L"
      RETURN iif( lLong, "[L]:", "" ) + iif( xI, ".T.", ".F." )
   ELSEIF cValtype == "P"
      RETURN iif( lLong, "[P]:", "" ) + "0p" + hb_NumToHex( xI )
   ELSE
      RETURN "[" + cValtype + "]" // BS,etc
   ENDIF
   RETURN NIL


FUNCTION HbQtLayInParent( oWidget, oParent )
   LOCAL oLayout

   IF HB_ISOBJECT( oParent )
      IF Empty( oLayout := oParent:layout() )
         oLayout := QHBoxLayout()
         oParent:setLayout( oLayout )
         oLayout:addWidget( oWidget )
      ELSE
         SWITCH __objGetClsName( oLayout )
         CASE "QVBOXLAYOUT"
         CASE "QHBOXLAYOUT"
            oLayout:addWidget( oWidget )
            EXIT
         CASE "QGRIDLAYOUT"
            oLayout:addWidget( oWidget, 0, 0, 1, 1 )
            EXIT
         ENDSWITCH
      ENDIF
   ENDIF
   RETURN NIL

//--------------------------------------------------------------------//
//           This Section Must be the Last in this Source
//--------------------------------------------------------------------//

#pragma -km+

STATIC FUNCTION __getHarbourHbx()
   #pragma __binarystreaminclude "harbour.hbx" | RETURN %s

FUNCTION __getQtCoreFilelist()
   #pragma __binarystreaminclude "../hbqt/qtcore/qth/filelist.hbm" | RETURN %s

FUNCTION __getQtGuiFilelist()
   #pragma __binarystreaminclude "../hbqt/qtgui/qth/filelist.hbm" | RETURN %s

FUNCTION __getQtNetworkFilelist()
   #pragma __binarystreaminclude "../hbqt/qtnetwork/qth/filelist.hbm" | RETURN %s

