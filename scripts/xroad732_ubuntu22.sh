#!/bin/bash

#REPO_URL="https://github.com/UT-CDC/XRoad_7.3.2_Ubuntu_22/releases/download/mirror-main-41eca2a/ubuntu22.04.zip"

REPO_URL="https://github.com/XRoad-Colombia/XROAD-CO/releases/download/7.3.2/ubuntu22.04.zip"
DEST_FILE="/home/ubuntu/ubuntu22.04.zip"

echo -e "\n"
echo "====================================================="
echo "=     Instalación X-ROAD 7.3.2 - Security Server    ="
echo "====================================================="
sleep 2; echo -e "\n"

if [ `id -u` != 0 ]
then
   echo ""
   echo "Debe ser root para ejecutar el script"
   echo ""
   exit 1
fi

echo "==============================================="
echo "=     Validando criterios de conectividad     ="
echo "==============================================="
sleep 2; echo -e "\n"

tel=$(dpkg -l | grep -i telnet | awk '{print $2}')
if [ "$tel" = "telnet" ]; then
  :
else
  echo "-----Paquete Telnet no instalado-----"
  sleep 2; echo -e "\n"
  apt -y update; apt -y install telnet
  echo -e "\n"
fi

if ! dpkg -s git &>/dev/null; then
  echo "===== Paquete git no instalado ====="
  sudo apt-get update -y
  sudo apt-get install -y git
  echo -e "\n"
fi


tln1=$(timeout 2 telnet xroadcentral.and.gov.co 4001 | awk 'NR == 2 {print $1}')
if [ "$tln1" = "Connected" ]; then
  echo "✅ telnet xroadcentral.and.gov.co 4001 OK"
else
  echo "❌ telnet xroadcentral.and.gov.co 4001 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln2=$(timeout 2 telnet xroadcentral.and.gov.co 80 | awk 'NR == 2 {print $1}')
if [ "$tln2" = "Connected" ]; then
  echo "✅ telnet xroadcentral.and.gov.co 80 OK"
else
  echo "❌ telnet xroadcentral.and.gov.co 80 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln3=$(timeout 2 telnet xroadsecadmin.and.gov.co 5500 | awk 'NR == 2 {print $1}')
if [ "$tln3" = "Connected" ]; then
  echo "✅ telnet xroadsecadmin.and.gov.co 5500 OK"
else
  echo "❌ telnet xroadsecadmin.and.gov.co 5500 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln4=$(timeout 2 telnet xroadsecadmin.and.gov.co 5577 | awk 'NR == 2 {print $1}')
if [ "$tln4" = "Connected" ]; then
  echo "✅ telnet xroadsecadmin.and.gov.co 5577 OK"
else
  echo "❌ telnet xroadsecadmin.and.gov.co 5577 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln5=$(timeout 2 telnet xroadsecserv.and.gov.co 5500 | awk 'NR == 2 {print $1}')
if [ "$tln5" = "Connected" ]; then
  echo "✅ telnet xroadsecserv.and.gov.co 5500  OK"
else
  echo "❌ telnt xroadsecserv.and.gov.co 5500 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln6=$(timeout 2 telnet xroadsecserv.and.gov.co 5577 | awk 'NR == 2 {print $1}')
if [ "$tln6" = "Connected" ]; then
  echo "✅ telnet xroadsecserv.and.gov.co 5577 OK"
else
  echo "❌ telnet xroadsecserv.and.gov.co 5577 ---->  Bloqueado"
fi
echo "--------------------------------------------"

tln7=$(timeout 2 telnet xsr1ru3qkc.execute-api.us-east-1.amazonaws.com 443 | awk 'NR == 2 {print $1}')
if [ "$tln7" = "Connected" ]; then
  echo "✅ Conexión TSA Certicamara OK"
else
  echo "❌ Conexión TSA Certicamara ---->  Bloqueado"
fi
echo "--------------------------------------------"

#tln8=$(timeout 2 telnet ocsp4096.certicamara.co 80 | awk 'NR == 2 {print $1}')
#if [ "$tln8" = "Connected" ]; then
#  echo "✅ Conexión OCSP Certicamara OK"
#else
#  echo "❌ Conexión OCSP Certicamara ---->  Bloqueado"
#fi
#echo "--------------------------------------------"

#if git ls-remote "$REPO_URL" &>/dev/null; then
# github=200
# echo "✅ Conexión repositorio X-Road OK"
#else
#   github=0
# echo "❌ No se tiene acceso al repositorio de X-Road"
# echo -e "\n"
# exit 1
#fi
#echo "--------------------------------------------"

github=$(wget --inet4-only --spider -S --timeout=5 "$REPO_URL" 2>&1 |grep "HTTP/" | awk '{print $2}' | grep 200)
if [ "$github" == "200" ]; then
  echo "✅ Conexión repositorio X-Road OK"
else
  echo "No se tiene acceso al repositorio de X-Road"
fi
echo "--------------------------------------------"



sleep 2; echo -e "\n"

value=("$tln1" "$tln2" "$tln3" "$tln4" "$tln5" "$tln6" "$tln7")
for i in "${value[@]}"; do
    if [ "$i" != "Connected" ]; then
        echo "No se cumplen los criterios de conectividad" ; echo -e "\n"
        exit 1
    fi
done

echo "============================================================"
echo "=     Estableciendo configuración regional del Sistema     ="
echo "============================================================"
sleep 2; echo -e "\n"
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
locale-gen en_US.UTF-8
timedatectl set-timezone America/Bogota
echo "186.155.28.147 horalegal.inm.gov.co" >> /etc/hosts
timedatectl
sleep 2; echo -e "\n"

echo "======================================================="
echo "=     Instalación y configuración del paquete NTP     ="
echo "======================================================="
sleep 2; echo -e "\n"
apt -y update; apt -y install ntp
sleep 2; echo -e "\n"
#### modificación archivo ntp.conf ####
sed -i '21,24s/^/# /' /etc/ntp.conf
sed -i '25s/^/server horalegal.inm.gov.co prefer iburst /' /etc/ntp.conf
systemctl restart ntp
sleep 2; echo -e "\n"
ntpq -p
sleep 2; echo -e "\n"

echo "=============================="
echo "=     Cambio de Hostname     ="
echo "=============================="
sleep 2; echo -e "\n"
hostnamectl set-hostname xroadsec
hostnamectl | grep -i hostname
sleep 2; echo -e "\n"

echo "===================================="
echo "=     Instalando paquete unzip     ="
echo "===================================="
apt install zip -y
sleep 2; echo -e "\n"

echo "======================================="
echo "=     Descargando paquetes X-ROAD     ="
echo "======================================="
sleep 2; echo -e "\n"
cd /home/ubuntu

echo "=== Descarga repositorio wget==="
wget -P /home/ubuntu/ "$REPO_URL" 
echo "✅ Descarga completada...."
sleep 2; echo -e "\n"


echo "📂 Descomprimiendo ubuntu22.04.zip..."
unzip /home/ubuntu/ubuntu22.04.zip -d /home/ubuntu/ 

# Comprobamos que el directorio existe después de descomprimir
if [ ! -d "/home/ubuntu/ubuntu22.04" ]; then
  echo "❌ Error: El directorio /home/ubuntu/ubuntu22.04 no existe."
  exit 1
fi


sleep 2; echo -e "\n"

echo "🔒 Ajustando permisos..."
chmod a+rx /home /home/ubuntu /home/ubuntu/ubuntu22.04
chmod -R a+rX /home/ubuntu/ubuntu22.04


echo "=========================================="
echo "=     Configurando repositorio local     ="
echo "=========================================="
sleep 2; echo -e "\n"
echo "deb [trusted=yes] file:///home/ubuntu/ubuntu22.04 ./" | tee -a /etc/apt/sources.list
echo "#### Se ha modificado sources.list ####"
tail -n 1 /etc/apt/sources.list
sleep 2; echo -e "\n"



echo "==============================="
echo "=     Instalando dpkg-dev     ="
echo "==============================="
sleep 2; echo -e "\n"
cd /home/ubuntu/ubuntu22.04
apt -y install dpkg-dev
dpkg-scanpackages . >Packages
sleep 2; echo -e "\n"

echo "================================="
echo "=     Actualizando paquetes     ="
echo "================================="
sleep 2; echo -e "\n"
apt-get update; apt --assume-yes install acl curl apt-transport-https locales aptitude software-properties-common
sleep 2; echo -e "\n"

echo "==============================="
echo "=     Creación de usuario     ="
echo "==============================="
sleep 2; echo -e "\n"
read -p "Defina usuario: " user
adduser --gecos "" --shell=/usr/sbin/nologin --no-create-home $user
sleep 2; echo -e "\n"
echo "---Se ha creado el usuario: "$user"---"
sleep 2; echo -e "\n"

echo "==========================================="
echo "=     Instalando paquetes adicionales     ="
echo "==========================================="
sleep 2; echo -e "\n"
apt install -y locales software-properties-common
locale-gen en_US.UTF-8
sleep 2; echo -e "\n"

echo "======================================"
echo "=     Instalando Security Server     ="
echo "======================================"
sleep 2; echo -e "\n"
apt -y install xroad-securityserver
apt -y install xroad-addon-opmonitoring
echo -e "\n
[message-log]
max-loggable-body-size=20971520" >> /etc/xroad/conf.d/local.ini
sleep 2; echo -e "\n"

echo "==============================================="
echo "=     Instalando paquete X-ROAD Autologin     ="
echo "==============================================="
sleep 2; echo -e "\n"
apt install -y xroad-autologin
sleep 2; echo -e "\n"

echo "======================================"
echo "=     Configurando PIN Autologin     ="
echo "======================================"
sleep 2; echo -e "\n"
read -sp "Inserte PIN: " code
echo $code > /etc/xroad/autologin
chown xroad:xroad /etc/xroad/autologin
usermod -s /sbin/nologin xroad
sleep 2; echo -e "\n"

echo "======================================"
echo "=     Validando servicios X-Road     ="
echo "======================================"
sleep 2; echo -e "\n"
systemctl list-units "xroad*"
sleep 2; echo -e "\n"

echo "==============================="
echo "=     Verificando puertos     ="
echo "==============================="
sleep 15; echo -e "\n"
ss -tnpl | grep -E '4000|80|443|5500|5577'
sleep 2; echo -e "\n"

#Obteniendo direccion IP del servidor
IP=$(hostname -I | awk '{print $1}')

echo "*****Instalación de Security Server finalizado*****"
echo -e "\n" ; sleep 2

echo "============================================================"
echo "=     Ingresar a -> https://$IP:4000/#/login      ="
echo "============================================================"
echo -e "\n" ; sleep 5
