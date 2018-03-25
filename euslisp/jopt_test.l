#!/usr/bin/env roseus

(require "package://eus_java/euslisp/eus_java.l")

(labels
 ((pap (r p) (if (null p) "" (format nil "~A/~A:~A" r (car p) (pap r (cdr p))))))
 (let* ((pkg (ros::rospack-find "eus_java"))
	(3rd (format nil "~A/3rdparty" pkg))
	(fjar '(lambda (s) (substringp "jar" s)))
	(jars (remove-if-not fjar (directory 3rd)))
	(cp (format nil "~A/java:~A" pkg (pap 3rd jars))))
   (eus_java::create-vm cp)))
(setq eus_java::*jopt* (eus_java::add-class "JOptimizer_test"))

(eus_java::jdefun eus_java::clear-request eus_java::*jopt* "initOptiizationRequest" () nil)
(eus_java::jdefun eus_java::set-initial-guess eus_java::*jopt* "setInitialPoint" (:darray) nil)
(eus_java::jdefun eus_java::set-tolerance eus_java::*jopt* "setTolerance" (:double) nil)
(eus_java::jdefun eus_java::set-quadratic-objective eus_java::*jopt* "setQuadraticObjective" (:darray :darray :double) nil)
(eus_java::jdefun eus_java::set-linear-equality eus_java::*jopt* "setLinearEquality" (:darray :darray) nil)
(eus_java::jdefun eus_java::set-linear-inequality eus_java::*jopt* "setLinearInequality" (:darray :darray) nil)
(eus_java::jdefun eus_java::set-linear-min-max-inequality eus_java::*jopt* "setLinearMinMaxInequality" (:darray :darray :darray) nil)
(eus_java::jdefun eus_java::optimize eus_java::*jopt* "optimize" () :long)
(eus_java::jdefun eus_java::solution eus_java::*jopt* "solution" () :darray)

;; (defvar eus_java::*test-lb* (fill (instantiate float-vector 3) -1000))
;; (defvar eus_java::*test-ub* (fill (instantiate float-vector 3) +1000))
(defvar eus_java::*test-ineq-mat*
  (let ((mu -0.3) (m (make-matrix 4 3)))
    (aset m 0 0 +1) (aset m 0 2 mu)
    (aset m 1 1 +1) (aset m 1 2 mu)
    (aset m 2 0 -1) (aset m 2 2 mu)
    (aset m 3 1 -1) (aset m 3 2 mu)
    m))
(defvar eus_java::*test-ineq-max* (float-vector 0 0 0 0))
(defvar eus_java::*test-guess* (float-vector 0 0 9.8))

(defun eus_java::jopt-test-qp-eiquadprog
  nil
  (require "package://eus_qpoases/euslisp/eus-qpoases.l")
  (solve-qpoases-qp
   :eval-weight-matrix (unit-matrix 3)
   ;; :state-min-vector eus_java::*test-lb*
   ;; :state-max-vector eus_java::*test-ub*
   :inequality-matrix eus_java::*test-ineq-mat*
   ;; :inequality-min-vector eus_java::*test-ineq-min*
   :inequality-max-vector eus_java::*test-ineq-max*
   ))

(defun eus_java::jopt-test-qp
  (&key (d 3))
  (eus_java::clear-request)
  (eus_java::set-tolerance 1e-9)
  (eus_java::set-initial-guess eus_java::*test-guess*)
  (eus_java::set-quadratic-objective
   (send (unit-matrix d) :get-val 'entity)
   (instantiate float-vector d) 0)
  ;; (eus_java::set-linear-min-max-inequality
  (eus_java::set-linear-inequality
   (send eus_java::*test-ineq-mat* :get-val 'entity)
   ;; eus_java::*test-ineq-min*
   eus_java::*test-ineq-max*)
  (if (plusp (eus_java::optimize))
      (print (eus_java::solution))
    (print 'failed)))
