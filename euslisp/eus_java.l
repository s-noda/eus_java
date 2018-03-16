#!/usr/bin/env roseus

(if (not (find-package "EUS_JAVA")) (make-package "EUS_JAVA"))

(In-package "EUS_JAVA")
(let* ((lib (load-foreign (format nil "~A/libeus_java.so" (ros::rospack-find "eus_java")))))
  (defforeign create-vm lib "eus_java_create_vm" (:string) :integer)
  (defforeign add-class lib "eus_java_add_cls" (:string :string) :integer)
  (defforeign get-method lib "eus_java_get_method" (:integer :string :string) :integer)
  (defforeign destroy-vm lib "eus_java_destroy_vm" () :integer)
  (defforeign test1 lib "eus_java_test1" () :integer)
  ;;
  (defforeign fargs-clear lib "eus_java_fargs_clear" () :integer)
  (defforeign fargs-add-long lib "eus_java_fargs_add_long" (:integer) :integer)
  (defforeign fargs-add-double lib "eus_java_fargs_add_double" (:double) :integer)
  (defforeign fargs-add-string lib "eus_java_fargs_add_string" (:string) :integer)
  (defforeign fargs-add-larray lib "eus_java_fargs_add_larray" (:integer :string) :integer)
  (defforeign fargs-add-darray lib "eus_java_fargs_add_darray" (:integer :string) :integer)
  ;;
  (defforeign call-void-method lib "eus_java_call_void_method" (:integer :integer) :integer)
  (defforeign call-long-method lib "eus_java_call_long_method" (:integer :integer) :integer)
  (defforeign call-double-method lib "eus_java_call_double_method" (:integer :integer) :integer)
  (defforeign call-string-method lib "eus_java_call_string_method" (:integer :integer) :integer)
  (defforeign call-larray-method lib "eus_java_call_larray_method" (:integer :integer) :integer)
  (defforeign call-darray-method lib "eus_java_call_darray_method" (:integer :integer) :integer)
  (defforeign return-long lib "eus_java_return_long" (:string) :integer)
  (defforeign return-double lib "eus_java_return_double" (:string) :integer)
  (defforeign return-string-length lib "eus_java_return_string_length" () :integer)
  (defforeign return-string lib "eus_java_return_string" (:integer :string) :integer)
  (defforeign return-larray-length lib "eus_java_return_larray_length" () :integer)
  (defforeign return-larray lib "eus_java_return_larray" (:integer :string) :integer)
  (defforeign return-darray-length lib "eus_java_return_darray_length" () :integer)
  (defforeign return-darray lib "eus_java_return_darray" (:integer :string) :integer)
  )
(In-package "USER")

(defvar eus_java::*type-str* #("V" "J" "D" "Ljava/lang/String;" "[J" "[D"))
(defvar eus_java::*type-key* #(nil :long :double :string :larray :darray))

(defun eus_java::arg-key2string
  (k) (aref eus_java::*type-str* (position k eus_java::*type-key*)))
(defun eus_java::arg-keylist2string
  (argl ret)
  (apply 'concatenate string "("
	 (append (mapcar 'eus_java::arg-key2string argl)
		 (list ")" (eus_java::arg-key2string ret)))))
(defun eus_java::alphabet-symbol-list
  (&optional (d 10) (st #\a))
  (if (zerop d) nil
    (cons (read-from-string (format nil "~c" st))
	  (eus_java::alphabet-symbol-list (- d 1) (+ st 1)))))
(defun eus_java::jdefun
  (fname cid jfname jarg jret)
  (let* ((arg (eus_java::arg-key2string jarg jret))
	 (fid (eus_java::get-method cid jfname arg))
	 (asym (eus_java::alphabet-symbol-list (length jarg))))
    (list 'defun jfname (append asym '(&optional buf))
	  '(eus_java::fargs-clear)
	  (cons
	   'progn
	   (mapcar
	    '(lambda (a s)
	       (cond
		((eq a :long) (list 'eus_java::fargs-add-long s))
		((eq a :double) (list 'eus_java::fargs-add-double s))
		((eq a :string) (list 'eus_java::fargs-add-string s))
		((eq a :larray) (list 'eus_java::fargs-add-larray (list 'length s)) s)
		((eq a :darray) (list 'eus_java::fargs-add-darray (list 'length s)) s)))
	    jarg asym))
	  (cond
	   ((eq jret nil) (list 'eus_java::call-void-method cid fid))
	   ((eq jret :long) (list 'eus_java::call-long-method cid fid))
	   ((eq jret :double) (list 'eus_java::call-long-method cid fid))
	   ((eq jret :string) (list 'eus_java::call-string-method cid fid))
	   ((eq jret :larray) (list 'eus_java::call-larray-method cid fid))
	   ((eq jret :darray) (list 'eus_java::call-darray-method cid fid)))
	  (cond
	   ((eq jret :long)
	    '(let ((b #i(0))) (eus_java::return-long b) (aref b 0)))
	   ((eq jret :double)
	    '(let ((b #f(0))) (eus_java::return-double b) (aref b 0)))
	   ((eq jret :string)
	    '(let ((l (eus_java::return-string-length))
		   (b (if (and (stringp buf) (>= (length buf) l))
			  buf (instantiate string l))))
	       (eus_java::return-string l b) b))
	   ((eq jret :larray)
	    '(let ((l (eus_java::return-larray-length))
		   (b (if (and (integer-vector-p buf) (>= (length buf) l))
			  buf (instantiate integer-vector l))))
	       (eus_java::return-larray l b) b))
	   ((eq jret :darray)
	    '(let ((l (eus_java::return-darray-length))
		   (b (if (and (float-vector-p buf) (>= (length buf) l))
			  buf (instantiate float-vector l))))
	       (eus_java::return-darray l b) b))))))

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

#|
(eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
(eus_java::fargs-clear)
(setq eus_java::*test-cid* (eus_java::add-class "Test" "()V"))
(eus_java::jdefun 'eus_java::test-v eus_java::*test-cid* "v" nil nil)
|#

(defun eus_java::test2
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "()V"))
  (setq eus_java::*v-fid* (eus_java::get-method eus_java::*test-cid* "v" "()V"))
  (eus_java::call-void-method eus_java::*test-cid* eus_java::*v-fid*)
  (eus_java::destroy-vm))

(defun eus_java::test3
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (eus_java::fargs-add-string "eus_java::test3")
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "(Ljava/lang/String;)V"))
  (eus_java::fargs-clear)
  (setq eus_java::*v-fid* (eus_java::get-method eus_java::*test-cid* "v" "()V"))
  (eus_java::call-void-method eus_java::*test-cid* eus_java::*v-fid*)
  (eus_java::destroy-vm))

(defun eus_java::test4
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
