#!/bin/bash

color_error="\e[31m"
color_done="\e[32;1m"
color_step="\e[30;1m"
color_warning="\e[33;1m"
color_param="\e[34;1m"
color_none="\e[0m"
color_head="\e[39;1m"
color_bold="\e[1m"

emit_header() {
    echo "-------------------------------------------------------------------------------"
    echo -e " ${color_head}$1${color_none}"
    echo "-------------------------------------------------------------------------------"
}

emit_step() {
    str=">>> ${color_step}$1${color_none}\n"
    shift
    args=()
	for i in "$@"; do
		args+=("${color_param}$i${color_step}")
	done
    printf "$str" "${args[@]}"
}

emit_done() {
    echo -e ">>> ${color_done}DONE${color_none}"
}

emit_warning() {
    echo -e " ${color_warning}WARNING${color_none}: ${color_step}$1${color_none}"
}

emit_error() {
    echo -e " ${color_error}ERROR${color_none}: ${color_step}$1${color_none}"
}

color()(set -o pipefail;"$@" 2> >(sed $'s,.*,\e[31m&\e[m,'>&2))

mk_meta_link() {
    color ln -fsn "../$1/$2"  "$2" 
    color ln -fsn "../$1/.meta_$2"  ".meta_$2" 
}

mk_ms_meta_link() {
    color ln -fsn "../OpenMSA_MS/$1"  "$1" 
    color ln -fsn "../OpenMSA_MS/.meta_$1"  ".meta_$1" 
}

mk_wf_meta_link() {
    color ln -fsn "../OpenMSA_WF/$1"  "$1" 
    color ln -fsn "../OpenMSA_WF/.meta_$1"  ".meta_$1" 
}