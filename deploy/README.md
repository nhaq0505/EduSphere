# Deploy EduSphere to Ubuntu

The VPS runs Java 17 under systemd and SQL Server 2022 Express in Docker.
The application and database initially bind to loopback. Use a TLS reverse proxy
when publishing the site. Keep the public base URL and any OAuth or webhook URLs
consistent with the `/EduSphere` context path.

1. As VPS administrator, review the [SQL Server license](https://aka.ms/useterms)
   and run `sudo env ACCEPT_SQL_SERVER_EULA=Y bash deploy/bootstrap-vps.sh`.
   This initializes an empty database. EduSphere creates and updates its schema
   on startup. Keep the SQL volume, `/var/lib/edusphere`, and backups across releases.
2. Set `APP_BASEURL=https://your-domain.example/EduSphere` in the root-only
   `/etc/edusphere/edusphere.env` file. Add freshly issued integration credentials
   as needed. The initial admin email is `admin@edusphere.vn`. Its randomly generated
   password is in the same file. Bootstrap demo accounts are disabled on the VPS.
3. Generate a dedicated Ed25519 key for deployment. As VPS administrator, put its
   public key on its own line in
   `/home/edusphere-deploy/.ssh/authorized_keys` with these options before the key:

   ```text
   restrict,command="/usr/local/bin/edusphere-receive-war" ssh-ed25519 AAAA...
   ```

   Give the file owner `edusphere-deploy` and mode `0600`. Keep the private key
   in the repository's Actions secret `VPS_DEPLOY_KEY`. Do not reuse a personal SSH key.
4. Set repository Actions variables `VPS_HOST` and `VPS_DEPLOY_USER`
   (`edusphere-deploy`). Set `VPS_KNOWN_HOST` to the exact line
   `hostname-or-IP ssh-ed25519 AAAA...`, using the server's
   `/etc/ssh/ssh_host_ed25519_key.pub` read from its trusted console.
5. Push or merge to `main` to run the workflow, or run it manually from `main`.
   It runs Maven tests, builds the WAR, streams it to the VPS through the dedicated
   SSH account, restarts EduSphere and checks the login page. An unhealthy release
   restores the previous WAR if available. Back up the database before releases that
   change its schema because rolling back a WAR does not reverse database migrations.
6. Verify the app locally on the VPS using
   `curl -fsS http://127.0.0.1:8080/EduSphere/login`. Set up the TLS reverse proxy to
   forward `/EduSphere/` and check the same page using the public HTTPS URL.

The workflow deploys the Java web application only. Run the separate AI service
where appropriate and set `AI_SERVICE_BASE_URL` to its address when it is available.
