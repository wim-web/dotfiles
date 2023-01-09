#!/usr/bin/env bash

script_dir=$(cd $(dirname $0); pwd)

function fish_install() {
    curl -sL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/fish-debian.sh | sudo bash
}

function aqua_install() {
    curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.0.2/aqua-installer | bash
    mkdir -p ~/.local/share/aquaproj-aqua/bin
    fish -c 'fish_add_path ~/.local/share/aquaproj-aqua/bin'
}

function chezmoi_init() {
    sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply -S .
}

fish_install
aqua_install
chezmoi_init
