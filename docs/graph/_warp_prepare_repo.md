---
aliases: ["Подготовка репозитория WARP"]
tags: [rw-helper]
тип: внутренняя функция
строка: 22
файл: lib/warp.sh
---
# Подготовка репозитория WARP

`_warp_prepare_repo` · `lib/warp.sh` L22

Ставит `curl gnupg2 apt-transport-https lsb-release ca-certificates`, добавляет GPG-ключ и репозиторий `pkg.cloudflareclient.com` в `/etc/apt/sources.list.d/cloudflare-client.list`, делает `apt-get update`.

## Внешние команды и файлы
`pkg.cloudflareclient.com`

## Откуда вызывается
- [[install_warp]]
