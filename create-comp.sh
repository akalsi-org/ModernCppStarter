#!/usr/bin/env sh

root=$(cd $(dirname $0) && pwd)

comp_path=""
lang=CXX
private=0

usage() {
    cat <<EOF
create-comp.sh PATH [--lang=LANG] [-h|--help] [--private]

Creates a C/C++ component
  o PATH is the components hierarchy, e.g. foo/bar
    This would create 3 files:
      o src/foo/bar.LANG_EXT_SRC
      o include/foo/bar.LANG_EXT_HDR
      o test/foo/bar.t.LANG_EXT_SRC
  o LANG can be either C or CXX
    Note that:
      o C implies that headers are '.h' and source files are '.c'
      o CXX implies that headers are '.h' and source files are '.cc'
  o If '--private' is specified, the files created are:
      o src/foo/bar.LANG_EXT_SRC
      o src/foo/bar.LANG_EXT_HDR
EOF
    exit 0
}

layout="subdir"

if test "$layout" = "subdir"; then
    comp_path=$(echo "$1" | sed 's|\.|/|g')
else
    comp_path=$(echo "$1" | sed 's|\/|_|g' | sed 's|\.|_|g')
fi

shift

while test "$#" -gt 0; do
    PARAM=$(echo "$1" | cut -d'=' -f1)
    VALUE=$(echo "$1" | cut -d'=' -f2)
    case $PARAM in
        -h|--help)
            usage
            exit 0
            ;;
        --lang)
            lang=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

cpp_src_ext='.cc'
if test "$lang" = CXX; then
    hdr_ext='.h'
    src_ext=$cpp_src_ext
elif test "$lang" = C; then
    hdr_ext='.h'
    src_ext='.c'
else
    >&2 echo Invalid language: "$lang"
    exit 1
fi

comp_name=$(basename "$comp_path")
comp_dir=$(dirname "$comp_path")

test "$comp_dir" = "." && comp_dir=""

reverse_word_order() {
    result=""
    for word in $@; do
        result="$word $result"
    done
    echo "$result"
}

print_include_guard() {
    echo "${comp_path}${hdr_ext}" | \
      tr '[:lower:]' '[:upper:]' | \
      sed 's|\.|_|g' | \
      sed 's|\/|_|g' | \
      sed 's|\\|_|g'
}

print_namespace_begin() {
    comp_parent=$(dirname $(echo "$comp_path" | sed 's|_|\/|g') | sed 's|\/|_|g')
    list=$(echo $comp_parent | \
      sed 's|\.| |g' | \
      sed 's|\/| |g' | \
      sed 's|_| |g'  | \
      sed 's|\\| |g')
    for item in ${list};
    do
        echo "namespace $item {"
    done
}

print_namespace_end() {
    comp_parent=$(dirname $(echo "$comp_path" | sed 's|_|\/|g') | sed 's|\/|_|g')
    list=$(echo $comp_parent | \
      sed 's|\.| |g' | \
      sed 's|\/| |g' | \
      sed 's|_| |g'  | \
      sed 's|\\| |g')
    for item in $(reverse_word_order "$list");
    do
        echo "} // namespace $item"
    done
}

print_commented_license() {
    cat "$root/LICENSE.md" | sed 's|^|// |g' | sed 's|[[:space:]]*$||' | \
        sed "s|<USER>|$(git config --global user.name)|" | \
        sed "s|<YEAR>|$(date +%Y)|"
}

# cd $root

guard=$(print_include_guard)
where=include/

mkdir -p "${where}${comp_dir}"
if test "$lang" = C; then

cat <<EOF > "${where}${comp_path}${hdr_ext}"
//! @file ${comp_name}${hdr_ext}
//! @brief description

$(print_commented_license)

#ifndef ${guard}_INCLUDED
#define ${guard}_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus



#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif // ${guard}_INCLUDED
EOF

else

cat <<EOF > "${where}${comp_path}${hdr_ext}"
//! @file ${comp_name}${hdr_ext}
//! @brief description

$(print_commented_license)

#ifndef ${guard}_INCLUDED
#define ${guard}_INCLUDED

$(print_namespace_begin)



$(print_namespace_end)

#endif // ${guard}_INCLUDED
EOF

fi

where=src/
mkdir -p "${where}${comp_dir}"
incl_beg='"'
incl_end='"'

if test "$lang" = C; then

cat <<EOF > "${where}/${comp_path}${src_ext}"
//! @file ${comp_name}${src_ext}

$(print_commented_license)

#include ${incl_beg}${comp_path}${hdr_ext}${incl_end}



EOF

else

cat <<EOF > "${where}/${comp_path}${src_ext}"
//! @file ${comp_name}${src_ext}

$(print_commented_license)

#include ${incl_beg}${comp_path}${hdr_ext}${incl_end}

$(print_namespace_begin)



$(print_namespace_end)
EOF

fi

where=test/
mkdir -p "${where}/${comp_dir}"
cat <<EOF > "${where}/${comp_path}.t${cpp_src_ext}"
//! @file ${comp_name}.t${cpp_src_ext}

#include "${comp_path}${hdr_ext}"

#include <doctest/doctest.h>

TEST_CASE("${comp_name}") {
}
EOF
