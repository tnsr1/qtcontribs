/*
 * $Id: hbqt_errorsys.prg 475 2020-02-20 03:07:47Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * The default error handler
 *
 * Copyright 1999 Antonio Linares <alinares@fivetech.com>
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

#include "error.ch"
#include "hbqtgui.ch"


PROCEDURE hbqt_ErrorSys()

   ErrorBlock( {| oError | DefError( oError ) } )

   RETURN


STATIC FUNCTION DefError( oError )
   LOCAL cMessage
   LOCAL cDOSError
   LOCAL aOptions
   LOCAL nChoice
   LOCAL n
   LOCAL cMsg := ""

   // By default, division by zero results in zero
   IF oError:genCode == EG_ZERODIV .AND. ;
      oError:canSubstitute
      RETURN 0
   ENDIF

   // By default, retry on RDD lock error failure */
   IF oError:genCode == EG_LOCK .AND. ;
      oError:canRetry
      // oError:tries++
      RETURN .T.
   ENDIF

   // Set NetErr() of there was a database open error
   IF oError:genCode == EG_OPEN .AND. ;
      oError:osCode == 32 .AND. ;
      oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

   // Set NetErr() if there was a lock error on dbAppend()
   IF oError:genCode == EG_APPENDLOCK .AND. ;
      oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

   cMessage := ErrorMessage( oError )
   IF ! Empty( oError:osCode )
      cDOSError := "(DOS Error " + hb_NToS( oError:osCode ) + ")"
   ENDIF

   // Build buttons

   aOptions := {}

   AAdd( aOptions, "Quit" )

   IF oError:canRetry
      AAdd( aOptions, "Retry" )
   ENDIF

   IF oError:canDefault
      AAdd( aOptions, "Default" )
   ENDIF

   // Show alert box

   nChoice := 0
   #if 0
   DO WHILE nChoice == 0

      IF cDOSError == NIL
         nChoice := Alert( cMessage, aOptions )
      ELSE
         nChoice := Alert( cMessage + ";" + cDOSError, aOptions )
      ENDIF

   ENDDO
   #endif

   IF ! Empty( nChoice )
      SWITCH aOptions[ nChoice ]
      CASE "Break"
         Break( oError )
      CASE "Retry"
         RETURN .T.
      CASE "Default"
         RETURN .F.
      ENDSWITCH
   ENDIF

   // "Quit" selected

   IF cDOSError != NIL
      cMessage += " " + cDOSError
   ENDIF

   cMsg += hb_eol()
   cMsg += cMessage

   n := 1
   DO WHILE ! Empty( ProcName( ++n ) )
      cMsg += hb_eol()
      cMsg += "Called from " + ProcName( n ) + "(" + hb_NToS( ProcLine( n ) ) + ")"
   ENDDO

   nChoice := hbqt_messageBox( cMsg, NIL, "HBQT Runtime Error", QMessageBox_Critical, oError )
   IF nChoice == QMessageBox_Abort
      // this make the difference; break means returns oError object to the recover procedure (CLIPPER)
      // BREAK( oError )
   ELSEIF nChoice == QMessageBox_Retry
      // RETURN .T.
   ELSEIF nChoice == QMessageBox_Ignore
      // RETURN .F.
   ENDIF

   IF hbqt_IsActiveApplication()
      WITH OBJECT QApplication()
         //:closeAllWindows()
         :exit( 0 )
      ENDWITH
   ENDIF

   ErrorLevel( 1 )
   QUIT

   RETURN .F.


STATIC FUNCTION ErrorMessage( oError )
   // start error message
   LOCAL cMessage := iif( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

   // add subsystem name if available
   IF HB_ISSTRING( oError:subsystem )
      cMessage += oError:subsystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code if available
   IF HB_ISNUMERIC( oError:subCode )
      cMessage += "/" + hb_NToS( oError:subCode )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description if available
   IF HB_ISSTRING( oError:description )
      cMessage += "  " + oError:description
   ENDIF

   // add either filename or operation
   DO CASE
   CASE !Empty( oError:filename )
      cMessage += ": " + oError:filename
   CASE !Empty( oError:operation )
      cMessage += ": " + oError:operation
   ENDCASE

   RETURN cMessage


STATIC FUNCTION hbqt_messageBox( cMsg, cInfo, cTitle, nIcon, oError )
   LOCAL oMB, nButtons
   LOCAL nReturn := QMessageBox_Abort

   IF hbqt_IsActiveApplication()

      hb_default( @cTitle, "Information" )
      hb_default( @nIcon, QMessageBox_Information )

      nButtons := QMessageBox_Abort
      IF oError:canRetry
         nButtons := hb_BitOr( nButtons, QMessageBox_Retry )
      ENDIF
      IF oError:canDefault
         nButtons := hb_BitOr( nButtons, QMessageBox_Ignore )
      ENDIF

      WITH OBJECT oMB := QMessageBox()
         :setText( cMsg )
         IF ! Empty( cInfo )
            :setInformativeText( cInfo )
         ENDIF
         :setIcon( nIcon )
         :setWindowTitle( cTitle )
         :setStyleSheet( "background-color: white;" )
         :setStandardButtons( nButtons )
         :setDefaultButton( QMessageBox_Abort )
      END WITH
      nReturn := oMB:exec()
   ENDIF

   RETURN nReturn


#if 0
STATIC PROCEDURE hbqt_messageBox( cMsg, cInfo, cTitle, nIcon, oError )
   LOCAL oMB

   IF hbqt_IsActiveApplication()

      hb_default( @cTitle, "Information" )
      hb_default( @nIcon, QMessageBox_Information )

      oMB := QMessageBox()
      oMB:setText( cMsg )
      IF !empty( cInfo )
         oMB:setInformativeText( cInfo )
      ENDIF
      oMB:setIcon( nIcon )
      oMB:setWindowTitle( cTitle )
      oMB:setStyleSheet( "background-color: white;" )
      oMB:exec()

   ELSE
      #include "hbtrace.ch"
      HB_TRACE( HB_TR_ALWAYS, hb_ValToExp( cMsg ) )
   ENDIF

   RETURN
#endif

