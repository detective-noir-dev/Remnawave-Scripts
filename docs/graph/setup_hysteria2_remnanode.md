---
aliases: ["Hysteria2 для Remnanode (Xray inbound)"]
tags: [rw-func]
тип: действие
строка: 376
файл: lib/hy2.sh
---
# Hysteria2 для Remnanode (Xray inbound)

`setup_hysteria2_remnanode` · `lib/hy2.sh` L376

Подготавливает ноду Remnawave к Xray-инбаунду Hysteria2 с TLS-сертификатом Let's Encrypt. Нужен root и существующий `/opt/remnanode/docker-compose.yml`.

## Что происходит
1. проверка root и compose; если уже настроено — спрашивает про перенастройку
2. ввод домена, проверка наличия `/etc/letsencrypt/live/<домен>/{fullchain,privkey}.pem`
3. ввод UDP-порта (по умолчанию 443)
4. добавляет в `volumes` compose недостающие монтирования: `/dev/shm`, `cert.pem`, `cert.key` (резервная копия `.bak`; если правка не удалась — стоп и список монтирований для ручного добавления)
5. создаёт deploy-хук `restart-remnanode.sh` для перезапуска ноды при продлении сертификата
6. `_hy2r_open_udp` — открыть UDP-порт
7. по желанию `docker compose down && up -d`
8. печатает значения `certificateFile`, `keyFile`, `port` для Xray inbound

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`docker compose`, `certbot`, `/var/lib/remnawave/configs/xray/ssl`

## Вызывает
- [[_hy2r_open_udp]] — Открыть UDP-порт для Hysteria2

## Откуда вызывается
- [[submenu_hysteria2]]
