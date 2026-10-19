#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

docker compose up -d edusphere-db

attempt=0
until docker compose exec -T edusphere-db /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -C -b -Q "SELECT 1" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        printf 'SQL Server did not become ready. Check: docker compose logs edusphere-db\n' >&2
        exit 1
    fi
    sleep 2
done

# Always run the canonical, repeatable schema. Having the six authentication
# tables is not a reason to skip the remaining course/learning tables.
docker compose exec -T edusphere-db /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -C -b -d master < SQLQuery1.sql

printf 'EduSphere schema is ready. Existing application data was preserved.\n'
