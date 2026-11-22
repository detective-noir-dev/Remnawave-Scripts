#!/bin/bash
# lib/pkg.sh — установка пакетов: один список менеджеров вместо цепочек if/elif по всему коду
# Подключается из scripts.sh через load_modules; сам по себе не запускается.
# Нужна переменная SUDO ("" для root, иначе "sudo"); если её нет, считаем что sudo не нужен.

# pkg_mgr — печатает имя найденного менеджера пакетов, код 1 если ни одного нет
pkg_mgr() {
    local m
    for m in apt-get dnf yum pacman zypper apk brew; do
        if command -v "$m" >/dev/null 2>&1; then
            echo "$m"
            return 0
        fi
    done
    return 1
}

# pkg_install ПАКЕТ... — ставит пакеты через найденный менеджер (вывод не глушится)
pkg_install() {
    local m
    m=$(pkg_mgr) || return 1
    case "$m" in
        apt-get) ${SUDO-} apt-get update -qq && ${SUDO-} apt-get install -y "$@" ;;
        dnf|yum) ${SUDO-} "$m" install -y "$@" ;;
        pacman)  ${SUDO-} pacman -Sy --noconfirm "$@" ;;
        zypper)  ${SUDO-} zypper install -y "$@" ;;
        apk)     ${SUDO-} apk add "$@" ;;
        brew)    brew install "$@" ;;
    esac
}

# pkg_install_any ПАКЕТ... — пробует пакеты по очереди (в разных дистрибутивах имя разное), останавливается на первом удачном
pkg_install_any() {
    local p
    for p in "$@"; do
        pkg_install "$p" && return 0
    done
    return 1
}

# pkg_remove ПАКЕТ... — удаляет пакеты через найденный менеджер
pkg_remove() {
    local m
    m=$(pkg_mgr) || return 1
    case "$m" in
        apt-get) ${SUDO-} apt-get purge -y "$@" ;;
        dnf|yum) ${SUDO-} "$m" remove -y "$@" ;;
        pacman)  ${SUDO-} pacman -Rns --noconfirm "$@" ;;
        zypper)  ${SUDO-} zypper remove -y "$@" ;;
        apk)     ${SUDO-} apk del "$@" ;;
        brew)    brew uninstall "$@" ;;
    esac
}

# pkg_remove_any ПАКЕТ... — удаляет первое найденное имя пакета
pkg_remove_any() {
    local p
    for p in "$@"; do
        pkg_remove "$p" && return 0
    done
    return 1
}

# _pkg_install ИМЯ... — ставит только те, которых ещё нет ни как команды, ни как пакета dpkg
_pkg_install() {
    local pkg
    for pkg in "$@"; do
        if ! command -v "$pkg" >/dev/null 2>&1 && ! { command -v dpkg >/dev/null 2>&1 && dpkg -s "$pkg" >/dev/null 2>&1; }; then
            echo -e "$(tr_text L_PKG_001 "$pkg")"
            pkg_install "$pkg" &>/dev/null || true
        fi
    done
}
