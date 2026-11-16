#!/usr/bin/env bats
# Таблица пакетных менеджеров: выбор менеджера и аргументы установки.
# Менеджеры подменяются заглушками; PATH ограничивается каталогом заглушек только на время вызова.

load helpers

setup() {
    make_tmp
    use_module pkg
    BIN="$TEST_TMP/bin"
    LOG="$TEST_TMP/calls.log"
    mkdir -p "$BIN"
    : > "$LOG"
    export LOG
}

teardown() { clean_tmp; }

# fake_mgr ИМЯ [шаблон-отказа]: заглушка пишет аргументы в лог; если среди аргументов есть шаблон — завершается с ошибкой
fake_mgr() {
    printf '#!/bin/sh\necho "%s $*" >> "$LOG"\n' "$1" > "$BIN/$1"
    if [ -n "${2:-}" ]; then
        printf 'case "$*" in *%s*) exit 1;; esac\n' "$2" >> "$BIN/$1"
    fi
    chmod +x "$BIN/$1"
}

# with_fakes КОМАНДА...: PATH = только заглушки (builtin `command -v` внешних программ не требует)
with_fakes() { local PATH="$BIN"; "$@"; }

# строка целиком есть в логе вызовов
logged() { grep -qx -- "$1" "$LOG"; }

@test "pkg_mgr: ничего нет → код 1" {
    run with_fakes pkg_mgr
    [ "$status" -eq 1 ]
}

@test "pkg_mgr: находит apk" {
    fake_mgr apk
    run with_fakes pkg_mgr
    [ "$output" = "apk" ]
}

@test "pkg_mgr: apt-get приоритетнее dnf" {
    fake_mgr dnf; fake_mgr apt-get
    run with_fakes pkg_mgr
    [ "$output" = "apt-get" ]
}

@test "pkg_install: apt-get обновляет индекс и ставит пакеты" {
    fake_mgr apt-get
    run with_fakes pkg_install jq htop
    [ "$status" -eq 0 ]
    logged 'apt-get update -qq'
    logged 'apt-get install -y jq htop'
}

@test "pkg_install: pacman и apk получают свои флаги" {
    fake_mgr pacman
    with_fakes pkg_install jq
    logged 'pacman -Sy --noconfirm jq'

    rm "$BIN/pacman"
    fake_mgr apk
    with_fakes pkg_install jq
    logged 'apk add jq'
}

@test "pkg_install: SUDO подставляется перед менеджером" {
    printf '#!/bin/sh\necho "sudo-wrapper $*" >> "$LOG"\nexec "$@"\n' > "$BIN/mysudo"
    chmod +x "$BIN/mysudo"
    fake_mgr dnf
    SUDO="mysudo"
    with_fakes pkg_install jq
    logged 'sudo-wrapper dnf install -y jq'
}

@test "pkg_install: без менеджера код 1" {
    run with_fakes pkg_install jq
    [ "$status" -eq 1 ]
}

@test "pkg_install_any: берёт первый пакет, который встал" {
    fake_mgr apt-get "vim-xxd"
    run with_fakes pkg_install_any vim-xxd xxd
    [ "$status" -eq 0 ]
    logged 'apt-get install -y xxd'
}

@test "pkg_install_any: если не встал ни один — код 1" {
    fake_mgr apt-get "install"
    run with_fakes pkg_install_any a b
    [ "$status" -eq 1 ]
}
