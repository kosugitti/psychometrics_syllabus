#!/bin/sh
dir_path="/."
dirs=`find ./ -name "*.png"`
for dir in $dirs;
do
    # ここから実行処理を記述
    extractbb $dir
done