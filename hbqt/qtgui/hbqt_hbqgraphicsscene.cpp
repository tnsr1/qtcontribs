/*
 * $Id: hbqt_hbqgraphicsscene.cpp 475 2020-02-20 03:07:47Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2010-2016 Pritpal Bedi <bedipritpal@hotmail.com>
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

/***************************************************************************
*   The parts of this source are borrowed and adopted from eXaro project   *
*                 Copyright (C) 2008 by BogDan Vatra                       *
*                         bog_dan_ro@yahoo.com                             *
***************************************************************************/

#include "hbqt.h"
#include "hbapiitm.h"
#include "hbvm.h"

#if QT_VERSION >= 0x040500

#include "hbqt_hbqgraphicsscene.h"

static bool bAllowResizing = true;
static bool bAllowMovement = true;
static bool bCanMoveItems = false;


bool __hbqGraphicsCanMoveItems()
{
   return bCanMoveItems;
}
HB_FUNC( __HBQGRAPHICS_CANMOVEITEMS )
{
   bool bOldSetting = bCanMoveItems;
   if( hb_pcount() == 1 && HB_ISLOG( 1 ) )
   {
      bCanMoveItems = hb_parl( 1 );
   }
   hb_retl( bOldSetting );
}

bool __hbqGraphicsAllowResizeInPlace()
{
   return bAllowResizing;
}
HB_FUNC( __HBQGRAPHICS_ALLOWRESIZEINPLACE )
{
   bool bOldSetting = bAllowResizing;
   if( hb_pcount() == 1 && HB_ISLOG( 1 ) )
   {
      bAllowResizing = hb_parl( 1 );
   }
   hb_retl( bOldSetting );
}

bool __hbqGraphicsAllowMovement()
{
   return bAllowMovement;
}
HB_FUNC( __HBQGRAPHICS_ALLOWMOVEMENT )
{
   bool bOldSetting = bAllowMovement;
   if( hb_pcount() == 1 && HB_ISLOG( 1 ) )
   {
      bAllowMovement = hb_parl( 1 );
   }
   hb_retl( bOldSetting );
}

HBQGraphicsScene::HBQGraphicsScene( QObject * parent ) : QGraphicsScene( parent )
{
   block          = 0;

   m_magnets      = 0;
   m_magnetArea   = 1;
   m_paperBorder  = 0;
   m_pageBorder   = 0;
   m_showGrid     = false;
   m_sceneSize    = QSize( 2590, 1960 );   /* Equal to  printable area of QPrinter::Letter */
   m_orientation  = QPrinter::Landscape;

   setSceneSize( m_sceneSize );

   QFont m_font = QFont( "Serif" );
   m_font.setPointSizeF( 3.5 );
   m_font.setStyleStrategy( QFont::PreferMatch );
   m_font.setStyleStrategy( QFont::ForceOutline );
   setFont( m_font );
}

HBQGraphicsScene::~HBQGraphicsScene()
{
   if( block )
   {
      hb_itemRelease( block );
      block = NULL;
   }
}

void HBQGraphicsScene::hbClearBlock()
{
   if( block )
   {
      hb_itemRelease( block );
      block = NULL;
   }
}

void HBQGraphicsScene::hbSetBlock( PHB_ITEM b )
{
   if( block )
   {
      hb_itemRelease( block );
      block = NULL;
   }

   if( b && hb_vmRequestReenter() )
   {
      block = hb_itemNew( b );
      hb_gcUnlock( block );

      QDesktopWidget *  qWid  = new QDesktopWidget();

      PHB_ITEM          p1    = hb_itemPutNI( NULL, 21001 );
      PHB_ITEM          p2    = hb_itemPutNI( NULL, qWid->screen()->physicalDpiX() );
      PHB_ITEM          p3    = hb_itemPutNI( NULL, qWid->screen()->physicalDpiY() );
      hb_vmEvalBlockV( block, 3, p1, p2, p3 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );
      hb_itemRelease( p3 );

      hb_vmRequestRestore();
   }
}

QRectF HBQGraphicsScene::geometry()
{
   return m_geometry;
}
void HBQGraphicsScene::setGeometry( QRectF rect )
{
   m_geometry = rect & sceneRect();
   drawBorder();
   emit geometryChanged( m_geometry );
}

void HBQGraphicsScene::updatePageRect()
{
   setSceneRect( 0, 0, m_sceneSize.width(), m_sceneSize.height() );
}

void HBQGraphicsScene::setSceneSize( const QSize & size )
{
   m_sceneSize = size;
   updatePageRect();
   m_paperRect = sceneRect();
   setGeometry( sceneRect() );
}

int HBQGraphicsScene::orientation()
{
   return m_orientation;
}
void HBQGraphicsScene::setOrientation( int orientation )
{
   m_orientation = orientation;
   updatePageRect();
   m_paperRect = sceneRect();
   setGeometry( m_paperRect );
}

int HBQGraphicsScene::magnetArea()
{
   return m_magnetArea;
}
void HBQGraphicsScene::setMagnetArea( int magnetArea )
{
   m_magnetArea = magnetArea;
}

/*----------------------------------------------------------------------*/
/*                            Mouse Events                              */
/*----------------------------------------------------------------------*/

void HBQGraphicsScene::mouseMoveEvent( QGraphicsSceneMouseEvent * mouseEvent )
{
   HBQGraphicsItem * item = NULL;

   if( itemAt( mouseEvent->scenePos(), QTransform() ) )
   {
      item = dynamic_cast< HBQGraphicsItem * >( itemAt( mouseEvent->scenePos(), QTransform() ) );
   }
   if( item && mouseEvent->buttons() == Qt::NoButton )
   {
      if( item->objectType() == ( QString ) "Page" )
      {
         item->setCursor( QCursor( Qt::ArrowCursor ) );
      }
      else if( __hbqGraphicsAllowResizeInPlace() )
      {

         int pc = item->determineResizeMode( item->mapFromScene( mouseEvent->scenePos() ) );

         if( RESIZE_MODE_FIXED != pc )
         {
            if( ( pc & RESIZE_MODE_TOP && pc & RESIZE_MODE_LEFT ) || ( pc & RESIZE_MODE_BOTTOM && pc & RESIZE_MODE_RIGHT ) )
               item->setCursor( QCursor( Qt::SizeFDiagCursor ) );
            else
            if( ( pc & RESIZE_MODE_TOP && pc & RESIZE_MODE_RIGHT ) || ( pc & RESIZE_MODE_BOTTOM && pc & RESIZE_MODE_LEFT ) )
               item->setCursor( QCursor( Qt::SizeBDiagCursor ) );
            else
            if( ( pc & RESIZE_MODE_TOP ) || ( pc & RESIZE_MODE_BOTTOM ) )
               item->setCursor( QCursor( Qt::SizeVerCursor ) );
            else
            if( ( pc & RESIZE_MODE_RIGHT ) || ( pc & RESIZE_MODE_LEFT ) )
               item->setCursor( QCursor( Qt::SizeHorCursor ) );
            else
            if( pc & RESIZE_MODE_FIXEDPOS )
               item->setCursor( QCursor( Qt::ArrowCursor ) );
         }
         else
         {
            if( RESIZE_MODE_FIXED == pc )
            {
               item->setCursor( QCursor( Qt::OpenHandCursor ) );
            }
         }
      }
      else
      {
          item->setCursor( QCursor( Qt::OpenHandCursor ) );
      }
   }

   QGraphicsScene::mouseMoveEvent( mouseEvent );

   if( mouseEvent->buttons() != Qt::LeftButton )
      return;

   item = 0;

   if( selectedItems().size() )
   {
      item = dynamic_cast< HBQGraphicsItem * >( selectedItems()[ 0 ] );
   }
   if( item && ! ( mouseEvent->modifiers() & Qt::ControlModifier ) )
   {
      drawMagnets( item );
   }
}

void HBQGraphicsScene::mousePressEvent( QGraphicsSceneMouseEvent * event )
{
   QPointF mousePos( event->buttonDownScenePos( Qt::LeftButton ).x(), event->buttonDownScenePos( Qt::LeftButton ).y() );
   movingItem = itemAt( mousePos.x(), mousePos.y(), QTransform() );
   if( movingItem != 0 && event->button() == Qt::LeftButton )
      mouseOldPos = movingItem->pos();

   QGraphicsScene::mousePressEvent( event );

   if( event->buttons() == Qt::LeftButton )
   {
      if( ! itemAt( event->scenePos(), QTransform() ) )
      {
         emit itemSelected( parent(), event->scenePos() );
      }
      else
      {
         if( itemAt( event->scenePos(), QTransform() ) == m_paperBorder || itemAt( event->scenePos(), QTransform() ) == m_pageBorder )
         {
            emit itemSelected( this, event->scenePos() );
         }
      }
      HBQGraphicsItem * item = dynamic_cast< HBQGraphicsItem * >( itemAt( event->scenePos(), QTransform() ) );
      if( ! item )
      {
         if( block && hb_vmRequestReenter() )
         {
            PHB_ITEM p1 = hb_itemPutNI( NULL, 21107 );
            PHB_ITEM p2 = hb_itemPutND( NULL, event->scenePos().x() );
            PHB_ITEM p3 = hb_itemPutND( NULL, event->scenePos().y() );
            hb_vmEvalBlockV( block, 3, p1, p2, p3 );
            hb_itemRelease( p1 );
            hb_itemRelease( p2 );
            hb_itemRelease( p3 );

            hb_vmRequestRestore();
         }
      }
   }
}

void HBQGraphicsScene::mouseReleaseEvent( QGraphicsSceneMouseEvent * event )
{
   foreach( QGraphicsItem * item, m_gideLines )
   removeItem( item );
   m_gideLines.clear();

   if( movingItem != 0 && event->button() == Qt::LeftButton )
   {
      if( mouseOldPos != movingItem->pos() )
      {
         emit itemMoved( dynamic_cast< QObject * >( movingItem ), mouseOldPos );
      }
      movingItem = 0;
   }
   QGraphicsScene::mouseReleaseEvent( event );
}

void HBQGraphicsScene::mouseDoubleClickEvent( QGraphicsSceneMouseEvent * event )
{
   QGraphicsScene::mouseDoubleClickEvent( event );

   if( block && hb_vmRequestReenter() )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, 21131 );
      PHB_ITEM p2 = hb_itemPutND( NULL, event->scenePos().x() );
      PHB_ITEM p3 = hb_itemPutND( NULL, event->scenePos().y() );
      hb_vmEvalBlockV( block, 3, p1, p2, p3 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );
      hb_itemRelease( p3 );

      hb_vmRequestRestore();
   }
}

/*----------------------------------------------------------------------*/
/*                             Key Events                               */
/*----------------------------------------------------------------------*/

void HBQGraphicsScene::keyReleaseEvent( QKeyEvent * keyEvent )
{
   foreach( QGraphicsItem * item, m_gideLines )
   removeItem( item );
   m_gideLines.clear();
   QGraphicsScene::keyReleaseEvent( keyEvent );
}

void HBQGraphicsScene::keyPressEvent( QKeyEvent * keyEvent )
{
   if( keyEvent->modifiers() == Qt::NoModifier || ( keyEvent->key() != Qt::Key_Left && keyEvent->key() != Qt::Key_Right &&
                                                    keyEvent->key() != Qt::Key_Up && keyEvent->key() != Qt::Key_Down ) )
   {
      QGraphicsScene::keyPressEvent( keyEvent );
      return;
   }

   HBQGraphicsItem * itm = 0;

   if( keyEvent->modifiers() & Qt::AltModifier )
   {
      foreach( QGraphicsItem * item, selectedItems() )
      {
         itm = dynamic_cast< HBQGraphicsItem * >( item );
         if( itm )
         {
            QRectF   curRect = itm->geometry();
            QRectF   rect;
            switch( keyEvent->key() )
            {
               case Qt::Key_Left:
                  rect  = QRectF( curRect.x() - 5, curRect.y(), curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Right:
                  rect  = QRectF( curRect.x() + 5, curRect.y(), curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Up:
                  rect  = QRectF( curRect.x(), curRect.y() - 5, curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Down:
                  rect  = QRectF( curRect.x(), curRect.y() + 5, curRect.width(), curRect.height() );
                  break;
            }
            itm->setGeometry( rect );
            drawMagnets( itm );
         }
      }
   }

   if( keyEvent->modifiers() & Qt::ControlModifier )
   {
      foreach( QGraphicsItem * item, selectedItems() )
      {
         HBQGraphicsItem * itm = dynamic_cast< HBQGraphicsItem * >( item );

         if( itm )
         {
            QRectF   curRect = itm->geometry();
            QRectF   rect;
            switch( keyEvent->key() )
            {
               case Qt::Key_Left:
                  rect  = QRectF( curRect.x() - 1, curRect.y(), curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Right:
                  rect  = QRectF( curRect.x() + 1, curRect.y(), curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Up:
                  rect  = QRectF( curRect.x(), curRect.y() - 1, curRect.width(), curRect.height() );
                  break;
               case Qt::Key_Down:
                  rect  = QRectF( curRect.x(), curRect.y() + 1, curRect.width(), curRect.height() );
                  break;
            }
            itm->setGeometry( rect );
            drawMagnets( itm );
         }
      }
   }

   if( keyEvent->modifiers() & Qt::ShiftModifier )
   {
      foreach( QGraphicsItem * item, selectedItems() )
      {
         HBQGraphicsItem * itm = dynamic_cast< HBQGraphicsItem * >( item );

         if( itm )
         {
            QRectF   curRect = itm->geometry();
            QRectF   rect;
            switch( keyEvent->key() )
            {
               case Qt::Key_Left:
                  rect  = QRectF( curRect.x(), curRect.y(), curRect.width() - 1, curRect.height() );
                  break;
               case Qt::Key_Right:
                  rect  = QRectF( curRect.x(), curRect.y(), curRect.width() + 1, curRect.height() );
                  break;
               case Qt::Key_Up:
                  rect  = QRectF( curRect.x(), curRect.y(), curRect.width(), curRect.height() - 1 );
                  break;
               case Qt::Key_Down:
                  rect  = QRectF( curRect.x(), curRect.y(), curRect.width(), curRect.height() + 1 );
                  break;
            }
            itm->setGeometry( rect );
            drawMagnets( itm );
         }
      }
   }
}

void HBQGraphicsScene::drawBackground( QPainter * painter, const QRectF & rect )
{
#if 0
   if( block && hb_vmRequestReenter() )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, 21201 );
      PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) painter, "HB_QPAINTER", NULL, 0 );
      PHB_ITEM p3 = hbqt_bindGetHbObject( NULL, new QRectF( rect ), "HB_QRECTF", NULL, 0 );
      hb_vmEvalBlockV( block, 3, p1, p2, p3 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );
      hb_itemRelease( p3 );

      hb_vmRequestRestore();
   }
#endif
   QGraphicsScene::drawBackground( painter, rect );
}

/*----------------------------------------------------------------------*/
/*                             Drag & Drop                              */
/*----------------------------------------------------------------------*/

void HBQGraphicsScene::contextMenuEvent( QGraphicsSceneContextMenuEvent * event )
{
   HBQGraphicsItem * item = dynamic_cast< HBQGraphicsItem * >( itemAt( event->scenePos(), QTransform() ) );
   if( ! item )
   {
      if( block && hb_vmRequestReenter() )
      {
         PHB_ITEM p1 = hb_itemPutNI( NULL, QEvent::GraphicsSceneContextMenu );
         PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENECONTEXTMENUEVENT", NULL, 0 );
         hb_vmEvalBlockV( block, 2, p1, p2 );
         hb_itemRelease( p1 );
         hb_itemRelease( p2 );

         hb_vmRequestRestore();
      }
   }
   QGraphicsScene::contextMenuEvent( event );
}

void HBQGraphicsScene::dragEnterEvent( QGraphicsSceneDragDropEvent * event )
{
   if( block && hb_vmRequestReenter() )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, ( int ) QEvent::GraphicsSceneDragEnter );
      PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENEDRAGDROPEVENT", NULL, 0 );
      hb_vmEvalBlockV( block, 2, p1, p2 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );

      hb_vmRequestRestore();
   }
   else
   {
      QGraphicsScene::dragEnterEvent( event );
   }
}
void HBQGraphicsScene::dragLeaveEvent( QGraphicsSceneDragDropEvent * event )
{
   if( block && hb_vmRequestReenter() )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, ( int ) QEvent::GraphicsSceneDragLeave );
      PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENEDRAGDROPEVENT", NULL, 0 );
      hb_vmEvalBlockV( block, 2, p1, p2 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );

      hb_vmRequestRestore();
   }
   else
   {
      QGraphicsScene::dragLeaveEvent( event );
   }
}
void HBQGraphicsScene::dragMoveEvent( QGraphicsSceneDragDropEvent * event )
{
   if( block && hb_vmRequestReenter() )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, ( int ) QEvent::GraphicsSceneDragMove );
      PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENEDRAGDROPEVENT", NULL, 0 );
      hb_vmEvalBlockV( block, 2, p1, p2 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );

      hb_vmRequestRestore();
   }
   else
   {
      QGraphicsScene::dragMoveEvent( event );
   }
}
void HBQGraphicsScene::dropEvent( QGraphicsSceneDragDropEvent * event )
{
   if( block && hb_vmRequestReenter() )
   {
      const QMimeData * mime = event->mimeData();

      if( mime->hasFormat( ( QString ) "application/x-qabstractitemmodeldatalist" ) )
      {
         PHB_ITEM p1 = hb_itemPutNI( NULL, ( int ) QEvent::GraphicsSceneDrop );
         PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENEDRAGDROPEVENT", NULL, 0 );
         PHB_ITEM p3 = hb_itemNew( NULL );

         QTreeWidget * tree = dynamic_cast< QTreeWidget * >( event->source() );
         QTreeWidgetItem * curItem = dynamic_cast< QTreeWidgetItem * >( tree->currentItem() );
         if( tree->indexOfTopLevelItem( curItem ) == -1 )
         {
            QTreeWidgetItem * parent = dynamic_cast< QTreeWidgetItem * >( curItem->parent() );

            if( curItem )
            {
               hb_arrayNew( p3, 3 );

               hb_arraySetC( p3, 1, tree->objectName().toLatin1().data() );
               hb_arraySetC( p3, 2, parent->text( 0 ).toLatin1().data() );
               hb_arraySetC( p3, 3, curItem->text( 0 ).toLatin1().data() );

               hb_vmEvalBlockV( block, 3, p1, p2, p3 );
            }
         }
         hb_itemRelease( p1 );
         hb_itemRelease( p2 );
         hb_itemRelease( p3 );
      }
      else
      {
         PHB_ITEM p1 = hb_itemPutNI( NULL, ( int ) QEvent::GraphicsSceneDrop );
         PHB_ITEM p2 = hbqt_bindGetHbObject( NULL, ( void * ) event, "HB_QGRAPHICSSCENEDRAGDROPEVENT", NULL, 0 );
         hb_vmEvalBlockV( block, 2, p1, p2 );
         hb_itemRelease( p1 );
         hb_itemRelease( p2 );
      }
      hb_vmRequestRestore();
   }
   else
   {
      QGraphicsScene::dropEvent( event );
   }
}

/*----------------------------------------------------------------------*/
/*                              General                                 */
/*----------------------------------------------------------------------*/

bool HBQGraphicsScene::showGrid()
{
   return m_showGrid;
}
void HBQGraphicsScene::setShowGrid( bool showGrid )
{
   m_showGrid = showGrid;
   drawBorder();
}
void HBQGraphicsScene::drawBorder()
{
   QPen p;

   delete m_paperBorder;
   delete m_pageBorder;

   m_paperBorder = addRect( m_paperRect );

   //p.setStyle( Qt::SolidLine );
   p.setStyle( Qt::NoPen );
   p.setColor( QColor( 255, 255, 255 ) );
   p.setWidth( 0 );
   m_pageBorder = addRect( geometry() );
   m_pageBorder->setPen( p );

   if( m_showGrid )
   {
      QPen p, p1;
      p.setColor( QColor( 225, 225, 225 ) );
      p.setWidth( 1 );
      p.setStyle( Qt::DotLine );

      p1.setColor( QColor( 210, 210, 210 ) );
      p1.setWidth( 1 );
      p1.setStyle( Qt::DotLine );

      if( views().size() )
      {
         p.setWidth( 1 + 1 / views()[ 0 ]->transform().m11() );
      }
      for( int i = 0, n = 0; i < width(); i += ( 5.0 / UNIT ), n++ )
      {
         QGraphicsLineItem * line = new QGraphicsLineItem( m_paperBorder );
         line->setPen( n % 2 == 0 ? p : p1 );
         line->setLine( i, 0, i, height() );
         if( n % 2 == 0 )
         {
            QGraphicsTextItem * text = new QGraphicsTextItem( QString::number( i * UNIT / 10 ), m_paperBorder );
            text->setPos( i - 15, 0.0 );
            text->setFont( QFont( "Ariel", 12 ) );
         }
      }
      for( int i = 0, n = 0; i < height(); i += ( 5.0 / UNIT ), n++ )
      {
         QGraphicsLineItem * line = new QGraphicsLineItem( m_paperBorder );
         line->setPen( n % 2 == 0 ? p : p1 );
         line->setLine( 0, i, width(), i );
         if( n % 2 == 0 )
         {
            QGraphicsTextItem * text = new QGraphicsTextItem( QString::number( i * UNIT / 10 ), m_paperBorder );
            text->setPos( 0.0, i - 15 );
            text->setFont( QFont( "Ariel", 12 ) );
         }
      }
   }
   m_pageBorder->setZValue( -1 );
   m_paperBorder->setZValue( -2 );
}

/*----------------------------------------------------------------------*/
/*                              Magnets                                 */
/*----------------------------------------------------------------------*/

void HBQGraphicsScene::setLeftMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Left;
   else
   {
      int a = 0xffff;
      a           ^= Left;
      m_magnets   &= a;
   }
}
void HBQGraphicsScene::setRightMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Right;
   else
   {
      int a = 0xffff;
      a           ^= Right;
      m_magnets   &= a;
   }
}
void HBQGraphicsScene::setTopMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Top;
   else
   {
      int a = 0xffff;
      a           ^= Top;
      m_magnets   &= a;
   }
}
void HBQGraphicsScene::setBottomMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Bottom;
   else
   {
      int a = 0xffff;
      a           ^= Bottom;
      m_magnets   &= a;
   }
}
void HBQGraphicsScene::setHorizontalMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Horizontal;
   else
   {
      int a = 0xffff;
      a           ^= Horizontal;
      m_magnets   &= a;
   }
}
void HBQGraphicsScene::setVerticalMagnet( bool magneted )
{
   if( magneted )
      m_magnets |= Vertical;
   else
   {
      int a = 0xffff;
      a           ^= Vertical;
      m_magnets   &= a;
   }
}

void HBQGraphicsScene::drawMagnets( HBQGraphicsItem * item )
{
   foreach( QGraphicsItem * it, m_gideLines )
   removeItem( it );

   m_gideLines.clear();

   if( ! m_magnets )
      return;

   QPen p;
   p.setWidth( 5 );
   p.setColor( Qt::red );
   p.setStyle( Qt::DashDotLine );

   foreach( QGraphicsItem * it, items() )
   {
      HBQGraphicsItem * ite = dynamic_cast< HBQGraphicsItem * >( it );

      if( ! ite || ite == item )
         continue;

      if( ( m_magnets & Left ) && qFabs( item->mapToScene( QPointF( 0, 0 ) ).x() - ite->mapToScene( QPointF( 0, 0 ) ).x() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( ite->mapToItem( item->parentItem(), QPointF( 0, 0 ) ).x(), item->geometry().y(), item->geometry().width(), item->geometry().height() ) );

         if( item->mapToScene( 0, 0 ).y() < ite->mapToScene( 0, ite->geometry().height() ).y() )
            m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), item->mapToScene( 0, 0 ).x(), ite->mapToScene( 0, ite->geometry().height() ).y(), p ) );
         else
            m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), ite->mapToScene( 0, 0 ).y(), item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Left ) && qFabs( item->mapToScene( QPointF( 0, 0 ) ).x() - ite->mapToScene( QPointF( ite->geometry().width(), 0 ) ).x() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( ite->mapToItem( item->parentItem(), QPointF( ite->geometry().width(), 0 ) ).x(), item->geometry().y(), item->geometry().width(), item->geometry().height() ) );

         if( item->mapToScene( 0, 0 ).y() < ite->mapToScene( 0, ite->geometry().height() ).y() )
            m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), item->mapToScene( 0, 0 ).x(), ite->mapToScene( 0, ite->geometry().height() ).y(), p ) );
         else
            m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), ite->mapToScene( 0, 0 ).y(), item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Right ) && qFabs( item->mapToScene( item->geometry().width(), 0 ).x() - ite->mapToScene( 0, 0 ).x() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( ite->mapToItem( item->parentItem(), 0, 0 ).x() - item->geometry().width(), item->geometry().y(), item->geometry().width(), item->geometry().height() ) );

         if( item->mapToScene( item->geometry().width(), 0 ).y() < ite->mapToScene( ite->geometry().width(), ite->geometry().height() ).y() )
            m_gideLines.push_back( addLine( item->mapToScene( item->geometry().width(), 0 ).x(), item->mapToScene( item->geometry().width(), 0 ).y(), item->mapToScene( item->geometry().width(), 0 ).x(), ite->mapToScene( ite->geometry().width(), ite->geometry().height() ).y(), p ) );
         else
            m_gideLines.push_back( addLine( item->mapToScene( item->geometry().width(), 0 ).x(), ite->mapToScene( ite->geometry().width(), 0 ).y(), item->mapToScene( item->geometry().width(), 0 ).x(), item->mapToScene( item->geometry().width(), item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Right ) && qFabs( item->mapToScene( item->geometry().width(), 0 ).x() - ite->mapToScene( ite->geometry().width(), 0 ).x() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( ite->mapToItem( item->parentItem(), ite->geometry().width(), 0 ).x() - item->geometry().width(), item->geometry().y(), item->geometry().width(), item->geometry().height() ) );

         if( item->mapToScene( item->geometry().width(), 0 ).y() < ite->mapToScene( ite->geometry().width(), ite->geometry().height() ).y() )
            m_gideLines.push_back( addLine( item->mapToScene( item->geometry().width(), 0 ).x(), item->mapToScene( item->geometry().width(), 0 ).y(), ite->mapToScene( ite->geometry().width(), 0 ).x(), ite->mapToScene( ite->geometry().width(), ite->geometry().height() ).y(), p ) );
         else
            m_gideLines.push_back( addLine( ite->mapToScene( ite->geometry().width(), 0 ).x(), ite->mapToScene( ite->geometry().width(), 0 ).y(), item->mapToScene( item->geometry().width(), 0 ).x(), item->mapToScene( item->geometry().width(), item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Top ) && qFabs( item->mapToScene( QPointF( 0, 0 ) ).y() - ite->mapToScene( QPointF( 0, 0 ) ).y() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( item->geometry().x(), ite->mapToItem( item->parentItem(), QPointF( 0, 0 ) ).y(), item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), ite->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), p ) );
      }

      if( ( m_magnets & Top ) && qFabs( item->mapToScene( QPointF( 0, 0 ) ).y() - ite->mapToScene( QPointF( 0, ite->geometry().height() ) ).y() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( item->geometry().x(), ite->mapToItem( item->parentItem(), QPointF( 0, ite->geometry().height() ) ).y(), item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), ite->mapToScene( 0, 0 ).x(), item->mapToScene( 0, 0 ).y(), p ) );
      }

      if( ( m_magnets & Bottom ) && qFabs( item->mapToScene( QPointF( 0, item->geometry().height() ) ).y() - ite->mapToScene( QPointF( 0, ite->geometry().height() ) ).y() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( item->geometry().x(), ite->mapToItem( item->parentItem(), QPointF( 0, ite->geometry().height() ) ).y() - item->geometry().height(), item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), ite->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Bottom ) && qFabs( item->mapToScene( QPointF( 0, item->geometry().height() ) ).y() - ite->mapToScene( QPointF( 0, 0 ) ).y() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( item->geometry().x(), ite->mapToItem( item->parentItem(), QPointF( 0, 0 ) ).y() - item->geometry().height(), item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), ite->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() ).y(), p ) );
      }

      if( ( m_magnets & Horizontal ) && qFabs( item->mapToScene( QPointF( 0, item->geometry().height() / 2 ) ).y() - ite->mapToScene( QPointF( 0, ite->geometry().height() / 2 ) ).y() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( item->geometry().x(), ite->mapToItem( item->parentItem(), QPointF( 0, ite->geometry().height() / 2 ) ).y() - item->geometry().height() / 2, item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() / 2 ).y(), ite->mapToScene( 0, 0 ).x(), item->mapToScene( 0, item->geometry().height() / 2 ).y(), p ) );
      }

      if( ( m_magnets & Vertical ) && qFabs( item->mapToScene( QPointF( item->geometry().width() / 2, 0 ) ).x() - ite->mapToScene( QPointF( ite->geometry().width() / 2, 0 ) ).x() ) <= m_magnetArea )
      {
         item->setGeometry( QRectF( ite->mapToItem( item->parentItem(), QPointF( ite->geometry().width() / 2, 0 ) ).x() - item->geometry().width() / 2, item->geometry().y(), item->geometry().width(), item->geometry().height() ) );
         m_gideLines.push_back( addLine( item->mapToScene( item->geometry().width() / 2, 0 ).x(), item->mapToScene( 0, 0 ).y(), item->mapToScene( item->geometry().width() / 2, 0 ).x(), ite->mapToScene( 0, ite->geometry().height() ).y(), p ) );
      }
   }
}

/*----------------------------------------------------------------------*/

#endif
