@echo off

@REM 此脚本执行以下操作：
@REM 从oray.com获取当前的公共IP地址。
@REM 检查当前的IP地址是否与oray.com上指定的DNS记录相同。
@REM 如果IP地址需要更新，则使用curl命令调用oray.com的API来更新DNS记录。
@REM 在使用脚本之前，请将 <your oray.com username>、<your oray.com password>和<your oray.com hostname> 替换为您的oray.com账户信息和DNS记录信息。此脚本需要在Windows环境下运行，并需要使用curl命令。请确保您已在计算机上安装了curl并将其添加到了系统路径中。
@REM 在脚本中，使用了 setlocal EnableDelayedExpansion命令，以便在for循环内部使用变量 !ORAY_IP! 来保存当前的IP地址。此外，使用了 goto 命令来跳过更新DNS记录的步骤，如果当前IP地址已经是最新的。
@REM 请注意，oray.com DDNS API在某些地区可能会遇到问题，导致更新DNS记录失败。如果您遇到任何问题，请尝试检查oray.com网站上的相关信息或联系oray.com支持团队。

REM 替换下面的变量为您的信息
set USERNAME=<your oray.com username>
set PASSWORD=<your oray.com password>
set HOSTNAME=<your oray.com hostname>

REM 从oray.com获取当前的公共IP地址
setlocal EnableDelayedExpansion
for /f "tokens=1,2" %%i in ('nslookup %HOSTNAME%.myip.oray.net ^| findstr /C:"Address"') do (
  set ORAY_IP=%%j
)
set ORAY_IP=!ORAY_IP:~0,-1!

REM 检查是否需要更新DNS
for /f "tokens=1,2" %%i in ('nslookup %HOSTNAME% ^| findstr /C:"Address"') do (
  set CURRENT_IP=%%j
)
if "%CURRENT_IP%"=="%ORAY_IP%" (
  echo IP address is already up to date: %CURRENT_IP%
  goto end
)

REM 更新DNS记录
curl -k "http://ddns.oray.com/ph/update?hostname=%HOSTNAME%&myip=%ORAY_IP%" -u "%USERNAME%:%PASSWORD%"
echo DNS record updated with IP address: %ORAY_IP%

:end
