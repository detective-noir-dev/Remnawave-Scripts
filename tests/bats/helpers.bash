# Общие настройки для bats-тестов. Подключение: load helpers
# Модули подключаются напрямую (source), без запуска меню: в lib/*.sh только функции и переменные.

ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"

# цвета и SUDO обычно задаёт scripts.sh; для юнит-тестов хватает пустых значений
RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''; NC=''; BOLD=''; DIM=''
SUDO=""
export SUDO

# эмодзи-флаги (\U...) печатаются только в UTF-8
export LC_ALL=C.UTF-8

use_module() {
    # shellcheck disable=SC1090
    source "$ROOT/lib/$1.sh"
}

make_tmp() {
    TEST_TMP="$(mktemp -d)"
}

clean_tmp() {
    [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
    return 0
}
