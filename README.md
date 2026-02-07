# HaexHub Supabase Self-Hosted

Self-hosted Supabase instance for haex.space.

## Architecture

- **API**: `https://api.sync.haex.space`
- **Studio**: `https://studio.sync.haex.space`

## Initial Deployment (via Ansible)

```bash
cd ~/Projekte/ansible
ansible-playbook haex.space.play.yml --tags haex-supabase
```

## Secrets Setup

### 1. Generate secrets

```bash
./scripts/generate-keys.sh
```

### 2. Generate JWT keys

Use the Node.js script from `generate-keys.sh` output or visit:
https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys

### 3. Generate password hash for Traefik Basic Auth

```bash
htpasswd -nb admin 'YOUR_PASSWORD'
```

The output format is `user:hash`. Use the hash in `.env` as `DASHBOARD_PASSWORD_HASH`.
**Important**: Escape `$` as `$$` in docker-compose!

### 4. Add secrets to Ansible

Add to `secrets.yml`:

```yaml
secrets:
  haex_supabase:
    postgres_password: "generated-password"
    jwt_secret: "generated-jwt-secret"
    anon_key: "generated-anon-key"
    service_role_key: "generated-service-role-key"
    dashboard_username: "admin"
    dashboard_password: "generated-password"
    dashboard_password_hash: "$$apr1$$..."  # Double $$ for escaping
    vault_enc_key: "32-char-key"
    secret_key_base: "64-char-key"
    realtime_secret_key_base: "64-char-key"
```

## Local Development

```bash
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| db | 5432 | PostgreSQL |
| kong | 8000 | API Gateway |
| auth | 9999 | GoTrue (Auth) |
| rest | 3000 | PostgREST |
| realtime | 4000 | WebSocket |
| storage | 5000 | File Storage |
| meta | 8080 | Postgres Meta |
| studio | 3000 | Dashboard |

## Migration from Supabase Cloud

1. Export data from Supabase Cloud:
   ```bash
   pg_dump -h db.xxx.supabase.co -U postgres -d postgres > backup.sql
   ```

2. Import to self-hosted:
   ```bash
   docker exec -i supabase-db psql -U postgres < backup.sql
   ```

3. Update client configurations:
   - Change `SUPABASE_URL` to `https://api.sync.haex.space`
   - Update API keys (ANON_KEY, SERVICE_ROLE_KEY)

## Backups

PostgreSQL data is stored in Docker volume `db_data`.

Backup:
```bash
docker exec supabase-db pg_dump -U postgres > backup_$(date +%Y%m%d).sql
```

Restore:
```bash
docker exec -i supabase-db psql -U postgres < backup.sql
```
