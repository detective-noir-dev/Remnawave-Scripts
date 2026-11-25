---
aliases: ["Проверка ключей authorized_keys"]
tags: [rw-helper]
тип: хелпер
файл: lib/server.sh
---
# Проверка ключей authorized_keys

`_ssh_authorized_key_count` · `lib/server.sh`

Подсчитывает распознаваемые публичные ключи в `authorized_keys`: ed25519, RSA, DSA, ECDSA и security-key. Пропускает пустые строки и комментарии. Используется как защита от блокировки доступа перед отключением парольной аутентификации.

## Откуда вызывается
- [[disable_ssh_password_auth]]
