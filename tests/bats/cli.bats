#!/usr/bin/env bats
# lib/cli.sh и port_apply: команды без меню

load helpers

setup() {
    make_tmp
    DATA_DIR="$TEST_TMP/data"; CONFIG_DIR="$TEST_TMP/cfg"
    CONFIG_FILE="$CONFIG_DIR/config"; LANG_FILE="$CONFIG_DIR/lang.conf"
    VERSION="9.9.9"; LANG_SET="en"
    mkdir -p "$DATA_DIR" "$CONFIG_DIR"
    use_core config_get
    use_module common
    use_module firewall
    use_module cli
    tr_text() { echo "$1"; }
    CALLS="$TEST_TMP/calls"; : > "$CALLS"
}

teardown() { clean_tmp; }

# ---- port_apply ----

fake_ufw() {
    detect_firewall() { echo ufw; }
    ufw() { echo "ufw $*" >> "$CALLS"; }
    add_port_to_json() { echo "json add $*" >> "$CALLS"; }
    remove_port_from_json() { echo "json remove $*" >> "$CALLS"; }
}

@test "port_apply open both: оба протокола в ufw и в ports.json" {
    fake_ufw
    port_apply open 443 both "vless"
    grep -qx 'ufw allow 443/tcp' "$CALLS"
    grep -qx 'ufw allow 443/udp' "$CALLS"
    grep -qx 'json add 443 tcp vless' "$CALLS"
    grep -qx 'json add 443 udp vless' "$CALLS"
}

@test "port_apply close: удаляет правило и запись" {
    fake_ufw
    port_apply close 8443 udp
    grep -qx 'ufw delete allow 8443/udp' "$CALLS"
    grep -qx 'json remove 8443 udp' "$CALLS"
}

@test "port_apply: неверный порт, протокол или действие → код 3, файрвол не тронут" {
    fake_ufw
    run port_apply open 0 tcp;      [ "$status" -eq 3 ]
    run port_apply open 70000 tcp;  [ "$status" -eq 3 ]
    run port_apply open abc tcp;    [ "$status" -eq 3 ]
    run port_apply open 443 icmp;   [ "$status" -eq 3 ]
    run port_apply drop 443 tcp;    [ "$status" -eq 3 ]
    [ ! -s "$CALLS" ]
}

@test "port_apply: без файрвола → код 2" {
    detect_firewall() { echo none; }
    run port_apply open 443 tcp
    [ "$status" -eq 2 ]
}

@test "port_apply: ошибка ufw → код 1 и порт не попадает в ports.json" {
    fake_ufw
    ufw() { return 1; }
    run port_apply open 443 tcp
    [ "$status" -eq 1 ]
    [ ! -s "$CALLS" ]
}

# ---- команды ----

@test "ports open/close через rw_cli: разбор PORT/proto" {
    fake_ufw
    run rw_cli ports open 443/udp "my desc"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok: open 443/udp"* ]]
    grep -qx 'ufw allow 443/udp' "$CALLS"
    grep -q 'cli ports open 443/udp' "$RW_LOG"
}

@test "ports list: порт/протокол по строке" {
    get_firewall_ports() { printf '22|tcp\n443|udp\n'; }
    run rw_cli ports list
    [ "$output" = $'22/tcp\n443/udp' ]
}

@test "rw_cli: неизвестная команда → код 127 (дальше работает меню)" {
    run rw_cli nonsense
    [ "$status" -eq 127 ]
}

@test "config: set проверяет допустимые значения" {
    run rw_cli config set lang de
    [ "$status" -eq 2 ]
    run rw_cli config set lang ru
    [ "$status" -eq 0 ]
    [ "$(rw_cli config get lang)" = "ru" ]
}

@test "log: показывает хвост журнала" {
    _log_action 0 "first"; _log_action 0 "second"
    run rw_cli log 1
    [[ "$output" == *"second"* ]]
    [[ "$output" != *"first"* ]]
}

# ---- сервисы ----

@test "svc_summary: только установленные сервисы, ✔/✖ по состоянию" {
    systemctl() {
        case "$1" in
            show) [ "$5" = "hysteria-server.service" ] || [ "$5" = "docker.service" ] || [ "$5" = "ssh.service" ] \
                    && echo loaded || echo not-found ;;
            is-active) [ "$3" = "docker.service" ] && return 1; return 0 ;;
        esac
    }
    run svc_summary
    [[ "$output" == *"✔ ssh"* ]]
    [[ "$output" == *"✖ docker"* ]]
    [[ "$output" == *"✔ hy2"* ]]
    [[ "$output" != *"warp"* ]]
    [[ "$output" != *"ufw"* ]]
}

@test "svc_summary: без systemd пусто и без ошибки" {
    run bash -c 'PATH=/nonexistent; . "$0/lib/cli.sh"; svc_summary' "$ROOT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ---- автодополнение ----

@test "completion bash/zsh: синтаксически верный скрипт со всеми командами" {
    run rw_completion bash
    [[ "$output" == *"complete -F _rw_scripts rw-scripts"* ]]
    [[ "$output" == *"rollback"* ]]
    rw_completion bash | bash -n
    run rw_completion zsh
    [[ "$output" == "#compdef rw-scripts"* ]]
    run rw_completion fish
    [ "$status" -eq 2 ]
}
