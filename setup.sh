#!/bin/bash -ex
#
# base env setup for debian based os
# @author Wenruij Jiang(wenruij@gmail.com)
#

##################### VERSION TO SET #######################
scala_version="2.11.7"
maven_version="3.3.3"
proto_version="2.5.0"
############################################################

INSTALLER=apt-get
curr_user=`whoami`
TMP_PATH=/tmp
cd ${TMP_PATH}

# build for apt-add-repository
version=$(lsb_release -ds | awk '{print $2}')
ubuntu_version=12.10
if (( $(echo "${version} ${ubuntu_version}" | awk '{print ($1 < $2)}') )); then
  sudo ${INSTALLER} -y install python-software-properties
else
  sudo ${INSTALLER} -y install software-properties-common
fi

# build for jdk
function install_jdk () {
sudo add-apt-repository ppa:webupd8team/java
sudo ${INSTALLER} update
sudo ${INSTALLER} -y install oracle-java7-installer
sudo update-java-alternatives -s java-7-oracle

JAVA_HOME=$(which java | xargs readlink -f | sed -E "s/(jre|jdk|)\/bin\/java$//")
sudo bash -c "echo 'export JAVA_HOME=${JAVA_HOME}' >> /etc/profile"
source /etc/profile
}

# build for scala
function install_scala () {
wget http://www.scala-lang.org/files/archive/scala-${scala_version}.deb
sudo ${INSTALLER} -y install libjansi-java libjansi-native-java libhawtjni-runtime-java
sudo dpkg -i scala-${scala_version}.deb
rm scala-${scala_version}.deb
}

# build for git
function install_git() {
sudo ${INSTALLER} -y -qq install git
}

# build for sbt
function install_sbt () {
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo ${INSTALLER} update
sudo ${INSTALLER} -y install sbt
}

# build for mvn
function install_mvn () {
wget http://ftp.twaren.net/Unix/Web/apache/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz
tar xzvf apache-maven-${maven_version}-bin.tar.gz
rm -rf apache-maven-${maven_version}-bin.tar.gz
sudo mv apache-maven-${maven_version} /opt
echo "export PATH=/opt/apache-maven-${maven_version}/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
}

# build for sublime 3
function install_sublime () {
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo ${INSTALLER} update
sudo ${INSTALLER} -y -qq install sublime-text-installer
}

# build for protobuf
function install_protobuf () {
wget https://protobuf.googlecode.com/files/protobuf-${proto_version}.tar.gz
tar -vxf protobuf-${proto_version}.tar.gz
cd protobuf-${proto_version}
./configure
make
sudo make install
sudo ldconfig
cd ..
rm -rf protobuf-${proto_version}
}

# build for ansible
function install_ansible () {
sudo apt-add-repository ppa:rquillo/ansible
sudo ${INSTALLER} update
sudo ${INSTALLER} -y install ansible
}

# build for docker
# NOTE: Docker works well on Linux kernel 3.8+
function install_docker () {
sudo ${INSTALLER} -y install apt-transport-https
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo bash -c "echo deb http://mirror.yandex.ru/mirrors/docker/ docker main > /etc/apt/sources.list.d/docker.list"
sudo ${INSTALLER} update
sudo ${INSTALLER} -y install lxc-docker
}

command -v java > /dev/null 2>&1 || {
install_protobuf
}

command -v scala >/dev/null 2>&1 || {
install_scala
}

command -v git >/dev/null 2>&1 || {
install_git
}

command -v sbt >/dev/null 2>&1 || {
install_sbt
}

command -v mvn >/dev/null 2>&1 || {
install_mvn
}

command -v subl >/dev/null 2>&1 || {
install_sublime
}

command -v protoc >/dev/null 2>&1 || {
install_protobuf
}

command -v ansible-playbook >/dev/null 2>&1 || {
install_ansible
}

command -v docker >/dev/null 2>&1 || {
install_docker
}
