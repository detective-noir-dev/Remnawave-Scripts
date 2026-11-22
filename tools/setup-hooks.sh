#!/bin/bash
# Один раз после клонирования: включает хуки из .githooks.
cd "$(dirname "$0")/.." || exit 1
git config core.hooksPath .githooks
chmod +x .githooks/* 2>/dev/null
echo "Хуки включены: core.hooksPath = .githooks"
