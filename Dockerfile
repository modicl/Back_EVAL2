# Etapa 1: Instalar dependencias de producción
FROM node:18-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm install --production

# Etapa 2: Imagen final de producción
FROM node:18-alpine AS production

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
