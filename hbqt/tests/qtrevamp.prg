/*
 * $Id: qtrevamp.prg 34 2012-10-13 21:57:41Z bedipritpal $
 */


#include "hbtrace.ch"

// Why do we need these two variables in scope ?
// Because :connect needs that Harbour object must
// always be accessible.
//

FUNCTION Main()
   LOCAL oWnd, qApp

   hbqt_errorsys()

   oWnd := QMainWindow()
   oWnd:resize( 400,200 )

   BuildMenuBar( oWnd )
   AddLabel( oWnd )

   oWnd:show()

   qApp := QApplication()
   qApp:exec()

   RETURN NIL


STATIC FUNCTION BuildMenuBar( oWnd )
   LOCAL oMenu1, oMenuBar
   LOCAL oItemIns, oItemMod

   oMenuBar := QMenuBar( oWnd )

   // if we do not construct a widget without a parent
   // it will be deleted once RETURN is his, so always
   // pass it its parent as an argument.
   //
   oMenu1 := QMenu( oMenuBar )
   //
   oMenu1:setTitle( "&Options" )

   IF empty( oItemIns )
      oItemIns := QAction( oWnd )
      oItemIns:setText( "&MessageBox()" )
      oItemIns:connect( "triggered()", {|| DlgMBox( "Yes" ) } )
   ENDIF

   IF empty( oItemMod )
      oItemMod := QAction( oWnd )
      oItemMod:setText( "&ContextMenu()" )
      oItemMod:connect( "triggered()", {|| ContextMenu( oWnd ) } )
   ENDIF

   oMenu1:addAction( oItemIns )
   oMenu1:addAction( oItemMod )

   oMenuBar:addMenu( oMenu1 )

   oWnd:setMenuBar( oMenuBar )

   RETURN NIL


FUNCTION AddLabel( oWnd )
   LOCAL oL

   oL := QLabel( oWnd )
   oL:move( 155,95 )
   oL:setText( "Harbour Qt Revamped" )

   // oL is local, still it is visible to the appln throughout.
   // Also memory is released automatically once its parent
   // will go out of scope.

   RETURN NIL


FUNCTION DlgMBox( cMsg )
   LOCAL oMB

   oMB := QMessageBox()
   oMB:setText( cMsg )
   oMB:exec()

   // oMB is local and QMessageBox() is not constructed with any
   // parent, so it will be deleted once RETURN is hit, and memory
   // will be reclaimed properly. Try to click on this option
   // repeatedly and see for yourself that memory remains constant.

   RETURN NIL


FUNCTION DlgFiles( cMask )
   LOCAL oFD

   oFD := QFileDialog()
   oFD:exec()

   // oFD is local and QMessageBox() is not constructed with any
   // parent, so it will be deleted once RETURN is hit, and memory
   // will be reclaimed properly. Try to click on this option
   // repeatedly and see for yourself that memory remains constant.

   RETURN cMask


FUNCTION ContextMenu( oWnd )
   LOCAL qMenu, qAct

   qMenu := QMenu()

   qMenu:addAction( "Copy"       )
   qMenu:addAction( "Select All" )
   qMenu:addAction( "Clear"      )
   qMenu:addAction( "Print"      )
   qMenu:addAction( "Save as..." )
   qMenu:addSeparator()
   qMenu:addAction( "Find"       )

   qAct := qMenu:exec( oWnd:mapToGlobal( QPoint( 10,10 ) ) )
   IF ! empty( qAct )
      //...
   ENDIF

   // qMenu is a local variable and is carries no parent,
   // which should be like this for any context menu,
   // The memory is released, along its actions, when
   // RETURN is hit.

   RETURN NIL

