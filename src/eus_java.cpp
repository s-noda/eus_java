#include <jni.h>
#include <iostream>
#include <cassert>
#include <vector>
#include <cstring>
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
  jvalue fret;
  long __addfarg(jvalue &v) {
    fargs.push_back(v); return fargs.size(); }
};

extern "C" { // function argument handle
  long eus_java_fargs_clear() { eus_java::fargs.clear(); return 0; }
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

extern "C" { // function ret handle
  eus_java::cls *__eus_java_call_method(int cid, int fid) {
    assert(cid < eus_java::clss.size());
    eus_java::cls *c = &eus_java::clss[cid];
    assert(fid < c->fns.size());
    return c; }
  long eus_java_call_void_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    eus_java::env->CallVoidMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    return 0; }
  long eus_java_call_long_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    eus_java::fret.j = eus_java::env->CallLongMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    return 0; }
  long eus_java_call_double_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    eus_java::fret.d = eus_java::env->CallDoubleMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    return 0; }
  long eus_java_call_string_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    jstring str = (jstring)eus_java::env->CallObjectMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    eus_java::fret.l = str; return 0; }
  long eus_java_call_larray_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    jlongArray la = (jlongArray)eus_java::env->CallObjectMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    eus_java::fret.l = la; return 0; }
  long eus_java_call_darray_method(int cid, int fid) {
    eus_java::cls *c = __eus_java_call_method(cid,fid);
    jdoubleArray da = (jdoubleArray)eus_java::env->CallObjectMethodA(c->o, c->fns[fid].mid, &eus_java::fargs[0]);
    eus_java::fret.l = da; return 0; }
  long eus_java_return_long(long* b) { b[0] = eus_java::fret.j; return 0; }
  long eus_java_return_double(double* b) { b[0] = eus_java::fret.d; return 0; }
  long eus_java_return_string_length() { return eus_java::env->GetStringLength((jstring)eus_java::fret.l); }
  long eus_java_return_string(int l, char* str) {
    jstring js = (jstring)eus_java::fret.l;
    const char* _str = eus_java::env->GetStringUTFChars(js, 0);
    std::memcpy(str,_str,l*sizeof(char));
    eus_java::env->ReleaseStringUTFChars(js, _str);
    return 0; }
  long eus_java_return_larray_length() { return eus_java::env->GetArrayLength((jlongArray)eus_java::fret.l); }
  long eus_java_return_larray(int l, long* la) {
    jlongArray jla = (jlongArray)eus_java::fret.l;
    long *_la = eus_java::env->GetLongArrayElements(jla, 0);
    std::memcpy(la,_la,l*sizeof(long));
    eus_java::env->ReleaseLongArrayElements(jla, _la, 0);
    return 0; }
  long eus_java_return_darray_length() { return eus_java::env->GetArrayLength((jdoubleArray)eus_java::fret.l); }
  long eus_java_return_darray(int l, double* da) {
    jdoubleArray jda = (jdoubleArray)eus_java::fret.l;
    double *_da = eus_java::env->GetDoubleArrayElements(jda, 0);
    std::memcpy(da,_da,l*sizeof(double));
    eus_java::env->ReleaseDoubleArrayElements(jda, _da, 0);
    return 0; }
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
    if(! cls){
      std::cerr << "[eus_java] class " << _cls << " not found" << std::endl;
      return -1; }
    jmethodID cns = eus_java::env->GetMethodID(cls, "<init>", _arg);
    if(! cns){
      std::cerr << "[eus_java] constructor " << _cls << _arg << " not found" << std::endl;
      return -1; }
    jobject obj = eus_java::env->NewObjectA(cls, cns, &eus_java::fargs[0]);
    eus_java::clss.push_back(eus_java::cls(cls, obj));
    return eus_java::clss.size() - 1; }
  long eus_java_get_method(int cid, char* _fn, char* _arg) {
    assert(cid < eus_java::clss.size());
    jmethodID mid = eus_java::env->GetMethodID(eus_java::clss[cid].c, _fn, _arg);
    if (! mid) {
      std::cerr << "[eus_java] func " << _fn << _arg << " not found" << std::endl;
      return -1;}
    return eus_java::clss[cid].add(eus_java::func(mid)); }
  long eus_java_destroy_vm() {
    if(!eus_java::jvm || eus_java::jvm->DestroyJavaVM()){
      std::cerr << "[eus_java] DestroyJavaVM fail" << std::endl;
      return -1; }
    std::cout << "[eus_java] JVM close" << std::endl;
    return 0; }
  //
  long eus_java_test_funcall() { return eus_java::test_funcall();}
  long eus_java_test_exponential(double *b, double d, long s) { b[0] = eus_java::test_exponential(d, s); return 0; }
  long eus_java_test_pi(double *b, long l) { b[0] = eus_java::test_pi(l); return 0; }
};
