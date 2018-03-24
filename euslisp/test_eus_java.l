#!/usr/bin/env roseus

(require "package://eus_java/euslisp/eus_java.l")

(let ((pkg (ros::rospack-find "eus_java")))
  (eus_java::create-vm (format nil "~A/java" pkg)))
(setq eus_java::*test-cid* (eus_java::add-class "Test" (format nil "test_eus_java_~A" (car (unix::gettimeofday)))))

(eus_java::jdefun eus_java::test-v eus_java::*test-cid* "v" () nil)
(eus_java::jdefun eus_java::test-l eus_java::*test-cid* "l" (:long) :long)
(eus_java::jdefun eus_java::test-d eus_java::*test-cid* "d" (:double) :double)
(eus_java::jdefun eus_java::test-s eus_java::*test-cid* "s" (:string) :string)
(eus_java::jdefun eus_java::test-lv eus_java::*test-cid* "lv" (:larray) :larray)
(eus_java::jdefun eus_java::test-dv eus_java::*test-cid* "dv" (:darray) :darray)
(eus_java::jdefun eus_java::test-exponential-java eus_java::*test-cid* "test_exponential" (:double :long) :double)
(eus_java::jdefun eus_java::test-pi-java eus_java::*test-cid* "test_pi" (:long) :double)

(defun eus_java::test-test
  nil
  (print (eus_java::test-v))
  (print (eus_java::test-l 7))
  (print (eus_java::test-d 3.14))
  (print (eus_java::test-s "noda"))
  (print (eus_java::test-lv #i(1 2 3)))
  (print (eus_java::test-dv #F(1.1 2.2 3.3))))

(defun eus_java::test-exponential-eus (d l)
  (let ((r d))
    (while (> (setq l (- l 1)) 0) (setq r (* r d))) r))

(defun eus_java::test-pi-eus (i)
  (let ((p 0))
    (while (> (setq i (- i 1)) 0)
      (setq p (+ p (/ 1.0 (* i i)))))
    (sqrt (* 6 p))))

(defun eus_java::test-calc-comp-func
  (f a r) (list 'lambda '(i) (list 'bench2 (list 'if (list 'not (list 'eps= (cons f a) r)) '(throw :test-calc-inconsistent nil)))))
(defun eus_java::length-str (str len)
  (if (numberp str) (setq str (format nil "~1,6f" str)))
  (cond
   ((eq (length str) len) str)
   ((> (length str) len) (subseq str 0 len))
   (t
    (let ((ret (instantiate string len))
	  (i 0) (slen (- len (length str))))
      (while (< i slen) (aset ret i #\ ) (setq i (+ i 1)))
      (while (< i len)
	(aset ret i (aref str (- i slen)))
	(setq i (+ i 1)))
      ret))))
(defun eus_java::test-calc-comp
  (cnt fe fc fj args)
  (let* ((l 8) (b (make-list cnt)) retv reft re rc rj)
    (format t "~A times calculation of ~A~%" cnt fe)
    (setq reft (bench2 (setq refv (apply fe args))))
    (format t "euslisp reference = ~A in ~A [s]~%" refv reft)
    (format t "~A||~A|~A|~A~%"
	    (eus_java::length-str "LANG" l)
	    (eus_java::length-str "AVE[s]" l)
	    (eus_java::length-str "MIN[s]" l)
	    (eus_java::length-str "MAX[s]" l))
    (format t "~A||~A|~A|~A~%"
	    (eus_java::length-str "---------" l)
	    (eus_java::length-str "---------" l)
	    (eus_java::length-str "---------" l)
	    (eus_java::length-str "---------" l))
    (format t "~A||~A|~A|~A~%"
	    (eus_java::length-str "EUS" l)
	    (eus_java::length-str reft l)
	    (eus_java::length-str "once" l)
	    (eus_java::length-str "once" l))
    (setq rc (eus_java::test-calc-comp-func fc args refv)
	  rc (mapcar rc b))
    (format t "~A||~A|~A|~A~%"
	    (eus_java::length-str "CPP" l)
	    (eus_java::length-str (/ (apply '+ rc) cnt) l)
	    (eus_java::length-str (apply 'min rc) l)
	    (eus_java::length-str (apply 'max rc) l))
    (setq rj (eus_java::test-calc-comp-func fj args refv)
	  rj (mapcar rj b))
    (format t "~A||~A|~A|~A~%"
	    (eus_java::length-str "JAVA" l)
	    (eus_java::length-str (/ (apply '+ rj) cnt) l)
	    (eus_java::length-str (apply 'min rj) l)
	    (eus_java::length-str (apply 'max rj) l))
    t))

(let* ((test-flag
	(find-if
	 '(lambda (str)
	    (and (stringp str)
		 (> (length str) (length "--test"))
		 (string-equal (subseq str 0 (length "--test"))
			       "--test")))
	 lisp::*eustop-argument*)))
  (cond
   (test-flag
    (sys::gc)
    (cond
     ((substringp "funcall" test-flag)
      (eus_java::test-test))
     ((substringp "exp" test-flag)
      (eus_java::test-calc-comp 100 'eus_java::test-exponential-eus 'eus_java::test-exponential-cpp 'eus_java::test-exponential-java '(1.000001 1000000)))
     ((substringp "pi" test-flag)
      (eus_java::test-calc-comp 100 'eus_java::test-pi-eus 'eus_java::test-pi-cpp 'eus_java::test-pi-java '(1000000)))
     (t (warning-message 1 "test_eus_java.l unknown test-flag ~A~%" test-flag)))
    (eus_java::destroy-vm)
    (exit))))

#|
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
