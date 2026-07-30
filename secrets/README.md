Copy to local secret files before first `docker compose up`:

```bash
cp mqAppPassword.example.txt mqAppPassword.txt
cp mqAdminPassword.example.txt mqAdminPassword.txt
```

These demo passwords match `.env.example` (`passw0rd`). Do not commit `*.txt` secrets (gitignored).
