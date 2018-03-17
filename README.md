# eus_java
java accessor from euslisp

## install
`catkin build eus_java`

## test
```
./euslisp/test_eus_java.l --test-funcall
./euslisp/test_eus_java.l --test-exponential
./euslisp/test_eus_java.l --test-pi
```

## usage

```
(require "package://eus_java/euslisp/eus_java.l")

(eus_java::create-vm "your/.class/path")

;; construction of class something like -->  class Test { public Test(String a) { ...
(setq classid (eus_java::add-class "Test" (list "arg")))

;; define func something like --> class Test { public double youFuncNameInJava(double a, long b) { ...
;; argument and return type include :double :long :string :darray :larray
(eus_java::jdefun your-func-name-in-euslisp classid "yourFuncNameInJava" (:double :long) :double)

;; call func in euslisp
(your-func-name-in-euslisp 3.14 5)
```
