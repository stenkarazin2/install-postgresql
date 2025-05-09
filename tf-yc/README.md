Terraform-скрипт для создания стенда на Yandex Cloud, состоящего из:
- виртуальной машины с ОС Debian
- виртуальной машины с ОС CentOS (AlmaLinux)
- виртуальной машины с load agent

На первые две виртуальные машины установлены веб-сервер Nginx для приема нагрузки от load agent и открытый ключ для SSH-соединений

Для запуска нужно:

1. Создать пару ключей для организации SSH-соединений. Файл с закрытым ключом id_rsa разместить в каталог со скриптом, а открытый ключ вставить в соответствующие поля файлов с метаданными metadata1.yaml и metadata2.yaml

2. В файле terraform.tfvars заполнить поля cloud_id, folder_id, subnet_id, service_account_id, yc_token. При этом сервисному аккаунту service_account_id в каталоге folder_id должна быть установлена роль loadtesting.generatorClient

3. Развернуть стенд, т.е. запустить команду

terraform init && terraform apply --auto-approve

4. С помощью load agent создать нагрузку на одну из виртуальных машин