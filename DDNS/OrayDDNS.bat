@echo off

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
