#!/bin/bash
# ============================================================
# U-Claw 虾盘 - Linux 一键启动
# 用法: bash ./运行.sh
# ============================================================

set -e

UCLAW_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW_DIR="$UCLAW_DIR/openclaw"
NODE_DIR="$UCLAW_DIR/runtime/node-linux-x64"
NODE_BIN="$NODE_DIR/bin/node"
NPM_BIN="$NODE_DIR/bin/npm"
PNPM_BIN="$NODE_DIR/bin/pnpm"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     U-Claw 虾盘 v1.0                ║"
echo "  ║     OpenClaw Linux 启动              ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

if [ ! -x "$NODE_BIN" ]; then
    echo -e "  ${RED}错误: 找不到 Linux Node.js 运行环境${NC}"
    echo "  请确保 runtime/node-linux-x64 目录完整"
    exit 1
fi

export PATH="$NODE_DIR/bin:$PATH"

ensure_pnpm() {
    if [ -x "$PNPM_BIN" ]; then
        return 0
    fi

    echo -e "  ${YELLOW}缺少 pnpm，正在补充安装...${NC}"
    "$NPM_BIN" install -g pnpm --registry=https://registry.npmmirror.com

    if [ ! -x "$PNPM_BIN" ]; then
        echo -e "  ${RED}错误: pnpm 安装失败，无法继续构建${NC}"
        exit 1
    fi
}

echo -e "  Node.js 版本: ${GREEN}$("$NODE_BIN" --version)${NC}"
echo ""

if [ ! -d "$OPENCLAW_DIR/node_modules" ]; then
    echo -e "  ${YELLOW}首次运行，正在安装依赖...${NC}"
    cd "$OPENCLAW_DIR"
    "$NPM_BIN" install --registry=https://registry.npmmirror.com
    echo ""
fi

if [ ! -d "$OPENCLAW_DIR/dist" ]; then
    echo -e "  ${YELLOW}首次运行，正在构建...${NC}"
    cd "$OPENCLAW_DIR"
    ensure_pnpm
    "$PNPM_BIN" run build
    if [ ! -d "$OPENCLAW_DIR/dist" ]; then
        echo -e "  ${RED}构建失败，请检查错误信息${NC}"
        exit 1
    fi
    echo ""
fi

cd "$OPENCLAW_DIR"

if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
    echo -e "  ${YELLOW}首次配置...${NC}"
    "$NODE_BIN" openclaw.mjs onboard --install-daemon
fi

echo -e "  ${CYAN}启动 OpenClaw 服务...${NC}"
"$NODE_BIN" openclaw.mjs || "$NPM_BIN" start
