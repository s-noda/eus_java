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
(eus_java::jdefun eus_java::optimize eus_java::*jopt* "optimize" () :long)
(eus_java::jdefun eus_java::solution eus_java::*jopt* "solution" () :darray)

(defun eus_java::jopt-test1
  nil
  (eus_java::clear-request)
  (eus_java::set-tolerance 1e-3)
  (eus_java::set-initial-guess #F(1 1))
  (eus_java::set-quadratic-objective #F(1 0 0 1) #F(0 0) 0)
  (if (plusp (eus_java::optimize))
      (print (eus_java::solution))
    (print 'failed)))
