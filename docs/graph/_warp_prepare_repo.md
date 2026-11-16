---
aliases: ["Подготовка репозитория WARP"]
tags: [rw-helper]
тип: внутренняя функция
строка: 1938
файл: scripts.sh
---
# Подготовка репозитория WARP

`_warp_prepare_repo` · `scripts.sh` L1938

Ставит `curl gnupg2 apt-transport-https lsb-release ca-certificates`, добавляет GPG-ключ и репозиторий `pkg.cloudflareclient.com` в `/etc/apt/sources.list.d/cloudflare-client.list`, делает `apt-get update`.

## Внешние команды и файлы
`pkg.cloudflareclient.com`

## Откуда вызывается
- [[install_warp]]
