#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 简化修复版安装脚本
# 专门解决语法错误问题 - Mio's Fixed Edition 😸
# =========================================================================

set -e  # 遇到错误立即退出

# 彩色输出定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 清屏并显示标题
clear
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 SillyTavern-Termux 简化修复版 🌸"
echo "💕 专门解决语法错误问题"
echo "✨ 宝子专用 - 稳定可靠！"
echo "=================================================="
echo -e "${NC}"

# 检查Termux环境
if [ ! -d "/data/data/com.termux" ]; then
    log_error "请在Termux环境中运行此脚本"
    exit 1
fi

# 设置工作目录
cd "$HOME"

# 步骤1：更新包管理器
log_info "步骤1: 更新包管理器..."
echo ""

# 简单设置中国镜像源
log_info "配置中国镜像源..."
mkdir -p "$PREFIX/etc/apt"

# 使用清华镜像源（最稳定）
cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main
EOF

log_success "镜像源配置完成"

# 清除缓存并更新
rm -rf "$PREFIX/var/lib/apt/lists/"* 2>/dev/null || true
apt clean 2>/dev/null || true

log_info "更新包列表..."
if ! pkg update; then
    log_warning "更新失败，尝试使用阿里云镜像源..."
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
deb https://mirrors.aliyun.com/termux/apt/termux-main stable main
EOF
    pkg update
fi

log_success "包管理器更新完成"

# 步骤2：安装必要工具
log_info "步骤2: 安装必要工具..."
echo ""

pkg install -y curl wget git nodejs npm python

log_success "必要工具安装完成"

# 步骤3：下载SillyTavern
log_info "步骤3: 下载SillyTavern..."
echo ""

# 删除旧版本
rm -rf SillyTavern 2>/dev/null || true

# GitHub镜像源列表
GITHUB_MIRRORS=(
    "https://ghfast.top"
    "https://ghproxy.net"
    "https://gh.ddlc.top"
    "https://hub.gitmirror.com"
)

# 尝试从镜像源下载
download_success=false
for mirror in "${GITHUB_MIRRORS[@]}"; do
    log_info "尝试从 $mirror 下载..."
    
    if timeout 30 git clone "$mirror/https://github.com/SillyTavern/SillyTavern.git"; then
        download_success=true
        log_success "下载成功！来源: $mirror"
        break
    else
        log_warning "从 $mirror 下载失败，尝试下一个..."
    fi
done

if [ "$download_success" = false ]; then
    log_error "所有镜像源都下载失败"
    exit 1
fi

# 步骤4：安装依赖
log_info "步骤4: 安装SillyTavern依赖..."
echo ""

cd SillyTavern

# 设置npm中国镜像源
npm config set registry https://registry.npmmirror.com
npm config set disturl https://npmmirror.com/dist
npm config set electron_mirror https://npmmirror.com/mirrors/electron/
npm config set electron_builder_binaries_mirror https://npmmirror.com/mirrors/electron-builder-binaries/

log_info "正在安装依赖包..."
if ! npm install; then
    log_warning "npm install失败，尝试清除缓存重试..."
    npm cache clean --force
    npm install
fi

log_success "依赖安装完成"

# 步骤5：创建启动脚本
log_info "步骤5: 创建启动脚本..."
echo ""

cat > "$HOME/start_sillytavern.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd "$HOME/SillyTavern"
echo "🌸 正在启动SillyTavern..."
echo "📱 启动后请在浏览器中访问: http://localhost:8000"
echo "💕 按 Ctrl+C 可以停止服务"
echo ""
node server.js
EOF

chmod +x "$HOME/start_sillytavern.sh"

log_success "启动脚本创建完成"

# 完成安装
echo ""
echo -e "${GREEN}${BOLD}"
echo "=================================================="
echo "🎉 SillyTavern 安装完成！"
echo "=================================================="
echo -e "${NC}"

echo -e "${CYAN}📱 启动方法:${NC}"
echo -e "${YELLOW}  bash ~/start_sillytavern.sh${NC}"
echo ""
echo -e "${CYAN}📱 或者手动启动:${NC}"
echo -e "${YELLOW}  cd ~/SillyTavern && node server.js${NC}"
echo ""
echo -e "${CYAN}🌐 访问地址:${NC}"
echo -e "${YELLOW}  http://localhost:8000${NC}"
echo ""

# 询问是否立即启动
echo -ne "${CYAN}${BOLD}🚀 是否立即启动SillyTavern？(Y/n): ${NC}"
read -t 10 -n1 start_choice 2>/dev/null || start_choice="y"
echo

if [[ "$start_choice" =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}💡 稍后可以运行以下命令启动:${NC}"
    echo -e "${CYAN}  bash ~/start_sillytavern.sh${NC}"
else
    echo -e "${GREEN}🚀 正在启动SillyTavern...${NC}"
    echo ""
    cd "$HOME/SillyTavern"
    node server.js
fi
