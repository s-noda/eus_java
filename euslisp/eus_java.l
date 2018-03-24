#!/usr/bin/env roseus

(if (not (find-package "EUS_JAVA")) (make-package "EUS_JAVA"))

(In-package "EUS_JAVA")
(let* ((lib (load-foreign (format nil "~A/libeus_java.so" (ros::rospack-find "eus_java")))))
  (defforeign create-vm lib "eus_java_create_vm" (:string) :integer)
  (defforeign _add-class lib "eus_java_add_cls" (:string :string) :integer)
  (defforeign get-method lib "eus_java_get_method" (:integer :string :string) :integer)
  (defforeign destroy-vm lib "eus_java_destroy_vm" () :integer)
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
  ;;
  (defforeign test-funcall lib "eus_java_test_funcall" () :integer)
  (defforeign _test-exponential-cpp lib "eus_java_test_exponential" (:string :double :integer) :integer)
  (defun test-exponential-cpp (d s) (let ((b #F(0))) (_test-exponential-cpp b d s) (aref b 0)))
  (defforeign _test-pi-cpp lib "eus_java_test_pi" (:string :integer) :integer)
  (defun test-pi-cpp (s) (let ((b #F(0))) (_test-pi-cpp b s) (aref b 0)))
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

(defmacro eus_java::jdefun
  (fname _cid jfname jarg jret)
  (let* ((cid (if (symbolp _cid) (eval _cid) _cid))
	 (arg (eus_java::arg-keylist2string jarg jret))
	 (fid (eus_java::get-method cid jfname arg))
	 (asym (eus_java::alphabet-symbol-list (length jarg))))
    (list 'defun fname (append asym '(&optional buf))
	  '(eus_java::fargs-clear)
	  (cons
	   'progn
	   (mapcar
	    '(lambda (a s)
	       (cond
		((eq a :long) (list 'eus_java::fargs-add-long s))
		((eq a :double) (list 'eus_java::fargs-add-double s))
		((eq a :string) (list 'eus_java::fargs-add-string s))
		((eq a :larray) (list 'eus_java::fargs-add-larray (list 'length s) s))
		((eq a :darray) (list 'eus_java::fargs-add-darray (list 'length s) s))))
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
	    '(let* ((l (eus_java::return-string-length))
		    (b (if (and (stringp buf) (>= (length buf) l))
			   buf (instantiate string l))))
	       (eus_java::return-string l b) b))
	   ((eq jret :larray)
	    '(let* ((l (eus_java::return-larray-length))
		    (b (if (and (integer-vector-p buf) (>= (length buf) l))
			   buf (instantiate integer-vector l))))
	       (eus_java::return-larray l b) b))
	   ((eq jret :darray)
	    '(let* ((l (eus_java::return-darray-length))
		    (b (if (and (float-vector-p buf) (>= (length buf) l))
			   buf (instantiate float-vector l))))
	       (eus_java::return-darray l b) b))))))

(defun eus_java::fargs-add (a)
  (cond
   ((integerp a) (eus_java::fargs-add-long a) :long)
   ((floatp a) (eus_java::fargs-add-double a) :double)
   ((stringp a) (eus_java::fargs-add-string a) :string)
   ((integer-vector-p a)
    (eus_java::fargs-add-larray (length a) a) :larray)
   ((float-vector-p a)
    (eus_java::fargs-add-darray (length a) a) :darray)))

(defun eus_java::add-class
  (cname &rest args)
  (eus_java::fargs-clear)
  (eus_java::_add-class
   cname
   (eus_java::arg-keylist2string
    (mapcar 'eus_java::fargs-add args) nil)))
