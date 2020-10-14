/*
 * $Id: changelog.prg 411 2015-06-17 00:43:27Z bedipritpal $
 */

/*
 * Copyright 2011-2015 Pritpal Bedi <bedipritpal@hotmail.com>
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
 *                               25May2011
 */
/*----------------------------------------------------------------------*/

#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"


#define __editChangelog_textChanged__            2001
#define __editUser_textChanged__                 2002
#define __buttonOpen_clicked__                   2003
#define __buttonNew_clicked__                    2004
#define __buttonTitle_clicked__                  2005
#define __buttonSource_clicked__                 2006
#define __buttonDesc_clicked__                   2007
#define __buttonSrcDesc_clicked__                2008
#define __buttonClearDesc_clicked__              2009
#define __buttonCancel_clicked__                 2010
#define __buttonSave_clicked__                   2011


CLASS IdeChangeLog INHERIT IdeObject

   DATA   nCntr                                   INIT 0
   DATA   qHiliter
   DATA   oEdit
   DATA   qEdit
   DATA   oTheme

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD show()
   METHOD execEvent( nEvent, p )
   METHOD updateLog()
   METHOD refresh()
   METHOD addToLog( aLog )
   METHOD getLogEntry()
   METHOD buildLogEntry()

   ENDCLASS


METHOD IdeChangeLog:new( oIde )
   ::oIde := oIde
   RETURN Self


METHOD IdeChangeLog:create( oIde )
   DEFAULT oIde TO ::oIde
   ::oIde := oIde
   RETURN Self


METHOD IdeChangeLog:destroy()
   IF !empty( ::oUI )
      ::oUI:buttonNew   :disconnect( "clicked()" )
      ::oUI:destroy()
   ENDIF
   RETURN Self


METHOD IdeChangeLog:show()

   IF empty( ::oUI )
      ::oUI := hbide_getUI( "changelog", ::oDlg:oWidget )
      ::oUI:setWindowFlags( Qt_Sheet )
      ::oUI:setWindowIcon( QIcon( hbide_image( "hbide" ) ) )

      ::oUI:buttonOpen      :setIcon( QIcon( hbide_image( "dc_folder" ) ) )
      ::oUI:buttonNew       :setIcon( QIcon( hbide_image( "new"       ) ) )
      ::oUI:buttonTitle     :setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
      ::oUI:buttonSource    :setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
      ::oUI:buttonDesc      :setIcon( QIcon( hbide_image( "dc_plus"   ) ) )
      ::oUI:buttonSrcDesc   :setIcon( QIcon( hbide_image( "dc_plus"   ) ) )

      ::oUI:buttonOpen      :setToolTip( "Open a ChangeLog"       )
      ::oUI:buttonNew       :setToolTip( "Create Empty ChangeLog" )
      ::oUI:buttonTitle     :setToolTip( "Add Title in current entry" )
      ::oUI:buttonSource    :setToolTip( "Add Source in current entry" )
      ::oUI:buttonDesc      :setToolTip( "Add Action_Description in current entry" )
      ::oUI:buttonSrcDesc   :setToolTip( "Add Source_Action_Description in current entry" )

      ::oUI:buttonOpen      :connect( "clicked()", {|| ::execEvent( __buttonOpen_clicked__      ) } )
      ::oUI:buttonNew       :connect( "clicked()", {|| ::execEvent( __buttonNew_clicked__       ) } )

      ::oUI:buttonTitle     :connect( "clicked()", {|| ::execEvent( __buttonTitle_clicked__     ) } )
      ::oUI:buttonSource    :connect( "clicked()", {|| ::execEvent( __buttonSource_clicked__    ) } )
      ::oUI:buttonDesc      :connect( "clicked()", {|| ::execEvent( __buttonDesc_clicked__      ) } )
      ::oUI:buttonSrcDesc   :connect( "clicked()", {|| ::execEvent( __buttonSrcDesc_clicked__   ) } )
      ::oUI:buttonClearDesc :connect( "clicked()", {|| ::execEvent( __buttonClearDesc_clicked__ ) } )

      ::oUI:buttonCancel    :connect( "clicked()", {|| ::execEvent( __buttonCancel_clicked__    ) } )
      ::oUI:buttonSave      :connect( "clicked()", {|| ::execEvent( __buttonSave_clicked__      ) } )

      ::oUI:editChangelog   :connect( "textChanged(QString)", {|p| ::execEvent( __editChangelog_textChanged__, p ) } )
      ::oUI:editUser        :connect( "textChanged(QString)", {|p| ::execEvent( __editUser_textChanged__     , p ) } )

      ::oUI:comboAction     :addItem( "! Fixed  : " )
      ::oUI:comboAction     :addItem( "* Changed: " )
      ::oUI:comboAction     :addItem( "% Optimzd: " )
      ::oUI:comboAction     :addItem( "+ Added  : " )
      ::oUI:comboAction     :addItem( "- Removed: " )
      ::oUI:comboAction     :addItem( "; Comment: " )
      ::oUI:comboAction     :addItem( "@ TODO   : " )
      ::oUI:comboAction     :addItem( "| Moved  : " )

      IF empty( ::oINI:cUserChangeLog )
         ::oINI:cUserChangeLog := hbide_fetchAString( ::oDlg:oWidget, ::oINI:cUserChangeLog, , "Developer Name" )
      ENDIF

      aeval( ::oINI:aLogTitle  , {|e| ::oUI:comboTitle:insertItem( 0,e ) } )
      aeval( ::oINI:aLogSources, {|e| ::oUI:comboSources:insertItem( 0,e ) } )

      ::oUI:comboTitle:setCurrentIndex( -1 )
      ::oUI:comboSources:setCurrentIndex( -1 )

      ::oUI:plainChangelog  :setFont( ::oFont:oWidget )
      ::oUI:plainLogEntry   :setFont( ::oFont:oWidget )
      ::oUI:plainCurrentLog :setFont( ::oFont:oWidget )

      ::oUI:plainLogEntry   :ensureCursorVisible()

      ::oUI:editUser:setText( ::oINI:cUserChangeLog )
      ::oUI:setWindowTitle( "Manage ChangeLog(s)" )

      ::oEdit := HbQtEditor():new()
      ::qEdit := ::oUI:plainChangelog
      ::oEdit:qEdit := ::qEdit
      ::oEdit:create()

      ::qEdit:setFocusPolicy( Qt_NoFocus )
      ::qEdit:hbHorzRulerVisible( .f. )

      ::oTheme := IdeThemes():new( ::oIde ):create()
      ::qHiliter := ::oTheme:setSyntaxHilighting( ::qEdit, , .t., .t. )
      ::qHiliter:hbSetType( 1 )

      ::oUI:editChangelog:setText( ::oINI:cChangeLog )

      ::oUI:oWidget:connect( QEvent_Close, {|| ::oIde:oINI:cChangelogDialogGeometry := hbide_posAndSize( ::oUI:oWidget ) } )
   ENDIF

   ::oIde:setPosAndSizeByIniEx( ::oUI:oWidget, ::oINI:cChangelogDialogGeometry )
   ::oUI:show()
   RETURN Self


STATIC FUNCTION hbide_eol()
   RETURN hb_eol()


STATIC FUNCTION hbide_getLogCounter( cBuffer )
   LOCAL n, n1, nCntr := 0

   IF ( n := at( "$<", cBuffer ) ) > 0
      n1 := at( ">", cBuffer )
      nCntr := val( substr( cBuffer, n + 2, n1 - n - 2 ) )
   ENDIF
   RETURN nCntr + 1


METHOD IdeChangeLog:execEvent( nEvent, p )
   LOCAL cTmp, cTmp1, s, n

   HB_SYMBOL_UNUSED( p )

   IF ::lQuitting
      RETURN Self
   ENDIF

   SWITCH nEvent

   CASE __buttonTitle_clicked__
      IF ! empty( cTmp := ::oUI:comboTitle:currentText() )
         ::addToLog( { "Title", cTmp, "" } )
         ::refresh()
         IF ascan( ::oINI:aLogTitle, {|e| upper( e ) == upper( cTmp ) } ) == 0
            aadd( ::oINI:aLogTitle, cTmp )
            ::oUI:comboTitle:insertItem( 0,cTmp )
         ENDIF
      ENDIF
      EXIT
   CASE __buttonSource_clicked__
      IF ! empty( cTmp := ::oUI:comboSources:currentText() )
         ::addToLog( { "Source", cTmp, "" } )
         ::refresh()
         IF ascan( ::oINI:aLogSources, {|e| upper( e ) == upper( cTmp ) } ) == 0
            aadd( ::oINI:aLogSources, cTmp )
            ::oUI:comboSources:insertItem( 0,cTmp )
         ENDIF
      ENDIF
      EXIT
   CASE __buttonDesc_clicked__
      IF ! empty( cTmp := ::oUI:plainCurrentLog:toPlainText() )
         ::addToLog( { "Desc", ::oUI:comboAction:currentText(), cTmp } )
         ::oUI:plainCurrentLog:clear()
         ::refresh()
      ENDIF
      EXIT
   CASE __buttonSrcDesc_clicked__
      IF ! empty( cTmp := ::oUI:comboSources:currentText() )
         ::addToLog( { "Source", cTmp, "" } )
      ENDIF
      IF ! empty( cTmp := ::oUI:plainCurrentLog:toPlainText() )
         ::addToLog( { "Desc", ::oUI:comboAction:currentText(), cTmp } )
         ::oUI:plainCurrentLog:clear()
      ENDIF
      ::refresh()
      EXIT
   CASE __buttonClearDesc_clicked__
      ::oUI:plainCurrentLog:clear()
      EXIT
   CASE __buttonSave_clicked__
      IF ! empty( cTmp := ::buildLogEntry() )
         cTmp1 := hb_memoread( ::oINI:cChangeLog )
         ::nCntr := hbide_getLogCounter( cTmp1 )
         s := "$<" + strzero( ::nCntr, 6 ) + "> " + hbide_dtosFmt() + " " + left( time(), 5 ) + " " + ::oINI:cUserChangeLog

         IF ( n := at( "$<", cTmp1 ) ) > 0
            //cTmp1 := substr( cTmp1, 1, n - 1 ) + s + hbide_eol() + cTmp + hbide_eol() + substr( cTmp1, n )
            cTmp1 := substr( cTmp1, 1, n - 1 ) + s + hbide_eol() + cTmp + substr( cTmp1, n )
         ELSE
            cTmp1 += hbide_eol() + s + hbide_eol() + cTmp1 + hbide_eol()
         ENDIF
         hb_memowrit( ::oINI:cChangeLog, cTmp1 )  /* TODO: put it under locking protocol */
         ::updateLog()
      ENDIF
      EXIT
   CASE __buttonCancel_clicked__
      ::oUI:plainLogEntry:clear()
      EXIT
   CASE __buttonOpen_clicked__
      cTmp := hbide_fetchAFile( ::oDlg, "Select a ChangeLog File" )
      IF ! empty( cTmp ) .AND. hb_fileExists( cTmp )
         ::oINI:cChangeLog := cTmp
         ::oUI:editChangelog:setText( ::oINI:cChangeLog )
      ENDIF
      EXIT
   CASE __buttonNew_clicked__
      cTmp := hbide_saveAFile( ::oDlg, "New ChangeLog File" )
      IF ! empty( cTmp )
         ::oINI:cChangeLog := cTmp

         s := "" + hbide_eol()
         s += "$<000000> " + hbide_dtosFmt( date() ) + " " + left( time(),5 ) + " hbIDE" + hbide_eol()
         s += "  # Initialized by hbIDE" + hbide_eol()

         hb_memowrit( ::oINI:cChangeLog, s )

         ::oUI:editChangelog:setText( ::oINI:cChangeLog )
      ENDIF
      EXIT
   CASE __editUser_textChanged__
      IF !empty( p )
         ::oINI:cUserChangeLog := p
      ENDIF
      EXIT
   CASE __editChangelog_textChanged__
      IF ! empty( p ) .AND. hb_fileExists( p )
         ::oINI:cChangeLog := p
         ::oUI:editChangelog:setStyleSheet( "" )
         ::updateLog()
      ELSE
         ::oUI:editChangelog:setStyleSheet( "background-color: rgba( 240,120,120,255 );" )
         ::oUI:plainChangelog:clear()
      ENDIF
      EXIT
   ENDSWITCH
   RETURN NIL


METHOD IdeChangeLog:updateLog()

   ::oUI:plainLogEntry:clear()
   ::oUI:plainCurrentLog:clear()
   ::oUI:plainChangelog:clear()

   ::oUI:plainChangelog:setPlainText( hb_memoread( ::oINI:cChangeLog ) )

   ::refresh()
   RETURN Self


STATIC FUNCTION hbide_dtosFmt( dDate )
   LOCAL s

   DEFAULT dDate TO date()
   s := dtos( dDate )
   RETURN substr( s, 1, 4 ) + "-" + substr( s, 5, 2 ) + "-" + substr( s, 7, 2 )


METHOD IdeChangeLog:refresh()
   RETURN Self


METHOD IdeChangeLog:addToLog( aLog )
   LOCAL k, e
   LOCAL a_:= ::getLogEntry()

   DO CASE
   CASE aLog[ 1 ] == "Title"
      aadd( a_, "  # " + aLog[ 2 ] )
   CASE aLog[ 1 ] == "Source"
      aadd( a_, "  * " + aLog[ 2 ] )
   CASE aLog[ 1 ] == "Desc"
      k := hbide_memoToArray( aLog[ 3 ] )
      FOR EACH e IN k
         IF e:__enumIndex() == 1
            aadd( a_, "    " + aLog[ 2 ] + e )
         ELSE
            aadd( a_, "    " + space( 11 ) + e )
         ENDIF
      NEXT
   ENDCASE

   ::oUI:plainLogEntry:setPlainText( hbide_arrayToMemo( a_ ) )
   QApplication():sendEvent( ::oUI:plainLogEntry, QKeyEvent( QEvent_KeyPress, Qt_Key_End, Qt_ControlModifier ) )
   RETURN Self


METHOD IdeChangeLog:getLogEntry()
   LOCAL e, n, f, s_:={}, lHandelled
   LOCAL a_:= hbide_memoToArray( ::oUI:plainLogEntry:toPlainText() )

   FOR EACH e IN a_
      lHandelled := .f.
      f := ltrim( e )

      SWITCH left( f, 1 )
      CASE "#"
         aadd( s_, "  " + f )
         lHandelled := .t.
         EXIT
      CASE "*"
         IF substr( f,3,7 ) == "Changed"
            aadd( s_, "    " + f )
         ELSE
            aadd( s_, "  " + f )
         ENDIF
         lHandelled := .t.
         EXIT
      CASE "!"
         IF substr( f,3,5 ) == "Fixed"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE "%"
         IF substr( f,3,7 ) == "Optimzd"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE "+"
         IF substr( f,3,5 ) == "Added"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE "-"
         IF substr( f,3,7 ) == "Removed"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE ";"
         IF substr( f,3,7 ) == "Comment"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE "@"
         IF substr( f,3,4 ) == "TODO"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      CASE "|"
         IF substr( f,3,5 ) == "Moved"
            aadd( s_, "    " + f )
            lHandelled := .t.
         ENDIF
         EXIT
      ENDSWITCH

      IF ! lHandelled
         n := hbide_howManyPreSpaces( e )
         IF n >= 15
            aadd( s_, e )
         ELSE
            aadd( s_, space( 15 ) + f )
         ENDIF
      ENDIF
   NEXT
   RETURN s_


METHOD IdeChangeLog:buildLogEntry()
   RETURN hbide_arrayToMemo( ::getLogEntry() )


STATIC FUNCTION hbide_howManyPreSpaces( cStr )
   LOCAL i, n := 0

   FOR i := 1 TO Len( cStr )
      IF ! ( substr( cStr, i, 1 ) == " " )
         EXIT
      ENDIF
      n++
   NEXT
   RETURN n

