#!/bin/bash

#Дата
backup_date=`date +"%Y-%m-%d_%H-%M"`
#Папка бэкапов
backup_dir="/mnt/backup/"
#Количество дней
number_of_days=15

#Шпаргалочка - получаем список всех баз для бэкапа
#Выводим список баз без заголовков(psql -U postgres -lt), вырезаем первый столбец ипользуя рездаелитель |(cut -d'|' -f1)
#Удаляем пробелы sed (-e's/ //g') удаляем дефолтные и тестовые\ненужные базы(-e'/postgres/g' -e'/template/g' -e '/test/g')
#Удаляем пустые строки (-e '/^$/d')
databases=`psql -U postgres -lt | cut -d'|' -f1 | sed -e 's/ //g' -e'/postgres/g' -e'/template/g' -e '/test/g' -e '/^$/d'`

#В цикле делаем дамп и архивируем базы в папку бэкапов
for base in $databases
do
pg_dump -U postgres -cO $base | pigz > $backup_dir$backup_date-$base.sql.gz
done

# Удаляем бэкапы старше number_of_days дней
find $backup_dir -type f -prune -mtime +$number_of_days -exec rm -f {} \;
