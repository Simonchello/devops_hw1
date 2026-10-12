# Само-ревью перед сдачей

Локальные проверки:

- [x] Compose config валиден.
- [x] YAML-файлы разбираются.
- [x] Bash syntax check проходит.
- [x] Пять тестов мониторинга проходят.
- [x] Порты и сети Terraform и Compose разделены.
- [x] Паролей, приватных ключей и Terraform state в коде нет.

Требуют выполнения на доступном хосте:

- [ ] Ansible syntax-check.
- [ ] Первый и второй запуск setup_host.yml; второй changed=0.
- [ ] Terraform fmt, init, validate, plan, apply, state list.
- [ ] nginx :8081 возвращает 200 OK; сеть и том подключены.
- [ ] Compose :80 возвращает Hello World; оба сервиса работают.
- [ ] monitor.sh проверен на реальном локальном хосте и VM.
- [ ] Реальные скриншоты добавлены в README.
- [ ] Файл .terraform.lock.hcl добавлен в Git после init.
- [ ] PR/MR просмотрен и слит; тег v0.1.0 поставлен после слияния.
