#!/usr/bin/env bash
set -euo pipefail
umask 027

cd /srv/edusphere/releases
exec 9>.deploy.lock
flock -x 9
incoming=$(mktemp .incoming.XXXXXX)
trap 'rm -f "$incoming"' EXIT
# Bound disk usage if the SSH client accidentally streams the wrong file.
head -c $((256 * 1024 * 1024 + 1)) > "$incoming"
if [[ $(stat -c %s "$incoming") -gt $((256 * 1024 * 1024)) ]]; then
    echo 'WAR exceeds 256 MiB.' >&2
    exit 1
fi
unzip -tq "$incoming" >/dev/null
unzip -p "$incoming" META-INF/MANIFEST.MF | tr -d '\r' | grep -Fx 'Main-Class: org.springframework.boot.loader.launch.WarLauncher' >/dev/null

if [[ -f current.war ]]; then
    ln -f current.war previous.war
fi
chmod 0640 "$incoming"
mv -f "$incoming" current.war

if sudo -n systemctl restart edusphere.service; then
    for attempt in {1..45}; do
        if curl --fail --silent --max-time 3 http://127.0.0.1:8080/EduSphere/login >/dev/null; then
            echo 'EduSphere responded successfully.'
            exit 0
        fi
        sleep 2
    done
fi

echo 'EduSphere failed its login-page check.' >&2
if [[ -f previous.war ]]; then
    mv -f previous.war current.war
    sudo -n systemctl restart edusphere.service
else
    mv -f current.war failed.war
fi
exit 1
