#!/bin/bash
# ====== НАСТРОЙКИ И ПОДГОТОВКА ======
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"
CONFIG_DIR="$HOME/.config/remnawave"
SCRIPT_PATH="$HOME/.local/bin/rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
PORTS_FILE="$DATA_DIR/ports.json"
CONFIG_FILE="$CONFIG_DIR/config"
LANG_FILE="$CONFIG_DIR/lang.conf"   # устарел: язык теперь в config; файл нужен откатам на старые версии

# config_get ключ [по_умолчанию] — значение из $CONFIG_FILE (строки ключ=значение); запись: config_set в lib/common.sh
config_get() {
    local v=""
    [ -f "$CONFIG_FILE" ] && v=$(sed -n "s/^$1=//p" "$CONFIG_FILE" | tail -n 1)
    echo "${v:-${2:-}}"
}

# читаем версию
if [ -s "$DATA_DIR/version.txt" ]; then
    VERSION=$(tr -d '\r\n' < "$DATA_DIR/version.txt")
else
    VERSION="dev"
fi

# Цвета
RED='\e[31m'; YELLOW='\e[33m'; GREEN='\e[32m'; BLUE='\e[34m'; CYAN='\e[36m'; MAGENTA='\e[35m'; NC='\e[0m'
BOLD='\e[1m'; DIM='\e[2m'

# Цвета выключаются переменной NO_COLOR, настройкой color=never и (при color=auto, по умолчанию) выводом не в терминал: cron, пайпы
_color_mode=$(config_get color auto)
if [ -n "${NO_COLOR+x}" ] || [ "$_color_mode" = never ] || { [ "$_color_mode" != always ] && [ ! -t 1 ]; }; then
    RED=''; YELLOW=''; GREEN=''; BLUE=''; CYAN=''; MAGENTA=''; NC=''; BOLD=''; DIM=''
fi

# sudo нужен только не-root пользователю (на VPS под root и в контейнерах его может не быть)
if [ "${EUID:-$(id -u)}" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

# ====== БАННЕР ======
show_banner() {
    clear
    echo -e "${BOLD}${GREEN}🚀 Remnawave-Scripts${NC} ${DIM}v$VERSION${NC}"
}

# ====== ТИХАЯ ПРОВЕРКА ОБНОВЛЕНИЙ ======
auto_check_update() {
    local latest
    latest=$(curl -fsS --connect-timeout 3 -m 5 "$REPO_URL/version.txt" 2>/dev/null | tr -d '\r\n')
    if [ -n "$latest" ] && [ "$latest" != "$VERSION" ]; then
        echo -e "${YELLOW}⚠️  A new version is available: $latest (you are on $VERSION)"
        echo -e "   Go to [4] Maintenance → [1] Update to install.${NC}"
        echo
    fi
}

# ====== БРЭЙЛ-КРУТИЛКА ======
loading_bar() {
    local delay=0.15
    local spin=(⠋ ⠙ ⠸ ⠴ ⠦ ⠧ ⠇ ⠏)
    tput civis
    while :; do
        for frame in "${spin[@]}"; do
            printf "$(tr_text L_CORE_001)" "$frame"
            sleep $delay
        done
    done
}

# ====== ЯЗЫК ======
LANG_SET=$(config_get lang)
if [ -z "$LANG_SET" ]; then
    LANG_SET="en"
    [ -f "$LANG_FILE" ] && LANG_SET=$(<"$LANG_FILE")   # установка, сделанная до появления config
fi

# ====== СЛОВАРЬ ======
# Тексты интерфейса лежат в lang/ru.sh и lang/en.sh, каждый файл определяет tr_text().
LANG_DIR="$DATA_DIR/lang"
tr_text() { echo "$1"; }   # запасной вариант, пока словарь не загружен

load_lang() {
    local code="en" f repo_dir
    [ "$LANG_SET" = "ru" ] && code="ru"

    # запуск из клонированного репозитория
    repo_dir=$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")
    if [ -s "$repo_dir/lang/$code.sh" ]; then
        # shellcheck disable=SC1090
        source "$repo_dir/lang/$code.sh"
        return 0
    fi

    f="$LANG_DIR/$code.sh"
    if [ ! -s "$f" ]; then
        # старый установщик/обновлятор не знал про lang/: докачиваем словарь
        mkdir -p "$LANG_DIR"
        curl -fsSL --connect-timeout 5 -m 15 "$REPO_URL/lang/$code.sh" -o "$f.part" 2>/dev/null \
            && mv "$f.part" "$f" || rm -f "$f.part"
    fi
    if [ -s "$f" ]; then
        # shellcheck disable=SC1090
        source "$f"
        return 0
    fi
    echo "⚠️  Dictionary $f not found, run the installer again." >&2
    return 1
}
load_lang

# ====== ЗАГОЛОВОК ПОДМЕНЮ ======
print_submenu_header() {
    local title="$1"
    echo -e "${CYAN}──${NC} ${BOLD}${MAGENTA}$title${NC} ${CYAN}──────────────────────${NC}"
}

# ====== МОДУЛИ ======
# Основной код лежит в lib/*.sh (по файлу на тему). Порядок подключения не важен:
# в модулях только определения функций и начальные значения переменных.
LIB_DIR="$DATA_DIR/lib"

load_modules() {
    local dir repo_dir stage f
    # запуск из клонированного репозитория
    repo_dir=$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")
    if [ -s "$repo_dir/lib/pkg.sh" ]; then
        dir="$repo_dir/lib"
    else
        dir="$LIB_DIR"
        if [ ! -s "$dir/pkg.sh" ]; then
            # старый установщик/обновлятор не знал про lib/: докачиваем модули
            stage="$DATA_DIR/.lib.$$"
            mkdir -p "$stage/lib"
            for f in pkg common firewall cli cleaner dante doctor hy2 ids maintenance memory menus scanner server system thirdparty warp; do
                curl -fsSL --connect-timeout 5 -m 15 "$REPO_URL/lib/$f.sh" -o "$stage/lib/$f.sh" 2>/dev/null \
                    || { rm -rf "$stage"; stage=""; break; }
            done
            if [ -n "$stage" ] && [ -s "$stage/lib/pkg.sh" ]; then
                rm -rf "$LIB_DIR"; mv "$stage/lib" "$LIB_DIR"; rm -rf "$stage"
            else
                echo "⚠️  Modules not found in $dir, run the installer again." >&2
                return 1
            fi
        fi
    fi
    for f in "$dir"/*.sh; do
        # shellcheck disable=SC1090
        source "$f"
    done
}
load_modules || exit 1

# ====== ЗАПУСК ======
# Команды без меню (cron, CI, баг-репорты):
#   rw-scripts clean           — полная уборка
#   rw-scripts doctor [--online] — диагностика окружения
#   rw-scripts version         — версия
#   rw-scripts rollback [--yes]  — вернуть версию до последнего обновления
#   status, ports, warp, hy2, config, log, completion, help — см. lib/cli.sh (rw-scripts help)
case "${1:-}" in
    status|ports|warp|hy2|config|log|completion|help|--help|-h)
        rw_cli "$@"
        exit $? ;;
    rollback|--rollback)
        rollback_update "${2:-}"
        exit $? ;;
    version|--version|-V)
        echo "$VERSION"
        exit 0 ;;
    doctor|--doctor)
        rw_doctor "${2:-}"
        exit $? ;;
    clean|--clean)
        before=$(_clean_get_free)
        _do_clean_all
        after=$(_clean_get_free)
        diff=$(( after - before ))
        echo
        if (( diff > 0 )); then
            echo -e "$(tr_text L_CORE_002 "$(_clean_human $diff)")"
        else
            echo -e "$(tr_text L_CORE_003)"
        fi
        echo "$(tr_text L_CORE_004 "$(_clean_human "$(_clean_get_free)")")"
        exit 0 ;;
esac
show_main_menu
