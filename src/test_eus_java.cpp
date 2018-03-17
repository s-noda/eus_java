#include <jni.h>
#include <iostream>
#include <cassert>
#include <cmath>

namespace eus_java {
  jmethodID _getm(JNIEnv *env, jclass &cls, const char* name, const char* arg) {
    jmethodID mid = env->GetMethodID(cls, name, arg);
    std::cout << " find " << name << arg << std::endl;
    assert(mid);
    return mid; }

  long test_funcall() {
    JNIEnv *env;
    JavaVM *jvm;

    JavaVMOption options[1];
    options[0].optionString = const_cast<char*>("-Djava.class.path=./java");

    JavaVMInitArgs vm_args;
    // JNI_GetDefaultJavaVMInitArgs(&vm_args);
    vm_args.version = JNI_VERSION_1_6;
    vm_args.options = options;
    vm_args.nOptions = 1;
    vm_args.ignoreUnrecognized = true;

    if ( JNI_CreateJavaVM(&jvm, (void **)&env, &vm_args) ) {
      std::cout << "JVM dead" << std::endl;
      return -1; }

    jclass cls = env->FindClass("Test");
    if(cls == 0){
      std::cout << "test(class) not found" << std::endl;
      return -1; }

    jmethodID cns = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;)V");
    if(cns == NULL){
      std::cout << "initialize fail" << std::endl;
      return -1; }
    jobject obj = env->NewObject(cls, cns, env->NewStringUTF("eus_java"));

    // javap -s Test
    jmethodID vid = _getm(env, cls, "v", "()V");
    env->CallVoidMethod(obj, vid);

    jmethodID iid = _getm(env, cls, "l", "(J)J");
    long ji = (long)env->CallLongMethod(obj, iid, 3);
    std::cout << "  -- " << ji << std::endl;

    jmethodID did = _getm(env, cls, "d", "(D)D");
    double di = (double)env->CallDoubleMethod(obj, did, 3.14);
    std::cout << "  -- " << di << std::endl;

    jmethodID sid = _getm(env, cls, "s", "(Ljava/lang/String;)Ljava/lang/String;");
    jstring js = (jstring)(env->CallObjectMethod(obj, sid, env->NewStringUTF("noda")));
    const char* cs = env->GetStringUTFChars(js, 0);
    std::cout << "  -- " << cs << std::endl;
    env->ReleaseStringUTFChars(js, cs);

    jmethodID ivid = _getm(env, cls, "lv", "([J)[J");
    jlongArray iv = env->NewLongArray(3);
    long _iv[3]; for ( int i=0; i<3; i++ ) _iv[i] = i;
    env->SetLongArrayRegion(iv, 0, 3, (jlong*)_iv);
    jlongArray iv2 = (jlongArray)(env->CallObjectMethod(obj, ivid, iv));
    jlong *_iv2 = env->GetLongArrayElements(iv2, 0);
    std::cout << "  --";
    for ( int i=0; i<3; i++ ) std::cout << " " << _iv2[i];
    std::cout << std::endl;
    env->ReleaseLongArrayElements(iv2, _iv2, 0);

    jmethodID dvid = _getm(env, cls, "dv", "([D)[D");
    jdoubleArray dv = env->NewDoubleArray(3);
    double _dv[3]; for ( int i=0; i<3; i++ ) _dv[i] = 3.14*i;
    env->SetDoubleArrayRegion(dv, 0, 3, (jdouble*)_dv);
    jdoubleArray dv2 = (jdoubleArray)(env->CallObjectMethod(obj, dvid, dv));
    jdouble *_dv2 = env->GetDoubleArrayElements(dv2, 0);
    std::cout << "  --";
    for ( int i=0; i<3; i++ ) std::cout << " " << _dv2[i];
    std::cout << std::endl;
    env->ReleaseDoubleArrayElements(dv2, _dv2, 0);

    if(jvm->DestroyJavaVM()){
      std::cout << "JVM broken" << std::endl;
      return -1; }

    std::cout << "test passed" << std::endl;
    return 0; }

  double test_exponential(double d, long s) {
    double r = d;
    while ((s -= 1) > 0) r *= d;
    return r; }
  double test_pi(long l) {
    double r = 0;
    while ((l -= 1) > 0) r += 1.0/(l*l);
    return std::sqrt(6*r); }
};

int main() { return eus_java::test_funcall(); }
