#include <jni.h>
#include <iostream>
#include <cassert>

namespace eus_java {
  jmethodID _getm(JNIEnv *env, jclass &cls, const char* name, const char* arg) {
    jmethodID mid = env->GetMethodID(cls, name, arg);
    std::cout << " find " << name << arg << std::endl;
    assert(mid);
    return mid; }

  int test1() {
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

    jmethodID iid = _getm(env, cls, "i", "(I)I");
    int ji = (int)env->CallIntMethod(obj, iid, 3);
    std::cout << "  -- " << ji << std::endl;

    jmethodID did = _getm(env, cls, "d", "(D)D");
    double di = (double)env->CallDoubleMethod(obj, did, 3.14);
    std::cout << "  -- " << di << std::endl;

    jmethodID sid = _getm(env, cls, "s", "(Ljava/lang/String;)Ljava/lang/String;");
    jstring js = (jstring)(env->CallObjectMethod(obj, sid, env->NewStringUTF("noda")));
    const char* cs = env->GetStringUTFChars(js, 0);
    std::cout << "  -- " << cs << std::endl;
    env->ReleaseStringUTFChars(js, cs);

    jmethodID ivid = _getm(env, cls, "iv", "([I)[I");
    jintArray iv = env->NewIntArray(3);
    int _iv[3]; for ( int i=0; i<3; i++ ) _iv[i] = i;
    env->SetIntArrayRegion(iv, 0, 3, (jint*)_iv);
    jintArray iv2 = (jintArray)(env->CallObjectMethod(obj, ivid, iv));
    jint *_iv2 = env->GetIntArrayElements(iv2, 0);
    std::cout << "  --";
    for ( int i=0; i<3; i++ ) std::cout << " " << _iv2[i];
    std::cout << std::endl;
    env->ReleaseIntArrayElements(iv2, _iv2, 0);

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
};

int main() { return eus_java::test1(); }
