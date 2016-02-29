#! /bin/bash

# Copyright 2016, Sandvine Incorporated.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

mkdir -p $GOPATH/src/github.com/influxdb
cd $GOPATH/src/github.com/influxdb
git clone --branch v0.8.8 https://github.com/influxdb/influxdb.git

mkdir -p $GOPATH/src/github.com/fiorix
cd $GOPATH/src/github.com/fiorix

git clone https://github.com/fiorix/go-diameter.git
cd go-diameter
git checkout b4c1bac20b8e8e1ac7e17fb54dc83b155aacba21

mkdir -p $GOPATH/src/git.svc.rocks/octo
cd $GOPATH/src/git.svc.rocks/octo

pwd
