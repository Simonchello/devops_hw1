# Само-ревью перед сдачей

Локальные проверки:

- [x] Compose config валиден.
- [x] YAML-файлы разбираются.
- [x] Bash syntax check проходит.
- [x] Пять тестов мониторинга проходят.
- [x] Порты и сети Terraform и Compose разделены.
- [x] Паролей, приватных ключей и Terraform state в коде нет.

Проверки развёртывания (по предоставленным выводам команд):

- [x] Ansible syntax-check.
- [x] Первый и второй запуск setup_host.yml; второй changed=0.
- [x] Terraform init, validate, plan, apply, state list.
- [ ] Подтверждён успешный Terraform fmt -check.
- [x] nginx :8081 возвращает 200 OK; сеть и том подключены.
- [x] Compose :80 возвращает Hello World; оба сервиса работают.
- [x] monitor.sh проверен на VM: активный и отсутствующий сервис.
- [x] monitor.sh проверен локально: отсутствие syslog (код 2), выгрузка journald (код 0).
- [x] Скриншоты Ansible и Terraform добавлены в README.
- [x] Скриншоты Compose и локального мониторинга добавлены в README.
- [ ] Скриншот мониторинга на VM добавлен в README.
- [x] Файл .terraform.lock.hcl добавлен в Git после init.
- [ ] PR/MR просмотрен и слит; тег v0.1.0 поставлен после слияния.
