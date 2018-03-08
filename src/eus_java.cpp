#include <jni.h>
#include <iostream>
#include <cassert>

jmethodID getm(JNIEnv *env, jclass &cls, const char* name, const char* arg) {
  jmethodID mid = env->GetMethodID(cls, name, arg);
  std::cout << " find " << name << arg << std::endl;
  assert(mid);
  return mid; }

int main() {
  JNIEnv *env;
  JavaVM *jvm;

  JavaVMOption options[1];
  options[0].optionString = "-Djava.class.path=./java";

  JavaVMInitArgs vm_args;
  vm_args.version = JNI_VERSION_1_6;
  vm_args.options = options;
  vm_args.nOptions = 1;
  JNI_GetDefaultJavaVMInitArgs(&vm_args);

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
  jmethodID vid = getm(env, cls, "v", "()V");
  env->CallVoidMethod(obj, vid);

  jmethodID iid = getm(env, cls, "i", "(I)I");
  int ji = (int)env->CallIntMethod(obj, iid, 3);
  std::cout << "  -- " << ji << std::endl;

  jmethodID did = getm(env, cls, "d", "(D)D");
  double di = (double)env->CallDoubleMethod(obj, did, 3.14);
  std::cout << "  -- " << di << std::endl;

  jmethodID sid = getm(env, cls, "s", "(Ljava/lang/String;)Ljava/lang/String;");
  jstring js = (jstring)(env->CallObjectMethod(obj, sid, env->NewStringUTF("noda")));
  const char* cs = env->GetStringUTFChars(js, 0);
  std::cout << "  -- " << cs << std::endl;
  env->ReleaseStringUTFChars(js, cs);

  if(jvm->DestroyJavaVM()){
    std::cout << "JVM broken" << std::endl;
    return -1; }

  std::cout << "test passed" << std::endl;
}
