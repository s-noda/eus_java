#!/usr/bin/env roseus

(if (not (find-package "EUS_JAVA")) (make-package "EUS_JAVA"))

(In-package "EUS_JAVA")
(let* ((lib (load-foreign (format nil "~A/libeus_java.so" (ros::rospack-find "eus_java")))))
  (defforeign init-vmargs lib "eus_java_init_vmargs" (:string) :integer)
  (defforeign create-vm lib "eus_java_create_vm" () :integer)
  (defforeign get-method lib "eus_java_get_method" (:integer :string :string) :integer)
  (defforeign call-method lib "eus_java_call_method" (:integer :integer) :integer)
  (defforeign destroy-vm lib "eus_java_destroy_vm" () :integer)
  )
(In-package "USER")

(eus_java::init-vmargs "./java")
(eus_java::create-vm)
(eus_java::destroy-vm)
