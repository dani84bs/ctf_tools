#!/bin/bash
LATEST_CHISEL=1.7.7
LATEST_PSPY=1.2.0
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname $SCRIPT_PATH)
TOOLS_DIR=${DIR_PATH}/tools
PYTHON=python

mkdir -p $TOOLS_DIR

function refresh_tools(){
    pushd $1
    wget -c "https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"
    wget -c "https://github.com/DominicBreuker/pspy/releases/download/v${LATEST_PSPY}/pspy64"
    wget -c "https://github.com/jpillora/chisel/releases/download/v${LATEST_CHISEL}/chisel_${LATEST_CHISEL}_linux_amd64.gz"
    wget -c "https://raw.githubusercontent.com/dani84bs/ctf-web-server/main/ctf_web_server.py"
    gunzip -f "chisel_${LATEST_CHISEL}_linux_amd64.gz"
    popd
}

function populate_www(){
    mkdir -p www
    cd www
    ln -sf ${TOOLS_DIR}/linpeas.sh .
    ln -sf ${TOOLS_DIR}/pspy64 .
    ln -sf ${TOOLS_DIR}/chisel_${LATEST_CHISEL}_linux_amd64 ./chi
    chmod +x ./chi
}

function run_exfilt(){
    if [[ ! -z $TMUX ]]
    then
      tmux new-window -n "www" "${PYTHON} ${TOOLS_DIR}/ctf_web_server.py"
    else
      python ${TOOLS_DIR}/ctf_web_server.py
    fi
}

function run_chisel(){
    if [[ ! -z $TMUX ]]
    then
        tmux new-window -n "chisel" "./chi server -p 9999 --reverse"
    else
        ./chi server -p 9999 --reverse &
    fi
 }
refresh_tools $TOOLS_DIR
populate_www
run_chisel
run_exfilt
