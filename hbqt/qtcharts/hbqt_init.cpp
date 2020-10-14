/*
 * $Id: hbqt_init.cpp 428 2016-10-20 01:05:49Z bedipritpal $
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Marcos Antonio Gambeta (marcosgambeta at gmail dot com)
 * Copyright 2014 Pritpal Bedi (bedipritpal@hotmail.com)
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

#include "hbqt.h"
#include "hbqtinit.h"

#include "hbapiitm.h"
#include "hbvm.h"
#include "hbinit.h"
#include "hbstack.h"

#if QT_VERSION >= 0x050700


#include <QtCharts/QBarSet>
#include <QtCharts/QBoxSet>

/*----------------------------------------------------------------------*/

HB_EXTERN_BEGIN

extern void hbqt_del_QBarSet( void * pObj, int iFlags );
extern void hbqt_del_QBoxSet( void * pObj, int iFlags );

HB_EXTERN_END

/*----------------------------------------------------------------------*/

static void hbqt_SlotsExecQBarSet( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QBARSET", NULL, HBQT_BIT_QOBJECT );
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

static void hbqt_SlotsExecIntQBarSet( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 2 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QBARSET", NULL, HBQT_BIT_QOBJECT );
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
}

static void hbqt_SlotsExecBoolIntQBarSet( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 3 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QBARSET", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPushLogical( *reinterpret_cast< bool( * ) >( arguments[ 1 ] ) );
         hb_vmPushInteger( *reinterpret_cast< int( * ) >( arguments[ 2 ] ) );
         hb_vmPush( p0 );
         hb_vmSend( 3 );
         hb_itemRelease( p0 );
      }
   }
}

static void hbqt_SlotsExecQBoxSet( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 1 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QBOXSET", NULL, HBQT_BIT_QOBJECT );
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

static void hbqt_SlotsExecBoolQBoxSet( PHB_ITEM * codeBlock, void ** arguments, QStringList pList )
{
   Q_UNUSED( pList );
   void * obj = *reinterpret_cast< void*( * ) >( arguments[ 2 ] );
   if( obj )
   {
      PHB_ITEM p0 = hbqt_bindGetHbObject( NULL, obj, "HB_QBOXSET", NULL, HBQT_BIT_QOBJECT );
      if( p0 )
      {
         hb_vmPushEvalSym();
         hb_vmPush( codeBlock );
         hb_vmPushLogical( *reinterpret_cast< bool( * ) >( arguments[ 1 ] ) );
         hb_vmPush( p0 );
         hb_vmSend( 2 );
         hb_itemRelease( p0 );
      }
   }
}

/*----------------------------------------------------------------------*/

HB_FUNC_EXTERN( HB_QBARSET );
HB_FUNC_EXTERN( HB_QBOXSET );

void _hbqtcharts_force_link_for_event( void )
{
   HB_FUNC_EXEC( HB_QBARSET );
   HB_FUNC_EXEC( HB_QBOXSET );
}

static void hbqt_registerCallbacks( void )
{
   hbqt_slots_register_callback( "QBarSet*"                                  , hbqt_SlotsExecQBarSet                  );
   hbqt_slots_register_callback( "int$QBarSet*"                              , hbqt_SlotsExecIntQBarSet               );
   hbqt_slots_register_callback( "bool$int$QBarSet*"                         , hbqt_SlotsExecBoolIntQBarSet           );

   hbqt_slots_register_callback( "QBoxSet*"                                  , hbqt_SlotsExecQBoxSet                  );
   hbqt_slots_register_callback( "bool$QBoxSet*"                             , hbqt_SlotsExecBoolQBoxSet              );
}

/*----------------------------------------------------------------------*/

HB_FUNC( __HBQTCHARTS ) {;}

static void hbqt_lib_init( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );

   hbqt_registerCallbacks();
}

static void hbqt_lib_exit( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );
}

HB_CALL_ON_STARTUP_BEGIN( _hbqtcharts_init_ )
   hb_vmAtInit( hbqt_lib_init, NULL );
   hb_vmAtExit( hbqt_lib_exit, NULL );
HB_CALL_ON_STARTUP_END( _hbqtcharts_init_ )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup _hbqtcharts_init_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( _hbqtcharts_init_ )
   #include "hbiniseg.h"
#endif

#endif
