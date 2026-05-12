# Backend - API REST con Node.js y Express

## Descripción

Backend API desarrollado en JavaScript con Node.js y Express framework. Proporciona endpoints RESTful para la gestión de usuarios con conexión a base de datos MySQL.

## Versiones y Herramientas Requeridas

### Lenguajes y Runtime

- **Node.js**: Versión 18.0.0 o superior!
- **npm**: Versión 8.0.0 o superior (incluido con Node.js)

### Dependencias Principales

- **express**: ^4.18.2 - Framework web para Node.js
- **cors**: ^2.8.5 - Middleware para habilitar CORS
- **mysql2**: ^3.6.0 - Driver de MySQL para Node.js
- **dotenv**: ^16.3.1 - Manejo de variables de entorno

### Dependencias de Desarrollo

- **nodemon**: ^3.0.1 - Para desarrollo con recarga automática

## Instalación

```bash
# Instalar dependencias
npm install

# Instalar dependencias de desarrollo
npm install --save-dev nodemon
```

## Configuración

1. Copiar el archivo de variables de entorno:

```bash
cp .env.example .env
```

2. Editar el archivo `.env` con las credenciales de tu base de datos MySQL:

```
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_contraseña
DB_NAME=proyecto_db
DB_PORT=3306
```

## Ejecución

```bash
# Para producción
npm start

# Para desarrollo (con recarga automática)
npm run dev
```

## Endpoints de la API

### Usuarios

- `GET /api/usuarios` - Obtener todos los usuarios
- `POST /api/usuarios` - Crear un nuevo usuario
- `PUT /api/usuarios/:id` - Actualizar un usuario existente
- `DELETE /api/usuarios/:id` - Eliminar un usuario

### Ejemplo de uso

```bash
# Obtener todos los usuarios
curl http://localhost:3000/api/usuarios

# Crear un nuevo usuario
curl -X POST http://localhost:3000/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Juan Pérez","email":"juan@example.com","edad":25}'
```

## Puertos Requeridos

### Para funcionamiento en contenedor:

- **Puerto 3000**: Puerto del servidor backend (HTTP)
- **Puerto 3306**: Puerto de conexión a base de datos MySQL (externo)

### Explicación de puertos:

- **3000**: Es el puerto donde escucha el servidor Express para recibir peticiones HTTP
- **3306**: Es el puerto estándar para comunicación con el servidor MySQL

## Estructura del Proyecto

```
backend/
├── server.js          # Archivo principal del servidor
├── package.json       # Configuración de dependencias
├── .env.example       # Ejemplo de variables de entorno
├── .env              # Variables de entorno (crear manualmente)
└── README.md         # Este archivo
```

## Notas Importantes

- Asegúrate de tener MySQL instalado y corriendo antes de iniciar el backend
- La base de datos `proyecto_db` debe existir (ver proyecto `database/`)
- El servidor se reiniciará automáticamente en modo desarrollo si usas `npm run dev`

---

## CI/CD con GitHub Actions

El pipeline se define en `.github/workflows/ci-cd.yml` y se ejecuta automáticamente al hacer push a la rama `deploy`.

### Flujo del pipeline

```
push a deploy
        │
        ▼
┌───────────────────┐
│  build-and-push   │  Construye la imagen Docker y la publica en Docker Hub
│                   │  Tags: :latest  y  :<git-sha>
└────────┬──────────┘
         │ (solo si rama = deploy)
         ▼
┌──────────────────────────────────────┐
│  deploy (vía Bastion Host)           │
│                                      │
│  GitHub Actions                      │
│      → SSH → EC2 pública (bastion)   │
│          → SSH → EC2 privada backend │
│              pull → reemplaza        │
│              contenedor → prune      │
└──────────────────────────────────────┘
```

> El backend vive en una EC2 privada sin acceso directo desde Internet.
> El pipeline entra primero a la EC2 pública del frontend (Bastion Host) y desde ahí salta a la EC2 privada del backend.

### Secrets requeridos en GitHub

Configura los siguientes secrets en **Settings → Secrets and variables → Actions** del repositorio:

| Secret | Descripción |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | Access Token de Docker Hub (no tu contraseña) |
| `BASTION_HOST` | IP pública de la EC2 del frontend (Bastion Host) |
| `BASTION_USER` | Usuario SSH del bastion (ej. `ubuntu`) |
| `BASTION_SSH_KEY` | Clave privada SSH del bastion (contenido del `.pem`) |
| `EC2_HOST` | IP privada de la EC2 del backend |
| `EC2_USER` | Usuario SSH de la EC2 backend (ej. `ubuntu`) |
| `EC2_SSH_KEY` | Clave privada SSH del backend (contenido del `.pem`) |

### Archivo de entorno en la EC2 del backend

El contenedor lee sus variables desde `/home/<EC2_USER>/.env.backend`.  
Crea ese archivo en la instancia antes del primer despliegue:

```bash
# En la EC2 privada del backend
cat > ~/.env.backend <<EOF
PORT=3000
DB_HOST=<IP-PRIVADA-RDS-O-MYSQL>
DB_USER=root
DB_PASSWORD=<contraseña-segura>
DB_NAME=proyecto_db
DB_PORT=3306
EOF
```

### Imagen publicada

```
docker.io/<DOCKERHUB_USERNAME>/backend-eval2:latest
docker.io/<DOCKERHUB_USERNAME>/backend-eval2:<git-sha>
```

### Ejecución manual

El workflow puede dispararse manualmente desde **Actions → CI/CD Backend Node.js → Run workflow**.
