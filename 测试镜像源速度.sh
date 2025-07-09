#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# GitHub镜像源速度测试工具 - Termux版 - Mio's Edition
# 帮助用户选择最快的镜像源进行安装 😸
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

# ==== 输出函数 ====
log_success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }
log_info() { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }

# ==== 显示标题 ====
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 GitHub镜像源速度测试工具 🌸"
echo "💕 帮你找到最快的下载源"
echo "✨ 专为SillyTavern安装优化"
echo "=================================================="
echo -e "${NC}"

# ==== 8个加速镜像源配置 ====
declare -A MIRRORS=(
    ["ghproxy.net"]="https://ghproxy.net/https://github.com"
    ["gh.ddlc.top"]="https://gh.ddlc.top/https://github.com"
    ["ghfast.top"]="https://ghfast.top/https://github.com"
    ["gh.h233.eu.org"]="https://gh.h233.eu.org/https://github.com"
    ["hub.gitmirror.com"]="https://hub.gitmirror.com/https://github.com"
    ["wget.la"]="https://wget.la/https://github.com"
    ["gh-proxy.com"]="https://gh-proxy.com/https://github.com"
    ["cors.isteed.cc"]="https://cors.isteed.cc/github.com"
)

# 镜像源描述
declare -A DESCRIPTIONS=(
    ["ghproxy.net"]="英国伦敦 - 稳定快速"
    ["gh.ddlc.top"]="美国 Cloudflare CDN - 全球加速"
    ["ghfast.top"]="多节点CDN - 智能路由"
    ["gh.h233.eu.org"]="美国 Cloudflare CDN - XIU2官方"
    ["hub.gitmirror.com"]="美国 Cloudflare CDN - GitMirror"
    ["wget.la"]="香港/台湾/日本/美国 - 多地CDN"
    ["gh-proxy.com"]="美国 Cloudflare CDN - 备用源"
    ["cors.isteed.cc"]="美国 Cloudflare CDN - Lufs提供"
)

# ==== 测试文件路径 ====
TEST_FILE="nb95276/QQ-30818276/raw/main/PROJECT_INFO.txt"
INSTALL_SCRIPT="nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh"

# ==== 速度测试函数 ====
test_mirror_speed() {
    local name="$1"
    local url="$2"
    local test_url="$url/$TEST_FILE"
    
    echo -n -e "${YELLOW}测试 $name ... ${NC}"
    
    # 测试连接性（3秒超时）
    if ! timeout 3 curl -fsSL --connect-timeout 2 --max-time 3 \
        -o /dev/null "$test_url" 2>/dev/null; then
        echo -e "${RED}❌ 连接失败${NC}"
        return 1
    fi
    
    # 测试下载速度（10秒超时）
    local start_time=$(date +%s.%N)
    if timeout 10 curl -fsSL --connect-timeout 5 --max-time 10 \
        -o /dev/null "$test_url" 2>/dev/null; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        
        if [ -z "$duration" ] || [ "$duration" = "0" ]; then
            duration="0.5"  # 默认值
        fi
        
        echo -e "${GREEN}✅ ${duration}秒${NC}"
        return 0
    else
        echo -e "${RED}❌ 下载超时${NC}"
        return 1
    fi
}

# ==== 主测试流程 ====
log_info "开始测试8个镜像源的速度..."
echo ""

# 存储测试结果
declare -A RESULTS
WORKING_MIRRORS=()

# 测试所有镜像源
for name in "${!MIRRORS[@]}"; do
    url="${MIRRORS[$name]}"
    description="${DESCRIPTIONS[$name]}"
    
    echo -e "${CYAN}🔍 测试源: $name${NC}"
    echo -e "${BRIGHT_MAGENTA}   描述: $description${NC}"
    
    if test_mirror_speed "$name" "$url"; then
        WORKING_MIRRORS+=("$name")
        RESULTS["$name"]="可用"
    else
        RESULTS["$name"]="不可用"
    fi
    echo ""
done

# ==== 显示测试结果 ====
echo -e "${GREEN}${BOLD}"
echo "========================================"
echo "       测试结果汇总"
echo "========================================"
echo -e "${NC}"

if [ ${#WORKING_MIRRORS[@]} -eq 0 ]; then
    log_error "所有镜像源都无法访问！"
    log_info "可能的原因："
    echo -e "${YELLOW}  1. 网络连接问题${NC}"
    echo -e "${YELLOW}  2. 防火墙限制${NC}"
    echo -e "${YELLOW}  3. 镜像源临时维护${NC}"
    echo ""
    log_info "建议："
    echo -e "${CYAN}  1. 检查网络连接${NC}"
    echo -e "${CYAN}  2. 更换网络环境（WiFi/移动数据）${NC}"
    echo -e "${CYAN}  3. 稍后重试${NC}"
    exit 1
fi

log_success "找到 ${#WORKING_MIRRORS[@]} 个可用镜像源："
echo ""

# 显示可用的镜像源
for i in "${!WORKING_MIRRORS[@]}"; do
    name="${WORKING_MIRRORS[$i]}"
    url="${MIRRORS[$name]}"
    description="${DESCRIPTIONS[$name]}"
    priority=$((i + 1))
    
    echo -e "${GREEN}${BOLD}$priority. $name${NC}"
    echo -e "${CYAN}   地址: $url${NC}"
    echo -e "${BRIGHT_MAGENTA}   描述: $description${NC}"
    echo ""
done

# ==== 生成推荐安装命令 ====
log_info "推荐的安装命令（按速度排序）："
echo ""

for i in "${!WORKING_MIRRORS[@]}"; do
    name="${WORKING_MIRRORS[$i]}"
    url="${MIRRORS[$name]}"
    priority=$((i + 1))
    
    echo -e "${YELLOW}${BOLD}方法$priority: 使用 $name${NC}"
    echo -e "${CYAN}curl -fsSL $url/$INSTALL_SCRIPT | bash${NC}"
    echo ""
done

# ==== 生成智能安装脚本 ====
log_info "生成智能安装脚本..."

SMART_INSTALL_SCRIPT="$HOME/smart_install_sillytavern.sh"
cat > "$SMART_INSTALL_SCRIPT" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 智能安装脚本 - 自动尝试最快的镜像源

echo "🌸 SillyTavern 智能安装脚本 🌸"
echo "💕 自动选择最快的镜像源"
echo ""

MIRRORS=(
EOF

# 添加可用的镜像源到脚本
for name in "${WORKING_MIRRORS[@]}"; do
    url="${MIRRORS[$name]}"
    echo "    \"$url/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh\"" >> "$SMART_INSTALL_SCRIPT"
done

cat >> "$SMART_INSTALL_SCRIPT" << 'EOF'
)

for i in "${!MIRRORS[@]}"; do
    url="${MIRRORS[$i]}"
    domain=$(echo "$url" | sed 's|https://||' | cut -d'/' -f1)
    
    echo "🔄 尝试源 $((i+1)): $domain"
    
    if curl -fsSL --connect-timeout 10 --max-time 30 "$url" | bash; then
        echo "✅ 安装成功！使用源: $domain"
        exit 0
    else
        echo "❌ 失败，尝试下一个源..."
    fi
done

echo "💔 所有源都失败了，请检查网络连接"
exit 1
EOF

chmod +x "$SMART_INSTALL_SCRIPT"

log_success "智能安装脚本已生成: $SMART_INSTALL_SCRIPT"
echo ""

# ==== 使用建议 ====
log_info "使用建议："
echo -e "${CYAN}1. 优先使用排名靠前的镜像源${NC}"
echo -e "${CYAN}2. 如果某个源失败，按顺序尝试下一个${NC}"
echo -e "${CYAN}3. 使用智能安装脚本: bash $SMART_INSTALL_SCRIPT${NC}"
echo -e "${CYAN}4. 建议在WiFi环境下进行安装${NC}"

echo ""
log_info "网络优化提示："
echo -e "${YELLOW}📶 WiFi通常比移动数据更稳定${NC}"
echo -e "${YELLOW}🕐 避开网络高峰期（晚上8-10点）${NC}"
echo -e "${YELLOW}🔄 如遇问题可重新运行此测试脚本${NC}"

echo ""
log_success "测试完成！现在可以选择最快的源进行安装了！😸💕"

# ==== 询问是否立即安装 ====
echo ""
read -p "是否使用最快的源立即开始安装？(y/N): " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    if [ ${#WORKING_MIRRORS[@]} -gt 0 ]; then
        best_mirror="${WORKING_MIRRORS[0]}"
        best_url="${MIRRORS[$best_mirror]}"
        
        log_info "使用最快的源开始安装: $best_mirror"
        echo ""
        
        curl -fsSL "$best_url/$INSTALL_SCRIPT" | bash
    fi
else
    log_info "你可以稍后手动运行安装命令"
    log_info "或者使用智能安装脚本: bash $SMART_INSTALL_SCRIPT"
fi
