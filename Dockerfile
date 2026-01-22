# --- ÉTAPE 1 : Compilation du Frontend ---
FROM node:20-slim AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- ÉTAPE 2 : Image Finale Django ---
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

# Dépendances système pour Postgres
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code Django
COPY . .

# RÉCUPÉRATION DU FRONTEND
COPY --from=frontend-builder /app/frontend/dist /code/static/dist

# Commande de lancement
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]