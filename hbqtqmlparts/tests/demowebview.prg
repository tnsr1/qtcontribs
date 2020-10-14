/*
 * $Id: demowebview.prg 417 2015-08-01 01:42:17Z bedipritpal $
 */

/*
 * Copyright 2015 Pritpal Bedi <bedipritpal@hotmail.com>
 * www - http://harbour-project.org
 */


#include "hbtoqt.ch"
#include "hbqtstd.ch"
#include "hbqtgui.ch"


FUNCTION Main()
   LOCAL oWnd, oWeb

   WITH OBJECT oWnd := QWidget()
      :resize( 640, 500 )
   ENDWITH

   WITH OBJECT oWeb := HbQtWebView():new():create( oWnd )
      :show( "http://www.vouch.in" )
   ENDWITH

   oWnd:show()

   QApplication():exec()

   HB_SYMBOL_UNUSED( oWeb )
   RETURN NIL



