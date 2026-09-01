# SimBox Adminka — Flutter

Порт интерактивного прототипа панели управления SIM-боксом (GostSimBox, 2015 as-is)
на Flutter, на токенах дизайн-системы **NativeMind**.

## Запуск

```bash
cd flutter_simbox_adminka
flutter create . --platforms=web,macos,windows,linux   # создаёт платформенные папки
flutter pub get
flutter run -d chrome                                   # или -d macos
```

Проект рассчитан на широкий экран (десктоп / веб). Минимальная комфортная
ширина — 1280px; таблицы скроллятся горизонтально.

## Что внутри

| Путь | Назначение |
| --- | --- |
| `lib/design/tokens.dart` | Цвета, типографика, тени, токены плотной таблицы (`--adm-*`) |
| `lib/data/models.dart` | `Sim`, `Dongle`, `LogEntry`, `Cell`, `ColDef` |
| `lib/data/mock.dart` | Демо-данные: 8 симок, 4 свистка, планы, биллинг |
| `lib/data/icons_catalog.dart` | Реестр набора иконок GostSimBox по семантическим осям |
| `lib/state/app_state.dart` | `ChangeNotifier`: выбор строк, сортировка, фильтр, лог команд |
| `lib/widgets/adm_icon.dart` | 16px глиф с `FilterQuality.none` (nearest-neighbour) |
| `lib/widgets/dense_table.dart` | Плотная таблица: grid-колонки, зебра, залипающая шапка |
| `lib/widgets/command_log.dart` | Нижняя панель «Вывод команд» |
| `lib/pages/` | 11 разделов панели |

## Иконки

Исходный набор — 214 файлов 16×16 из `www/simbox/imgs`. Flutter не декодирует
`.ico`, поэтому все глифы сконвертированы в PNG с сохранением путей и имён.
Рендерятся строго 16px (или целым кратным) с `FilterQuality.none` —
дробные размеры замыливают пиксельную сетку.

## Отличия от прототипа

* Всплывающий лог у курсора (`showlog_cut.php`) реализован через `Tooltip` —
  привязан к элементу, а не к координатам курсора.
* Тосты — `SnackBar`; подтверждения — `AlertDialog`.
* Данные мок-овые; точки интеграции помечены `// TODO(api)` в `app_state.dart`.
