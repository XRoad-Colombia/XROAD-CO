# Instalador X-ROAD 7.3.2 Security Server - Ubuntu 22.04

Script automatizado para la instalación y configuración del Security Server de X-ROAD versión 7.3.2 en sistemas Ubuntu 22.04 LTS.

## 📋 Requisitos Previos

### Sistema Operativo
- Ubuntu 22.04 LTS
- Acceso root al sistema

### Conectividad de Red
El script valida automáticamente la conectividad a los siguientes servicios:

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| `xroadcentral.and.gov.co` | 4001 | Central Server |
| `xroadcentral.and.gov.co` | 80 | HTTP Central Server |
| `xroadsecadmin.and.gov.co` | 5500 | Security Server Admin |
| `xroadsecadmin.and.gov.co` | 5577 | Security Server Admin SSL |
| `xroadsecserv.and.gov.co` | 5500 | Security Server Service |
| `xroadsecserv.and.gov.co` | 5577 | Security Server Service SSL |
| `xsr1ru3qkc.execute-api.us-east-1.amazonaws.com` | 443 | TSA Certicámara |
| `ocsp4096.certicamara.co` | 80 | OCSP Certicámara |

### Repositorios Externos
- Repositorio Azure DevOps de X-ROAD Colombia
- Repositorios oficiales de Ubuntu 22.04

## 🚀 Instalación

### 1. Validación de Permisos
- Verifica que se ejecute con privilegios de root

### 2. Instalación de Dependencias
- **telnet**: Para verificación de conectividad
- **git**: Para clonación del repositorio
- **zip/unzip**: Para manejo de archivos comprimidos

### 3. Validación de Conectividad
- Prueba conexión a todos los servicios requeridos de X-ROAD
- Valida conectividad con servicios de **Certicámara** (TSA y OCSP)
- **El script se detiene si no se cumplen los criterios de conectividad**

### 4. Configuración Regional del Sistema
- Establece idioma: `en_US.UTF-8`
- Configura zona horaria: `America/Bogota`
- Añade servidor de tiempo: `horalegal.inm.gov.co`
- Genera locales necesarios

### 5. Configuración de Sincronización de Tiempo
- Instala y configura **NTP**
- Configura servidor de tiempo nacional: `horalegal.inm.gov.co`
- Verifica sincronización con `ntpq -p`

### 6. Configuración de Hostname
- Establece hostname del sistema como: `xroadsec`

### 7. Descarga e Instalación de X-ROAD
- Clona repositorio desde Azure DevOps
- Descarga archivo `ubuntu22.04.zip`
- Descomprime paquetes en `/home/ubuntu/ubuntu22.04`
- Ajusta permisos necesarios

### 8. Configuración de Repositorio Local
- Configura repositorio local en `/etc/apt/sources.list`
- Ejecuta `dpkg-scanpackages` para generar índices
- Actualiza cache de paquetes

### 9. Creación de Usuario Administrativo
```bash
# Durante la instalación se solicitará:
Defina usuario: [nombre_usuario]
```

### 10. Instalación de Componentes X-ROAD
- **xroad-securityserver**: Servidor principal
- **xroad-addon-opmonitoring**: Addon de monitoreo operacional
- **xroad-autologin**: Módulo de autenticación automática

### 11. Configuración de Autologin
- Configura PIN de acceso automático
```bash
# Durante la instalación se solicitará:
Inserte PIN: [pin_seguro]
```

### 12. Configuración Final
- Configura límites de logging: `max-loggable-body-size=20971520`
- Valida servicios X-ROAD activos
- Verifica puertos en uso

## 🔐 Configuración Post-Instalación

### Servicios Instalados
Los siguientes servicios se instalan y configuran automáticamente:
- `xroad-proxy.service`
- `xroad-confclient.service`
- `xroad-monitor.service`
- `xroad-proxy-ui-api.service`
- `xroad-signer.service`
- `xroad-opmonitor.service` (addon)

### Puertos Utilizados
| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 80 | HTTP | Proxy HTTP |
| 443 | HTTPS | Proxy HTTPS |
| 4000 | Admin UI | Interfaz de administración |
| 5500 | Management | Gestión del servidor |
| 5577 | Management SSL | Gestión SSL del servidor |

### Archivos de Configuración
- **Logs**: Configurado para máximo 20MB por mensaje
- **Autologin**: PIN almacenado en `/etc/xroad/autologin`
- **Local Config**: `/etc/xroad/conf.d/local.ini`

## 🌐 Acceso al Sistema

Una vez completada la instalación:

```
Acceder a: https://[IP_SERVIDOR]:4000/#/login
```

Donde `[IP_SERVIDOR]` es la dirección IP de tu servidor (se muestra al finalizar la instalación).

## 📁 Estructura de Archivos

```
/home/ubuntu/ubuntu22.04/        # Paquetes X-ROAD locales
/etc/xroad/                      # Configuración X-ROAD
├── autologin                    # PIN de autologin
└── conf.d/local.ini            # Configuración local
/etc/apt/sources.list           # Repositorio local añadido
/etc/ntp.conf                   # Configuración NTP
```

## ⚠️ Consideraciones Importantes

### Diferencias con Versión RHEL
- **NTP vs Chrony**: Ubuntu usa NTP para sincronización de tiempo
- **APT vs YUM**: Sistema de paquetes diferente
- **Repositorio local**: Se configura en `/home/ubuntu/` en lugar de `/opt/`
- **Servicios adicionales**: Incluye `xroad-addon-opmonitoring`

### Seguridad
- **Usuario xroad**: Se configura con shell `/sbin/nologin`
- **PIN Autologin**: Almacenado de forma segura con permisos `xroad:xroad`
- **Hostname**: Se establece como `xroadsec`

### Conectividad Externa
- **Certicámara**: Validación de TSA y OCSP para PKI
- **Hora Legal**: Sincronización con servidor oficial colombiano

## 🛠️ Solución de Problemas

### Error de Conectividad a Certicámara
Si fallan las conexiones TSA u OCSP:
```bash
# Verificar conectividad manual
telnet xsr1ru3qkc.execute-api.us-east-1.amazonaws.com 443
telnet ocsp4096.certicamara.co 80
```

### Problemas de NTP
Si la sincronización de tiempo falla:
```bash
# Verificar estado NTP
systemctl status ntp
ntpq -p
# Forzar sincronización
sudo service ntp restart
```

### Error de Repositorio Local
Si hay problemas con el repositorio local:
```bash
# Verificar estructura de archivos
ls -la /home/ubuntu/ubuntu22.04/
# Regenerar índices
cd /home/ubuntu/ubuntu22.04
dpkg-scanpackages . >Packages
apt-get update
```

### Servicios No Iniciados
```bash
# Revisar todos los servicios X-ROAD
systemctl list-units "xroad*"
# Ver logs específicos
journalctl -u xroad-proxy.service
```

## 🔍 Verificaciones Post-Instalación

### Validar Servicios
```bash
systemctl list-units "xroad*"
```

### Verificar Puertos Activos
```bash
ss -tnpl | grep -E '4000|80|443|5500|5577'
```

### Comprobar Configuración NTP
```bash
ntpq -p
timedatectl status
```

### Verificar Hostname
```bash
hostnamectl status
```


## 📝 Notas de Versión

- **Versión**: X-ROAD 7.2.2
- **SO Soportado**: Ubuntu 22.04 LTS
- **Addons incluidos**: Operational Monitoring

---

**⚠️ Importante**: Este documento está diseñado específicamente para la implementación de X-ROAD en Colombia y requiere acceso a infraestructura específica de AND (Agencia Nacional Digital).