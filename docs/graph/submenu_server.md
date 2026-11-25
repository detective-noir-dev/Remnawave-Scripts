---
aliases: ["Меню 5 · Server Setup"]
tags: [rw-menu]
тип: меню
строка: 12
файл: lib/menus.sh
---
# Меню 5 · Server Setup

`submenu_server` · `lib/menus.sh` L12

Подменю: 1 сменить порт SSH, 2 добавить публичный ключ SSH ed25519, 3 отключить вход по паролю SSH, 4 просмотреть конфиг SSH, 5 установить Zapret, 6 Hysteria2, 7 Cloudflare WARP, 8 Dante SOCKS5. 0 — назад.

## Содержит
- [[change_ssh_port]] — Смена SSH-порта
- [[add_ssh_ed25519_key]] — Добавление публичного ключа SSH ed25519
- [[disable_ssh_password_auth]] — Отключение входа по паролю SSH
- [[show_ssh_config]] — Просмотр конфигурации SSH
- [[install_zapret]] — Установка Zapret
- [[submenu_hysteria2]] — Hysteria2 (подменю)
- [[submenu_warp]] — Cloudflare WARP (подменю)

## Откуда вызывается
- [[show_main_menu]]
