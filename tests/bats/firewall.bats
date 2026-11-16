#!/usr/bin/env bats
# Разбор вывода файрвола (get_firewall_ports) и работа с ports.json.
# ufw / firewall-cmd / iptables подменяются функциями, поэтому реальный файрвол не нужен.

load helpers

setup() {
    make_tmp
    use_module firewall
    PORTS_FILE="$TEST_TMP/ports.json"
}

teardown() { clean_tmp; }

@test "detect_firewall: возвращает одно из известных значений" {
    run detect_firewall
    [[ "$output" =~ ^(ufw|firewalld|iptables|none)$ ]]
}

@test "get_firewall_ports: ufw (включая строки (v6), дубли схлопываются)" {
    detect_firewall() { echo ufw; }
    ufw() {
        cat <<'OUT'
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
443/udp                    ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
OUT
    }
    run get_firewall_ports
    [ "$status" -eq 0 ]
    [ "$output" = $'22|tcp\n443|udp' ]
}

@test "get_firewall_ports: firewalld" {
    detect_firewall() { echo firewalld; }
    firewall-cmd() { echo "80/tcp 8443/udp 51820/udp"; }
    run get_firewall_ports
    [ "$output" = $'51820|udp\n80|tcp\n8443|udp' ]
}

@test "get_firewall_ports: iptables берёт только ACCEPT с dpt:" {
    detect_firewall() { echo iptables; }
    iptables() {
        cat <<'OUT'
Chain INPUT (policy DROP)
target     prot opt source               destination
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:443
ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0            udp dpt:51820
DROP       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:23
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
OUT
    }
    run get_firewall_ports
    [ "$output" = $'443|tcp\n51820|udp' ]
}

@test "get_firewall_ports: нет файрвола → пусто" {
    detect_firewall() { echo none; }
    run get_firewall_ports
    [ -z "$output" ]
}

# ---- ports.json (нужен jq; в CI он ставится) ----

@test "ports.json: добавить, переименовать, удалить" {
    command -v jq >/dev/null 2>&1 || skip "jq не установлен"

    add_port_to_json 443 tcp "vless"
    [ "$(jq -r '.[0].port' "$PORTS_FILE")" = "443" ]
    [ "$(jq -r '.[0].protocol' "$PORTS_FILE")" = "tcp" ]
    [ "$(jq -r '.[0].description' "$PORTS_FILE")" = "vless" ]

    edit_port_description 443 tcp "xray"
    [ "$(jq -r '.[0].description' "$PORTS_FILE")" = "xray" ]

    add_port_to_json 443 udp "hy2"
    [ "$(jq 'length' "$PORTS_FILE")" -eq 2 ]

    remove_port_from_json 443 tcp
    [ "$(jq 'length' "$PORTS_FILE")" -eq 1 ]
    [ "$(jq -r '.[0].protocol' "$PORTS_FILE")" = "udp" ]
}

@test "init_ports_file: создаёт пустой массив и не затирает существующий файл" {
    init_ports_file
    [ "$(cat "$PORTS_FILE")" = "[]" ]
    echo '[{"port":"1"}]' > "$PORTS_FILE"
    init_ports_file
    [ "$(cat "$PORTS_FILE")" = '[{"port":"1"}]' ]
}
