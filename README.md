# 📊 Theme Statistic & Chat Analyzer
SQL Workflow Documentation

Этот проект содержит SQL-скрипты, которые формируют две аналитические таблицы:

- **theme_statistic** — детальная аналитика консультаций  
- **first_chat_analiser** — определение момента начала чат-тредов  

---

## 🚀 1. Таблица `theme_statistic`

Таблица создаётся на основе данных из:

- `prod_v_dds.consultation`
- `prod_v_dds.communication`
- `prod_v_dds.communication_x_chat_thread`
- `prod_v_dds.chat_thread`

### Что делает SQL:

### 1) Удаляет старую версию таблицы
```sql
drop table if exists theme_statistic;
```

### 2) Извлекает консультации за период  
Фильтр по теме: `Auto.Travel.Partners`  
Период: `2024-10-01` → `2024-11-01`

### 3) Разбирает строковое поле `consultation_desc`

Из строки вида:
```
"type":"Hotel","brand":"Ibis","provider":"Expedia","order":"12345","process":"payment","topic":"refund",...
```

SQL извлекает:

- type  
- brand  
- provider  
- order  
- process  
- topic  
- subTopic  
- subTopic2  

Через:
- `split_part()`
- `substring()`
- `trim()`

### 4) Присоединяет данные коммуникаций

Через `communication_rk` добавляются:

- communication_id  
- communication_method_cd  
- communication_direction_cd  
- chat_thread_id  

### 5) Создаёт таблицу
```sql
create table theme_statistic as
select ...
```

---

## 💬 2. Таблица `first_chat_analiser`

Таблица хранит время первого сообщения в каждом чат-треде.

### Логика:

### 1) Удаляет старую версию
```sql
drop table if exists first_chat_analiser;
```

### 2) Находит минимальное сообщение по треду
```sql
create table first_chat_analiser as
select chat_thread_rk, min(create_dttm)
from prod_v_dds.chat_message
where create_dttm::date between '2024-10-01' and '2024-11-01'
group by chat_thread_rk;
```

---

## 📄 Пример результата `theme_statistic`

| create_dttm | consultation_rk | type | brand | provider | ord | process | topic | subTopic | subTopic2 | communication_id | method | direction | chat_thread_id |
|-------------|-----------------|------|--------|----------|------|----------|---------|-----------|------------|------------------|--------|-----------|-----------------|
| 2024-10-05 | 1002345 | Hotel | Ibis | Expedia | 12345 | payment | refund | delay | card | COMM_001 | chat | outbound | THR_0001 |
| 2024-10-05 | 1002388 | Flight | Aeromexico | Amadeus | 99117 | change | price | fee | policy | COMM_002 | phone | inbound | THR_0002 |

---

## 📄 Пример результата `first_chat_analiser`

| chat_thread_rk | first_message_dttm |
|----------------|--------------------|
| 56701 | 2024-10-05 10:14:55 |
| 56702 | 2024-10-05 11:03:12 |

---

## 🗂 Итог

После выполнения SQL создаются две таблицы:

### **theme_statistic**
- детальная аналитика консультаций  
- параметры из `consultation_desc`  
- данные коммуникаций и чат-тредов  

### **first_chat_analiser**
- время начала каждого чата  
- используется для SLA, waiting time, duration  

