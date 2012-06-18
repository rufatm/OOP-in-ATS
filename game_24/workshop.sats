//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

(*
** Implementing a workshop
*)

(* ****** ****** *)

%{#
//
#include "workshop.cats"
//
%} // end of [%{#]

(* ****** ****** *)

abstype workshop // representing a workshop

(* ****** ****** *)

absviewtype job

(* ****** ****** *)

fun job_finish (ws: workshop, x: job): void

(* ****** ****** *)

fun job_get_kind (x: !job):<> int
fun job_get_priority (x: !job):<> int

(* ****** ****** *)

viewtypedef jobopt = Option_vt (job)

(* ****** ****** *)

absviewtype jobstore

(* ****** ****** *)

fun jobstore_make_nil (): jobstore
fun jobstore_make_cap {m:pos} (m: size_t m): jobstore

(* ****** ****** *)

fun jobstore_isemp (js: !jobstore): bool
fun jobstore_isful (js: !jobstore): bool

(* ****** ****** *)

fun jobstore_get_job (store: &jobstore): jobopt
fun jobstore_put_job (store: &jobstore, x: job): jobopt

(* ****** ****** *)

fun workshop_new
  (js: jobstore): workshop = "workshop_new"
// end of [workshop_new]

fun workshop_add_worker (ws: workshop): int(*err*)

(* ****** ****** *)

fun workshop_get_nworker
  (ws: workshop): int = "workshop_get_nworker"
// end of [workshop_get_nworker]

(* ****** ****** *)

fun workshop_get_jobstore
  (ws: workshop): jobstore = "workshop_get_jobstore"
// end of [workshop_get_jobstore]

fun workshop_put_jobstore
  (ws: workshop, js: jobstore): void = "workshop_put_jobstore"
// end of [workshop_put_jobstore]

(* ****** ****** *)

fun workshop_get_job (ws: workshop): job // caller may be blocked
fun workshop_get_job_try (ws: workshop): jobopt // caller is not blocked
fun workshop_block_isemp (ws: workshop, js: jobstore): void // blocking the caller
  = "workshop_block_isemp"
fun workshop_unblock_isemp (ws: workshop): void // unblocking the blocked workers
  = "workshop_unblock_isemp"

(* ****** ****** *)

fun workshop_put_job (ws: workshop, x: job): void // caller may be blocked
fun workshop_put_job_try (ws: workshop, x: job): jobopt // caller is not blocked
fun workshop_block_isful (ws: workshop, js: jobstore): void // blocking the caller
  = "workshop_block_isful"
fun workshop_unblock_isful (ws: workshop): void // unblocking the blocked submitters
  = "workshop_unblock_isful"

(* ****** ****** *)

fun workshop_wait_nwisz (ws: workshop): void // blocking until every worker has quit
  = "workshop_wait_nwisz"

(* ****** ****** *)

(* end of [workshop.sats] *)