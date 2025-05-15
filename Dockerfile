FROM node:18-bullseye

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем зависимости
COPY package.json package-lock.json* ./

# Устанавливаем зависимости (с legacy peer deps, если нужно)
RUN npm install --legacy-peer-deps

# Копируем исходники (включая scripts/scan.js)
COPY . .

# Указываем порт, который будет слушать контейнер
EXPOSE 4000

# Убедимся, что тип модулей указан как ESM (если не было)
RUN node -e "let p=require('./package.json'); p.type='module'; require('fs').writeFileSync('./package.json', JSON.stringify(p, null, 2))"

# Запуск scan.js напрямую
CMD ["node", "scripts/scan.js"]
