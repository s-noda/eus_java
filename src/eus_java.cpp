#include <jni.h>
#include <iostream>
#include <cassert>
#include <vector>
#include "test_eus_java.cpp"

namespace eus_java {
  class func {
  public:
    jmethodID mid;
    func(jmethodID _mid) : mid(_mid) {}
  };
  class cls {
  public:
    jclass c;
    jobject o;
    std::vector<func> fns;
    cls(jclass _cls, jobject _obj) : o(_obj), c(_cls) {}
    int add(func f) { this->fns.push_back(f); return this->fns.size() - 1; }
  };
};

namespace eus_java {
  JNIEnv *env;
  JavaVM *jvm;
  JavaVMInitArgs vm_args;
  std::vector<eus_java::cls> clss;
};

extern "C" {
  long eus_java_create_vm(char* _nm) {
    std::string dp = "-Djava.class.path=";
    std::string os = dp + std::string(_nm);
    JavaVMOption options[1];
    options[0].optionString = const_cast<char*>(os.c_str());
    eus_java::vm_args.version = JNI_VERSION_1_6;
    eus_java::vm_args.options = options;
    eus_java::vm_args.nOptions = 1;
    eus_java::vm_args.ignoreUnrecognized = true;
    std::cout << "class root change to " << eus_java::vm_args.options[0].optionString << std::endl;
    if ( JNI_CreateJavaVM(&eus_java::jvm, (void **)&eus_java::env, &eus_java::vm_args) ) {
      std::cout << "JVM dead" << std::endl;
      return -1; }
    return 0; }
  long eus_java_add_cls(char* _cls, char* _arg=const_cast<char*>("()V")) {
    jclass cls = eus_java::env->FindClass(_cls);
    if(cls == 0){
      std::cout << _cls << "(class) not found" << std::endl;
      return -1; }
    jmethodID cns = eus_java::env->GetMethodID(cls, "<init>", _arg);
    if(cns == NULL){
      std::cout << "initialize fail" << std::endl;
      return -1; }
    jobject obj = eus_java::env->NewObject(cls, cns);
    eus_java::clss.push_back(eus_java::cls(cls, obj));
    return eus_java::clss.size() - 1; }
  long eus_java_get_method(int cid, char* _fn, char* _arg) {
    assert(cid < eus_java::clss.size());
    jmethodID mid = eus_java::env->GetMethodID(eus_java::clss[cid].c, _fn, _arg);
    return eus_java::clss[cid].add(eus_java::func(mid)); }
  long eus_java_call_method(int cid, int fid) {
    assert(cid < eus_java::clss.size());
    eus_java::cls *c = &eus_java::clss[cid];
    assert(fid < c->fns.size());
    eus_java::env->CallVoidMethod(c->o, c->fns[fid].mid);
    return 0; }
  long eus_java_destroy_vm() {
    if(!eus_java::jvm || eus_java::jvm->DestroyJavaVM()){
      std::cout << "JVM broken" << std::endl;
      return -1; }
    return 0; }
  long eus_java_test1() { return eus_java::test1();}
};
