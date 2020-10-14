/*
 * $Id: format.prg 411 2015-06-17 00:43:27Z bedipritpal $
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
 *                               07Jan2011
 */
/*----------------------------------------------------------------------*/

#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"


CLASS IdeFormat INHERIT IdeObject

   DATA   lSelOnly                                INIT .f.
   DATA   oFormat
   DATA   qEdit
   DATA   qLayout
   DATA   qHiliter

   METHOD new( oIde )
   METHOD create( oIde )
   METHOD destroy()
   METHOD show()
   METHOD execEvent( cEvent, p )
   METHOD format( nMode )

   ENDCLASS


METHOD IdeFormat:new( oIde )

   ::oIde := oIde

   RETURN Self


METHOD IdeFormat:create( oIde )

   DEFAULT oIde TO ::oIde
   ::oIde := oIde

   RETURN Self


METHOD IdeFormat:destroy()

   IF !empty( ::oUI )
      ::oUI:btnEditCmnds:disconnect( "clicked()"         )
      ::oUI:btnStart    :disconnect( "clicked()"         )
      ::oUI:btnCancel   :disconnect( "clicked()"         )
      ::oUI:btnUpdSrc   :disconnect( "clicked()"         )
      ::oUI:checkSelOnly:disconnect( "stateChanged(int)" )

      ::qEdit    := NIL
      ::qHiliter := NIL
      ::oFormat  := NIL

      ::oUI:destroy()
   ENDIF

   RETURN Self


METHOD IdeFormat:show()

   IF empty( ::oUI )
      ::oUI := hbide_getUI( "format" )
      ::oFormatDock:oWidget:setWidget( ::oUI:oWidget )

      ::oUI:btnEditCmnds:connect( "clicked()"             , {| | ::execEvent( "buttonEditCmds_clicked"  ) } )
      ::oUI:btnStart    :connect( "clicked()"             , {| | ::execEvent( "buttonStart_clicked"     ) } )
      ::oUI:btnCancel   :connect( "clicked()"             , {| | ::execEvent( "buttonCancel_clicked"    ) } )
      ::oUI:btnUpdSrc   :connect( "clicked()"             , {| | ::execEvent( "buttonUpdSrc_clicked"    ) } )
      ::oUI:checkSelOnly:connect( "stateChanged(int)"     , {|i| ::execEvent( "checkSelOnly_changed", i ) } )

      ::qEdit   := ::oUI:plainFormatter

      ::qEdit:setLineWrapMode( QTextEdit_NoWrap )
      ::qEdit:setFont( ::oIde:oFont:oWidget )
      ::qEdit:ensureCursorVisible()
      ::qEdit:setReadOnly( .t. )
      ::qEdit:setTextInteractionFlags( Qt_TextSelectableByMouse + Qt_TextSelectableByKeyboard )
      ::qHiliter := ::oTH:SetSyntaxHilighting( ::qEdit, "Pritpal's Favourite" )

      ::oFormat := HbFormatCode():new()
   ENDIF

   ::lSelOnly := .f.
   ::oUI:checkSelOnly:setChecked( .f. )
   ::qEdit:clear()

   RETURN Self


METHOD IdeFormat:execEvent( cEvent, p )

   HB_SYMBOL_UNUSED( p )

   IF ::lQuitting
      RETURN Self
   ENDIF

   SWITCH cEvent

   CASE "checkSelOnly_changed"
      ::lSelOnly := p > 0
      EXIT

   CASE "buttonStart_clicked"
      ::format( 1 )
      EXIT

   CASE "buttonUpdSrc_clicked"
      ::format( 2 )
      EXIT

   CASE "buttonCancel_clicked"
      ::oFormatDock:hide()
      EXIT

   CASE "buttonEditCmds_clicked"
      EXIT

   ENDSWITCH

   RETURN NIL


METHOD IdeFormat:format( nMode )
   LOCAL oEdit, aText, cBuffer

   HB_SYMBOL_UNUSED( nMode )

   IF !empty( oEdit := ::oEM:getEditObjectCurrent() )
      IF ::lSelOnly
         cBuffer := oEdit:getSelectedText()
      ELSE
         cBuffer := oEdit:qEdit:toPlainText()
      ENDIF

      aText := hb_aTokens( strtran( cBuffer, chr( 13 ) ), chr( 10 ) )

      #ifdef __PRITPAL__
      IF nMode == 1
         FormatCode( aText, 3 )
      ELSE
         ::oFormat:reFormat( aText )
      ENDIF
      #else
      ::oFormat:reFormat( aText )
      #endif

      ::qEdit:setPlainText( hbide_arrayToMemo( aText ) )
   ENDIF

   RETURN Self
