(*
** Implementing a workshop
*)

(* ****** ****** *)

%{#
//
#include "workshop2.cats"
//
%} // end of [%{#]

(* ****** ****** *)

staload "libc/SATS/time.sats"

(* ****** ****** *)

absviewtype job (a:type) = a
viewtypedef jobopt (a:type) = Option_vt (job(a))

fun{a:type} job_new (): job (a)
fun{a:type} job_finish (x: job (a)): void
fun{a:type} job_get_priority (x: !job (a)):<> lint

fun{a:type} job_compare (x1: !job a, x2: !job a):<> int

(* ****** ****** *)

absviewtype jobstore (a:type)

(* ****** ****** *)

fun{a:type} jobstore_make_nil (): jobstore (a)

fun{a:type} jobstore_getmin_priority (js: !jobstore (a)): lint

(* ****** ****** *)

fun{a:type}
jobstore_get_job (store: &jobstore (a)): jobopt (a)
fun{a:type}
jobstore_put_job (store: &jobstore (a), x: job a): jobopt (a)

(* ****** ****** *)

abstype jobstorelock (a:type) // protected by a mutex

fun
jobstorelock_get_jobstore{a:type}
  (lock: jobstorelock (a)): jobstore (a) = "jobstorelock_get_jobstore"
// end of [jobstorelock_get_jobstore]
fun
jobstorelock_put_jobstore{a:type}
  (lock: jobstorelock (a), js: jobstore (a)): void = "jobstorelock_put_jobstore"
// end of [jobstorelock_put_jobstore]

fun{a:type}
jobstorelock_get_job (lock: jobstorelock (a)): job (a)
fun{a:type}
jobstorelock_put_job (lock: jobstorelock (a), x: job (a)): void

fun
jobstorelock_block_isemp
  {a:type} (
  lock: jobstorelock (a), js: jobstore a
) : void = "jobstorelock_block_isemp"
fun
jobstorelock_unblock_isemp
  {a:type} (lock: jobstorelock (a)): void = "jobstorelock_unblock_isemp"
// end of [jobstorelock_unblock_isemp]

fun
jobstorelock_block_isful
  {a:type} (
  lock: jobstorelock (a), js: jobstore a
) : void = "jobstorelock_block_isful"
fun
jobstorelock_unblock_isful
  {a:type} (lock: jobstorelock (a)): void = "jobstorelock_unblock_isful"
// end of [jobstorelock_unblock_isful]

(* ****** ****** *)

abstype workshop // representing a workshop

(* ****** ****** *)

abstype jobknd = $extype "jobknd"
abstype tjobknd = $extype "tjobknd"

viewtypedef job = job (jobknd)
viewtypedef jobstore = jobstore (jobknd)

viewtypedef tjob = job (tjobknd)
viewtypedef tjobstore = jobstore (tjobknd)

(* ****** ****** *)

fun job_new_jobknd (n: int,shop:workshop): job
fun job_new_tjobknd (timestamp:lint, n: int, shop:workshop): tjob
fun job_finish_jobknd (x: job): void
fun job_get_priority_jobknd (x: !job):<> lint
fun job_get_priority_tjobknd (x: !tjob):<> lint

fun job_compare_jobknd (x1: !job, x2: !job):<> int
fun job_compare_tjobknd (x1: !tjob, x2: !tjob):<> int

(* ****** ****** *)

fun tjob2job (x: tjob): job

(* ****** ****** *)

symintr workshop_new
fun workshop_new0 (): workshop = "workshop_new"
overload workshop_new with workshop_new0
fun workshop_new2 (js: jobstore, tjs: tjobstore): workshop = "workshop_new2"
overload workshop_new with workshop_new2

fun workshop_add_worker (ws: workshop): int(*err*)
fun workshop_add_tmanager (ws: workshop): int(*err*)

(* ****** ****** *)

fun workshop_get_nworker
  (ws: workshop): int = "workshop_get_nworker"
// end of [workshop_get_nworker]

fun workshop_awaken_tmanager (ws: workshop): void

(* ****** ****** *)

fun workshop_get_jobstorelock
  (ws: workshop): jobstorelock (jobknd) = "workshop_get_jobstorelock"
fun workshop_get_tjobstorelock
  (ws: workshop): jobstorelock (tjobknd) = "workshop_get_tjobstorelock"

(* ****** ****** *)

fun workshop_get_job (ws: workshop): job
fun workshop_put_job (ws: workshop, x: job): void

(* ****** ****** *)

fun workshop_get_tjob (ws: workshop): tjob
fun workshop_put_tjob (ws: workshop, x: tjob): void

(* ****** ****** *)

fun workshop_getready_tjob
  (ws: workshop, ready: &lint? >> lint): Option_vt (tjob)

(* ****** ****** *)

(* end of [workshop2.sats] *)