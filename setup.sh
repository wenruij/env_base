#!/bin/bash -ex
#
# base env setup for debian based os
# @author Wenruij Jiang(wenruij@gmail.com)
#

# setup for jdk oracle 7

# setup for scala 2.11.x

# setup for sbt 0.13.x

# setup for maven


# setup for git
apt-get -y -qq install git

# setup for sublime
add-apt-repository ppa:webupd8team/sublime-text-3
apt-get update
apt-get -y -qq install sublime-text-installer
