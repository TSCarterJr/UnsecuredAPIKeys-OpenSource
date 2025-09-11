param(
    [string]$DbName = "UnsecuredAPIKeys",
    [string]$DbUser = "postgres",
    [string]$DbPass = "mysecretpassword",
    [int]$DbPort = 5432,
    [string]$DbContainer = "unsecured-api-keys-db"
)

Write-Host "🚀 Starting setup for UnsecuredAPIKeys..."

# Start PostgreSQL container
if (-not (docker ps -q -f "name=$DbContainer")) {
    if (docker ps -aq -f "status=exited" -f "name=$DbContainer") {
        docker start $DbContainer
    } else {
        docker run --name $DbContainer `
            -e POSTGRES_DB=$DbName `
            -e POSTGRES_USER=$DbUser `
            -e POSTGRES_PASSWORD=$DbPass `
            -p $DbPort:5432 -d postgres:15
    }
}

# Apply EF migrations
Write-Host "📦 Applying EF Core migrations..."
cd UnsecuredAPIKeys.WebAPI
dotnet ef database update --project ../UnsecuredAPIKeys.Data --startup-project .

# Run backend
Write-Host "▶️ Running Backend API..."
Start-Process powershell -ArgumentList "cd $(Get-Location); dotnet run"

# Run frontend
Write-Host "▶️ Running Frontend UI..."
cd ../UnsecuredAPIKeys.UI
npm install
npm run dev
