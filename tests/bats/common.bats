#!/usr/bin/env bats
# lib/common.sh: настройки, журнал действий, run_step, безопасный запуск сторонних скриптов

load helpers

setup() {
    make_tmp
    DATA_DIR="$TEST_TMP/data"; CONFIG_DIR="$TEST_TMP/cfg"
    CONFIG_FILE="$CONFIG_DIR/config"; LANG_FILE="$CONFIG_DIR/lang.conf"
    mkdir -p "$DATA_DIR" "$CONFIG_DIR"
    use_core config_get _sha256_of
    use_module common
    tr_text() { echo "$1"; }
}

teardown() { clean_tmp; }

# ---- настройки ----

@test "config_get: значение по умолчанию, если файла или ключа нет" {
    [ "$(config_get lang en)" = "en" ]
    [ -z "$(config_get lang)" ]
    echo "color=never" > "$CONFIG_FILE"
    [ "$(config_get lang ru)" = "ru" ]
}

@test "config_set: записывает, заменяет и не трогает другие ключи" {
    config_set lang ru
    config_set color never
    config_set lang en
    [ "$(config_get lang)" = "en" ]
    [ "$(config_get color)" = "never" ]
    [ "$(grep -c '^lang=' "$CONFIG_FILE")" -eq 1 ]
}

@test "config_set lang: дублирует язык в lang.conf для откатов на старые версии" {
    config_set lang ru
    [ "$(cat "$LANG_FILE")" = "ru" ]
}

# ---- журнал ----

@test "_log_action: пишет код, описание и подробности (не больше 20 строк)" {
    _log_action 2 "demo step" "$(seq 1 50)"
    grep -q 'rc=2 demo step' "$RW_LOG"
    [ "$(wc -l < "$RW_LOG")" -eq 21 ]
}

@test "_log_action: большой журнал уходит в actions.log.1" {
    head -c 300000 /dev/zero | tr '\0' 'x' > "$RW_LOG"
    _log_action 0 "after rotation"
    [ -f "$RW_LOG.1" ]
    [ "$(wc -l < "$RW_LOG")" -eq 1 ]
}

# ---- run_step ----

@test "run_step: успех → ✅ и rc=0 в журнале" {
    run run_step "make coffee" true
    [ "$status" -eq 0 ]
    [[ "$output" == *"✅ make coffee"* ]]
    grep -q 'rc=0 make coffee' "$RW_LOG"
}

@test "run_step: ошибка → ❌, код команды и хвост вывода" {
    run run_step "break things" bash -c 'echo boom; exit 3'
    [ "$status" -eq 3 ]
    [[ "$output" == *"❌ break things (rc=3)"* ]]
    [[ "$output" == *"boom"* ]]
    grep -q 'rc=3 break things' "$RW_LOG"
}

# ---- сторонние скрипты ----

remote_url() {
    printf '#!/bin/sh\necho "ran with: $*" > "%s/ran.txt"\n' "$TEST_TMP" > "$TEST_TMP/script.sh"
    REMOTE_URL="file://$(cd "$TEST_TMP" && { pwd -W 2>/dev/null || pwd; })/script.sh"
}

@test "run_remote_script: после «y» запускает, передаёт аргументы, сохраняет копию" {
    remote_url
    run_remote_script "$REMOTE_URL" --flag <<<"y" >/dev/null
    [ "$(cat "$TEST_TMP/ran.txt")" = "ran with: --flag" ]
    [ -n "$(ls "$DATA_DIR/third-party")" ]
}

@test "run_remote_script: «n» отменяет и ничего не запускает" {
    remote_url
    run run_remote_script "$REMOTE_URL" <<<"n"
    [ "$status" -eq 3 ]
    [ ! -e "$TEST_TMP/ran.txt" ]
}

@test "run_remote_script: неверный RW_EXPECT_SHA256 отклоняется без вопросов" {
    remote_url
    RW_EXPECT_SHA256="0000" run run_remote_script "$REMOTE_URL" <<<"y"
    [ "$status" -eq 1 ]
    [ ! -e "$TEST_TMP/ran.txt" ]
}

@test "run_remote_script: верный RW_EXPECT_SHA256 принимается" {
    remote_url
    local h; h=$(_sha256_of "$TEST_TMP/script.sh")
    RW_EXPECT_SHA256="$h" run_remote_script "$REMOTE_URL" <<<"y" >/dev/null
    [ -e "$TEST_TMP/ran.txt" ]
}

@test "run_remote_script: недоступный URL → код 1" {
    run run_remote_script "file:///nonexistent/none.sh" <<<"y"
    [ "$status" -eq 1 ]
}
