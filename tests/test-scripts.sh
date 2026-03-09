#!/bin/bash
# ============================================================
# U-Claw 脚本测试套件
# 验证 Windows .bat 和 macOS .command 脚本的正确性
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UCLAW_SCRIPTS="$SCRIPT_DIR/uclaw-scripts"

PASS=0
FAIL=0
TOTAL=0

pass() {
    PASS=$((PASS + 1))
    TOTAL=$((TOTAL + 1))
    echo "  ✓ $1"
}

fail() {
    FAIL=$((FAIL + 1))
    TOTAL=$((TOTAL + 1))
    echo "  ✗ $1"
}

check() {
    local desc="$1"
    local file="$2"
    local pattern="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        pass "$desc"
    else
        fail "$desc"
    fi
}

check_not() {
    local desc="$1"
    local file="$2"
    local pattern="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        fail "$desc"
    else
        pass "$desc"
    fi
}

echo ""
echo "=========================================="
echo "  U-Claw 脚本测试套件"
echo "=========================================="

# ── 文件存在性测试 ──
echo ""
echo "── 文件存在性 ──"

for f in "Windows-从U盘启动.bat" "Mac-从U盘启动.command" "Windows-全部功能.bat" "Mac-全部功能.command" "Windows-安装到电脑.bat" "Mac-安装到电脑.command" "使用说明.txt" "中国用户指南.txt"; do
    if [ -f "$UCLAW_SCRIPTS/$f" ]; then
        pass "存在: $f"
    else
        fail "缺失: $f"
    fi
done

# ── macOS .command 语法检查 ──
echo ""
echo "── macOS 脚本语法检查 ──"

for f in "Mac-从U盘启动.command" "Mac-全部功能.command" "Mac-安装到电脑.command"; do
    if bash -n "$UCLAW_SCRIPTS/$f" 2>/dev/null; then
        pass "语法正确: $f"
    else
        fail "语法错误: $f"
    fi
done

# ── 运行.bat 测试 ──
echo ""
echo "── 运行.bat ──"
BAT_RUN="$UCLAW_SCRIPTS/Windows-从U盘启动.bat"

check "设置 UTF-8 编码" "$BAT_RUN" "chcp 65001"
check "设置便携模式 OPENCLAW_HOME" "$BAT_RUN" "OPENCLAW_HOME"
check "设置便携模式 OPENCLAW_STATE_DIR" "$BAT_RUN" "OPENCLAW_STATE_DIR"
check "设置便携模式 OPENCLAW_CONFIG_PATH" "$BAT_RUN" "OPENCLAW_CONFIG_PATH"
check "使用 gateway run" "$BAT_RUN" "gateway run"
check "使用 --allow-unconfigured" "$BAT_RUN" "\-\-allow-unconfigured"
check "使用 --force" "$BAT_RUN" "\-\-force"
check "首次用户走 onboard" "$BAT_RUN" "onboard"
check "检查 Node.js 存在" "$BAT_RUN" "NODE_BIN"
check_not "不依赖 pnpm" "$BAT_RUN" "pnpm"
check "版本号 v1.1" "$BAT_RUN" "v1.1"

# ── 运行.command 测试 ──
echo ""
echo "── 运行.command ──"
CMD_RUN="$UCLAW_SCRIPTS/Mac-从U盘启动.command"

check "设置便携模式 OPENCLAW_HOME" "$CMD_RUN" "OPENCLAW_HOME"
check "设置便携模式 OPENCLAW_STATE_DIR" "$CMD_RUN" "OPENCLAW_STATE_DIR"
check "设置便携模式 OPENCLAW_CONFIG_PATH" "$CMD_RUN" "OPENCLAW_CONFIG_PATH"
check "使用 gateway run" "$CMD_RUN" "gateway run"
check "使用 --allow-unconfigured" "$CMD_RUN" "\-\-allow-unconfigured"
check "使用 --force" "$CMD_RUN" "\-\-force"
check "首次用户走 onboard" "$CMD_RUN" "onboard"
check "自动打开浏览器" "$CMD_RUN" 'open "$URL"'
check "检测 CPU 架构" "$CMD_RUN" "uname -m"
check "支持 arm64" "$CMD_RUN" "arm64"
check_not "不依赖 pnpm" "$CMD_RUN" "pnpm"

# ── 启动菜单.bat 测试 ──
echo ""
echo "── 启动菜单.bat ──"
BAT_MENU="$UCLAW_SCRIPTS/Windows-全部功能.bat"

check "设置 UTF-8 编码" "$BAT_MENU" "chcp 65001"
check "便携模式 OPENCLAW_HOME" "$BAT_MENU" "OPENCLAW_HOME"
check "有 QQ Bot 选项" "$BAT_MENU" "QQ Bot"
check "QQ AppID 单独输入" "$BAT_MENU" "AppID"
check "QQ AppSecret 单独输入" "$BAT_MENU" "AppSecret"
check "DeepSeek 模型提示" "$BAT_MENU" "deepseek"
check "Custom Provider 提示" "$BAT_MENU" "Custom Provider"
check "有控制台入口" "$BAT_MENU" "控制台"
check "gateway run 命令" "$BAT_MENU" "gateway run"
check "版本号 v1.1" "$BAT_MENU" "v1.1"
check_not "不依赖 pnpm" "$BAT_MENU" "pnpm"

# ── 启动菜单.command 测试 ──
echo ""
echo "── 启动菜单.command ──"
CMD_MENU="$UCLAW_SCRIPTS/Mac-全部功能.command"

check "便携模式 OPENCLAW_HOME" "$CMD_MENU" "OPENCLAW_HOME"
check "有 QQ 选项" "$CMD_MENU" "QQ"
check "QQ AppID 单独输入" "$CMD_MENU" "AppID"
check "QQ AppSecret 单独输入" "$CMD_MENU" "AppSecret"
check "DeepSeek 模型提示" "$CMD_MENU" "deepseek"
check "Custom Provider 提示" "$CMD_MENU" "Custom Provider"
check "有 dashboard 入口" "$CMD_MENU" "dashboard"
check "gateway run 命令" "$CMD_MENU" "gateway run"
check "自动打开浏览器" "$CMD_MENU" 'open "$URL"'

# ── 安装到电脑.bat 测试 ──
echo ""
echo "── 安装到电脑.bat ──"
BAT_INSTALL="$UCLAW_SCRIPTS/Windows-安装到电脑.bat"

check "设置 UTF-8 编码" "$BAT_INSTALL" "chcp 65001"
check "安全提醒" "$BAT_INSTALL" "安全提醒"
check "共享电脑警告" "$BAT_INSTALL" "共享电脑"
check "安装到 .uclaw" "$BAT_INSTALL" "\.uclaw"
check "创建 uclaw.cmd" "$BAT_INSTALL" "uclaw.cmd"
check "创建 openclaw.cmd" "$BAT_INSTALL" "openclaw.cmd"
check "添加到 PATH" "$BAT_INSTALL" "setx PATH"
check "PATH 长度检查" "$BAT_INSTALL" "1024"
check "Node.js 安装检查" "$BAT_INSTALL" "node.exe"
check "版本号 v1.1" "$BAT_INSTALL" "v1.1"
check_not "不备份 .env" "$BAT_INSTALL" "env-backup"

# ── 安装到电脑.command 测试 ──
echo ""
echo "── 安装到电脑.command ──"
CMD_INSTALL="$UCLAW_SCRIPTS/Mac-安装到电脑.command"

check "安全提醒" "$CMD_INSTALL" "安全提醒"
check "共享电脑警告" "$CMD_INSTALL" "共享电脑"
check "安装到 .uclaw" "$CMD_INSTALL" "\.uclaw"
check "检测 CPU 架构" "$CMD_INSTALL" "uname -m"
check "支持 arm64" "$CMD_INSTALL" "arm64"
check "创建 symlink" "$CMD_INSTALL" "ln -sf"
check "添加到 shell RC" "$CMD_INSTALL" "zshrc"
check "spinner 动画" "$CMD_INSTALL" "run_with_spinner"
check "set -euo pipefail" "$CMD_INSTALL" "set -euo pipefail"

# ── 安全检查（无敏感信息泄露）──
echo ""
echo "── 安全检查 ──"

for f in "$UCLAW_SCRIPTS"/*.bat "$UCLAW_SCRIPTS"/*.command "$UCLAW_SCRIPTS"/*.txt; do
    fname=$(basename "$f")
    check_not "无 API Key: $fname" "$f" "sk-[a-zA-Z0-9]\{20,\}"
    check_not "无硬编码密码: $fname" "$f" "password.*=.*['\"][^'\"]\{8,\}"
done

# ── Windows/Mac 一致性检查 ──
echo ""
echo "── 跨平台一致性 ──"

# 两边都有 gateway run
if grep -q "gateway run" "$BAT_RUN" && grep -q "gateway run" "$CMD_RUN"; then
    pass "运行脚本：两端都用 gateway run"
else
    fail "运行脚本：gateway run 不一致"
fi

# 两边都有 onboard
if grep -q "onboard" "$BAT_RUN" && grep -q "onboard" "$CMD_RUN"; then
    pass "运行脚本：两端都有 onboard 流程"
else
    fail "运行脚本：onboard 流程不一致"
fi

# 两边菜单都有 QQ
if grep -q "QQ" "$BAT_MENU" && grep -q "QQ" "$CMD_MENU"; then
    pass "启动菜单：两端都有 QQ 接入"
else
    fail "启动菜单：QQ 接入不一致"
fi

# 两边安装都有安全提醒
if grep -q "安全提醒" "$BAT_INSTALL" && grep -q "安全提醒" "$CMD_INSTALL"; then
    pass "安装脚本：两端都有安全提醒"
else
    fail "安装脚本：安全提醒不一致"
fi

# ── 结果汇总 ──
echo ""
echo "=========================================="
if [ $FAIL -eq 0 ]; then
    echo "  全部通过! $PASS/$TOTAL"
else
    echo "  失败 $FAIL 项 / 共 $TOTAL 项"
fi
echo "=========================================="
echo ""

exit $FAIL
