# Sistema de Gestión de Flota - Configuración Docker

Este proyecto proporciona una configuración completa de Docker para ejecutar el Sistema de Gestión de Flota basado en Frappe/ERPNext v15.

## Requisitos del Sistema

- **Servidor**: VPS con Ubuntu 24.04 (tu servidor actual)
- **Recursos**: 8 núcleos, 32GB RAM, 400GB SSD
- **Docker**: Docker y Docker Compose instalados
- **Puertos**: 80 o 8083 (HTTP), 8080 (phpMyAdmin opcional)

## Arquitectura de Servicios

```
┌─────────────────────────────────────────────────────────┐
│                   Frappe Fleet Management                │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │ Frappe Web  │  │ Frappe      │  │ SocketIO    │   │
│  │ (Nginx)     │  │ Backend     │  │ Server      │   │
│  │   :80       │  │   :8000     │  │   :9000     │   │
│  └─────────────┘  └─────────────┘  └─────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │ Redis       │  │ Redis       │  │ Redis       │   │
│  │ Cache       │  │ Queue       │  │ SocketIO    │   │
│  └─────────────┘  └─────────────┘  └─────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────────────────────┐ │
│  │ MariaDB     │  │ Workers (Scheduler, Queue)     │ │
│  │   :3306     │  │                                 │ │
│  └─────────────┘  └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Archivos del Proyecto

- **docker-compose.yml**: Configuración principal de contenedores
- **.env**: Variables de entorno (contraseñas, configuración)
- **Makefile**: Comandos simplificados para gestión
- **install-fleet-app.sh**: Script de instalación de la app de flota

## Configuración Inicial

### 1. Configurar Variables de Entorno

Edita el archivo `.env` con tus valores seguros:

```bash
# Contraseñas importantes (CAMBIA ESTAS EN PRODUCCIÓN)
MARIADB_ROOT_PASSWORD=TuContraseñaRoot2024!
MARIADB_PASSWORD=TuContraseñaUsuario2024!

# Configuración del sitio
FRAPPE_SITE=erp.tudominio.com
ADMIN_PASSWORD=TuContraseñaAdmin2024!

# Tu IP del servidor
SERVER_IP=187.77.2.74
```

### 2. Iniciar los Contenedores

```bash
# Iniciar todos los servicios
docker compose up -d

# O usando Make
make up

# Ver estado
docker compose ps
```

### 3. Acceder al Sistema

- **ERPNext**: http://187.77.2.74:8083
- **phpMyAdmin**: http://187.77.2.74:8080
- **Usuario**: Administrator
- **Contraseña**: La que configuraste en ADMIN_PASSWORD

### 4. Instalar la Aplicación de Flota

```bash
# Ejecutar el instalador
bash install-fleet-app.sh

# O usando Make
make install-fleet
```

## Comandos Útiles

### Gestión de Contenedores

```bash
# Iniciar servicios
make up

# Detener servicios
make down

# Reiniciar servicios
make restart

# Ver logs en tiempo real
make logs

# Estado de contenedores
make status
```

### Acceso a Contenedores

```bash
# Acceso al shell de Frappe
make shell

# Acceso a la base de datos
make shell-db
```

### Mantenimiento

```bash
# Reconstruir contenedores (tras cambios)
make rebuild

# Limpiar todo (CUIDADO: borra datos)
make clean
```

## Configuración Post-Instalación

Una vez instalado el Sistema de Gestión de Flota, necesitas configurar:

### 1. Configuración de Transporte

Ve a: **Configuración de Transporte > Configuración**
- Configura artículos de combustible
- Configura almacenes
- Configura dimensiones contables

### 2. Datos Maestros

- **Vehículos**: Registro de camiones y remolques
- **Conductores**: Perfiles con gestión de documentos
- **Rutas**: Rutas predefinidas con distancias
- **Gastos**: Plantillas de gastos por ruta

### 3. Integración con n8n

El sistema puede integrarse con tu n8n existente para automatizaciones:

- Webhooks para crear manifiestos
- Integración con sistemas de GPS
- Notificaciones automáticas

## Resolución de Problemas

### Los contenedores no inician

```bash
# Ver logs de errores
docker compose logs

# Verificar puertos
netstat -tlnp | grep -E ':(8083|3306|6379)'
```

### Error de conexión a base de datos

```bash
# Verificar que MariaDB esté corriendo
docker exec -it frappe_mariadb mysql -u root -p

# Verificar logs de MariaDB
docker compose logs mariadb
```

### Reinstalar la aplicación de flota

```bash
# Eliminar sitio existente y crear nuevo
docker exec -it frappe_backend bench drop-site fleetmanagement.local --force
bash install-fleet-app.sh
```

## Actualizaciones

Para actualizar Frappe/ERPNext:

```bash
# Detener servicios
make down

# Actualizar imagenes
docker compose pull

# Iniciar servicios
make up

# Actualizar base de datos
docker exec -it frappe_backend bench --site fleetmanagement.local migrate
```

## Respaldo y Restauración

### Respaldo de Base de Datos

```bash
docker exec frappe_mariadb mysqldump -u root -p erpnext > backup_$(date +%Y%m%d).sql
```

### Restaurar Base de Datos

```bash
docker exec -i frappe_mariadb mysql -u root -p erpnext < backup_20240315.sql
```

## Especificaciones Técnicas

| Componente | Versión | Propósito |
|------------|---------|-----------|
| Frappe | v16 | Framework backend |
| ERPNext | v16 | Sistema ERP base |
| MariaDB | 10.11 | Base de datos |
| Redis | 7-alpine | Cache y colas |
| Nginx | Incluido | Servidor web |

## Siguientes Pasos

1. ✅ Configurar Docker y docker-compose
2. ⏳ Iniciar contenedores
3. ⏳ Acceder a ERPNext
4. ⏳ Instalar Fleet Management
5. ⏳ Configurar datos maestros
6. ⏳ Probar flujos de trabajo

## Soporte

Para problemas con el Fleet Management System:
- Documentación: https://nelsonmpanju.github.io/Fleet-Management-System/
- Issues: https://github.com/navariltd/Fleet-Management-System/issues
