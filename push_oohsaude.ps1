# push_oohsaude.ps1 — Publica o Ooh! Saude no GitHub Pages
# ANTES DE USAR: crie o repositorio vazio "OohSaude" em https://github.com/new
# (dono ZZ-29, sem README) e depois ative GitHub Pages (Settings > Pages > branch main).

$log = "C:\Users\User\Desktop\Icones_Antigos\OohSaude\push_log.txt"
$pastaOrigem = "C:\Users\User\Desktop\Icones_Antigos\OohSaude"
$repoDir = "C:\Users\User\AppData\Local\Temp\OohSaudeRepo"
$repoUrl = "https://github.com/ZZ-29/OohSaude.git"

"=== Ooh Saude Push Log $(Get-Date) ===" | Out-File $log -Encoding utf8

$arquivos = @("index.html","manifest.json","sw.js","icon-192.png","icon-512.png")
foreach ($f in $arquivos) {
    if (-not (Test-Path "$pastaOrigem\$f")) {
        "ERRO: Arquivo nao encontrado: $f" | Add-Content $log
        Write-Host "ERRO: $f nao encontrado em OohSaude" -ForegroundColor Red
        pause; exit 1
    }
}
"Arquivos fonte OK" | Add-Content $log

if (Test-Path $repoDir) {
    Remove-Item $repoDir -Recurse -Force
    "Clone antigo removido" | Add-Content $log
}

Write-Host "Clonando repositorio..." -ForegroundColor Cyan
"Clonando..." | Add-Content $log
$cloneResult = & git clone $repoUrl $repoDir 2>&1
$cloneResult | Add-Content $log

if (-not (Test-Path "$repoDir\.git")) {
    "ERRO: Clone falhou. O repositorio OohSaude existe no GitHub?" | Add-Content $log
    Write-Host "ERRO: Nao foi possivel clonar. Crie o repositorio OohSaude no GitHub primeiro (https://github.com/new)." -ForegroundColor Red
    pause; exit 1
}
"Clone OK" | Add-Content $log

Set-Location $repoDir
& git config user.email "jorgeelopes@gmail.com" 2>&1 | Add-Content $log
& git config user.name "Jorge" 2>&1 | Add-Content $log

foreach ($f in $arquivos) {
    Copy-Item "$pastaOrigem\$f" "$repoDir\$f" -Force
}
"Arquivos copiados" | Add-Content $log

Write-Host "Fazendo commit e push..." -ForegroundColor Cyan
$add    = & git add -A 2>&1; $add | Add-Content $log
$msg = "atualizacao Ooh Saude"
$commit = & git commit -m $msg 2>&1; $commit | Add-Content $log
$push   = & git push 2>&1; $push | Add-Content $log

"=== FIM $(Get-Date) ===" | Add-Content $log

$logContent = Get-Content $log -Raw
if ($logContent -match "main -> main" -or $logContent -match "Everything up-to-date" -or $logContent -match "HEAD -> main") {
    Write-Host ""
    Write-Host "SUCESSO! App publicado em https://ZZ-29.github.io/OohSaude/" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Verifique push_log.txt para detalhes" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Log salvo em: $log"
pause
