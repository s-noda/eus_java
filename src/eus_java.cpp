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
  std::vector<jvalue> fargs;
  long __addfarg(jvalue &v) {
    fargs.push_back(v); return fargs.size(); }
};

extern "C" { // function argument handle
  long eus_java_fargs_clear() {
    eus_java::fargs.clear(); return 0; }
  long eus_java_fargs_add_long(long l) {
    jvalue v; v.j = l; return eus_java::__addfarg(v); }
  long eus_java_fargs_add_double(double d) {
    jvalue v; v.d = d; return eus_java::__addfarg(v); }
  long eus_java_fargs_add_string(char* _cl) {
    jstring cl = eus_java::env->NewStringUTF(_cl);
    jvalue v; v.l = cl; return eus_java::__addfarg(v); }
  long eus_java_fargs_add_darray(long s, double* _dl) {
    jdoubleArray dl = eus_java::env->NewDoubleArray(s);
    eus_java::env->SetDoubleArrayRegion(dl, 0, s, _dl);
    jvalue v; v.l = dl; return eus_java::__addfarg(v); }
  long eus_java_fargs_add_larray(long s, long* _ll) {
    jlongArray ll = eus_java::env->NewLongArray(s);
    eus_java::env->SetLongArrayRegion(ll, 0, s, _ll);
    jvalue v; v.l = ll; return eus_java::__addfarg(v); }
};

extern "C" { // jvm accessor
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
      std::cerr << "[eus_java] JNI_CreateJavaVM fail" << std::endl; return -1; }
    std::cout << "[eus_java] JVM open" << std::endl;
    return 0; }
  long eus_java_add_cls(char* _cls, char* _arg=const_cast<char*>("()V")) {
    jclass cls = eus_java::env->FindClass(_cls);
    if(cls == 0){
      std::cerr << "[eus_java] class " << _cls << " not found" << std::endl;
      return -1; }
    jmethodID cns = eus_java::env->GetMethodID(cls, "<init>", _arg);
    if(cns == NULL){
      std::cerr << "[eus_java] constructor " << _cls << _arg << " not found" << std::endl;
      return -1; }
    jobject obj = eus_java::env->NewObjectA(cls, cns, &eus_java::fargs[0]);
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
    eus_java::env->CallVoidMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    return 0; }
  long eus_java_destroy_vm() {
    if(!eus_java::jvm || eus_java::jvm->DestroyJavaVM()){
      std::cerr << "[eus_java] DestroyJavaVM fail" << std::endl;
      return -1; }
    std::cout << "[eus_java] JVM close" << std::endl;
    return 0; }
  long eus_java_test1() { return eus_java::test1();}
};
