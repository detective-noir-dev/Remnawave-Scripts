---
aliases: ["Установка jq"]
tags: [rw-shared]
тип: общий хелпер
строка: 23
файл: lib/firewall.sh
---
# Установка jq

`ensure_jq` · `lib/firewall.sh` L23

Если `jq` нет — ставит его через найденный пакетный менеджер (apt-get/apt/dnf/yum/pacman/zypper/brew) под спиннером. Возвращает 0/1. Нужна для работы с `ports.json`.

## Использует (общие хелперы)
`loading_bar`

## Откуда вызывается
- [[Общие хелперы]]
