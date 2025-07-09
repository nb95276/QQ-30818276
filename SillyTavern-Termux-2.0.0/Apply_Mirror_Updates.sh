#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 应用镜像源更新到现有脚本 - Termux版 - Mio's Edition
# 将最新的GitHub镜像源应用到所有相关的安装脚本中 😸
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 输出函数 ====
log_success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }
log_info() { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }

# ==== 显示标题 ====
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 镜像源更新应用工具 - Termux版 🌸"
echo "💕 将最新镜像源应用到所有安装脚本"
echo "✨ 确保所有脚本使用最新最快的镜像源"
echo "=================================================="
echo -e "${NC}"

# ==== 环境检测 ====
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    log_error "本脚本仅适用于 Termux 环境！"
    exit 1
fi

# ==== 检查配置文件 ====
CONFIG_FILE="$HOME/github_mirrors_termux.json"
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "未找到镜像源配置文件: $CONFIG_FILE"
    log_info "请先运行: bash ~/Update_Mirror_Sources_Termux.sh"
    exit 1
fi

log_success "找到镜像源配置文件"

# ==== 从配置文件提取镜像源 ====
log_info "从配置文件提取镜像源..."
MIRROR_URLS=()

# 提取clone_url部分的镜像源
while IFS= read -r line; do
    if echo "$line" | grep -q '"url":'; then
        url=$(echo "$line" | sed 's/.*"url": *"\([^"]*\)".*/\1/')
        # 只要包含github.com的URL，但排除纯github.com
        if [[ "$url" == *"github.com"* ]]; then
            MIRROR_URLS+=("$url")
        fi
    fi
done < <(sed -n '/"clone_url":/,/"download_url":/p' "$CONFIG_FILE")

# 确保原始GitHub在最后
if [[ ! " ${MIRROR_URLS[@]} " =~ " https://github.com " ]]; then
    MIRROR_URLS+=("https://github.com")
fi

log_success "提取到 ${#MIRROR_URLS[@]} 个镜像源"

# ==== 构建新的镜像源数组字符串 ====
build_mirror_array() {
    local array_name="$1"
    local result="$array_name=(\n"
    
    for url in "${MIRROR_URLS[@]}"; do
        result="$result    \"$url\"\n"
    done
    result="$result)"
    
    echo -e "$result"
}

# ==== 更新脚本函数 ====
update_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    
    if [ ! -f "$script_path" ]; then
        log_warning "脚本不存在: $script_name"
        return 1
    fi
    
    log_info "更新脚本: $script_name"
    
    # 创建备份
    local backup_path="${script_path}.backup.$(date '+%Y%m%d_%H%M%S')"
    cp "$script_path" "$backup_path"
    log_info "已备份到: $(basename "$backup_path")"
    
    # 检查是否包含GITHUB_MIRRORS数组
    if ! grep -q "GITHUB_MIRRORS=(" "$script_path"; then
        log_warning "$script_name 中未找到 GITHUB_MIRRORS 数组"
        return 1
    fi
    
    # 构建新的数组
    local new_array=$(build_mirror_array "GITHUB_MIRRORS")
    
    # 创建临时文件进行替换
    local temp_file=$(mktemp)
    
    # 使用awk进行精确替换
    awk '
    /^GITHUB_MIRRORS=\(/ {
        in_array = 1
        print "'"$(echo "$new_array" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')"'"
        next
    }
    in_array && /^\)/ {
        in_array = 0
        next
    }
    !in_array {
        print
    }
    ' "$script_path" > "$temp_file"
    
    # 检查替换是否成功
    if grep -q "GITHUB_MIRRORS=(" "$temp_file"; then
        mv "$temp_file" "$script_path"
        chmod +x "$script_path"
        log_success "$script_name 更新成功"
        return 0
    else
        rm -f "$temp_file"
        log_error "$script_name 更新失败"
        return 1
    fi
}

# ==== 更新所有相关脚本 ====
log_info "开始更新所有相关脚本..."

SCRIPTS_TO_UPDATE=(
    "$HOME/Install.sh"
    "$HOME/Install_优化版.sh"
    "$(dirname "$0")/Install.sh"
    "$(dirname "$0")/Install_优化版.sh"
)

UPDATED_COUNT=0
TOTAL_COUNT=0

for script in "${SCRIPTS_TO_UPDATE[@]}"; do
    if [ -f "$script" ]; then
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        if update_script "$script"; then
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
    fi
done

# ==== 更新菜单脚本（如果存在镜像源配置） ====
MENU_SCRIPTS=(
    "$HOME/menu.sh"
    "$HOME/menu_优化版.sh"
    "$(dirname "$0")/menu.sh"
    "$(dirname "$0")/menu_优化版.sh"
)

for menu_script in "${MENU_SCRIPTS[@]}"; do
    if [ -f "$menu_script" ] && grep -q "GITHUB_MIRRORS" "$menu_script"; then
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        if update_script "$menu_script"; then
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
    fi
done

# ==== 显示更新结果 ====
echo ""
echo -e "${GREEN}${BOLD}========================================"
echo "       镜像源应用完成！"
echo "========================================${NC}"
echo ""

log_info "更新统计:"
echo -e "${CYAN}  - 总脚本数: $TOTAL_COUNT${NC}"
echo -e "${CYAN}  - 成功更新: $UPDATED_COUNT${NC}"
echo -e "${CYAN}  - 失败数量: $((TOTAL_COUNT - UPDATED_COUNT))${NC}"

echo ""
log_info "已应用的镜像源（前5个）:"
for i in "${!MIRROR_URLS[@]}"; do
    if [ $i -lt 5 ]; then
        domain=$(echo "${MIRROR_URLS[$i]}" | sed 's|https://||' | cut -d'/' -f1)
        echo -e "${GREEN}  ✅ $domain${NC}"
    fi
done

echo ""
if [ $UPDATED_COUNT -gt 0 ]; then
    log_success "镜像源更新应用完成！现在所有脚本都使用最新的镜像源了！😸💕"
    log_info "建议: 重新运行安装脚本以体验更快的下载速度"
else
    log_warning "没有脚本被更新，请检查脚本文件是否存在"
fi

echo ""
log_info "下次使用: bash ~/Apply_Mirror_Updates.sh"
