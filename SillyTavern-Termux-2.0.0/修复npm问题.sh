#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# NPM问题快速修复脚本 - SillyTavern-Termux专版
# 作者：mio酱 💕 专门解决"E: Unable to locate package npm"错误
# =========================================================================

# 彩色输出定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🔧 NPM问题快速修复脚本 - Termux专版"
echo "💕 专门解决npm安装问题，让小白也能轻松搞定"
echo "=================================================="
echo -e "${NC}"

# 检查Termux环境
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    echo -e "${RED}${BOLD}>> ❌ 本脚本仅适用于 Termux 环境！${NC}"
    exit 1
fi

echo -e "${YELLOW}${BOLD}>> 🔍 正在诊断npm问题...${NC}"

# 检查当前状态
echo -e "\n${CYAN}${BOLD}==== 当前状态检查 ====${NC}"

if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}${BOLD}>> ✅ Node.js 已安装，版本: $(node --version)${NC}"
    NODE_OK=true
else
    echo -e "${RED}${BOLD}>> ❌ Node.js 未安装${NC}"
    NODE_OK=false
fi

if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}${BOLD}>> ✅ npm 已安装，版本: $(npm --version)${NC}"
    NPM_OK=true
else
    echo -e "${RED}${BOLD}>> ❌ npm 不可用${NC}"
    NPM_OK=false
fi

# 如果都正常，无需修复
if [ "$NODE_OK" = true ] && [ "$NPM_OK" = true ]; then
    echo -e "\n${GREEN}${BOLD}>> 🎉 Node.js和npm都正常，无需修复！${NC}"
    echo -e "${CYAN}${BOLD}>> 💡 如果仍有问题，可能是其他原因导致的${NC}"
    exit 0
fi

# 开始修复流程
echo -e "\n${YELLOW}${BOLD}>> 🚀 开始修复流程...${NC}"

# 步骤1：更新包管理器
echo -e "\n${CYAN}${BOLD}==== 步骤 1/4：更新包管理器 ====${NC}"
echo -e "${YELLOW}${BOLD}>> 📦 更新Termux包列表...${NC}"

if pkg update; then
    echo -e "${GREEN}${BOLD}>> ✅ 包列表更新成功${NC}"
else
    echo -e "${YELLOW}${BOLD}>> ⚠️ 包列表更新有警告，继续执行...${NC}"
fi

# 步骤2：清理旧安装
echo -e "\n${CYAN}${BOLD}==== 步骤 2/4：清理旧安装 ====${NC}"
echo -e "${YELLOW}${BOLD}>> 🧹 清理可能有问题的Node.js安装...${NC}"

pkg uninstall nodejs nodejs-lts 2>/dev/null || true
echo -e "${GREEN}${BOLD}>> ✅ 清理完成${NC}"

# 步骤3：重新安装Node.js
echo -e "\n${CYAN}${BOLD}==== 步骤 3/4：安装Node.js ====${NC}"
echo -e "${YELLOW}${BOLD}>> 📦 正在安装Node.js（包含npm）...${NC}"
echo -e "${CYAN}${BOLD}>> 💡 重要：在Termux中，npm包含在nodejs包中，无需单独安装！${NC}"

# 尝试安装LTS版本
if pkg list-all | grep -q '^nodejs-lts/'; then
    echo -e "${YELLOW}${BOLD}>> 🔄 尝试安装 nodejs-lts...${NC}"
    if pkg install -y nodejs-lts; then
        echo -e "${GREEN}${BOLD}>> ✅ nodejs-lts 安装成功${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> ⚠️ nodejs-lts 安装失败，尝试普通版本...${NC}"
        if pkg install -y nodejs; then
            echo -e "${GREEN}${BOLD}>> ✅ nodejs 安装成功${NC}"
        else
            echo -e "${RED}${BOLD}>> ❌ Node.js 安装失败！${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}${BOLD}>> 🔄 安装 nodejs...${NC}"
    if pkg install -y nodejs; then
        echo -e "${GREEN}${BOLD}>> ✅ nodejs 安装成功${NC}"
    else
        echo -e "${RED}${BOLD}>> ❌ Node.js 安装失败！${NC}"
        exit 1
    fi
fi

# 步骤4：验证和配置
echo -e "\n${CYAN}${BOLD}==== 步骤 4/4：验证和配置 ====${NC}"

# 验证安装结果
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}${BOLD}>> 🎉 修复成功！${NC}"
    echo -e "${CYAN}${BOLD}>> 📋 Node.js 版本: $(node --version)${NC}"
    echo -e "${CYAN}${BOLD}>> 📋 npm 版本: $(npm --version)${NC}"
    
    # 配置npm
    echo -e "${YELLOW}${BOLD}>> 🔧 配置npm环境...${NC}"
    npm config set prefix "$PREFIX"
    
    # 设置中国镜像源
    echo -e "${YELLOW}${BOLD}>> 🌏 设置npm中国镜像源...${NC}"
    npm config set registry https://registry.npmmirror.com/
    echo -e "${GREEN}${BOLD}>> ✅ 镜像源设置完成${NC}"
    
else
    echo -e "${RED}${BOLD}>> ❌ 修复失败！${NC}"
    echo -e "${YELLOW}${BOLD}>> 💡 建议尝试以下操作：${NC}"
    echo -e "${YELLOW}${BOLD}   1. 重启Termux应用${NC}"
    echo -e "${YELLOW}${BOLD}   2. 检查存储空间是否充足${NC}"
    echo -e "${YELLOW}${BOLD}   3. 运行: pkg clean 清理缓存${NC}"
    exit 1
fi

# 最终测试
echo -e "\n${CYAN}${BOLD}==== 🧪 最终测试 ====${NC}"
echo -e "${YELLOW}${BOLD}>> 测试npm功能...${NC}"

if npm config list >/dev/null 2>&1; then
    echo -e "${GREEN}${BOLD}>> ✅ npm功能正常${NC}"
    echo -e "${CYAN}${BOLD}>> 📋 当前npm配置：${NC}"
    echo -e "${CYAN}>> registry: $(npm config get registry)${NC}"
    echo -e "${CYAN}>> prefix: $(npm config get prefix)${NC}"
else
    echo -e "${YELLOW}${BOLD}>> ⚠️ npm配置可能有问题，但基本功能可用${NC}"
fi

echo -e "\n${GREEN}${BOLD}"
echo "🎉🎉🎉 NPM问题修复完成！🎉🎉🎉"
echo "✨ 现在可以正常使用npm安装包了"
echo "💕 如果还有问题，请查看NPM_安装问题解决方案.md"
echo "=================================================="
echo -e "${NC}"

echo -e "${CYAN}${BOLD}>> 💡 接下来可以继续运行SillyTavern安装脚本了~${NC}"
