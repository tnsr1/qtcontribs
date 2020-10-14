/*
 * $Id: hbqt_init.cpp 431 2016-10-29 02:28:13Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Marcos Antonio Gambeta (marcosgambeta at gmail dot com)
 * Copyright 2009-2016 Pritpal Bedi (pritpal@vouchcac.com)
 * Copyright 2010 Viktor Szakats (harbour syenar.net)
 * Copyright 2010 Francesco Perillo ()
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

#include "hbgtinfo.ch"

#include "hbqt.h"
#include "hbqtinit.h"
#include "hbstack.h"

#include "hbapierr.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbinit.h"

#if QT_VERSION >= 0x040500

#include <QtCore/QCoreApplication>
#include <QtCore/QStringList>
#include <QtCore/QTextCodec>

#include <QtGui/QTextCursor>
#include <QtGui/QTextCharFormat>
#include <QtGui/QTextBlock>
#include <QtGui/QSessionManager>
#include <QtGui/QColor>
#include <QtGui/QPen>
#include <QtGui/QBrush>
#include <QtGui/QImage>
#include <QtGui/QKeyEvent>
#include <QtGui/QStandardItem>
#include <QtGui/QCloseEvent>

#if QT_VERSION <= 0x040900
#include <QtGui/QMainWindow>
#include <QtGui/QPrinter>
#include <QtGui/QAction>
#include <QtGui/QItemSelection>
#include <QtGui/QApplication>
#include <QtGui/QListWidgetItem>
#include <QtGui/QTreeWidgetItem>
#include <QtGui/QMdiSubWindow>
#include <QtGui/QAbstractButton>
#include <QtGui/QWidget>
#else
#include <QtCore/QItemSelection>
#include <QtPrintSupport/QPrinter>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QListWidgetItem>
#include <QtWidgets/QTreeWidgetItem>
#include <QtWidgets/QMdiSubWindow>
#include <QtWidgets/QAbstractButton>
#include <QtWidgets/QWidget>
#include <QtWidgets/QScroller>
#include <QtWidgets/QScrollerProperties>
#endif


HB_EXTERN_BEGIN

extern void hbqt_del_QObject( void * pObj, int iFlags );
extern void hbqt_del_QColor( void * pObj, int iFlags );
extern void hbqt_del_QPen( void * pObj, int iFlags );
extern void hbqt_del_QBrush( void * pObj, int iFlags );
extern void hbqt_del_QImage( void * pObj, int iFlags );
extern void hbqt_del_QItemSelection( void * pObj, int iFlags );
extern void hbqt_del_QTextCharFormat( void * pObj, int iFlags );
extern void hbqt_del_QFont( void * pObj, int iFlags );
extern void hbqt_del_QTextCursor( void * pObj, int iFlags );
extern void hbqt_del_QTextBlock( void * pObj, int iFlags );
extern void hbqt_del_QAbstractButton( void * pObj, int iFlags );
extern void hbqt_del_QAction( void * pObj, int iFlags );
extern void hbqt_del_QMdiSubWindow( void * pObj, int iFlags );
extern void hbqt_del_QPrinter( void * pObj, int iFlags );
extern void hbqt_del_QStandardItem( void * pObj, int iFlags );
extern void hbqt_del_QListWidgetItem( void * pObj, int iFlags );
extern void hbqt_del_QTreeWidgetItem( void * pObj, int iFlags );
extern void hbqt_del_QTableWidgetItem( void * pObj, int iFlags );
extern void hbqt_del_QWidget( void * pObj, int iFlags );
extern void hbqt_del_QRect( void * pObj, int iFlags );
extern void hbqt_del_QScrollerProperties( void * pObj, int iFlags );
//
extern void hbqt_del_QActionEvent( void * pObj, int iFlags );
extern void hbqt_del_QContextMenuEvent( void * pObj, int iFlags );
extern void hbqt_del_QDragEnterEvent( void * pObj, int iFlags );
extern void hbqt_del_QDragLeaveEvent( void * pObj, int iFlags );
extern void hbqt_del_QDropEvent( void * pObj, int iFlags );
extern void hbqt_del_QEvent( void * pObj, int iFlags );
extern void hbqt_del_QFocusEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneContextMenuEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneMouseEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneDragDropEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneHoverEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneMoveEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneResizeEvent( void * pObj, int iFlags );
extern void hbqt_del_QGraphicsSceneWheelEvent( void * pObj, int iFlags );
extern void hbqt_del_QHelpEvent( void * pObj, int iFlags );
extern void hbqt_del_QHideEvent( void * pObj, int iFlags );
extern void hbqt_del_QHoverEvent( void * pObj, int iFlags );
extern void hbqt_del_QInputMethodEvent( void * pObj, int iFlags );
extern void hbqt_del_QKeyEvent( void * pObj, int iFlags );
extern void hbqt_del_QMouseEvent( void * pObj, int iFlags );
extern void hbqt_del_QMoveEvent( void * pObj, int iFlags );
extern void hbqt_del_QPaintEvent( void * pObj, int iFlags );
extern void hbqt_del_QResizeEvent( void * pObj, int iFlags );
extern void hbqt_del_QShortcutEvent( void * pObj, int iFlags );
extern void hbqt_del_QShowEvent( void * pObj, int iFlags );
extern void hbqt_del_QWheelEvent( void * pObj, int iFlags );
extern void hbqt_del_QWindowStateChangeEvent( void * pObj, int iFlags );
extern void hbqt_del_QCloseEvent( void * pObj, int iFlags );

HB_EXTERN_END

/*----------------------------------------------------------------------*/

static void hbqt_SlotsExecQColor( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QColor( ( *reinterpret_cast< QColor( * ) >( arguments[ 1 ] ) ) ), "HB_QCOLOR", hbqt_del_QColor, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQPen( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QPen( ( *reinterpret_cast< QPen( * ) >( arguments[ 1 ] ) ) ), "HB_QPEN", hbqt_del_QPen, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQBrush( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QBrush( ( *reinterpret_cast< QBrush( * ) >( arguments[ 1 ] ) ) ), "HB_QBRUSH", hbqt_del_QBrush, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQImage( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QImage( ( *reinterpret_cast< QImage( * ) >( arguments[ 1 ] ) ) ), "HB_QIMAGE", hbqt_del_QImage, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecItemSelItemSel( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QItemSelection( ( *reinterpret_cast< QItemSelection( * ) >( arguments[ 1 ] ) ) ), "HB_QITEMSELECTION", hbqt_del_QObject, HBQT_BIT_OWNER );
   if( p0 )
   {
      PHB_ITEM p1 = hbqt_bindGetHbObject( NULL, new QItemSelection( ( *reinterpret_cast< QItemSelection( * ) >( arguments[ 2 ] ) ) ), "HB_QITEMSELECTION", hbqt_del_QObject, HBQT_BIT_OWNER ) ;
      if( p1 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmPush( p1 );
         hb_vmSend( 2 );
         hb_itemRelease( p1 );
      }
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQTextCharFormat( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QTextCharFormat( ( *reinterpret_cast< QTextCharFormat( * ) >( arguments[ 1 ] ) ) ), "HB_QTEXTCHARFORMAT", hbqt_del_QTextCharFormat, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQFont( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QFont( ( *reinterpret_cast< QFont( * ) >( arguments[ 1 ] ) ) ), "HB_QFONT", hbqt_del_QFont, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQTextCursor( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QTextCursor( ( *reinterpret_cast< QTextCursor( * ) >( arguments[ 1 ] ) ) ), "HB_QTEXTCURSOR", hbqt_del_QTextCursor, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQTextBlock( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QTextBlock( *reinterpret_cast< QTextBlock( * ) >( arguments[ 1 ] ) ), "HB_QTEXTBLOCK", hbqt_del_QTextBlock, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecQAbstractButton( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   QAbstractButton * obj = ( QAbstractButton * ) arguments[ 1 ];
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QWidget( obj ), "HB_QABSTRACTBUTTON", hbqt_del_QWidget, HBQT_BIT_OWNER | HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQAction( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   QAction * obj = ( QAction * ) arguments[ 1 ];
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QAction( obj ), "HB_QACTION", hbqt_del_QAction, HBQT_BIT_OWNER | HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQMdiSubWindow( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj , "HB_QMDISUBWINDOW", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQTreeWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj , "HB_QTREEWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQTreeWidgetItemInt( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QTREEWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 2 ] ) );
         hb_vmSend( 2 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQPrinter( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QPRINTER", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQStandardItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QSTANDARDITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQListWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QLISTWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQListWidgetItemQListWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QLISTWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         PHB_ITEM p1 = hbqt_bindGetHbObject( NULL, *reinterpret_cast< void*( * ) >( arguments[ 2 ] ) , "HB_QLISTWIDGETITEM", NULL, HBQT_BIT_NONE );
         if( p1 )
         {
            hb_vmPushEvalSym();
            hb_vmPush( codeBlock );
            hb_vmPush( p0 );
            hb_vmPush( p1 );
            hb_vmSend( 2 );
            hb_itemRelease( p1 );
         }
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQTableWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QTABLEWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQTableWidgetItemQTableWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QTABLEWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         PHB_ITEM p1 = hbqt_bindGetHbObject( NULL, *reinterpret_cast< void*( * ) >( arguments[ 2 ] ) , "HB_QTABLEWIDGETITEM", NULL, HBQT_BIT_NONE );
         if( p1 )
         {
            hb_vmPushEvalSym();
            hb_vmPush( codeBlock );
            hb_vmPush( p0 );
            hb_vmPush( p1 );
            hb_vmSend( 2 );
            hb_itemRelease( p1 );
         }
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQTreeWidgetItemQTreeWidgetItem( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QTREEWIDGETITEM", NULL, HBQT_BIT_NONE );
      if( p0 )
      {
         PHB_ITEM p1 = hbqt_bindGetHbObject( NULL, *reinterpret_cast< void*( * ) >( arguments[ 2 ] ) , "HB_QTREEWIDGETITEM", NULL, HBQT_BIT_NONE );
         if( p1 )
         {
            hb_vmPushEvalSym();
            hb_vmPush( codeBlock );
            hb_vmPush( p0 );
            hb_vmPush( p1 );
            hb_vmSend( 2 );
            hb_itemRelease( p1 );
         }
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQWidget( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QWIDGET", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmSend( 1 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQWidgetQWidget( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QWIDGET", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         PHB_ITEM p1 = hbqt_bindGetHbObject( NULL, *reinterpret_cast< void*( * ) >( arguments[ 2 ] ) , "HB_QWIDGET", NULL, HBQT_BIT_QOBJECT );
         if( p1 )
         {
            hb_vmPushEvalSym();
            hb_vmPush( codeBlock );
            hb_vmPush( p0 );
            hb_vmPush( p1 );
            hb_vmSend( 2 );
            hb_itemRelease( p1 );
         }
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQWidgetInt( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QWIDGET", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPush( p0 );
         hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 2 ] ) );
         hb_vmSend( 2 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQRectInt( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QRect( ( *reinterpret_cast< QRect( * ) >( arguments[ 1 ] ) ) ), "HB_QRECT", hbqt_del_QRect, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 2 ] ) );
      hb_vmSend( 2 );
      hb_itemRelease( p0 );
   }
}

static void hbqt_SlotsExecBlurHints( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   hb_vmPushEvalSym();
   hb_vmPush( codeBlock );
   hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 1 ] ) );
   hb_vmSend( 1 );
}

static void hbqt_SlotsExecIntQImage( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QImage( ( *reinterpret_cast< QImage( * ) >( arguments[ 2 ] ) ) ), "HB_QIMAGE", hbqt_del_QImage, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 1 ] ) );
      hb_vmPush( p0 );
      hb_vmSend( 2 );
      hb_itemRelease( p0 );
   }
}
#if QT_VERSION >= 0x050000
static void hbqt_SlotsExecQScrollerProperties( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, new QScrollerProperties( ( *reinterpret_cast< QScrollerProperties( * ) >( arguments[ 1 ] ) ) ), "HB_QSCROLLERPROPERTIES", hbqt_del_QScrollerProperties, HBQT_BIT_OWNER );
   if( p0 )
   {
      hb_vmPushEvalSym();
      hb_vmPush( codeBlock );
      hb_vmPush( p0 );
      hb_vmSend( 1 );
      hb_itemRelease( p0 );
   }
}
#endif

HB_FUNC_EXTERN( HB_QABSTRACTBUTTON );
HB_FUNC_EXTERN( HB_QACTION );
HB_FUNC_EXTERN( HB_QMDISUBWINDOW );
HB_FUNC_EXTERN( HB_QPRINTER );
HB_FUNC_EXTERN( HB_QSTANDARDITEM );
HB_FUNC_EXTERN( HB_QLISTWIDGETITEM );
HB_FUNC_EXTERN( HB_QTABLEWIDGETITEM );
HB_FUNC_EXTERN( HB_QTREEWIDGETITEM );
HB_FUNC_EXTERN( HB_QSCROLLER );
HB_FUNC_EXTERN( HB_QSCROLLERPROPERTIES );
HB_FUNC_EXTERN( HB_QACTIONEVENT );
HB_FUNC_EXTERN( HB_QCONTEXTMENUEVENT );
HB_FUNC_EXTERN( HB_QDRAGENTEREVENT );
HB_FUNC_EXTERN( HB_QDRAGLEAVEEVENT );
HB_FUNC_EXTERN( HB_QDRAGMOVEEVENT );
HB_FUNC_EXTERN( HB_QDROPEVENT );
HB_FUNC_EXTERN( HB_QEVENT );
HB_FUNC_EXTERN( HB_QFOCUSEVENT );
HB_FUNC_EXTERN( HB_QGESTUREEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENECONTEXTMENUEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENEDRAGDROPEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENEHOVEREVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENEMOUSEEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENEMOVEEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENERESIZEEVENT );
HB_FUNC_EXTERN( HB_QGRAPHICSSCENEWHEELEVENT );
HB_FUNC_EXTERN( HB_QHELPEVENT );
HB_FUNC_EXTERN( HB_QHIDEEVENT );
HB_FUNC_EXTERN( HB_QHOVEREVENT );
HB_FUNC_EXTERN( HB_QINPUTMETHODEVENT );
HB_FUNC_EXTERN( HB_QKEYEVENT );
HB_FUNC_EXTERN( HB_QMOUSEEVENT );
HB_FUNC_EXTERN( HB_QMOVEEVENT );
HB_FUNC_EXTERN( HB_QPAINTEVENT );
HB_FUNC_EXTERN( HB_QRESIZEEVENT );
HB_FUNC_EXTERN( HB_QSHORTCUTEVENT );
HB_FUNC_EXTERN( HB_QSHOWEVENT );
HB_FUNC_EXTERN( HB_QWHEELEVENT );
HB_FUNC_EXTERN( HB_QWINDOWSTATECHANGEEVENT );

void _hbqtgui_force_link_for_event( void )
{
   HB_FUNC_EXEC( HB_QACTIONEVENT );
   HB_FUNC_EXEC( HB_QCONTEXTMENUEVENT );
   HB_FUNC_EXEC( HB_QDRAGENTEREVENT );
   HB_FUNC_EXEC( HB_QDRAGLEAVEEVENT );
   HB_FUNC_EXEC( HB_QDRAGMOVEEVENT );
   HB_FUNC_EXEC( HB_QDROPEVENT );
   HB_FUNC_EXEC( HB_QEVENT );
   HB_FUNC_EXEC( HB_QFOCUSEVENT );
   HB_FUNC_EXEC( HB_QGESTUREEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENECONTEXTMENUEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENEDRAGDROPEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENEHOVEREVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENEMOUSEEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENEMOVEEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENERESIZEEVENT );
   HB_FUNC_EXEC( HB_QGRAPHICSSCENEWHEELEVENT );
   HB_FUNC_EXEC( HB_QHELPEVENT );
   HB_FUNC_EXEC( HB_QHIDEEVENT );
   HB_FUNC_EXEC( HB_QHOVEREVENT );
   HB_FUNC_EXEC( HB_QINPUTMETHODEVENT );
   HB_FUNC_EXEC( HB_QKEYEVENT );
   HB_FUNC_EXEC( HB_QMOUSEEVENT );
   HB_FUNC_EXEC( HB_QMOVEEVENT );
   HB_FUNC_EXEC( HB_QPAINTEVENT );
   HB_FUNC_EXEC( HB_QRESIZEEVENT );
   HB_FUNC_EXEC( HB_QSHOWEVENT );
   HB_FUNC_EXEC( HB_QSHORTCUTEVENT );
   HB_FUNC_EXEC( HB_QWHEELEVENT );
   HB_FUNC_EXEC( HB_QWINDOWSTATECHANGEEVENT );
   HB_FUNC_EXEC( HB_QABSTRACTBUTTON );
   HB_FUNC_EXEC( HB_QACTION );
   HB_FUNC_EXEC( HB_QMDISUBWINDOW );
   HB_FUNC_EXEC( HB_QPRINTER );
   HB_FUNC_EXEC( HB_QSTANDARDITEM );
   HB_FUNC_EXEC( HB_QLISTWIDGETITEM );
   HB_FUNC_EXEC( HB_QTABLEWIDGETITEM );
   HB_FUNC_EXEC( HB_QTREEWIDGETITEM );
#if QT_VERSION >= 0x050000
   HB_FUNC_EXEC( HB_QSCROLLER );
   HB_FUNC_EXEC( HB_QSCROLLERPROPERTIES );
#endif
}

static void hbqt_registerCallbacks( void )
{
   hbqt_slots_register_callback( "QColor"                                    , hbqt_SlotsExecQColor                           );
   hbqt_slots_register_callback( "QPen"                                      , hbqt_SlotsExecQPen                             );
   hbqt_slots_register_callback( "QBrush"                                    , hbqt_SlotsExecQBrush                           );
   hbqt_slots_register_callback( "QFont"                                     , hbqt_SlotsExecQFont                            );
   hbqt_slots_register_callback( "QItemSelection$QItemSelection"             , hbqt_SlotsExecItemSelItemSel                   );
   hbqt_slots_register_callback( "QTextBlock"                                , hbqt_SlotsExecQTextBlock                       );
   hbqt_slots_register_callback( "QTextCharFormat"                           , hbqt_SlotsExecQTextCharFormat                  );
   hbqt_slots_register_callback( "QTextCursor"                               , hbqt_SlotsExecQTextCursor                      );
   hbqt_slots_register_callback( "QImage"                                    , hbqt_SlotsExecQImage                           );

   hbqt_slots_register_callback( "QAbstractButton*"                          , hbqt_SlotsExecQAbstractButton                  );
   hbqt_slots_register_callback( "QAction*"                                  , hbqt_SlotsExecQAction                          );
   hbqt_slots_register_callback( "QListWidgetItem*$QListWidgetItem*"         , hbqt_SlotsExecQListWidgetItemQListWidgetItem   );
   hbqt_slots_register_callback( "QMdiSubWindow*"                            , hbqt_SlotsExecQMdiSubWindow                    );
   hbqt_slots_register_callback( "QPrinter*"                                 , hbqt_SlotsExecQPrinter                         );
   hbqt_slots_register_callback( "QStandardItem*"                            , hbqt_SlotsExecQStandardItem                    );
   hbqt_slots_register_callback( "QTableWidgetItem*"                         , hbqt_SlotsExecQTableWidgetItem                 );
   hbqt_slots_register_callback( "QTableWidgetItem*$QTableWidgetItem*"       , hbqt_SlotsExecQTableWidgetItemQTableWidgetItem );
   hbqt_slots_register_callback( "QTreeWidgetItem*$int"                      , hbqt_SlotsExecQTreeWidgetItemInt               );
   hbqt_slots_register_callback( "QTreeWidgetItem*$QTreeWidgetItem*"         , hbqt_SlotsExecQTreeWidgetItemQTreeWidgetItem   );
   hbqt_slots_register_callback( "QWidget*$int"                              , hbqt_SlotsExecQWidgetInt                       );
   hbqt_slots_register_callback( "QWidget*$QWidget*"                         , hbqt_SlotsExecQWidgetQWidget                   );
   hbqt_slots_register_callback( "QTreeWidgetItem*"                          , hbqt_SlotsExecQTreeWidgetItem                  );
   hbqt_slots_register_callback( "QListWidgetItem*"                          , hbqt_SlotsExecQListWidgetItem                  );
   hbqt_slots_register_callback( "QWidget*"                                  , hbqt_SlotsExecQWidget                          );
   hbqt_slots_register_callback( "QRect$int"                                 , hbqt_SlotsExecQRectInt                         );
   hbqt_slots_register_callback( "BlurHints"                                 , hbqt_SlotsExecBlurHints                        );
   hbqt_slots_register_callback( "int$QImage"                                , hbqt_SlotsExecIntQImage                        );
#if QT_VERSION >= 0x050000
   hbqt_slots_register_callback( "QScrollerProperties"                       , hbqt_SlotsExecQScrollerProperties              );
#endif
   hbqt_events_register_createobj( QEvent::MouseButtonPress                  , "hb_QMouseEvent"                    );
   hbqt_events_register_createobj( QEvent::MouseButtonRelease                , "hb_QMouseEvent"                    );
   hbqt_events_register_createobj( QEvent::MouseButtonDblClick               , "hb_QMouseEvent"                    );
   hbqt_events_register_createobj( QEvent::MouseMove                         , "hb_QMouseEvent"                    );
   hbqt_events_register_createobj( QEvent::KeyPress                          , "hb_QKeyEvent"                      );
   hbqt_events_register_createobj( QEvent::KeyRelease                        , "hb_QKeyEvent"                      );
   hbqt_events_register_createobj( QEvent::FocusIn                           , "hb_QFocusEvent"                    );
   hbqt_events_register_createobj( QEvent::FocusOut                          , "hb_QFocusEvent"                    );
   hbqt_events_register_createobj( QEvent::Enter                             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Leave                             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Paint                             , "hb_QPaintEvent"                    );
   hbqt_events_register_createobj( QEvent::Move                              , "hb_QMoveEvent"                     );
   hbqt_events_register_createobj( QEvent::Resize                            , "hb_QResizeEvent"                   );
   hbqt_events_register_createobj( QEvent::Show                              , "hb_QShowEvent"                     );
   hbqt_events_register_createobj( QEvent::Hide                              , "hb_QHideEvent"                     );
   hbqt_events_register_createobj( QEvent::Close                             , "hb_QCloseEvent"                    );
   hbqt_events_register_createobj( QEvent::ParentChange                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowActivate                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowDeactivate                  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ShowToParent                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::HideToParent                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Wheel                             , "hb_QWheelEvent"                    );
   hbqt_events_register_createobj( QEvent::WindowTitleChange                 , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowIconChange                  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationWindowIconChange       , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationFontChange             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationLayoutDirectionChange  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationPaletteChange          , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::PaletteChange                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Clipboard                         , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::MetaCall                          , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::SockAct                           , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ShortcutOverride                  , "hb_QKeyEvent"                      );
   hbqt_events_register_createobj( QEvent::DeferredDelete                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::DragEnter                         , "hb_QDragEnterEvent"                );
   hbqt_events_register_createobj( QEvent::DragLeave                         , "hb_QDragLeaveEvent"                );
   hbqt_events_register_createobj( QEvent::DragMove                          , "hb_QDragMoveEvent"                 );
   hbqt_events_register_createobj( QEvent::Drop                              , "hb_QDropEvent"                     );
   hbqt_events_register_createobj( QEvent::ChildAdded                        , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ChildPolished                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ChildRemoved                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::PolishRequest                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Polish                            , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LayoutRequest                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::UpdateRequest                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::UpdateLater                       , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ContextMenu                       , "hb_QContextMenuEvent"              );
   hbqt_events_register_createobj( QEvent::InputMethod                       , "hb_QInputMethodEvent"              );
   hbqt_events_register_createobj( QEvent::TabletMove                        , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LocaleChange                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LanguageChange                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LayoutDirectionChange             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::TabletPress                       , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::TabletRelease                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::OkRequest                         , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::IconDrag                          , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::FontChange                        , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::EnabledChange                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ActivationChange                  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::StyleChange                       , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::IconTextChange                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ModifiedChange                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowBlocked                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowUnblocked                   , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WindowStateChange                 , "hb_QWindowStateChangeEvent"        );
   hbqt_events_register_createobj( QEvent::MouseTrackingChange               , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ToolTip                           , "hb_QHelpEvent"                     );
   hbqt_events_register_createobj( QEvent::WhatsThis                         , "hb_QHelpEvent"                     );
   hbqt_events_register_createobj( QEvent::StatusTip                         , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ActionChanged                     , "hb_QActionEvent"                   );
   hbqt_events_register_createobj( QEvent::ActionAdded                       , "hb_QActionEvent"                   );
   hbqt_events_register_createobj( QEvent::ActionRemoved                     , "hb_QActionEvent"                   );
   hbqt_events_register_createobj( QEvent::FileOpen                          , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Shortcut                          , "hb_QShortcutEvent"                 );
   hbqt_events_register_createobj( QEvent::WhatsThisClicked                  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ToolBarChange                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationActivate               , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationActivated              , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationDeactivate             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::QueryWhatsThis                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::EnterWhatsThisMode                , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LeaveWhatsThisMode                , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ZOrderChange                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::HoverEnter                        , "hb_QHoverEvent"                    );
   hbqt_events_register_createobj( QEvent::HoverLeave                        , "hb_QHoverEvent"                    );
   hbqt_events_register_createobj( QEvent::HoverMove                         , "hb_QHoverEvent"                    );
#if QT_VERSION <= 0x040900
   hbqt_events_register_createobj( QEvent::AccessibilityPrepare              , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::AccessibilityDescription          , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::AccessibilityHelp                 , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::MenubarUpdated                    , "hb_QEvent"                         );
#endif
   hbqt_events_register_createobj( QEvent::ParentAboutToChange               , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WinEventAct                       , "hb_QEvent"                         );
#if defined( QT_KEYPAD_NAVIGATION )
   hbqt_events_register_createobj( QEvent::EnterEditFocus                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::LeaveEditFocus                    , "hb_QEvent"                         );
#endif
   hbqt_events_register_createobj( QEvent::GraphicsSceneMouseMove            , "hb_QGraphicsSceneMouseEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneMousePress           , "hb_QGraphicsSceneMouseEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneMouseRelease         , "hb_QGraphicsSceneMouseEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneMouseDoubleClick     , "hb_QGraphicsSceneMouseEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneContextMenu          , "hb_QGraphicsSceneContextMenuEvent" );
   hbqt_events_register_createobj( QEvent::GraphicsSceneHoverEnter           , "hb_QGraphicsSceneHoverEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneHoverMove            , "hb_QGraphicsSceneHoverEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneHoverLeave           , "hb_QGraphicsSceneHoverEvent"       );
   hbqt_events_register_createobj( QEvent::GraphicsSceneHelp                 , "hb_QHelpEvent"                     );
   hbqt_events_register_createobj( QEvent::GraphicsSceneDragEnter            , "hb_QGraphicsSceneDragDropEvent"    );
   hbqt_events_register_createobj( QEvent::GraphicsSceneDragMove             , "hb_QGraphicsSceneDragDropEvent"    );
   hbqt_events_register_createobj( QEvent::GraphicsSceneDragLeave            , "hb_QGraphicsSceneDragDropEvent"    );
   hbqt_events_register_createobj( QEvent::GraphicsSceneDrop                 , "hb_QGraphicsSceneDragDropEvent"    );
   hbqt_events_register_createobj( QEvent::GraphicsSceneWheel                , "hb_QGraphicsSceneWheelEvent"       );
   hbqt_events_register_createobj( QEvent::KeyboardLayoutChange              , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::DynamicPropertyChange             , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::TabletEnterProximity              , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::TabletLeaveProximity              , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::NonClientAreaMouseMove            , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::NonClientAreaMouseButtonPress     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::NonClientAreaMouseButtonRelease   , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::NonClientAreaMouseButtonDblClick  , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::MacSizeChange                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ContentsRectChange                , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::GraphicsSceneResize               , "hb_QGraphicsSceneResizeEvent"      );
   hbqt_events_register_createobj( QEvent::GraphicsSceneMove                 , "hb_QGraphicsSceneMoveEvent"        );
   hbqt_events_register_createobj( QEvent::CursorChange                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ToolTipChange                     , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::GrabMouse                         , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::UngrabMouse                       , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::GrabKeyboard                      , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::UngrabKeyboard                    , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::Gesture                           , "hb_QGestureEvent"                  );
   hbqt_events_register_createobj( QEvent::GestureOverride                   , "hb_QGestureEvent"                  );

   hbqt_events_register_createobj( QEvent::TouchBegin                        , "hb_QTouchEvent"                    );
   hbqt_events_register_createobj( QEvent::TouchUpdate                       , "hb_QTouchEvent"                    );
   hbqt_events_register_createobj( QEvent::TouchEnd                          , "hb_QTouchEvent"                    );
   hbqt_events_register_createobj( QEvent::RequestSoftwareInputPanel         , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::CloseSoftwareInputPanel           , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::WinIdChange                       , "hb_QEvent"                         );
#if QT_VERSION > 0x040802
   hbqt_events_register_createobj( QEvent::PlatformPanel                     , "hb_QEvent"                         );
#endif
#if QT_VERSION >= 0x050000
   hbqt_events_register_createobj( QEvent::TouchCancel                       , "hb_QTouchEvent"                    );
   hbqt_events_register_createobj( QEvent::ScrollPrepare                     , "hb_QScrollPrepareEvent"            );
   hbqt_events_register_createobj( QEvent::Scroll                            , "hb_QScrollEvent"                   );
   hbqt_events_register_createobj( QEvent::InputMethodQuery                  , "hb_QInputMethodQueryEvent"         );
   hbqt_events_register_createobj( QEvent::Expose                            , "hb_QEvent"                         );
   hbqt_events_register_createobj( QEvent::ApplicationStateChange            , "hb_QEvent"                         );
#endif
}

/*----------------------------------------------------------------------*/

static QApplication * s_qtapp = NULL;
static HB_BOOL fIsQuitting = HB_FALSE;

HB_FUNC_EXTERN( __HBQTCORE );

HB_FUNC( __HBQTGUI )
{
   HB_FUNC_EXEC( __HBQTCORE );
}

HB_EXTERN_BEGIN
extern HB_EXPORT QApplication * __hbqtgui_app( void );
HB_EXTERN_END

QApplication * __hbqtgui_app( void )
{
   return s_qtapp;
}

static void hbqt_lib_quit( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );

   s_qtapp->quit();
   delete s_qtapp;
   s_qtapp = NULL;
}

static void hbqt_lib_init( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );

   if( ! s_qtapp )
   {
      s_qtapp = qApp;
      if( ! s_qtapp )
      {
         PHB_DYNS pDynsym = hb_dynsymFind( "__HBQTLIBRARYPATH" );
         if( pDynsym && hb_vmRequestReenter() )
         {
            hb_vmPushDynSym( pDynsym );
            hb_vmPushNil();
            hb_vmDo( 0 );
            if( hb_vmRequestQuery() == 0 )
            {
               PHB_ITEM pReturn = hb_stackReturnItem();

               if( pReturn && ( hb_itemType( pReturn ) & HB_IT_STRING ) )
               {
                  QCoreApplication::addLibraryPath( ( QString ) hb_itemGetC( pReturn ) );
               }
            }
            hb_vmRequestRestore();
         }
         static char ** s_argv;
         static int s_argc;

         s_argc = hb_cmdargARGC();
         s_argv = hb_cmdargARGV();

         s_qtapp = new QApplication( s_argc, s_argv );
         if( ! s_qtapp )
            hb_errInternal( 10001, "QT initialization error.", NULL, NULL );

         hb_vmAtQuit( hbqt_lib_quit, NULL );
         hb_cmdargInit( s_argc, s_argv );
      }
   }
   hbqt_registerCallbacks();

#if QT_VERSION <= 0x040900
   QTextCodec::setCodecForTr( QTextCodec::codecForName( "UTF-8" ) );
   QTextCodec::setCodecForCStrings( QTextCodec::codecForName( "UTF-8" ) );
#endif
}

#if 0
static void hbqt_lib_init( void * cargo )
{
   static int s_argc;
   static char ** s_argv;

   HB_SYMBOL_UNUSED( cargo );

   PHB_DYNS pDynsym = hb_dynsymFind( "__HBQTLIBRARYPATH" );
   if( pDynsym && hb_vmRequestReenter() )
   {
      hb_vmPushDynSym( pDynsym );
      hb_vmPushNil();
      hb_vmDo( 0 );
      if( hb_vmRequestQuery() == 0 )
      {
         PHB_ITEM pReturn = hb_stackReturnItem();

         if( pReturn && ( hb_itemType( pReturn ) & HB_IT_STRING ) )
         {
            QCoreApplication::addLibraryPath( ( QString ) hb_itemGetC( pReturn ) );
         }
      }
      hb_vmRequestRestore();
   }

   s_argc = hb_cmdargARGC();
   s_argv = hb_cmdargARGV();

   s_qtapp = new QApplication( s_argc, s_argv );

   if( ! s_qtapp )
      hb_errInternal( 11001, "hbqt_lib_init(): HBQTGUI Initilization Error.", NULL, NULL );

   hb_cmdargInit( s_argc, s_argv );
   HB_TRACE( HB_TR_DEBUG, ( "hbqt_lib_init %p", s_qtapp ) );

   hbqt_registerCallbacks();
#if QT_VERSION <= 0x040900
   QTextCodec::setCodecForTr( QTextCodec::codecForName( "UTF-8" ) );
   QTextCodec::setCodecForCStrings( QTextCodec::codecForName( "UTF-8" ) );
#endif
}
#endif

static void hbqt_lib_exit( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );
   fIsQuitting = HB_TRUE;
}

HB_FUNC( HBQT_ISACTIVEAPPLICATION )
{
   hb_retl( ! fIsQuitting );
}

/* hbqt_findChild( oParent, cObjectName, cWidget ) */
/* hbqt_findChild( oMainWindow, "myToolbar", "QToolbar" ) */
HB_FUNC( HBQT_FINDCHILD )
{
   if( hb_pcount() == 3 && hbqt_par_isDerivedFrom( 1, "QWIDGET" ) && HB_ISCHAR( 2 ) && HB_ISCHAR( 3 ) )
   {
      QObject * p = ( QObject * ) hbqt_get_ptr( hb_param( 1, HB_IT_OBJECT ) );
      if( p )
      {
         QObject * child = p->findChild<QObject *>( ( QString ) hb_parc( 2 ) );
         if( child )
         {
            QString widget = hb_parc( 3 );
            widget = "HB_" + widget.toUpper();
            hb_itemReturnRelease( hbqt_bindGetHbObject( NULL, child, widget.toLatin1().data(), NULL, 1 ) );
         }
      }
   }
}

/* hb_gtInfo( HB_GTI_WIDGET ) */
HB_FUNC( GTQTC_MAINWINDOW )
{
   HB_GT_INFO gtInfo;

   memset( &gtInfo, 0, sizeof( gtInfo ) );
   hb_gtInfo( HB_GTI_WINHANDLE, &gtInfo );
   if( gtInfo.pResult )
   {
      void * pqWnd = hb_itemGetPtr( gtInfo.pResult );
      if( pqWnd )
         hb_itemReturnRelease( hbqt_bindGetHbObject( NULL, pqWnd, "HB_QMAINWINDOW", NULL, HBQT_BIT_QOBJECT ) );
      hb_itemRelease( gtInfo.pResult );
   }
}

/* hb_gtInfo( HB_GTI_DRAWINGAREA ) */
HB_FUNC( GTQTC_DRAWINGAREA )
{
   HB_GT_INFO gtInfo;

   memset( &gtInfo, 0, sizeof( gtInfo ) );
   hb_gtInfo( HB_GTI_WINHANDLE, &gtInfo );
   if( gtInfo.pResult )
   {
      QMainWindow * pqWnd = ( QMainWindow * ) hb_itemGetPtr( gtInfo.pResult );
      if( pqWnd )
         hb_itemReturnRelease( hbqt_bindGetHbObject( NULL, pqWnd->centralWidget(), "HB_QWIDGET", NULL, HBQT_BIT_QOBJECT ) );
      hb_itemRelease( gtInfo.pResult );
   }
}

HB_CALL_ON_STARTUP_BEGIN( _hbqtgui_init_ )
   hb_vmAtInit( hbqt_lib_init, NULL );
   hb_vmAtExit( hbqt_lib_exit, NULL );
HB_CALL_ON_STARTUP_END( _hbqtgui_init_ )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup _hbqtgui_init_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( _hbqtgui_init_ )
   #include "hbiniseg.h"
#endif

#endif
