project(eus_java)

cmake_minimum_required(VERSION 2.4.6)

find_package(catkin COMPONENTS cmake_modules euslisp)

set(JAVA_HOME /usr/lib/jvm/java-7-oracle)

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${JAVA_HOME}/include ${JAVA_HOME}/include/linux)

##link_directories(/usr/lib/jvm/java-7-oracle/jre/lib/amd64)

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)

catkin_package()

set(CMAKE_CXX_FLAGS "-std=c++0x -O3")

add_executable(test_eus_java src/test_eus_java.cpp)
target_link_libraries(test_eus_java ${JAVA_HOME}/jre/lib/amd64/server/libjvm.so)
execute_process(COMMAND ln -snf ${CATKIN_DEVEL_PREFIX}/lib/eus_java/test_eus_java ${PROJECT_SOURCE_DIR}/test_eus_java)

add_library(eus_java SHARED src/eus_java.cpp)
target_link_libraries(eus_java ${JAVA_HOME}/jre/lib/amd64/server/libjvm.so)
execute_process(COMMAND ln -snf ${CATKIN_DEVEL_PREFIX}/lib/libeus_java.so ${PROJECT_SOURCE_DIR}/libeus_java.so)
