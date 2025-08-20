# DiaryApp CI/CD Runbook

## What you will run
- App (ASP.NET Core MVC)
  - Local (Dev): http://localhost:5298
  - Container (Prod): http://localhost:8081
- SQL Server (Docker): host port 8082 -> container 1433
- Jenkins (Docker): http://localhost:8080

Ports summary
- Jenkins: 8080
- App container: 8081 -> 8080 (in container)
- Local app (dev/Kestrel): 5298
- SQL Server: 8082 (host) -> 1433 (container)

---

## Prerequisites (Windows)
- Docker Desktop
- Git
- .NET SDK 8.x (`dotnet --version` should start with 8.)
- PowerShell

Repo layout
```
Diary/
├─ DiaryApp/                 # App source, Dockerfile, Jenkinsfile, docker-compose-db.yml
├─ RUNBOOK.md
└─ Diary.sln
```

---

## 1) First-time database setup (Docker)
Run these from the repo root unless noted otherwise.

1. Start SQL Server (compose lives under `DiaryApp/`):
```powershell
docker-compose -f DiaryApp/docker-compose-db.yml up -d
```
2. Verify it’s up:
```powershell
docker ps
# look for: diaryapp-db  ->  0.0.0.0:8082->1433/tcp
```
3. Check logs (optional):
```powershell
docker logs diaryapp-db | Select-String "ready for client connections"
```
4. Create the `Diary` database (choose ONE method):
   - Using EF Core tools
     ```powershell
     dotnet tool install --global dotnet-ef
     $env:Path += ";$env:USERPROFILE\.dotnet\tools"
     cd DiaryApp
     # If no migrations exist, create one first
     # dotnet ef migrations add InitialCreate
     dotnet ef database update
     ```
   - Or manually via SSMS/Azure Data Studio
     - Connect to: Server `localhost,8082` | User `sa` | Password `Password123!`
     - New Query:
       ```sql
       CREATE DATABASE Diary;
       ```

Connection string used by the app (DiaryApp/appsettings.json):
```
Server=localhost,8082;Database=Diary;User Id=sa;Password=Password123!;TrustServerCertificate=true;MultipleActiveResultSets=true
```

---

## 2) Run locally (Developer experience)
1. From repo root:
```powershell
cd DiaryApp
dotnet run
```
2. Open:
- App: http://localhost:5298
- Entries: http://localhost:5298/DiaryEntries

Local runs use the same Docker SQL database on port 8082. Changes are visible in both local and prod.

---

## 3) Run in “production” (Jenkins + Docker)
Pipeline lives in `DiaryApp/Jenkinsfile`.

Triggering
- Push to `main` (SCM polling every minute) or click “Build Now”.

Stages
- Checkout -> Build & Test -> Publish -> Build Docker Image -> Deploy

Deploy details
- Image: `diaryapp:latest`
- Container name: `diaryapp-container`
- App binds: `8081:8080`
- App joins network: `diaryapp_diary-network` (created by the DB compose)

Open production app: http://localhost:8081

If deploy fails with “network not found”, (re)start DB compose first:
```powershell
docker-compose -f DiaryApp/docker-compose-db.yml up -d
```

---

## 4) Manual container run (without Jenkins)
```powershell
cd DiaryApp
# build app image
docker build -t diaryapp:latest .
# ensure DB network exists (created by compose)
docker network ls | findstr diaryapp_diary-network
# run app on same network as DB
docker run -d --name diaryapp-container -p 8081:8080 --network diaryapp_diary-network diaryapp:latest
```
Browse: http://localhost:8081

---

## 5) Troubleshooting quick wins
- Styles missing
  - Ensure `DiaryApp/wwwroot/css/site.css` exists
  - Ensure `DiaryApp.csproj` does NOT remove `wwwroot` content
- Static web assets error (`DefineStaticWebAssets` / duplicate items)
  ```powershell
  cd DiaryApp
  dotnet clean
  Remove-Item -Recurse -Force obj, bin
  # Remove any stray files under wwwroot (e.g., accidentally placed C# files)
  ```
- 500 on /DiaryEntries (production)
  - Confirm DB is up: `docker ps` (look for `diaryapp-db`)
  - App is on same network: `docker inspect diaryapp-container | Select-String diaryapp_diary-network`
  - Connection string in container comes from the built image (push changes then redeploy)
- SQL login failed for user 'sa'
  - Recreate DB container fresh (resets password and data):
    ```powershell
    docker-compose -f DiaryApp/docker-compose-db.yml down
    docker rm -f diaryapp-db 2>$null
    docker volume rm diaryapp_sqlserver_data 2>$null
    docker-compose -f DiaryApp/docker-compose-db.yml up -d
    ```
  - Default credentials in compose: `sa` / `Password123!`
- Port already in use
  - 8081: `docker ps` then `docker stop diaryapp-container`
  - 5298: kill local `DiaryApp.exe` if locked: `taskkill /F /IM DiaryApp.exe`
- Jenkins cannot talk to Docker
  - Ensure Jenkins container has access to `/var/run/docker.sock` and the `jenkins` user is in the `docker` group

---

## 6) Demo script (2–3 minutes)
1. Make a tiny code change (e.g., update a comment in `DiaryApp/Program.cs`).
2. Commit & push to `main`:
   ```powershell
   git add .
   git commit -m "demo: trigger pipeline"
   git push origin main
   ```
3. Open Jenkins -> Job -> watch build start automatically (SCM polling).
4. After success, browse http://localhost:8081 and show the change.
5. Create a diary entry to show DB persistence (same DB used by local runs).

---

## 7) Stop / cleanup
```powershell
# stop app container
docker stop diaryapp-container 2>$null
# stop DB (compose)
docker-compose -f DiaryApp/docker-compose-db.yml down
```

That’s it—happy coding and shipping!
