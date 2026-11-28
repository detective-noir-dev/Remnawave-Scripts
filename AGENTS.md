# Правила работы с проектом Remnawave-Scripts

## Карта проекта (Obsidian)
Перед любой работой с кодом **прочитай карту**:
- `docs/graph/Карта rw-scripts.md` — точка входа, легенда, список веток
- Заметки по конкретным функциям: `docs/graph/<имя_функции>.md`

Это экономит токены — не нужно перечитывать исходники с нуля.

## Структура быстрого доступа
| Что нужно | Где смотреть |
|-----------|-------------|
| Главное меню, подменю | `lib/menus.sh` |
| Языковые строки (RU) | `lang/ru.sh` |
| Языковые строки (EN) | `lang/en.sh` |
| Переменные окружения, пути | `docs/graph/Окружение.md` |
| Конкретная функция | `docs/graph/<функция>.md` |

## Обновление карты после изменений
После каждого изменения кода **обнови** соответствующие заметки в `docs/graph/`:
- Если изменилась функция → обнови её `.md`
- Если добавлен новый пункт меню → обнови заметку подменю и `show_main_menu.md`
- Версию в `Карта rw-scripts.md` → синхронизируй с `version.txt`

## Процедура релиза
1. Изменить файлы
2. Обновить `version.txt` (bump)
3. Добавить запись в `CHANGELOG.md` и обновить версию в `README.md` и `README-ENG.md` (бейдж вверху, строка «Версия» / «Version» внизу и блок «Что нового» / «What's new»)
4. `SHA256SUMS` пересчитывается автоматически (`tools/gen-checksums.sh`) для совместимости со старыми версиями
5. `git add` → `git commit` → `git tag -a vX.Y.Z` → `git push origin main` → `git push origin vX.Y.Z`
6. `gh release create vX.Y.Z --title "vX.Y.Z" --notes "..."`
7. Обновить `Карта rw-scripts.md` с новой версией

> ⚠️ `git` и `gh` требуют `BypassSandbox: true`

## Ключевые пути (runtime)
- `DATA_DIR` = `~/.local/share/remnawave`
- `CONFIG_DIR` = `~/.config/remnawave`
- `SCRIPT_PATH` = `~/.local/bin/rw-scripts`
- `REPO_URL` = `https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main`
