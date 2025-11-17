# Local Lakehouse Platform (MinIO + Nessie + Trino + Airflow)

Автоматизированное развёртывание локальной Lakehouse-платформы на Ubuntu 22.04.
Подходит для того, чтобы быстро поднять полноценную среду для разработки и тестирования пайплайнов.

Платформа включает:

* **MinIO** - S3-хранилище
* **Nessie** - каталог Iceberg
* **Trino** - SQL-движок
* **Airflow** - оркестратор ETL/ELT

Развёртывание выполняется через набор скриптов и Docker Compose.

---

# Скрипты

## **01-install-deps.sh**

Устанавливает:

* Docker CE
* Docker Compose v2
* Python3 + pip
* cryptography
* git, curl, openssl

Добавляет пользователя в группу `docker`.

**Зачем:** полностью автоматизировать подготовку среды на чистой Ubuntu.
После выполнения требуется перелогиниться.

---

## **02-clone-lakehouse.sh**

Клонирует upstream-репозиторий в `/opt/lakehouse_repo`.

---

## **03-generate-env.sh**

Создаёт `.env` со всеми секретами:

* MINIO_ROOT_PASSWORD
* Airflow Fernet Key
* Airflow Webserver Secret
* Airflow Admin Password
* Trino password
* Nessie password
* `AIRFLOW_UID=50000` (для корректной работы compose)

Используются криптостойкие генераторы (`openssl rand -hex`, `Fernet`).

---

## **03-regenerate-env.sh**

Полный reset:

* останавливает все сервисы
* удаляет `.env`
* генерирует новый

Используется перед “чистым запуском”.

---

## **04-start-lakehouse.sh**

Запускает весь стек в нужном порядке:

1. MinIO + Nessie
2. Trino
3. Airflow

Дополнительно:

* выполняет `init.sql` в Trino (создаёт схемы `landing/staging/curated`)
* выводит доступы и пароли

---

## **05-stop-lakehouse.sh**

Корректно останавливает:

1. Airflow
2. Trino
3. MinIO + Nessie

Удаляет volumes.

---

## **06-status-lakehouse.sh**

Показывает состояние всех контейнеров с health-чеками, сгруппировано по сервисам.

---

# Изменения в репозитории

## Dockerfile (Airflow)

**Исправлено:**

* pip запускается под `airflow`, а не под root
* dbt-пакеты устанавливаются корректно
* устраняются ошибки Airflow при старте

---

## docker-compose-airflow.yaml

**Исправлено:**

* добавлена переменная `AIRFLOW_UID=50000`
* корректная сборка кастомного Airflow-образа
* вынесены все пароли в `.env`

---

## docker-compose-trino.yaml

**Исправлено:**

* корректные пути к конфигам
* поддержка `.env`
* единая структура volumes

---

## docker-compose-lake.yaml

**Исправлено:**

* убран hardcoded пароль MinIO
* добавлена поддержка `.env`
* обновлён entrypoint MinIO

---

# Развёртывание 

### **1. Установить зависимости**

```
sudo /opt/scripts/01-install-deps.sh
```

Перелогиниться.

### **2. Клонировать lakehouse**

```
/opt/scripts/02-clone-lakehouse.sh
```

### **3. Сгенерировать .env**

```
/opt/scripts/03-generate-env.sh
```

### **4. Запустить стек**

```
/opt/scripts/04-start-lakehouse.sh
```

### **5. Проверить статус**

```
/opt/scripts/06-status-lakehouse.sh
```

---

# Полный Reset среды

Если нужно пересоздать всё:

```
/opt/scripts/05-stop-lakehouse.sh
/opt/scripts/03-regenerate-env.sh
/opt/scripts/04-start-lakehouse.sh
```
