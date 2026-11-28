---
tags: [rw-menu]
---
# submenu_dante

Подменю «🧦 SOCKS5-прокси (Dante)» — пункт **5** в [[submenu_server]].

## Пункты меню
| # | Функция | Тег |
|---|---------|-----|
| 1 | `_dante_install` | `#rw-func` |
| 2 | `_dante_change_ips` | `#rw-func` |
| 3 | `_dante_status` | `#rw-func` |
| 4 | inline restart + `_dante_bind_state` | `#rw-func` |
| 5 | `journalctl -u danted` | `#rw-func` |
| 6 | `_dante_remove` | `#rw-func` |

## Хелперы
| Функция | Что делает | Тег |
|---------|------------|-----|
| `_dante_installed` | проверяет наличие `danted` в PATH | `#rw-helper` |
| `_dante_valid_ip` | валидация IPv4 (не 0.0.0.0) | `#rw-helper` |
| `_dante_valid_port` | валидация порта 1-65535 | `#rw-helper` |
| `_dante_iface` | интерфейс маршрута по умолчанию | `#rw-helper` |
| `_dante_port` | порт из `DANTE_CONF` | `#rw-helper` |
| `_dante_conf_iface` | интерфейс из `DANTE_CONF` | `#rw-helper` |
| `_dante_ips` | список IP из `client pass` блоков | `#rw-helper` |
| `_dante_ask_ips` | интерактивный ввод IP → массив `DANTE_IPS` | `#rw-helper` |
| `_dante_fw add\|del IP PORT` | правило фаервола (ufw/firewalld/iptables), возвращает ошибку команды; в iptables повторы и отсутствующие правила не ошибка, сохраняет через `netfilter-persistent` | `#rw-helper` |
| `_dante_write_conf PORT IFACE IP…` | генерирует конфиг, проверяет `danted -Vf`, сохраняет `.bak` | `#rw-helper` |
| `_dante_bind_state` | сравнивает listen-адрес с текущим IP интерфейса | `#rw-helper` |
| `_dante_print_summary` | итоговый блок: порт, IP, команда проверки | `#rw-helper` |

При установке и смене IP старые правила снимаются только после того, как новый конфиг прошёл проверку.

## Использует (общие хелперы)
`show_banner`, `print_submenu_header`, `run_step`, `pkg_install_any`, `pkg_remove_any`,
`detect_firewall`, `tr_text`, `$SUDO`, `$DANTE_CONF` (=/etc/danted.conf),
`_DASH_EXT_IP` (кэш внешнего IP из menus.sh)

## Файл
`lib/dante.sh`

## Переменная конфига
`DANTE_CONF=/etc/danted.conf`

## Ключи словарей
Все строки — `L_DANTE_*` + `SUB_DANTE`, `SUB_DANTE_SUBMENU` в `lang/ru.sh` и `lang/en.sh`.

## Дашборд / status
Сервис `danted` добавлен в `RW_SERVICES` в `lib/cli.sh` как `dante:danted`.
