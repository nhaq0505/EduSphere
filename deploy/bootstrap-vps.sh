#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ $EUID -ne 0 ]]; then
    echo 'Run as root: sudo bash deploy/bootstrap-vps.sh' >&2
    exit 1
fi
if [[ ${ACCEPT_SQL_SERVER_EULA:-} != Y ]]; then
    echo 'Review the Microsoft SQL Server license, then set ACCEPT_SQL_SERVER_EULA=Y.' >&2
    exit 1
fi
here=$(cd -- "$(dirname -- "$0")" && pwd)

apt-get update
apt-get install -y openjdk-17-jre-headless docker.io curl unzip
systemctl enable --now docker

id edusphere >/dev/null 2>&1 || useradd --system --user-group --shell /usr/sbin/nologin edusphere
id edusphere-deploy >/dev/null 2>&1 || useradd --create-home --shell /bin/bash edusphere-deploy
install -d -m 0755 /srv/edusphere
install -d -m 2750 -o edusphere-deploy -g edusphere /srv/edusphere/releases
chmod g+s /srv/edusphere/releases
install -d -m 0700 /etc/edusphere
install -d -m 0700 -o edusphere-deploy -g edusphere-deploy /home/edusphere-deploy/.ssh

if [[ ! -f /etc/edusphere/sql.env ]]; then
    sql_password="Aa9_$(openssl rand -hex 24)"
    printf 'ACCEPT_EULA=Y\nMSSQL_PID=Express\nMSSQL_SA_PASSWORD=%s\n' "$sql_password" > /etc/edusphere/sql.env
fi
if [[ ! -f /etc/edusphere/edusphere.env ]]; then
    app_password="Aa9_$(openssl rand -hex 24)"
    admin_password="Aa9_$(openssl rand -hex 24)"
    cat > /etc/edusphere/edusphere.env <<SETTINGS
SPRING_DATASOURCE_URL="jdbc:sqlserver://127.0.0.1:1435;databaseName=EduSphere;encrypt=true;trustServerCertificate=true"
SPRING_DATASOURCE_USERNAME=edusphere_app
SPRING_DATASOURCE_PASSWORD=$app_password
APP_BOOTSTRAP_ADMINPASSWORD=$admin_password
APP_BASEURL=http://localhost:8080/EduSphere
SETTINGS
fi
for setting in \
    'APP_BASEURL=http://localhost:8080/EduSphere' \
    'PAYOS_CLIENT_ID=' \
    'PAYOS_API_KEY=' \
    'PAYOS_CHECKSUM_KEY='; do
    key=${setting%%=*}
    if ! grep -q "^$key=" /etc/edusphere/edusphere.env; then
        printf '%s\n' "$setting" >> /etc/edusphere/edusphere.env
    fi
done
chmod 0600 /etc/edusphere/edusphere.env

if ! docker container inspect edusphere-sqlserver >/dev/null 2>&1; then
    docker run --detach --name edusphere-sqlserver --restart unless-stopped \
        --env-file /etc/edusphere/sql.env --publish 127.0.0.1:1435:1433 \
        --volume edusphere_sqlserver_data:/var/opt/mssql \
        mcr.microsoft.com/mssql/server:2022-latest
else
    docker start edusphere-sqlserver >/dev/null
fi
sql() {
    docker exec -i edusphere-sqlserver sh -c \
        'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" exec /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b' "$@"
}
for attempt in {1..45}; do
    if sql <<< 'SELECT 1' >/dev/null 2>&1; then
        break
    fi
    if [[ $attempt -eq 45 ]]; then
        echo 'SQL Server did not become ready.' >&2
        exit 1
    fi
    sleep 2
done
app_password=$(sed -n 's/^SPRING_DATASOURCE_PASSWORD=//p' /etc/edusphere/edusphere.env)
[[ "$app_password" =~ ^[[:alnum:]_]+$ ]]
sql <<SQL
IF DB_ID(N'EduSphere') IS NULL CREATE DATABASE EduSphere;
GO
IF SUSER_ID(N'edusphere_app') IS NULL CREATE LOGIN edusphere_app WITH PASSWORD = '$app_password';
GO
USE EduSphere;
GO
IF USER_ID(N'edusphere_app') IS NULL
BEGIN
    CREATE USER edusphere_app FOR LOGIN edusphere_app;
    ALTER ROLE db_owner ADD MEMBER edusphere_app;
END;
GO
SQL

install -m 0755 "$here/receive-war.sh" /usr/local/bin/edusphere-receive-war
install -m 0644 "$here/edusphere.service" /etc/systemd/system/edusphere.service
sudoers=$(mktemp)
trap 'rm -f "$sudoers"' EXIT
printf '%s\n' 'edusphere-deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart edusphere.service' > "$sudoers"
visudo -cf "$sudoers" >/dev/null
install -m 0440 "$sudoers" /etc/sudoers.d/edusphere-deploy
systemctl daemon-reload
systemctl enable edusphere.service
