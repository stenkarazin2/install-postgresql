З а д а н и е :

Реализовать консольное приложение, которое будет устанавливать PostgreSQL на удаленный хост, настраивать и запускать.

Вводные: 2 сервера, один на Debian, второй на CentOS (AlmaLinux). На обоих серверах пользователю root подложен один и тот же открытый ssh ключ. У исполнителя есть закрытая часть ключа, с помощью которой он подключается.

Реализация должна включать:

- подключение к удаленным хостам по ssh
- оценку загруженности серверов, выбор наименее нагруженного из серверов как целевого
- инсталляцию PostgreSQL на целевой хост
- настройку PostgreSQL для приема внешних соединений, т.е. БД должна отвечать на sql-запросы с внешних ip-адресов
- настройку подключения пользователя “student” к PostgreSql только с ip адреса второго сервера.

Требования

- приложение принимает один строковый параметр - ip адреса или имена серверов одной строкой, разделитель - запятая
- приложение должно сообщать статус выполнения инсталляции

Будет плюсом

- приложение выполняет проверку работы БД, выполняя sql запрос (SELECT 1)

Требования к коду

- язык разработки: bash, python, ansible
- библиотеки можно использовать любые
- код должен быть выложен на Github с Readme файлом с инструкцией по запуску и примерами. Важно, чтобы по инструкции можно было запустить код и он работал
- при возникновении вопросов по ТЗ оставляем принятие решения за тобой.

Желательно отразить в Readme, какие вопросы возникали и какие решения были приняты



И н с т р у к ц и я :

1. Создать тестовый стенд, включающий два хоста:
- хост №1 с ОС Debian, доступный по имени или IP-адресу ID1 (ID = идентификатор)
- хост №2 с ОС AlmaLinux, доступный по имени или IP-адресу ID2

На каждом из хостов для этих же IP-адресов должен быть открыт доступ для запросов к порту 5432

2. Запустить скрипт в среде bash командой

python3 script.py ID1,ID2

Например,

python3 script.py 158.160.18.110,158.160.57.17

3. Аутентифицироваться на хосте №2 с помощью команды

ssh root@ID2

4. Попытаться подключиться к СУБД на целевом хосте с адресом IDЦ, используя учетную запись student с паролем secure (для определения того, какой из хостов является целевым, см. вывод предыдущей команды), например:

psql -U student -W -h IDЦ -d postgres

(ДОЛЖНО ПОЛУЧИТЬСЯ)

5. Попытаться подключиться к СУБД на целевом хосте с другим адресом IDД, используя учетную запись student с паролем secure, например:

psql -U student -W -h IDД -d postgres

(ДОЛЖНО НЕ ПОЛУЧИТЬСЯ)

6. Повторить пп.3-5 для хоста №1 (ДОЛЖНО НЕ ПОЛУЧИТЬСЯ)

7. Аутентифицироваться на целевом хосте с помощью команды

ssh root@IDЦ

8. Запустить команду

useradd student

9. Запустить команду

su student

10. Попытаться подключиться к СУБД c помощью unix-sockets, используя учетную запись student, например:

psql -d postgres

(ДОЛЖНО НЕ ПОЛУЧИТЬСЯ)

11. Аутентифицироваться на любом хосте (т.е. на хосте с идентификатором IDЛ) с помощью команды

ssh root@IDЛ

12. Попытаться подключиться к СУБД на целевом хосте с адресом IDЦ, используя другую вновь созданную учетную запись, например:

psql -U aspirant -W -h IDЦ -d postgres

(ДОЛЖНО ПОЛУЧИТЬСЯ)



К о м м е н т а р и и :

1. Критериями качества при создании скрипта script.py были выбраны минимизация количества установлений SSH-соединений, максимально возможное соответствие стандартной установке из репозиториев и удобство запуска, в частности решено не добавлять каких-либо дополнительных учетных записей и не заставлять пользователя устанавливать какие-либо dependencies

2. Скрипт script.py тестировался на инфраструктуре Yandex Cloud. Terraform-скрипты и инструкция для развертывания данной инфраструктуры приведены в каталоге tf-yc

3. При первом обращении к хосту по SSH в файле known_hosts нет информации об этом хосте, поэтому выводится сообщение
Are you sure you want to continue connecting (yes/no)?
В ответ нужно ввести yes, чтобы добавить в файл known-hosts информацию о новом хосте. Для удобства можно подключиться по SSH к обоим хостам до запуска скрипта script.py

4. Критерий для определения целевого хоста не задан; в качестве такового был выбран осредненный по всем ядрам показатель простоя процессора %idle, доступный по команде mpstat. Аналогично можно определить нагрузку на каждое ядро каждого хоста и выбрать наименее нагруженное ядро. Для генерации нагрузки на процессор использовался load-agent (см. Terraform-скрипт для его создания в каталоге tf-yc). Можно было выбрать и другие критерии нагруженности как с точки зрения времени отклика, так и с точки зрения реальных потребностей СУБД в объемах ОЗУ и ПЗУ, отражающие динамику изменения параметров за различные промежутки времени

5. В конфигах скрипта script.py пароль для учетной записи student указан в открытом виде. Это сделано исключительно в демонстрационных целях (чтобы не усложнять). Конечно, нужно как минимум использовать Ansible Vault для шифрования файла с паролем, а лучше организовать создание пароля самим пользователем

6. В задании указано, что учетной записи student нужно обеспечить доступ к серверу PostgreSQL со второго хоста по IP, даже если этот сервер установлен на том же, втором, хосте. Конечно, логичнее было бы организовать доступ через unix-sockets или хотя бы через интерфейс обратной петли; это обеспечило бы меньшее время отклика и лучшую сетевую безопасность: локальный доступ по внешнему IP противоречит здравому смыслу и обычно запрещается настройками сетевого экрана

7. При использовании облачной инфраструктуры обращение к хостам происходит по публичным IP-адресам; при этом в listen_addresses нужно указывать локальный IP-адрес целевого хоста, а в файле pg_hba.conf в качестве IP-адреса для учетной записи student можно указать как публичный, так и локальный IP-адрес второго хоста. В случае запуска скрипта script.py на хосте, расположенном в одной локальной сети с удаленными хостами, для везде будут использоваться IP-адреса локальной сети

8. Непосредственно для установки PostgreSQL используется роль geerlingguy.postgresql. Эта роль предоставляет возможность настройки переменных, в частности:
- если на целевом сервере используется Python 3, то используется библиотека python3-psycopg2
- если в качестве целевого выбран сервер с AlmaLinux, можно указать репозиторий, например, epel

9. Внесены изменения в роль geerlingguy.postgresql, а именно в файл defaults/main.yml:
- добавлена локаль ru_RU.UTF-8
- в конфигурационную опцию listen_addresses добавлен локальный IP-адрес (если точнее, IP-адрес по умолчанию) целевого хоста, хотя для обращения к серверу PostgreSQL нужно использовать публичный IP-адрес
- добавлена переменная ip_address_for_student для использования в шаблоне templates/pg_hba.conf.j2, чтобы обеспечить доступ для учетной записи student с заданного IP-адреса
- добавлены строки в шаблон файла pg_hba.conf для ограничения доступа учетной записи student как со всех IP-адресов, кроме заданного, так и через unix-sockets в случае создания одноименной учетной записи Linux
- добавлены строки в шаблон файла pg_hba.conf для разрешения доступа остальным пользователям с любых адресов

10. Тестовая команда SELECT 1 обращается к БД postgres от имени учетной записи postgres (в СУБД и в Linux)

11. Запуск команды dig для выяснения IP-адреса второго хоста соответствует антипаттерну bashsible. Чтобы этого избежать, нужно использовать коллекцию community.general

12. Много нервов отняла борьба с warnings