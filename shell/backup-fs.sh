#!/bin/bash

# делаем "инкриментальный" бэкап через rsync
# все текущие данные будут лежать в папке для бэкапа
# дельта, измененные\удалённые данные из папки с данными попадут в папку для "инкрементального" бэкапа/сегодняшняя_дата
/usr/bin/rsync -a --delete /папка_с_данными /папка_для_бэкапа --backup --backup-dir=/папка_для_инкрементального_бэкапа/`date +%Y-%m-%d`/


# Чистим папки с инкрементными архивами старше 14-ти дней(не работает, чего то не хватает, не чистим)
#/usr/bin/find /mnt/adm/incr/ -type d -mtime +14 -exec rm -rf {} \;
