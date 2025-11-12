@echo off
setlocal EnableExtensions
cd /d "%~dp0"

REM -------------------------
REM CONFIGURACION (editar)
REM CPU_PERCENT: porcentaje (1-100). Default = 40
set "CPU_PERCENT=40"
REM -------------------------

REM validar CPU_PERCENT: si no es número entre 1 y 100, usar 40
set "_nonnum="
for /f "delims=0123456789" %%A in ("%CPU_PERCENT%") do set "_nonnum=%%A"
if defined _nonnum (
  echo [WARN] CPU_PERCENT no es numerico, se usara 40%%.
  set "CPU_PERCENT=40"
)
if "%CPU_PERCENT%"=="" set "CPU_PERCENT=40"
if %CPU_PERCENT% LSS 1 set "CPU_PERCENT=40"
if %CPU_PERCENT% GTR 100 set "CPU_PERCENT=40"

REM confirmar valor
echo [INFO] Limite de CPU configurado: %CPU_PERCENT%%

REM 1) Comprobar que xmrig (renombrado AMD.exe) existe
if not exist "AMD.exe" (
  echo [ERROR] No encuentro AMD.exe en: %cd%
  dir /b *.exe
  pause
  exit /b 1
)

REM 2) Desbloquear por si Windows lo marco como descargado
powershell -NoProfile -Command "try{Unblock-File -Path 'AMD.exe'}catch{}" >nul 2>&1


REM 3) Mostrar version (diagnostico)
echo ========= XMRig --version =========
".\AMD.exe" --version
echo ===================================

REM 4) Preparar argumento de limitador de CPU
set "CPU_ARG=--max-cpu-usage=%CPU_PERCENT%"

REM 5) Lanzar con config.json y log nativo (log: miner_xmr_log.txt)
echo.
echo Iniciando XMRig con config.json (log: log.txt)...
echo Comando: ".\AMD.exe" --config="config.json" --log-file="log.txt" --no-color %CPU_ARG%
echo.

".\AMD.exe" --config="config.json" --log-file="log.txt" --no-color %CPU_ARG%
set "RC=%ERRORLEVEL%"

echo.
echo XMRig salio con RC=%RC%
echo Ultimas 40 lineas del log:
powershell -NoProfile -Command "if(Test-Path 'log.txt'){Get-Content -Path 'log.txt' -Tail 40}else{'(sin log)'}"
echo.
pause
exit /b %RC%
