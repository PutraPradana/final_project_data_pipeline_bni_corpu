# Final Project Data Pipeline — BNI Corpu

Repo ini berisi final project **ETL Pipeline dengan Apache Airflow v3 + PostgreSQL** menggunakan Docker Compose.

---

## Struktur Repo

```
.
├── dags/                          # Airflow DAG files
│   ├── dag_etl_accounts.py
│   ├── dag_etl_branches.py
│   ├── dag_etl_channels.py
│   ├── dag_etl_customers.py
│   ├── dag_etl_dim_date.py
│   ├── dag_etl_fraud_labels.py
│   └── dag_etl_transactions.py
├── image/                          # screenshot hasil eksekusi query
│   ├── 01.Transaction_Analytics_-_Daily_Transaction_Trend.png
│   ├── 01.Transaction_Analytics_-_Monthly_Transaction_Trend.png
│   ├── 01.Transaction_Analytics_-_Weekly_Transaction_Trend.png
│   ├── 02.Customer_360_-_Most_Active_Customers.png
│   ├── 02.Customer_360_-_Customer_Distribution_by_Segment.png
│   ├── 03.Branch_Performance.png
│   ├── 04.Channel_Analysis_-_Channel_Usage.png
│   ├── 04.Channel_Analysis_-_Channel_Usage_Trend.png
│   ├── 05.Product_Performance.png
│   ├── 06.Risk&Fraud_Detection_-_Fraud_Detection.png
│   └── 06.Risk&Fraud_Detection_-_Failed_Transactions.png
├── include/
│   ├── dataset/                   # Source CSV files (generate dulu, lihat langkah 4)
│   ├── script/                    # Python ETL scripts
│   │   ├── generate_banking_dataset.py
│   │   └── etl_bank_transactions.py
│   └── sql/                       # SQL transform files
│       ├── accounts/
│       ├── branches/
│       ├── channels/
│       ├── customers/
│       ├── dim_date/
│       └── transactions/
├── sql/                          # Query untuk menjawab pertanyaan bisnis
│   ├── 01.transaction_analytics.SQL
│   ├── 02.customer_360.SQL
│   ├── 03.branch_performance.SQL
│   ├── 04.channel_analysis.SQL
│   ├── 05.product_performance.SQL
│   └── 06.risk&fraud_detection.SQL
├── docker-compose.yaml
├── .env.example                   # Template environment variables
└── requirements.txt
```

---
## Pertanyaan Bisnis

### 01. Transaction Analytics
```bash
Berapa total volume dan nilai transaksi per hari, minggu, dan bulan?
Apa tren pertumbuhannya?
```
#### SQL QUERY
- [Transactions Analytics Query](sql/01.transaction_analytics.SQL)
#### Screenshot
- ![Transaction Analytics - Daily Transaction Trend](image/01.Transaction_Analytics_-_Daily_Transaction_Trend.png)
- ![Transaction Analytics - Monthly Transaction Trend](image/01.Transaction_Analytics_-_Monthly_Transaction_Trend.png)
- ![Transaction Analytics - Weekly Transaction Trend](image/01.Transaction_Analytics_-_Weekly_Transaction_Trend.png)

---

### 02. Customer 360
```bash
Siapa nasabah paling aktif berdasarkan frekuensi dan nilai transaksi?
Bagaimana distribusi per segmen (Retail/Priority/VIP)?
```
#### SQL QUERY
- [Customer 360 Query](sql/02.customer_360.SQL)
#### Screenshot
- ![Customer 360 - Most Active Customers](image/02.Customer_360_-_Most_Active_Customers.png)
- ![Customer 360 - Customer Distribution by Segment](image/02.Customer_360_-_Customer_Distribution_by_Segment.png)

---

### 03. Branch Performance
```bash
Cabang mana yang memiliki performa tertinggi berdasarkan jumlah transaksi dan total nilai transaksi per region?
```
#### SQL QUERY
- [Branch Performance Query](sql/03.branch_performance.SQL)
#### Screenshot
- ![Branch Performance](image/03.Branch_Performance.png)

---

### 04. Channel Analysis
```bash
Channel apa yang paling banyak digunakan nasabah (ATM, Mobile, Teller, Internet Banking) ?
Bagaimana tren migrasi ke digital?
```
#### SQL QUERY
- [Channel Analysis Query](sql/04.channel_analysis.SQL)
#### Screenshot
- ![Channel Analysis - Channel Usage](image/04.Channel_Analysis_-_Channel_Usage.png)
- ![Channel Analysis - Channel Usage Trend](image/04.Channel_Analysis_-_Channel_Usage_Trend.png)


---

### 05. Product Performance
```bash
Produk rekening mana (Tabungan/Giro/Deposito) yang menghasilkan volume transaksi dan saldo rata-rata tertinggi?
```
#### SQL QUERY
- [Product Performance Query](sql/05.product_performance.SQL)
#### Screenshot
- ![Product Performance](image/05.Product_Performance.png)

---

### 06. Risk & Fraud Detection
```bash
Adakah transaksi anomali (nilai sangat besar, frekuensi tidak wajar, atau status FAILED berulang) yang perlu diwaspadai?
```
#### SQL QUERY
- [Risk & Fraud Detection Query](sql/06.risk&fraud_detection.SQL)
#### Screenshot
- ![Risk & Fraud Detection - Fraud Detection](image/06.Risk&Fraud_Detection_-_Fraud_Detection.png)
- ![Risk & Fraud Detection - Failed Transactions](image/06.Risk&Fraud_Detection_-_Failed_Transactions.png)

---