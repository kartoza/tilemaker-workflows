#!/usr/bin/env bash
#docker run -it --rm -p 8888:8888 maputnik/editor
git submodule init
cd maputnik
npm install
npm run start

