@echo off
REM 请注意，您需要将脚本中的以下值替换为您自己的Cloudflare API信息和DNS记录信息：
REM <your email>：您的Cloudflare登录邮箱。
REM <your api key>：您的Cloudflare API密钥。
REM <your zone id>：您要更新DNS记录的Cloudflare区域ID。
REM <your record name>：您要更新的DNS记录名称。
REM <your record type>：您要更新的DNS记录类型。
REM <your record TTL>：您要设置的DNS记录TTL值。
REM 该脚本的基本工作流程如下：
REM 获取当前计算机的公共IP地址。
REM 使用Cloudflare API获取特定DNS记录的ID。
REM 如果找不到该DNS记录，则使用Cloudflare API创建一个新的DNS记录。
REM 如果找到该DNS记录，则使用Cloudflare API更新该DNS记录的IP地址。
REM 请注意，此脚本依赖于curl命令行工具来执行API请求。在使用之前，请确保已在计算机上安装curl。此外，由于Windows BAT脚本的限制，此脚本可能无法处理某些特殊字符。如果您遇到任何问题，请检查脚本中的字符并进行必要的更改。


set CLOUDFLARE_API_EMAIL=<your email>
set CLOUDFLARE_API_KEY=<your api key>
set CLOUDFLARE_ZONE_ID=<your zone id>
set CLOUDFLARE_RECORD_NAME=<your record name>
set CLOUDFLARE_RECORD_TYPE=<your record type>
set CLOUDFLARE_RECORD_TTL=<your record TTL>

set CURRENT_IP=
for /f "delims=" %%i in ('nslookup %CLOUDFLARE_RECORD_NAME% 8.8.8.8 ^| findstr /i "address"') do set CURRENT_IP=%%i
set CURRENT_IP=%CURRENT_IP:*: =%

curl -X GET "https://api.cloudflare.com/client/v4/zones/%CLOUDFLARE_ZONE_ID%/dns_records?type=%CLOUDFLARE_RECORD_TYPE%&name=%CLOUDFLARE_RECORD_NAME%" -H "X-Auth-Email: %CLOUDFLARE_API_EMAIL%" -H "X-Auth-Key: %CLOUDFLARE_API_KEY%" -H "Content-Type: application/json" > dns.json

set /p DNS_RECORD_ID=<dns.json findstr /C:"\"id\":" | findstr /C:"\"type\":\"%CLOUDFLARE_RECORD_TYPE%\"" | findstr /C:"\"name\":\"%CLOUDFLARE_RECORD_NAME%\"" | findstr /C:"\"id\":" | findstr /v /C:"proxy\"" | findstr /m /C:"\"id\":"

if [%CURRENT_IP%]==[] (
    echo Failed to get current IP address. Exiting...
    exit /b 1
)

if [%DNS_RECORD_ID%]==[] (
    echo Failed to get DNS record ID. Creating new record...
    curl -X POST "https://api.cloudflare.com/client/v4/zones/%CLOUDFLARE_ZONE_ID%/dns_records" -H "X-Auth-Email: %CLOUDFLARE_API_EMAIL%" -H "X-Auth-Key: %CLOUDFLARE_API_KEY%" -H "Content-Type: application/json" --data "{\"type\":\"%CLOUDFLARE_RECORD_TYPE%\",\"name\":\"%CLOUDFLARE_RECORD_NAME%\",\"content\":\"%CURRENT_IP%\",\"ttl\":%CLOUDFLARE_RECORD_TTL%,\"proxied\":false}"
) else (
    echo Updating DNS record with new IP address...
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/%CLOUDFLARE_ZONE_ID%/dns_records/%DNS_RECORD_ID%" -H "X-Auth-Email: %CLOUDFLARE_API_EMAIL%" -H "X-Auth-Key: %CLOUDFLARE_API_KEY%" -H "Content-Type: application/json" --data "{\"type\":\"%CLOUDFLARE_RECORD_TYPE%\",\"name\":\"%CLOUDFLARE_RECORD_NAME%\",\"content\":\"%CURRENT_IP%\",\"ttl\":%CLOUDFLARE_RECORD_TTL%,\"proxied\":false}"
)

echo DNS record updated successfully.
pause();