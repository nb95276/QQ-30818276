#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 一键更新GitHub镜像源 - Termux版 - Mio's Edition
# 自动获取最新镜像源并应用到所有相关脚本 😸
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

# ==== 进度显示函数 ====
show_progress() {
    local step=$1
    local total=$2
    local message=$3
    local percent=$((step * 100 / total))
    local filled=$((percent / 10))
    local empty=$((10 - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo -e "${BRIGHT_MAGENTA}${BOLD}🌸 更新进度：[${bar}] ${percent}%${NC}"
    echo -e "${CYAN}${BOLD}💕 ${message}${NC}"
    echo ""
}

# ==== 显示标题 ====
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 一键更新GitHub镜像源 - Termux版 🌸"
echo "💕 专为小红书姐妹们优化的自动更新工具"
echo "✨ 让SillyTavern安装和更新更快更稳定"
echo "=================================================="
echo -e "${NC}"

# ==== 环境检测 ====
show_progress 1 4 "正在检查Termux环境..."
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    log_error "本脚本仅适用于 Termux 环境，请在 Termux 中运行！"
    exit 1
fi
log_success "Termux环境检测通过"

# ==== 检查必要工具 ====
log_info "检查必要工具..."
missing_tools=()
for tool in curl grep sed awk; do
    if ! command -v $tool >/dev/null 2>&1; then
        missing_tools+=($tool)
    fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
    log_warning "缺少必要工具: ${missing_tools[*]}"
    log_info "正在自动安装..."
    pkg update && pkg install -y "${missing_tools[@]}"
    
    # 再次检查
    for tool in "${missing_tools[@]}"; do
        if ! command -v $tool >/dev/null 2>&1; then
            log_error "工具安装失败: $tool"
            exit 1
        fi
    done
    log_success "必要工具安装完成"
else
    log_success "必要工具检查完成"
fi

# ==== 步骤1：获取最新镜像源 ====
show_progress 2 4 "正在从XIU2官方源获取最新镜像源..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/Update_Mirror_Sources_Termux.sh"

if [ ! -f "$UPDATE_SCRIPT" ]; then
    log_error "未找到更新脚本: $UPDATE_SCRIPT"
    log_info "请确保所有脚本文件都在同一目录中"
    exit 1
fi

log_info "运行镜像源更新脚本..."
if bash "$UPDATE_SCRIPT"; then
    log_success "镜像源获取成功"
else
    log_error "镜像源获取失败"
    exit 1
fi

# ==== 步骤2：应用到现有脚本 ====
show_progress 3 4 "正在将新镜像源应用到所有安装脚本..."

APPLY_SCRIPT="$SCRIPT_DIR/Apply_Mirror_Updates.sh"

if [ ! -f "$APPLY_SCRIPT" ]; then
    log_error "未找到应用脚本: $APPLY_SCRIPT"
    exit 1
fi

log_info "运行镜像源应用脚本..."
if bash "$APPLY_SCRIPT"; then
    log_success "镜像源应用成功"
else
    log_error "镜像源应用失败"
    exit 1
fi

# ==== 步骤3：验证更新结果 ====
show_progress 4 4 "正在验证更新结果..."

CONFIG_FILE="$HOME/github_mirrors_termux.json"
if [ -f "$CONFIG_FILE" ]; then
    MIRROR_COUNT=$(grep -c '"url":' "$CONFIG_FILE")
    LAST_UPDATED=$(grep '"last_updated":' "$CONFIG_FILE" | sed 's/.*"last_updated": *"\([^"]*\)".*/\1/')
    log_success "配置文件验证通过"
    log_info "镜像源数量: $MIRROR_COUNT 个"
    log_info "最后更新: $LAST_UPDATED"
else
    log_error "配置文件验证失败"
    exit 1
fi

# ==== 显示更新完成信息 ====
echo ""
echo -e "${GREEN}${BOLD}"
echo "🎉🎉🎉 镜像源更新完成！🎉🎉🎉"
echo "✨ 所有脚本现在都使用最新最快的镜像源"
echo "💕 SillyTavern安装和更新速度将大幅提升"
echo "🌸 感谢使用Mio的一键更新工具"
echo "=================================================="
echo -e "${NC}"

# ==== 显示推荐的镜像源 ====
log_info "当前使用的推荐镜像源（前5个）:"
grep -A 20 '"clone_url":' "$CONFIG_FILE" | grep '"url":' | head -5 | while read -r line; do
    url=$(echo "$line" | sed 's/.*"url": *"\([^"]*\)".*/\1/')
    domain=$(echo "$url" | sed 's|https://||' | cut -d'/' -f1)
    echo -e "${GREEN}  ✅ $domain${NC}"
done

echo ""
log_info "使用建议:"
echo -e "${CYAN}  1. 现在可以重新运行 Install.sh 体验更快的安装速度${NC}"
echo -e "${CYAN}  2. 建议每月运行一次此脚本保持镜像源最新${NC}"
echo -e "${CYAN}  3. 如遇到网络问题，脚本会自动尝试多个镜像源${NC}"

echo ""
log_info "相关文件位置:"
echo -e "${CYAN}  - 镜像源配置: ~/github_mirrors_termux.json${NC}"
echo -e "${CYAN}  - 脚本备份: 各脚本的 .backup.* 文件${NC}"
echo -e "${CYAN}  - 一键更新: $(basename "$0")${NC}"

echo ""
log_success "镜像源更新完成！现在享受飞一般的下载速度吧！😸💕"

# ==== 询问是否立即测试 ====
echo ""
read -p "是否立即测试镜像源速度？(y/N): " test_choice
if [[ "$test_choice" =~ ^[Yy]$ ]]; then
    log_info "正在测试镜像源速度..."
    
    # 简单的速度测试
    test_file="nb95276/SillyTavern-Termux/raw/main/README.md"
    
    while IFS= read -r line; do
        if echo "$line" | grep -q '"url":'; then
            url=$(echo "$line" | sed 's/.*"url": *"\([^"]*\)".*/\1/')
            if [[ "$url" == *"github.com"* ]]; then
                domain=$(echo "$url" | sed 's|https://||' | cut -d'/' -f1)
                echo -n -e "${YELLOW}测试 $domain ... ${NC}"
                
                if timeout 5 curl -fsSL --connect-timeout 3 --max-time 5 \
                    -o /dev/null "$url/$test_file" 2>/dev/null; then
                    echo -e "${GREEN}✅ 可用${NC}"
                else
                    echo -e "${RED}❌ 不可用${NC}"
                fi
            fi
        fi
    done < <(grep -A 20 '"clone_url":' "$CONFIG_FILE" | head -20)
    
    echo ""
    log_success "速度测试完成！"
fi

echo ""
log_info "再次感谢使用！如有问题请查看相关文档 💖"
