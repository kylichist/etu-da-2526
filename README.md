# etu-da-2526

## Пререквизиты

1. Установка пакетов: `spin tcl tk graphviz wish`
2. Установка gui-скрипта: [raw](https://raw.githubusercontent.com/nimble-code/Spin/refs/heads/master/optional_gui/ispin.tcl)

Для Ubuntu можно запустить таргет `prerequisites`:

```bash
make prerequisites
```

## Проверка окружения

Запустить таргет `run-helloworld`:

```bash
make run-helloworld
```

Если видим в логах что-то вроде

```text
Running Hello World in CLI...
Spin Version 6.5.2 -- 6 December 2019
      Hello, World!
1 process created
```

## Запуск верификации

CLI:

```bash
make run
```

GUI:

```bash
make run-gui
```
