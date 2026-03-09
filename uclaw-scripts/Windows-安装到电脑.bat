@echo off
chcp 65001 >nul 2>&1
title U-Claw 虾盘 - 安装 OpenClaw 到电脑

echo.
echo   ╔══════════════════════════════════════╗
echo   ║     U-Claw 虾盘 v1.1                ║
echo   ║     OpenClaw 永久安装 (Windows)      ║
echo   ╚══════════════════════════════════════╝
echo.

set "UCLAW_DIR=%~dp0"
set "INSTALL_DIR=%USERPROFILE%\.uclaw"

echo   安装位置: %INSTALL_DIR%
echo   安装内容: Node.js + OpenClaw + 所有依赖
echo.
echo   [安全提醒] 这会把 OpenClaw 和配置写入当前电脑。
echo   如果这是老电脑、共享电脑、公司电脑或临时机器，
echo   更推荐回到主菜单选择「直接从 U 盘运行」。
echo.
set /p CONFIRM="  是否继续安装? (y/n) "
if /i not "%CONFIRM%"=="y" (
    echo   已取消安装
    pause
    exit /b 0
)
echo.

echo   [1/4] 创建安装目录...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo   [2/4] 安装 Node.js 运行环境...
if exist "%INSTALL_DIR%\node" rmdir /s /q "%INSTALL_DIR%\node"
xcopy "%UCLAW_DIR%runtime\node-win-x64" "%INSTALL_DIR%\node\" /e /i /q >nul
if not exist "%INSTALL_DIR%\node\node.exe" (
    echo   [错误] Node.js 安装失败
    echo   请确认 U 盘复制完成，再重新运行安装。
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('"%INSTALL_DIR%\node\node.exe" --version') do echo   Node.js %%v 已安装

echo   [3/4] 安装 OpenClaw...
echo   这一步会复制大量文件，首次安装通常需要 3-10 分钟，请耐心等待...
if exist "%INSTALL_DIR%\openclaw" rmdir /s /q "%INSTALL_DIR%\openclaw"
xcopy "%UCLAW_DIR%openclaw" "%INSTALL_DIR%\openclaw\" /e /i /q >nul

if exist "%UCLAW_DIR%memory" xcopy "%UCLAW_DIR%memory" "%INSTALL_DIR%\memory\" /e /i /q >nul 2>&1
if exist "%UCLAW_DIR%persona" xcopy "%UCLAW_DIR%persona" "%INSTALL_DIR%\persona\" /e /i /q >nul 2>&1

echo   [4/4] 配置环境变量...

(
echo @echo off
echo set "UCLAW_HOME=%%USERPROFILE%%\.uclaw"
echo "%%UCLAW_HOME%%\node\node.exe" "%%UCLAW_HOME%%\openclaw\openclaw.mjs" %%*
) > "%INSTALL_DIR%\uclaw.cmd"

(
echo @echo off
echo set "UCLAW_HOME=%%USERPROFILE%%\.uclaw"
echo "%%UCLAW_HOME%%\node\node.exe" "%%UCLAW_HOME%%\openclaw\openclaw.mjs" %%*
) > "%INSTALL_DIR%\openclaw.cmd"

echo.
echo   正在添加到系统 PATH...
set "CURRENT_PATH="
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURRENT_PATH=%%b"

echo %CURRENT_PATH% | findstr /i ".uclaw" >nul 2>&1
if errorlevel 1 (
    REM 检查 PATH 是否为空（全新账户）
    if not defined CURRENT_PATH (
        setx PATH "%INSTALL_DIR%;%INSTALL_DIR%\node" >nul 2>&1
    ) else (
        REM 检查 setx 1024 字符限制
        set "NEW_PATH=%INSTALL_DIR%;%INSTALL_DIR%\node;%CURRENT_PATH%"
        setlocal enabledelayedexpansion
        if "!NEW_PATH:~1024,1!" neq "" (
            echo   [警告] PATH 超过 1024 字符，setx 会截断！
            echo   请手动添加以下路径到系统 PATH:
            echo     %INSTALL_DIR%
            echo     %INSTALL_DIR%\node
            endlocal
        ) else (
            endlocal
            setx PATH "%INSTALL_DIR%;%INSTALL_DIR%\node;%CURRENT_PATH%" >nul 2>&1
        )
    )
    echo   已添加到用户 PATH
) else (
    echo   PATH 已配置，跳过
)

echo.
echo   ╔══════════════════════════════════════╗
echo   ║     安装完成!                        ║
echo   ╚══════════════════════════════════════╝
echo.
echo   安装位置: %INSTALL_DIR%
echo.
echo   使用方法:
echo     1. 打开新的命令提示符或 PowerShell
echo     2. 运行: openclaw onboard --install-daemon
echo     3. 配置完成后运行: openclaw dashboard
echo.
echo   小白用户推荐：
echo     先按引导完成首次配置，再打开网页控制台
echo.
pause
