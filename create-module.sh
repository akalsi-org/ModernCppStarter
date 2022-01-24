#!/bin/sh

mod="$1"

mkdir -p "include/$mod" "src/$mod" "test/$mod"

cat <<EOF >> "CMakeLists.txt"
define_lib(${mod} "" "")
EOF
