@echo off
chcp 65001 >nul 2>&1
title U-Claw 虾盘 - 启动菜单
setlocal enabledelayedexpansion

set "UCLAW_DIR=%~dp0"
set "OPENCLAW_DIR=%UCLAW_DIR%openclaw"
set "NODE_DIR=%UCLAW_DIR%runtime\node-win-x64"
set "NODE_BIN=%NODE_DIR%\node.exe"
set "NPM_BIN=%NODE_DIR%\npm.cmd"
set "PORTABLE_HOME=%UCLAW_DIR%portable-home"
set "PORTABLE_STATE_DIR=%PORTABLE_HOME%\.openclaw"
set "PORTABLE_CONFIG_PATH=%PORTABLE_STATE_DIR%\openclaw.json"

set "OPENCLAW_HOME=%PORTABLE_HOME%"
set "OPENCLAW_STATE_DIR=%PORTABLE_STATE_DIR%"
set "OPENCLAW_CONFIG_PATH=%PORTABLE_CONFIG_PATH%"
set "PATH=%NODE_DIR%;%PATH%"

if not exist "%PORTABLE_STATE_DIR%" mkdir "%PORTABLE_STATE_DIR%"

goto MENU

:MENU
cls
echo.
echo   ╔════════════════════════════════════════════════════════╗
echo   ║                                                        ║
echo   ║          U-Claw 虾盘 v1.1                              ║
echo   ║          OpenClaw AI 助手 一键安装盘                     ║
echo   ║                                                        ║
echo   ║          专为中国用户优化 · 免翻墙 · 离线安装            ║
echo   ║                                                        ║
echo   ╠════════════════════════════════════════════════════════╣
echo   ║                                                        ║

:: 状态检测
for /f "tokens=*" %%v in ('"%NODE_BIN%" --version 2^>nul') do set "NODE_VER=%%v"
set "ST_MOD=未安装"
set "ST_BUILD=未构建"
set "ST_INST=未安装"
set "ST_PORT=未配置"
if exist "%OPENCLAW_DIR%\node_modules" set "ST_MOD=已安装"
if exist "%OPENCLAW_DIR%\dist" set "ST_BUILD=已构建"
if exist "%USERPROFILE%\.uclaw\openclaw" set "ST_INST=已安装"
if exist "%PORTABLE_CONFIG_PATH%" set "ST_PORT=已配置"

echo   ║  系统: x64 ^| Node: %NODE_VER%                          ║
echo   ║  依赖: %ST_MOD% ^| 构建: %ST_BUILD%                           ║
echo   ║  便携配置: %ST_PORT% ^| 电脑安装: %ST_INST%                    ║
echo   ║                                                        ║
echo   ╠════════════════════════════════════════════════════════╣
echo.
echo     ---- 安装 -----------------------------------------
echo.
echo     [1]  安装 OpenClaw 到本机（仅限自己的电脑）
echo     [2]  仅安装依赖（npm install）
echo     [3]  仅构建项目（npm build）
echo     [4]  直接从 U 盘运行（配置也保存在 U 盘里）
echo.
echo     ---- 中国优化 -------------------------------------
echo.
echo     [5]  首次配置向导（选模型、选平台、填 API Key）
echo     [6]  配置中国聊天平台（QQ Bot/飞书/微信）
echo     [7]  设置国内镜像源
echo.
echo     ---- 维护工具 -------------------------------------
echo.
echo     [8]  诊断修复（openclaw doctor）
echo     [9]  备份当前状态
echo     [10] 恢复备份
echo     [11] 重置 OpenClaw（恢复出厂）
echo     [12] 清理缓存和临时文件
echo.
echo     ---- 其他 -----------------------------------------
echo.
echo     [13] 浏览预装技能（58个，已离线可用）
echo     [14] 中国用户快速上手指南
echo     [15] 查看使用说明
echo     [16] 系统信息
echo     [17] 打开本地网页控制台
echo     [0]  退出
echo.
echo   ╚════════════════════════════════════════════════════════╝
echo.

set /p CHOICE="  请选择 [0-17]: "

if "%CHOICE%"=="1" goto INSTALL
if "%CHOICE%"=="2" goto NPM_INSTALL
if "%CHOICE%"=="3" goto BUILD
if "%CHOICE%"=="4" goto RUN
if "%CHOICE%"=="5" goto CHINA_MODELS
if "%CHOICE%"=="6" goto CHINA_CHANNELS
if "%CHOICE%"=="7" goto MIRROR
if "%CHOICE%"=="8" goto DOCTOR
if "%CHOICE%"=="9" goto BACKUP
if "%CHOICE%"=="10" goto RESTORE
if "%CHOICE%"=="11" goto RESET
if "%CHOICE%"=="12" goto CLEANUP
if "%CHOICE%"=="13" goto SKILLS
if "%CHOICE%"=="14" goto CHINA_GUIDE
if "%CHOICE%"=="15" goto README
if "%CHOICE%"=="16" goto SYSINFO
if "%CHOICE%"=="17" goto DASHBOARD
if "%CHOICE%"=="0" goto EXIT

echo   无效选择
pause
goto MENU

:INSTALL
echo.
echo   === 安装 OpenClaw 到电脑 ===
echo.
echo   提醒：如果这是临时电脑、公司电脑或别人的电脑，
echo   更推荐返回主菜单选择 [4] 从 U 盘运行。
echo.
call "%UCLAW_DIR%安装到电脑.bat"
pause
goto MENU

:NPM_INSTALL
echo.
echo   === 安装 npm 依赖 ===
echo.
cd /d "%OPENCLAW_DIR%"
call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
echo.
echo   依赖安装完成!
pause
goto MENU

:BUILD
echo.
echo   === 构建 OpenClaw ===
echo.
if not exist "%OPENCLAW_DIR%\node_modules" (
    echo   先安装依赖...
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"
call "%NODE_BIN%" "%NPM_BIN%" run build
echo.
echo   构建完成!
pause
goto MENU

:RUN
echo.
echo   === 从 U 盘启动 OpenClaw ===
echo.
echo   便携模式：配置、状态、记忆都会写在这只 U 盘里。
echo   拔掉 U 盘后当前会话会结束，但换一台电脑再插上还能继续用。
echo.
if not exist "%OPENCLAW_DIR%\node_modules" (
    echo   先安装依赖...
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
if not exist "%OPENCLAW_DIR%\dist" (
    echo   先构建...
    cd /d "%OPENCLAW_DIR%"
    call "%NODE_BIN%" "%NPM_BIN%" run build
)
cd /d "%OPENCLAW_DIR%"
if not exist "%PORTABLE_CONFIG_PATH%" (
    echo   检测到你还没有完成首次配置。
    echo   首次配置会保存在 U 盘中，不会写进这台电脑。
    echo.
    set /p DO_ONBOARD="  现在开始首次配置? (y/n) "
    if /i "!DO_ONBOARD!"=="y" (
        "%NODE_BIN%" openclaw.mjs onboard
        echo.
        echo   首次配置完成，已保存到 U 盘。
    )
) else (
    echo   正在启动网关服务...
    echo   此窗口不要关闭，关闭后服务会停止。
    echo.
    "%NODE_BIN%" openclaw.mjs gateway run --allow-unconfigured --force
)
pause
goto MENU

:CHINA_MODELS
echo.
echo   === 首次配置向导 ===
echo.
echo   国产模型选择提示:
echo.
echo   DeepSeek    → 选 Custom Provider
echo                  Base URL: https://api.deepseek.com/v1
echo                  模型名: deepseek-chat
echo   Kimi        → 选 Moonshot AI
echo   通义千问    → 选 Qwen
echo   MiniMax     → 选 MiniMax
echo   豆包        → 选 Volcano Engine
echo.
echo   按方向键上下滚动列表，回车确认
echo.
if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"
"%NODE_BIN%" openclaw.mjs onboard
pause
goto MENU

:CHINA_CHANNELS
echo.
echo   === 配置中国聊天平台 ===
echo.
echo   [a] 飞书 Feishu/Lark       — 已内置，企业首选
echo   [b] QQ（腾讯官方）★推荐    — 3条命令，1分钟，免费免翻墙
echo   [c] 微信（社区插件）         — iPad协议
echo   [d] Telegram                 — 推荐，简单好用
echo.
set /p CH="  请选择 (a-d): "

if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"

if /i "%CH%"=="a" (
    echo.
    echo   配置飞书 Feishu
    echo   1. 访问 https://open.feishu.cn/app 创建应用
    echo   2. 获取 App ID 和 App Secret
    echo   3. 配置事件订阅和权限
    echo.
    "%NODE_BIN%" openclaw.mjs onboard
)
if /i "%CH%"=="b" (
    echo.
    echo   配置 QQ（腾讯官方接入）
    echo.
    echo   这是国内最简单的 AI 助手接入方式！
    echo   全程 1 分钟，完全免费，无需翻墙。
    echo.
    echo   1. 扫码注册: http://q.qq.com/qqbot/openclaw/login.html
    echo   2. 点击「创建机器人」，获取 AppID 和 AppSecret
    echo.
    if exist "%OPENCLAW_DIR%\dist" (
        set /p DO_QQ="  是否现在安装 QQ 插件? (y/n) "
        if /i "!DO_QQ!"=="y" (
            echo.
            echo   正在安装 QQ 插件...
            "%NODE_BIN%" openclaw.mjs plugins install @sliverp/qqbot@latest
            echo.
            set /p QQ_APP_ID="  AppID:  "
            echo.
            set /p QQ_APP_SECRET="  AppSecret:  "
            echo.
            if not "!QQ_APP_ID!"=="" if not "!QQ_APP_SECRET!"=="" (
                echo   正在绑定 QQ 机器人...
                "%NODE_BIN%" openclaw.mjs channels add --channel qqbot --token "!QQ_APP_ID!:!QQ_APP_SECRET!"
                echo.
                set /p QQ_ALLOW="  请输入你自己的 QQ 号（设置白名单，留空跳过）: "
                if not "!QQ_ALLOW!"=="" (
                    "%NODE_BIN%" openclaw.mjs config set channels.qqbot.allowFrom "\"!QQ_ALLOW!\""
                    echo   白名单已设置
                )
                echo.
                echo   QQ 机器人配置完成！
                echo   请重启网关后生效（主菜单选 [4] 或 [17]）
            )
        )
    )
)
if /i "%CH%"=="c" (
    echo.
    echo   配置微信（社区插件）
    echo   安装微信插件:
    "%NODE_BIN%" openclaw.mjs plugins install @icesword760/openclaw-wechat
)
if /i "%CH%"=="d" (
    echo.
    echo   配置 Telegram
    echo   1. 在 Telegram 中找 @BotFather
    echo   2. 发送 /newbot 创建机器人
    echo   3. 获取 Bot Token
    echo.
    "%NODE_BIN%" openclaw.mjs onboard
)
pause
goto MENU

:MIRROR
echo.
echo   === 设置国内镜像源 ===
echo.
cd /d "%OPENCLAW_DIR%"
call "%NPM_BIN%" config set registry https://registry.npmmirror.com --location=project
echo   npm 镜像已设置: registry.npmmirror.com
pause
goto MENU

:DOCTOR
echo.
echo   === 诊断修复 ===
echo.
echo   提示: 选 [17] 可打开网页控制台，在浏览器中查看完整状态
echo.
if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"
"%NODE_BIN%" openclaw.mjs doctor --repair
pause
goto MENU

:BACKUP
echo.
echo   === 备份当前状态 ===
echo.
set "TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "BACKUP_DIR=%UCLAW_DIR%backups\backup_%TIMESTAMP%"
mkdir "%BACKUP_DIR%" 2>nul

if exist "%PORTABLE_STATE_DIR%" (
    xcopy "%PORTABLE_STATE_DIR%" "%BACKUP_DIR%\portable-state\" /e /i /q >nul 2>&1
    echo   [OK] 便携模式状态已备份
)
if exist "%OPENCLAW_DIR%\.env" (
    copy "%OPENCLAW_DIR%\.env" "%BACKUP_DIR%\.env" >nul
    echo   [OK] .env 配置已备份
)

echo.
echo   备份完成! 位置: %BACKUP_DIR%
pause
goto MENU

:RESTORE
echo.
echo   === 恢复备份 ===
echo.
set "BACKUP_BASE=%UCLAW_DIR%backups"
if not exist "%BACKUP_BASE%" (
    echo   没有找到任何备份
    pause
    goto MENU
)
echo   可用备份:
dir /b "%BACKUP_BASE%" 2>nul
echo.
set /p RESTORE_NAME="  输入备份名称: "
set "RESTORE_PATH=%BACKUP_BASE%\%RESTORE_NAME%"

if not exist "%RESTORE_PATH%" (
    echo   备份不存在
    pause
    goto MENU
)

if exist "%RESTORE_PATH%\portable-state" (
    xcopy "%RESTORE_PATH%\portable-state" "%PORTABLE_STATE_DIR%\" /e /i /q /y >nul 2>&1
    echo   [OK] 便携模式状态已恢复
)
if exist "%RESTORE_PATH%\.env" (
    copy "%RESTORE_PATH%\.env" "%OPENCLAW_DIR%\.env" >nul
    echo   [OK] .env 已恢复
)

echo.
echo   恢复完成!
pause
goto MENU

:RESET
echo.
echo   === 重置 OpenClaw ===
echo.
echo   [1] 仅重置配置（保留凭据）
echo   [2] 重置配置+凭据+会话
echo   [3] 完全重置（恢复出厂）
echo   [0] 取消
echo.
set /p RESET_CHOICE="  选择重置级别: "

if "%RESET_CHOICE%"=="0" goto MENU
if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"

if "%RESET_CHOICE%"=="1" "%NODE_BIN%" openclaw.mjs reset --scope config
if "%RESET_CHOICE%"=="2" "%NODE_BIN%" openclaw.mjs reset --scope config+creds+sessions
if "%RESET_CHOICE%"=="3" (
    set /p CONFIRM="  确定完全重置? 输入 YES 确认: "
    if "!CONFIRM!"=="YES" "%NODE_BIN%" openclaw.mjs reset --scope full
)
pause
goto MENU

:CLEANUP
echo.
echo   === 清理缓存 ===
echo.
call "%NPM_BIN%" cache clean --force 2>nul
echo   npm 缓存已清理
if exist "%PORTABLE_STATE_DIR%\logs" (
    rmdir /s /q "%PORTABLE_STATE_DIR%\logs" 2>nul
    echo   日志已清理
)
echo.
echo   清理完成!
pause
goto MENU

:SKILLS
echo.
echo   === 预装技能 ===
echo.
if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"
"%NODE_BIN%" openclaw.mjs plugins list
pause
goto MENU

:CHINA_GUIDE
echo.
if exist "%UCLAW_DIR%中国用户指南.txt" (
    type "%UCLAW_DIR%中国用户指南.txt"
) else (
    echo   指南文件不存在
)
pause
goto MENU

:README
echo.
if exist "%UCLAW_DIR%使用说明.txt" (
    type "%UCLAW_DIR%使用说明.txt"
) else (
    echo   使用说明文件不存在
)
pause
goto MENU

:SYSINFO
echo.
echo   === 系统信息 ===
echo.
echo   操作系统:    %OS%
echo   处理器:      %PROCESSOR_ARCHITECTURE%
echo   Node.js:     %NODE_VER%
echo   U-Claw 路径: %UCLAW_DIR%
echo   便携配置:    %ST_PORT%
echo.
if exist "%USERPROFILE%\.uclaw" (
    echo   已安装路径: %USERPROFILE%\.uclaw
) else (
    echo   电脑安装:   未安装
)
echo.
pause
goto MENU

:DASHBOARD
echo.
echo   === 启动网关 + 打开网页控制台 ===
echo.
if not exist "%PORTABLE_CONFIG_PATH%" (
    echo   你还没有完成便携配置。请先选 [4] 从 U 盘运行。
    pause
    goto MENU
)
if not exist "%OPENCLAW_DIR%\node_modules" (
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
)
cd /d "%OPENCLAW_DIR%"
echo   此窗口不要关闭，关闭后服务会停止。
echo.
"%NODE_BIN%" openclaw.mjs gateway run --allow-unconfigured --force
pause
goto MENU

:EXIT
echo.
echo   再见!
echo.
exit /b 0
