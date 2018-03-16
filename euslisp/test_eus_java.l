#!/usr/bin/env roseus

(require "package://eus_java/euslisp/eus_java.l")

(eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
(eus_java::fargs-clear)
(eus_java::fargs-add-string (format nil "[~A]" (car (piped-fork-returns-list "LANG=C date"))))
(setq eus_java::*test-cid* (eus_java::add-class "Test" (eus_java::arg-keylist2string '(:string) nil)))

(eus_java::jdefun eus_java::test-v eus_java::*test-cid* "v" () nil)
(eus_java::jdefun eus_java::test-l eus_java::*test-cid* "l" (:long) :long)
(eus_java::jdefun eus_java::test-d eus_java::*test-cid* "d" (:double) :double)
(eus_java::jdefun eus_java::test-s eus_java::*test-cid* "s" (:string) :string)
(eus_java::jdefun eus_java::test-lv eus_java::*test-cid* "lv" (:larray) :larray)
(eus_java::jdefun eus_java::test-dv eus_java::*test-cid* "dv" (:darray) :darray)

(defun eus_java::test-test
  nil
  (print (eus_java::test-v))
  (print (eus_java::test-l 7))
  (print (eus_java::test-d 3.14))
  (print (eus_java::test-s "noda"))
  (print (eus_java::test-lv #i(1 2 3)))
  (print (eus_java::test-dv #F(1.1 2.2 3.3))))

(let* ((ff '(lambda (str) (and (stringp str) (> (length str) 2) (eq (aref str 0) #\-))))
       (flag (find-if ff lisp::*eustop-argument*)) (stm 10) (mtm 15))
  (cond
   ((substringp "run-test" flag)
    (eus_java::test-test)
    (eus_java::destroy-vm)
    (exit))))

;; @deprecated
(defclass eus_java::__func
  :super object
  :slots (cid fid fstr astr))
(defmethod eus_java::__func
  (:init
   (_cid _fstr _astr)
   (setq cid _cid fstr _fstr astr _astr
	 fid (eus_java::get-method cid fstr astr))
   self)
  (:eval
   (&rest args)
   (eus_java::fargs-clear)
   (dolist (a args)
     (cond
      ((integerp a) (eus_java::fargs-add-long a))
      ((floatp a) (eus_java::fargs-add-double a))
      ((stringp a) (eus_java::fargs-add-string a))
      ((integer-vector-p a) (eus_java::fargs-add-larray (length a) a))
      ((float-vector-p a) (eus_java::fargs-add-darray (length a) a))
      (t (warning-message 1 "invalid arg type ~A~%" a))))
   (let* ((pos (position #\) astr)) (rstr (subseq astr (+ pos 1))))
     (cond
      ((string-equal rstr "V") (eus_java::call-void-method cid fid))
      ((string-equal rstr "J") (eus_java::call-long-method cid fid)
       (let ((b #i(0))) (eus_java::return-long b) (aref b 0)))
      ((string-equal rstr "D") (eus_java::call-double-method cid fid)
       (let ((b #F(0))) (eus_java::return-double b) (aref b 0)))
      ((string-equal rstr "Ljava/lang/String;")
       (eus_java::call-string-method cid fid)
       (let ((b (instantiate string (eus_java::return-string-length))))
	 (eus_java::return-string (length b) b) b))
      ((string-equal rstr "[J")
       (eus_java::call-larray-method cid fid)
       (let ((b (instantiate integer-vector (eus_java::return-larray-length))))
	 (eus_java::return-larray (length b) b) b))
      ((string-equal rstr "[D")
       (eus_java::call-darray-method cid fid)
       (let ((b (instantiate float-vector (eus_java::return-darray-length))))
	 (eus_java::return-darray (length b) b) b))))))
(defun eus_java::test-testX
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (eus_java::fargs-add-string "eus_java::test4")
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "(Ljava/lang/String;)V"))
  ;;
  (setq eus_java::*test-vf* (instance eus_java::__func :init eus_java::*test-cid* "v" "()V"))
  (print (send eus_java::*test-vf* :eval))
  ;;
  (setq eus_java::*test-lf* (instance eus_java::__func :init eus_java::*test-cid* "l" "(J)J"))
  (print (send eus_java::*test-lf* :eval 3))
  ;;
  (setq eus_java::*test-df* (instance eus_java::__func :init eus_java::*test-cid* "d" "(D)D"))
  (print (send eus_java::*test-df* :eval 3.14))
  ;;
  (setq eus_java::*test-sf* (instance eus_java::__func :init eus_java::*test-cid* "s" "(Ljava/lang/String;)Ljava/lang/String;"))
  (print (send eus_java::*test-sf* :eval "piyo"))
  ;;
  (setq eus_java::*test-lvf* (instance eus_java::__func :init eus_java::*test-cid* "lv" "([J)[J"))
  (print (send eus_java::*test-lvf* :eval #i(1 2 3)))
  ;;
  (setq eus_java::*test-dvf* (instance eus_java::__func :init eus_java::*test-cid* "dv" "([D)[D"))
  (print (send eus_java::*test-dvf* :eval #F(1.1 2.2 3.3)))
  ;;
  (eus_java::destroy-vm))
