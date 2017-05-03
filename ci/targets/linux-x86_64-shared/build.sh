#!/bin/sh

enter_build_dir() {
	pushd ~/tensorflow
}

leave_build_dir() {
	popd
}

build_tensorflow() {
	enter_build_dir

	export PYTHON_BIN_PATH=/usr/bin/python2
	export USE_DEFAULT_PYTHON_LIB_PATH=1
	export TF_NEED_CUDA=0

	# disable Google Cloud Platform support
	export TF_NEED_GCP=0
	# disable Hadoop File System support
	export TF_NEED_HDFS=0
	# disable OpenCL support
	export TF_NEED_OPENCL=0
	# disable VERBS support
	export TF_NEED_VERBS=0
	# disable XLA JIT compiler
	export TF_ENABLE_XLA=0
	# enable jemalloc support
	export TF_NEED_JEMALLOC=1
	# set up architecture dependent optimization flags
	export CC_OPT_FLAGS="-march=native"

	./configure

	bazel build --config=opt //tensorflow:libtensorflow_cc.so
	bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package

	bazel-bin/tensorflow/tools/pip_package/build_pip_package $HOME/tensorflow/tensorflow_pkg

	leave_build_dir
}

retrieve_files_from_wheel() {
	enter_build_dir
	cd tensorflow_pkg
	unzip $(ls tensorflow*.whl)
	cd $(ls tensorflow*.data)
	mkdir -p ~/root/usr/include
	cp -R purelib/tensorflow/include/* ~/root/usr/include/
	cd ../..
	leave_build_dir
}

retrieve_files_from_bin() {
	enter_build_dir
	mkdir -p ~/root/usr/lib
	cp bazel-bin/tensorflow/libtensorflow_cc.so ~/root/usr/lib/
	leave_build_dir
}

retrieve_files_from_genfiles() {
	enter_build_dir
	mkdir -p ~/root/usr/include/tensorflow/cc
	cp -R bazel-genfiles/tensorflow/cc/* ~/root/usr/include/tensorflow/cc/
	leave_build_dir
}

cd
mkdir -p root

pacaur -S jdk8-openjdk unzip --noconfirm --noedit --silent
source /etc/profile
yaourt -S bazel python2-numpy python2-pip python2-wheel python2-six --m-arg "--skippgpcheck" --noconfirm > /dev/null

git clone --depth=1 https://github.com/tensorflow/tensorflow.git

sudo rm /usr/bin/python
sudo ln -s /usr/bin/python2 /usr/bin/python

# build
echo building...
build_tensorflow

retrieve_files_from_wheel
retrieve_files_from_bin
retrieve_files_from_genfiles
