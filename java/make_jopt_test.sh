#!/usr/bin/env bash

EJ_HOME=`rospack find eus_java`;
EJ_3rd=${EJ_HOME}/3rdparty;

if [ ! -e "${EJ_3rd}" ]; then mkdir -p ${EJ_3rd}; fi
(
    cd ${EJ_3rd};
    _JROOT=https://sourceforge.net/projects/cvxopt/files;
    _JOPT=joptimizer-4.0.0.jar;
    _JDEP=joptimizer-4.0.0-dependencies.zip

    if [ ! -e "${_JOPT}" ]; then curl -L ${_JROOT}/${_JOPT}/download > ${_JOPT}; fi
    if [ ! -e "${_JDEP}" ]; then
	curl -L ${_JROOT}/${_JDEP}/download > ${_JDEP};
	unzip joptimizer-4.0.0-dependencies.zip;
    fi
)

(
    cd ${EJ_HOME}/java;
    _tmp="";
    for p in `ls ${EJ_3rd} | grep -e "\.jar$"`;
    do
	_tmp=${EJ_3rd}/$p:${_tmp};
    done

    ##echo $_tmp;
    CLASSPATH=${_tmp} javac JOptimizer_test.java;
    CLASSPATH=${_tmp} java JOptimizer_test;
)
