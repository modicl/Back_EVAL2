# Usa una imagen oficial de Node.js como base, versión alpine para que sea más ligera
FROM node:18-alpine

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia primero los archivos de dependencias para aprovechar el caché de capas de Docker
COPY package*.json ./

# Instala las dependencias (solo las de producción)
RUN npm install --production

# Copia el resto del código de la aplicación al contenedor
COPY . .

# Expone el puerto 3000 en el que escucha el backend Node.js
EXPOSE 3000

# Comando para ejecutar la aplicación cuando inicie el contenedor
CMD ["npm", "start"]
