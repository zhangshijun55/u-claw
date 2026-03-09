#!/bin/bash
# ============================================================
# U-Claw 虾盘 - macOS 安装到电脑
# 将 OpenClaw 及运行环境永久安装到电脑上
# ============================================================

set -euo pipefail

UCLAW_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.uclaw"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

run_with_spinner() {
    local message="$1"
    shift
    local tmp_log
    tmp_log="$(mktemp -t uclaw-install.XXXXXX)"
    "$@" >"$tmp_log" 2>&1 &
    local cmd_pid=$!
    local frames='|/-\'
    local i=0

    while kill -0 "$cmd_pid" 2>/dev/null; do
        local frame="${frames:i%4:1}"
        printf "\r  %b[%s]%b %s" "$CYAN" "$frame" "$NC" "$message"
        i=$((i + 1))
        sleep 0.2
    done

    wait "$cmd_pid"
    local status=$?
    printf "\r"

    if [ $status -ne 0 ]; then
        echo -e "  ${RED}安装步骤失败：${message}${NC}"
        sed -n '1,120p' "$tmp_log"
        rm -f "$tmp_log"
        exit $status
    fi

    echo -e "  ${GREEN}完成${NC} ${message}"
    rm -f "$tmp_log"
}

copy_tree_quiet() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    (
        export COPYFILE_DISABLE=1
        cd "$src"
        tar --exclude='.DS_Store' --exclude='._*' -cf - .
    ) | (
        cd "$dst"
        tar -xpf -
    )
}

clear
echo ""
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     U-Claw 安装到电脑               ║"
echo "  ║     OpenClaw 永久安装                ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "  安装位置: $INSTALL_DIR"
echo "  安装内容: Node.js + OpenClaw + 所有依赖"
echo ""
echo -e "  ${YELLOW}安全提醒: 这会把 OpenClaw 和配置写入当前电脑。${NC}"
echo -e "  ${YELLOW}如果这是老电脑、共享电脑、公司电脑或临时机器，${NC}"
echo -e "  ${YELLOW}更推荐回到主菜单选择「直接从 U 盘运行」。${NC}"
echo ""
read -p "  是否继续安装? (y/n) " -n 1 -r
echo ""
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  已取消安装"
    exit 0
fi

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    NODE_SRC="$UCLAW_DIR/runtime/node-mac-arm64"
    echo -e "  ${GREEN}Apple Silicon (M系列)${NC}"
else
    NODE_SRC="$UCLAW_DIR/runtime/node-mac-x64"
    echo -e "  ${GREEN}Intel Mac${NC}"
fi

echo -e "  ${CYAN}[1/4] 创建安装目录...${NC}"
mkdir -p "$INSTALL_DIR"

echo -e "  ${CYAN}[2/4] 安装 Node.js 运行环境...${NC}"
rm -rf "$INSTALL_DIR/node"
mkdir -p "$INSTALL_DIR/node"
run_with_spinner "复制 Node.js 运行环境..." copy_tree_quiet "$NODE_SRC" "$INSTALL_DIR/node"
if [ ! -x "$INSTALL_DIR/node/bin/node" ]; then
    echo -e "  ${RED}Node.js 安装失败：$INSTALL_DIR/node/bin/node 不存在${NC}"
    echo -e "  ${YELLOW}请先确认 U 盘复制完成，再重新运行安装。${NC}"
    exit 1
fi
NODE_VERSION_INSTALLED="$("$INSTALL_DIR/node/bin/node" --version)"
echo -e "  ${GREEN}Node.js ${NODE_VERSION_INSTALLED} 已安装${NC}"

echo -e "  ${CYAN}[3/4] 安装 OpenClaw...${NC}"
echo -e "  ${YELLOW}这一步会复制约 861M 文件，首次安装通常需要 3-10 分钟，请耐心等待...${NC}"
if [ -d "$INSTALL_DIR/openclaw" ] && [ -f "$INSTALL_DIR/openclaw/.env" ]; then
    cp "$INSTALL_DIR/openclaw/.env" "/tmp/.uclaw-env-backup" 2>/dev/null || true
fi
rm -rf "$INSTALL_DIR/openclaw"
mkdir -p "$INSTALL_DIR/openclaw"
run_with_spinner "复制 OpenClaw 主程序和依赖..." copy_tree_quiet "$UCLAW_DIR/openclaw" "$INSTALL_DIR/openclaw"
if [ -f "/tmp/.uclaw-env-backup" ]; then
    cp "/tmp/.uclaw-env-backup" "$INSTALL_DIR/openclaw/.env"
    rm -f "/tmp/.uclaw-env-backup"
fi

# 复制用户数据
[ -d "$UCLAW_DIR/memory" ] && [ "$(ls -A "$UCLAW_DIR/memory" 2>/dev/null)" ] && cp -R "$UCLAW_DIR/memory" "$INSTALL_DIR/"
[ -d "$UCLAW_DIR/persona" ] && [ "$(ls -A "$UCLAW_DIR/persona" 2>/dev/null)" ] && cp -R "$UCLAW_DIR/persona" "$INSTALL_DIR/"

echo -e "  ${CYAN}[4/4] 配置环境变量...${NC}"

SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bash_profile"

if ! grep -q ".uclaw/node/bin" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# U-Claw OpenClaw" >> "$SHELL_RC"
    echo 'export PATH="$HOME/.uclaw/node/bin:$PATH"' >> "$SHELL_RC"
    echo "alias openclaw='\$HOME/.uclaw/node/bin/node \$HOME/.uclaw/openclaw/openclaw.mjs'" >> "$SHELL_RC"
    echo -e "  ${GREEN}已添加到 $SHELL_RC${NC}"
else
    echo -e "  ${YELLOW}PATH 已配置，跳过${NC}"
fi

# 创建全局命令
cat > "$INSTALL_DIR/uclaw" << 'SCRIPT'
#!/bin/bash
UCLAW_HOME="$HOME/.uclaw"
exec "$UCLAW_HOME/node/bin/node" "$UCLAW_HOME/openclaw/openclaw.mjs" "$@"
SCRIPT
chmod +x "$INSTALL_DIR/uclaw"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
ln -sf "$INSTALL_DIR/uclaw" "$LOCAL_BIN/uclaw"
ln -sf "$INSTALL_DIR/uclaw" "$LOCAL_BIN/openclaw"

if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    ln -sf "$INSTALL_DIR/uclaw" /usr/local/bin/uclaw 2>/dev/null || true
    ln -sf "$INSTALL_DIR/uclaw" /usr/local/bin/openclaw 2>/dev/null || true
    echo -e "  ${GREEN}已创建全局命令: uclaw / openclaw${NC}"
else
    echo -e "  ${GREEN}已创建用户命令: $LOCAL_BIN/uclaw / $LOCAL_BIN/openclaw${NC}"
    echo -e "  ${YELLOW}如需系统级命令，可运行 sudo ln -sf $INSTALL_DIR/uclaw /usr/local/bin/uclaw${NC}"
fi

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║     安装完成!                        ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "  安装位置: $INSTALL_DIR"
echo "  Node.js:  ${NODE_VERSION_INSTALLED}"
echo ""
echo "  使用方法:"
echo "    1. 打开新的终端窗口"
echo "    2. 运行: openclaw onboard --install-daemon"
echo "    3. 配置完成后运行: openclaw dashboard"
echo ""
echo "  小白用户推荐："
echo "    先按引导完成首次配置，再打开网页控制台"
echo ""
read -p "  按回车键关闭..."
