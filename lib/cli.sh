#!/bin/bash
# lib/cli.sh — команды без меню: status, ports, warp, hy2, config, log, completion, help
# Подключается из scripts.sh через load_modules; сам по себе не запускается.
# Вывод на английском и без вопросов: команды рассчитаны на cron, Ansible и мониторинг.
# Новые модули пишутся совместимо с `set -u` (все необязательные переменные через ${имя:-}); это проверяет tests/run.sh.

# ====== СЕРВИСЫ ======
# _svc_state ЮНИТ... — active|inactive для первого найденного юнита; код 1, если ни один не установлен (или нет systemd)
_svc_state() {
    local u
    command -v systemctl >/dev/null 2>&1 || return 1
    for u in "$@"; do
        [ "$(systemctl show -p LoadState --value "$u.service" 2>/dev/null)" = "loaded" ] || continue
        if systemctl is-active --quiet "$u.service"; then echo active; else echo inactive; fi
        return 0
    done
    return 1
}

# список «имя:юниты» для дашборда и status
RW_SERVICES=("ssh:ssh sshd" "ufw:ufw" "docker:docker" "hy2:hysteria-server" "warp:warp-svc" "fail2ban:fail2ban")

# svc_summary — одна строка «✔ ssh  ✔ docker  ✖ hy2», только установленные сервисы
svc_summary() {
    local pair name st out=""
    for pair in "${RW_SERVICES[@]}"; do
        name="${pair%%:*}"
        # shellcheck disable=SC2086
        st=$(_svc_state ${pair#*:}) || continue
        if [ "$st" = "active" ]; then out+="${BOLD}${GREEN}✔${NC} $name  "; else out+="${BOLD}${RED}✖${NC} $name  "; fi
    done
    [ -n "$out" ] && echo -e "${out%  }"
    return 0
}

# ====== КОМАНДЫ ======
cli_help() {
    cat <<'EOF'
Usage: rw-scripts [command]

  (no command)               interactive menu
  status                     version and state of ssh, ufw, docker, hysteria2, warp, fail2ban
  ports [list]               open ports as seen by the firewall
  ports open PORT[/tcp|/udp] [description]
  ports close PORT[/tcp|/udp]
  warp status|connect|disconnect
  hy2 status|start|stop|restart|enable|logs|version
  clean                      full system cleanup
  doctor [--online]          environment diagnostics
  verify [--online]          check installed files against SHA256SUMS
  rollback [--yes]           return to the version before the last update
  config [list|get KEY|set KEY VALUE]   settings: lang (ru|en), color (auto|always|never)
  log [N]                    last N lines of the action log (default 30)
  completion bash|zsh        print a shell completion script
  version                    print version
EOF
}

cli_status() {
    local pair name st any=0
    echo "rw-scripts $VERSION (lang: $LANG_SET)"
    for pair in "${RW_SERVICES[@]}"; do
        name="${pair%%:*}"
        # shellcheck disable=SC2086
        st=$(_svc_state ${pair#*:}) || continue
        printf '%-10s %s\n' "$name" "$st"
        any=1
    done
    [ "$any" -eq 1 ] || echo "(no known services found, or systemd is not available)"
    return 0
}

cli_ports() {
    local sub="${1:-list}" spec port proto rc line
    case "$sub" in
        list)
            while IFS='|' read -r port proto; do
                [ -n "$port" ] && echo "$port/$proto"
            done < <(get_firewall_ports)
            ;;
        open|close)
            spec="${2:-}"
            [ -n "$spec" ] || { echo "usage: rw-scripts ports $sub PORT[/tcp|/udp]" >&2; return 2; }
            port="${spec%%/*}"; proto="both"
            [[ "$spec" == */* ]] && proto="${spec#*/}"
            port_apply "$sub" "$port" "$proto" "${3:-via CLI}"
            rc=$?
            case "$rc" in
                0) echo "ok: $sub $port/$proto" ;;
                2) echo "no supported firewall found" >&2 ;;
                3) echo "invalid port or protocol: $spec" >&2 ;;
                *) echo "failed to $sub $port/$proto" >&2 ;;
            esac
            _log_action "$rc" "cli ports $sub $port/$proto"
            return "$rc"
            ;;
        *) line="usage: rw-scripts ports [list|open|close]"; echo "$line" >&2; return 2 ;;
    esac
}

cli_warp() {
    command -v warp-cli >/dev/null 2>&1 || { echo "warp-cli is not installed" >&2; return 1; }
    case "${1:-status}" in
        status)     warp-cli --accept-tos status ;;
        connect)    run_step "WARP connect" warp-cli --accept-tos connect ;;
        disconnect) run_step "WARP disconnect" warp-cli --accept-tos disconnect ;;
        *) echo "usage: rw-scripts warp status|connect|disconnect" >&2; return 2 ;;
    esac
}

cli_hy2() {
    local unit="hysteria-server.service" act="${1:-status}"
    case "$act" in
        status)  $SUDO systemctl status "$unit" --no-pager -l ;;
        start|stop|restart)
            run_step "hysteria2 $act" $SUDO systemctl "$act" "$unit" ;;
        enable)  run_step "hysteria2 enable" $SUDO systemctl enable --now "$unit" ;;
        logs)    $SUDO journalctl --no-pager -n "${2:-50}" -u "$unit" ;;
        version) hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        *) echo "usage: rw-scripts hy2 status|start|stop|restart|enable|logs|version" >&2; return 2 ;;
    esac
}

cli_config() {
    local sub="${1:-list}" key="${2:-}"
    case "$sub" in
        list)
            [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "(no settings saved; defaults are used)"
            ;;
        get)
            [ -n "$key" ] || { echo "usage: rw-scripts config get KEY" >&2; return 2; }
            config_get "$key"
            ;;
        set)
            [ -n "$key" ] && [ -n "${3:-}" ] || { echo "usage: rw-scripts config set KEY VALUE" >&2; return 2; }
            case "$key:$3" in
                lang:ru|lang:en|color:auto|color:always|color:never) ;;
                *) echo "unsupported setting: $key=$3 (lang: ru|en, color: auto|always|never)" >&2; return 2 ;;
            esac
            config_set "$key" "$3" && echo "$key=$3"
            ;;
        *) echo "usage: rw-scripts config [list|get KEY|set KEY VALUE]" >&2; return 2 ;;
    esac
}

cli_log() {
    local n="${1:-30}"
    [[ "$n" =~ ^[0-9]+$ ]] || n=30
    if [ -s "$RW_LOG" ]; then tail -n "$n" "$RW_LOG"; else echo "(action log is empty)"; fi
}

# rw_completion bash|zsh — скрипт автодополнения для подкоманд
rw_completion() {
    local words="status ports warp hy2 clean doctor verify rollback config log completion version help"
    case "${1:-bash}" in
        bash)
            cat <<EOF
# rw-scripts bash completion. Install: rw-scripts completion bash > ~/.local/share/bash-completion/completions/rw-scripts
_rw_scripts() {
    local cur="\${COMP_WORDS[COMP_CWORD]}" prev="\${COMP_WORDS[COMP_CWORD-1]}"
    if [ "\$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( \$(compgen -W "$words" -- "\$cur") )
        return
    fi
    case "\${COMP_WORDS[1]}" in
        ports)  COMPREPLY=( \$(compgen -W "list open close" -- "\$cur") ) ;;
        warp)   COMPREPLY=( \$(compgen -W "status connect disconnect" -- "\$cur") ) ;;
        hy2)    COMPREPLY=( \$(compgen -W "status start stop restart enable logs version" -- "\$cur") ) ;;
        config) COMPREPLY=( \$(compgen -W "list get set" -- "\$cur") ) ;;
        completion) COMPREPLY=( \$(compgen -W "bash zsh" -- "\$cur") ) ;;
        doctor|verify) COMPREPLY=( \$(compgen -W "--online" -- "\$cur") ) ;;
        rollback) COMPREPLY=( \$(compgen -W "--yes" -- "\$cur") ) ;;
    esac
}
complete -F _rw_scripts rw-scripts
EOF
            ;;
        zsh)
            cat <<EOF
#compdef rw-scripts
# rw-scripts zsh completion. Install: rw-scripts completion zsh > "\${fpath[1]}/_rw-scripts"
_rw_scripts() {
    local -a cmds
    cmds=(${words})
    if (( CURRENT == 2 )); then
        compadd -- \$cmds
        return
    fi
    case \$words[2] in
        ports)  compadd list open close ;;
        warp)   compadd status connect disconnect ;;
        hy2)    compadd status start stop restart enable logs version ;;
        config) compadd list get set ;;
        completion) compadd bash zsh ;;
        doctor|verify) compadd -- --online ;;
        rollback) compadd -- --yes ;;
    esac
}
_rw_scripts "\$@"
EOF
            ;;
        *) echo "usage: rw-scripts completion bash|zsh" >&2; return 2 ;;
    esac
}

# rw_cli КОМАНДА [АРГУМЕНТЫ] — точка входа для scripts.sh
rw_cli() {
    local cmd="${1:-}"
    [ "$#" -gt 0 ] && shift
    case "$cmd" in
        status)     cli_status ;;
        ports)      cli_ports "$@" ;;
        warp)       cli_warp "$@" ;;
        hy2)        cli_hy2 "$@" ;;
        config)     cli_config "$@" ;;
        log)        cli_log "$@" ;;
        completion) rw_completion "${1:-bash}" ;;
        help|--help|-h) cli_help ;;
        *) return 127 ;;
    esac
}
