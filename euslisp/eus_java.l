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
  )
(In-package "USER")

#|
(eus_java::create-vm (format nil "~A/java" (ros::rospack-find "eus_java")))
(setq eus_java::*test-cid* (eus_java::add-class "Test" "()V"))
(setq eus_java::*v-fid* (eus_java::get-method eus_java::*test-cid* "v" "()V"))
(eus_java::call-method eus_java::*test-cid* eus_java::*v-fid*)
(eus_java::destroy-vm)
