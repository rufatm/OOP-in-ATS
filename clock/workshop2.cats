/*
** Implementing a workshop
*/

/* ****** ****** */

#ifndef WORKSHOP2_CATS
#define WORKSHOP2_CATS

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//
#include "signal.h"
//
#include <pthread.h>
//
/* ****** ****** */

typedef ats_ptr_type jobknd ;
typedef ats_ptr_type tjobknd ;

/* ****** ****** */

typedef struct {
//
  pthread_mutex_t JS_mutex ;
  pthread_cond_t JSisemp_cond ;
  pthread_cond_t JSisful_cond ;
//
  ats_ptr_type jobstore ;
//
} jobstorelock_struct ;

typedef jobstorelock_struct *jobstorelock ;

/* ****** ****** */

/*
fun jobstorelock_get_jobstore (lock: jobstorelock): jobstore
*/
ATSinline()
ats_ptr_type
jobstorelock_get_jobstore
  (ats_ptr_type lock0) {
  jobstorelock lock = (jobstorelock)lock0 ;
  pthread_mutex_lock (&lock->JS_mutex) ;
  return lock->jobstore ;
} // end of [jobstorelock_get_jobstore]

/*
fun jobstorelock_put_jobstore (lock: jobstorelock, js: jobstore): void
*/
ATSinline()
ats_void_type
jobstorelock_put_jobstore (
  ats_ptr_type lock0, ats_ptr_type js
) {
  jobstorelock lock = (jobstorelock)lock0 ;
  lock->jobstore = js ;
  pthread_mutex_unlock (&lock->JS_mutex) ;
  return ;
} // end of [jobstorelock_put_jobstore]

/* ****** ****** */

/*
fun jobstorelock_block_isemp
  (lock: jobstorelock, js: !jobstore): void // blocking the caller
*/
ATSinline()
ats_void_type
jobstorelock_block_isemp (
  ats_ptr_type lock0, ats_ptr_type js
) {
  jobstorelock lock = (jobstorelock)lock0 ;
  lock->jobstore = js ;
  pthread_cond_wait (&lock->JSisemp_cond, &lock->JS_mutex) ;
  pthread_mutex_unlock (&lock->JS_mutex) ;
  return ;
} // end of [jobstorelock_block_isemp]

/*
fun jobstorelock_unblock_isemp (lock: jobstorelock): void // unblocking the blocked submitters
*/
ATSinline()
ats_void_type
jobstorelock_unblock_isemp
  (ats_ptr_type lock0) {
  jobstorelock lock = (jobstorelock)lock0 ;
  pthread_cond_broadcast (&lock->JSisemp_cond) ;
  return ;
} // end of [jobstorelock_unblock_isemp]

/* ****** ****** */

/*
fun jobstorelock_block_isful (lock: jobstorelock, js: jobstore): void // blocking the caller
*/
ATSinline()
ats_void_type
jobstorelock_block_isful (
  ats_ptr_type lock0, ats_ptr_type js
) {
  jobstorelock lock = (jobstorelock)lock0 ;
  lock->jobstore = js ;
  pthread_cond_wait (&lock->JSisful_cond, &lock->JS_mutex) ;
  pthread_mutex_unlock (&lock->JS_mutex) ;
  return ;
} // end of [jobstorelock_block_isful]

/*
fun jobstorelock_unblock_isful (lock: jobstorelock): void // unblocking the blocked submitters
*/
ATSinline()
ats_void_type
jobstorelock_unblock_isful
  (ats_ptr_type lock0) {
  jobstorelock lock = (jobstorelock)lock0 ;
  pthread_cond_broadcast (&lock->JSisful_cond) ;
  return ;
} // end of [jobstorelock_unblock_isful]

/* ****** ****** */

typedef struct {
//
  volatile sig_atomic_t nworker ;
//
  pthread_t tmanager ;
  volatile sig_atomic_t ntmanager ;  
//
  jobstorelock_struct jobstorelock ; // flat embedding
  jobstorelock_struct tjobstorelock ; // flat embedding
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
  ((workshop)ws0)->nworker += 1 ; return ;
} // end of [workshop_inc_nworker]

/* ****** ****** */

ATSinline()
ats_int_type
workshop_get_ntmanager
  (ats_ptr_type ws0) {
  return ((workshop)ws0)->ntmanager ;
} // end of [workshop_get_ntmanager]

ATSinline()
ats_void_type
workshop_inc_ntmanager
  (ats_ptr_type ws0) {
  ((workshop)ws0)->ntmanager += 1 ; return ;
} // end of [workshop_inc_ntmanager]

/* ****** ****** */

ATSinline()
pthread_t
workshop_get_tmanager
  (ats_ptr_type ws0) {
  return ((workshop)ws0)->tmanager ;
} // end of [workshop_get_tmanager]

ATSinline()
ats_void_type
workshop_set_tmanager (
  ats_ptr_type ws0, pthread_t tid
) {
  ((workshop)ws0)->tmanager = tid ; return ;
} // end of [workshop_set_tmanager]

/* ****** ****** */

/*
fun workshop_get_jobstorelock (ws: workshop): jobstorelock
*/
ATSinline()
ats_ptr_type
workshop_get_jobstorelock
  (ats_ptr_type ws0) {
  return &((workshop)ws0)->jobstorelock ;
} // end of [workshop_get_jobstorelock]

/*
fun workshop_get_tjobstorelock (ws: workshop): tjobstorelock
*/
ATSinline()
ats_ptr_type
workshop_get_tjobstorelock
  (ats_ptr_type ws0) {
  return &((workshop)ws0)->tjobstorelock ;
} // end of [workshop_get_tjobstorelock]

/* ****** ****** */

#endif // WORKSHOP2_CATS

/* ****** ****** */

/* end of [workshop2.cats] */