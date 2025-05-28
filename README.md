# 🍽️ SmartChef - Recomendador Inteligente de Receitas

O **SmartChef** é um aplicativo mobile desenvolvido em Flutter que recomenda receitas com base nos ingredientes disponíveis, preferências alimentares, alergias e nível de experiência culinária. A recomendação é feita por uma IA integrada via API (Node.js), com dados armazenados em um banco de dados MySQL.

---

## 📁 Estrutura do Projeto

```
smartchef/
├── frontend/         # App Flutter
├── api/              # Backend Node.js (Express)
├── database/         # Dump do banco de dados MySQL
│   └── receitas_db.sql
├── README.md
└── .gitignore
```

---

## 🚀 Como rodar o projeto

### 📱 1. Rodar o App Flutter

> Pré-requisitos: Flutter SDK instalado

```bash
cd frontend
flutter pub get
flutter run
```

📝 **Dica**: emuladores Android usam `http://10.0.2.2` para acessar `localhost`. Atualize as chamadas de API no app, se necessário.

---

### 🔌 2. Rodar a API Node.js

> Pré-requisitos: Node.js e npm instalados

```bash
cd api
npm install
npm start
```

A API estará disponível em `http://localhost:3000`

---

### 🗄️ 3. Configurar o Banco de Dados

> Pré-requisitos: MySQL instalado e em execução

1. Crie o banco:

```sql
CREATE DATABASE receitas_db;
```

2. Importe o dump:

```bash
mysql -u root -p receitas_db < database/receitas_db.sql
```

3. Configure o acesso ao banco no backend (ex: `.env`):

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=receitas_db
```

---

## 🧪 Tecnologias Utilizadas

- **Flutter** (Dart) – App mobile
- **Node.js + Express** – API backend
- **MySQL** – Banco de dados relacional
- **SharedPreferences** – Armazenamento local
- **Twilio API** – Envio de token SMS (para recuperação de senha)

---

## 👨‍💻 Autor

- Germano Antônio Zani Jorge ([GitHub](https://github.com/germano-unifeob))

---

## 📄 Licença

Este projeto está licenciado sob a **MIT License**. Veja o arquivo `LICENSE` para mais detalhes.
