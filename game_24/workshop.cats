//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

/* ****** ****** */

/*
** Implementing a workshop
*/

/* ****** ****** */

#ifndef WORKSHOP_CATS
#define WORKSHOP_CATS

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//
#include <pthread.h>
//
/* ****** ****** */

typedef ats_ptr_type myjob ;

/* ****** ****** */

typedef struct {
//
  pthread_mutex_t JS_mutex ;
//
  pthread_cond_t JSisemp_cond ;
  pthread_cond_t JSisful_cond ;
//
  pthread_mutex_t NWK_mutex ;
  pthread_cond_t NWKiszero_cond ;
  int nworker ;
//
  ats_ptr_type jobstore ;
//
  pthread_spinlock_t RES_lock ;
  ats_ptr_type res ;
//
} workshop_struct ;

typedef workshop_struct *workshop ;

/* ****** ****** */

ATSinline()
ats_int_type
workshop_get_nworker
  (ats_ptr_type ws0) {
  return ((workshop)ws0)->nworker ;
} // end of [workshop_get_nworker]

ATSinline()
ats_void_type
workshop_inc_nworker
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_mutex_lock (&ws->NWK_mutex) ;
  ws->nworker += 1 ;
  pthread_mutex_unlock (&ws->NWK_mutex) ;
  return ;
} // end of [workshop_inc_nworker]

ATSinline()
ats_void_type
workshop_dec_nworker
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_mutex_lock (&ws->NWK_mutex) ;
  ws->nworker -= 1 ;
  int nworker = ws->nworker ;
  pthread_mutex_unlock (&ws->NWK_mutex) ;
  if (nworker==0) pthread_cond_broadcast (&ws->NWKiszero_cond) ;
  return ;
} // end of [workshop_dec_nworker]

/* ****** ****** */

ATSinline()
ats_ptr_type
workshop_get_res
(ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;  
  pthread_spin_lock (&ws->RES_lock) ;
  ats_ptr_type res = ws->res ;
  pthread_spin_unlock (&ws->RES_lock) ;
  return res ;
} // end of [workshop_get_res]

ATSinline()
ats_void_type
workshop_set_res (
  ats_ptr_type ws0, ats_ptr_type xs
) {
  workshop ws = (workshop)ws0 ;  
  pthread_spin_lock (&ws->RES_lock) ;
  ws->res = xs ;
  pthread_spin_unlock (&ws->RES_lock) ;
  return ;
} // end of [workshop_set_res]

/* ****** ****** */

/*
fun workshop_get_jobstore (ws: workshop): jobstore
*/
ATSinline()
ats_ptr_type
workshop_get_jobstore
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_mutex_lock (&ws->JS_mutex) ;
  return ws->jobstore ;
} // end of [workshop_get_jobstore]

/*
fun workshop_put_jobstore (ws: workshop, js: jobstore): void
*/
ATSinline()
ats_void_type
workshop_put_jobstore (
  ats_ptr_type ws0, ats_ptr_type js
) {
  workshop ws = (workshop)ws0 ;
  ws->jobstore = js ;
  pthread_mutex_unlock (&ws->JS_mutex) ;
  return ;
} // end of [workshop_put_jobstore]

/* ****** ****** */

/*
fun workshop_block_isemp
  (ws: workshop, js: !jobstore): void // blocking the caller
*/
ATSinline()
ats_void_type
workshop_block_isemp (
  ats_ptr_type ws0, ats_ptr_type js
) {
  workshop ws = (workshop)ws0 ;
  ws->jobstore = js ;
  pthread_cond_wait (&ws->JSisemp_cond, &ws->JS_mutex) ;
  pthread_mutex_unlock (&ws->JS_mutex) ;
  return ;
} // end of [workshop_block_isemp]

/*
fun workshop_unblock_isemp (ws: workshop): void // unblocking the blocked submitters
*/
ATSinline()
ats_void_type
workshop_unblock_isemp
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_cond_broadcast (&ws->JSisemp_cond) ;
  return ;
} // end of [workshop_unblock_isemp]

/* ****** ****** */

/*
fun workshop_block_isful (ws: workshop, js: jobstore): void // blocking the caller
*/
ATSinline()
ats_void_type
workshop_block_isful (
  ats_ptr_type ws0, ats_ptr_type js
) {
  workshop ws = (workshop)ws0 ;
  ws->jobstore = js ;
  pthread_cond_wait (&ws->JSisful_cond, &ws->JS_mutex) ;
  pthread_mutex_unlock (&ws->JS_mutex) ;
  return ;
} // end of [workshop_block_isful]

/*
fun workshop_unblock_isful (ws: workshop): void // unblocking the blocked submitters
*/
ATSinline()
ats_void_type
workshop_unblock_isful
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_cond_broadcast (&ws->JSisful_cond) ;
  return ;
} // end of [workshop_unblock_isful]

/* ****** ****** */

#endif // WORKSHOP_CATS

/* ****** ****** */

/* end of [workshop.cats] */