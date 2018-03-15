#!/usr/bin/env roseus

(if (not (find-package "EUS_JAVA")) (make-package "EUS_JAVA"))

(In-package "EUS_JAVA")
(let* ((lib (load-foreign (format nil "~A/libeus_java.so" (ros::rospack-find "eus_java")))))
  (defforeign create-vm lib "eus_java_create_vm" (:string) :integer)
  (defforeign add-class lib "eus_java_add_cls" (:string :string) :integer)
  (defforeign get-method lib "eus_java_get_method" (:integer :string :string) :integer)
  (defforeign call-method lib "eus_java_call_method" (:integer :integer) :integer)
  (defforeign destroy-vm lib "eus_java_destroy_vm" () :integer)
  (defforeign test1 lib "eus_java_test1" () :integer)
  ;;
  (defforeign fargs-clear lib "eus_java_fargs_clear" () :integer)
  (defforeign fargs-add-long lib "eus_java_fargs_add_long" (:integer) :integer)
  (defforeign fargs-add-double lib "eus_java_fargs_add_double" (:double) :integer)
  (defforeign fargs-add-string lib "eus_java_fargs_add_string" (:string) :integer)
  (defforeign fargs-add-larray lib "eus_java_fargs_add_larray" (:integer :string) :integer)
  (defforeign fargs-add-darray lib "eus_java_fargs_add_darray" (:integer :string) :integer)
  )
(In-package "USER")

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
   (eus_java::call-method cid fid)))

(defun eus_java::test2
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "()V"))
  (setq eus_java::*v-fid* (eus_java::get-method eus_java::*test-cid* "v" "()V"))
  (eus_java::call-method eus_java::*test-cid* eus_java::*v-fid*)
  (eus_java::destroy-vm))

(defun eus_java::test3
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (eus_java::fargs-add-string "eus_java::test3")
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "(Ljava/lang/String;)V"))
  (eus_java::fargs-clear)
  (setq eus_java::*v-fid* (eus_java::get-method eus_java::*test-cid* "v" "()V"))
  (eus_java::call-method eus_java::*test-cid* eus_java::*v-fid*)
  (eus_java::destroy-vm))

(defun eus_java::test4
  nil
  (eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
  (eus_java::fargs-clear)
  (eus_java::fargs-add-string "eus_java::test4")
  (setq eus_java::*test-cid* (eus_java::add-class "Test" "(Ljava/lang/String;)V"))
  ;;
  (setq eus_java::*test-vf* (instance eus_java::__func :init eus_java::*test-cid* "v" "()V"))
  (send eus_java::*test-vf* :eval)
  ;;
  (setq eus_java::*test-lf* (instance eus_java::__func :init eus_java::*test-cid* "l" "(J)J"))
  (send eus_java::*test-lf* :eval 3)
  ;;
  (setq eus_java::*test-df* (instance eus_java::__func :init eus_java::*test-cid* "d" "(D)D"))
  (send eus_java::*test-df* :eval 3.14)
  ;;
  (setq eus_java::*test-sf* (instance eus_java::__func :init eus_java::*test-cid* "s" "(Ljava/lang/String;)Ljava/lang/String;"))
  (send eus_java::*test-sf* :eval "piyo")
  ;;
  (setq eus_java::*test-lvf* (instance eus_java::__func :init eus_java::*test-cid* "lv" "([J)[J"))
  (send eus_java::*test-lvf* :eval #i(1 2 3))
  ;;
  (setq eus_java::*test-dvf* (instance eus_java::__func :init eus_java::*test-cid* "dv" "([D)[D"))
  (send eus_java::*test-dvf* :eval #F(1.1 2.2 3.3))
  ;;
  (eus_java::destroy-vm))
