#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# GitHub镜像源自动更新脚本 - Termux版 - Mio's Edition
# 从XIU2的GitHub增强脚本同步最新的镜像源到Android Termux环境 😸
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

# ==== 版本信息 ====
SCRIPT_VERSION="1.0.0"
UPDATE_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ==== 输出函数 ====
log_success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }
log_info() { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }
log_debug() { echo -e "${BRIGHT_MAGENTA}[DEBUG]${NC} $1"; }

# ==== 显示标题 ====
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 GitHub镜像源自动更新工具 - Termux版 🌸"
echo "💕 专为Android Termux环境优化"
echo "✨ 与XIU2的GitHub增强脚本保持同步"
echo "=================================================="
echo -e "${NC}"

# ==== 环境检测 ====
log_info "正在检查Termux环境..."
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    log_error "本脚本仅适用于 Termux 环境，请在 Termux 中运行！"
    exit 1
fi
log_success "Termux环境检测通过"

# ==== 检查必要工具 ====
log_info "检查必要工具..."
for tool in curl grep sed; do
    if ! command -v $tool >/dev/null 2>&1; then
        log_error "缺少必要工具: $tool，请先安装: pkg install $tool"
        exit 1
    fi
done
log_success "必要工具检查完成"

# ==== GitHub增强脚本的源地址（Termux优化版） ====
SOURCE_URLS=(
    "https://ghproxy.net/https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js"
    "https://gh.ddlc.top/https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js"
    "https://ghfast.top/https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js"
    "https://hub.gitmirror.com/https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js"
    "https://ghproxy.cfd/https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js"
)

# ==== 获取最新的GitHub增强脚本 ====
log_info "正在获取最新的GitHub增强脚本..."
SCRIPT_CONTENT=""

for url in "${SOURCE_URLS[@]}"; do
    domain=$(echo "$url" | sed 's|https://||' | cut -d'/' -f1)
    log_debug "尝试镜像: $domain"
    
    if SCRIPT_CONTENT=$(timeout 20 curl -fsSL --connect-timeout 8 --max-time 20 "$url" 2>/dev/null); then
        if [ ${#SCRIPT_CONTENT} -gt 10000 ]; then
            log_success "成功获取脚本内容，使用镜像: $domain"
            break
        fi
    fi
    log_warning "镜像失败: $domain"
    SCRIPT_CONTENT=""
done

if [ -z "$SCRIPT_CONTENT" ]; then
    log_error "所有镜像都无法获取GitHub增强脚本！"
    log_info "请检查网络连接或稍后重试"
    exit 1
fi

# ==== 解析函数 ====
parse_mirror_array() {
    local pattern="$1"
    local content="$2"
    local type_name="$3"
    
    log_info "解析${type_name}镜像源..."
    
    if echo "$content" | grep -q "$pattern"; then
        local array_content=$(echo "$content" | sed -n "/$pattern/,/\]/p" | tr -d '\n' | sed 's/.*\[\(.*\)\].*/\1/')
        local count=$(echo "$array_content" | grep -o "\['" | wc -l)
        
        if [ "$count" -gt 0 ]; then
            log_success "找到 $count 个${type_name}镜像源"
            
            # 提取镜像源信息并转换为JSON格式
            echo "$array_content" | grep -o "\['[^']*','[^']*','[^']*'\]" | while read -r match; do
                url=$(echo "$match" | sed "s/\['\([^']*\)'.*/\1/")
                location=$(echo "$match" | sed "s/.*','\([^']*\)'.*/\1/")
                description=$(echo "$match" | sed "s/.*','\([^']*\)'\]/\1/")
                
                # 输出JSON格式
                echo "    {"
                echo "      \"url\": \"$url\","
                echo "      \"location\": \"$location\","
                echo "      \"description\": \"$description\""
                echo "    },"
            done
        else
            log_warning "未能解析${type_name}镜像源"
            echo ""
        fi
    else
        log_warning "未找到${type_name}数组"
        echo ""
    fi
}

# ==== 解析各类镜像源 ====
CLONE_SOURCES=$(parse_mirror_array "clone_url.*=" "$SCRIPT_CONTENT" "Git Clone")
DOWNLOAD_SOURCES=$(parse_mirror_array "download_url_us.*=" "$SCRIPT_CONTENT" "Download/ZIP")
RAW_SOURCES=$(parse_mirror_array "raw_url.*=" "$SCRIPT_CONTENT" "Raw文件")

# ==== 生成加速源配置文件 ====
log_info "生成Termux专用的加速源配置文件..."
CONFIG_FILE="$HOME/github_mirrors_termux.json"
BACKUP_FILE="$HOME/github_mirrors_backup_$(date '+%Y%m%d_%H%M%S').json"

# 备份现有文件
if [ -f "$CONFIG_FILE" ]; then
    log_info "备份现有配置文件到: $BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# 生成新配置文件
cat > "$CONFIG_FILE" << EOF
{
  "version": "2.6.27",
  "last_updated": "$UPDATE_DATE",
  "platform": "Android Termux",
  "script_version": "$SCRIPT_VERSION",
  "source_url": "https://github.com/XIU2/UserScript/raw/refs/heads/master/GithubEnhanced-High-Speed-Download.user.js",
  "clone_url": [
$(echo "$CLONE_SOURCES" | sed '$s/,$//')
  ],
  "download_url": [
$(echo "$DOWNLOAD_SOURCES" | sed '$s/,$//')
  ],
  "raw_url": [
$(echo "$RAW_SOURCES" | sed '$s/,$//')
  ],
  "note": "本文件由Mio的Termux自动同步脚本生成，与XIU2的GitHub增强脚本保持同步"
}
EOF

if [ -f "$CONFIG_FILE" ]; then
    log_success "新的加速源配置文件已保存: $CONFIG_FILE"
else
    log_error "保存配置文件失败！"
    exit 1
fi

# ==== 更新Termux安装脚本中的镜像源 ====
log_info "更新Termux安装脚本中的镜像源..."

# 从配置文件中提取镜像源URL
MIRROR_URLS=()
while IFS= read -r line; do
    if echo "$line" | grep -q '"url":'; then
        url=$(echo "$line" | sed 's/.*"url": *"\([^"]*\)".*/\1/')
        if [[ "$url" == *"github.com"* ]] && [[ "$url" != "https://github.com" ]]; then
            MIRROR_URLS+=("$url")
        fi
    fi
done < "$CONFIG_FILE"

# 添加原始GitHub作为备用
MIRROR_URLS+=("https://github.com")

log_success "提取到 ${#MIRROR_URLS[@]} 个可用镜像源"

# ==== 更新Install.sh脚本 ====
INSTALL_SCRIPT="$HOME/Install.sh"
if [ -f "$INSTALL_SCRIPT" ]; then
    log_info "更新 Install.sh 中的镜像源..."

    # 备份原始脚本
    cp "$INSTALL_SCRIPT" "${INSTALL_SCRIPT}.backup.$(date '+%Y%m%d_%H%M%S')"

    # 构建新的镜像源数组
    NEW_MIRRORS_ARRAY="GITHUB_MIRRORS=(\n"
    for url in "${MIRROR_URLS[@]}"; do
        NEW_MIRRORS_ARRAY="$NEW_MIRRORS_ARRAY    \"$url\"\n"
    done
    NEW_MIRRORS_ARRAY="$NEW_MIRRORS_ARRAY)"

    # 替换镜像源数组
    if grep -q "GITHUB_MIRRORS=(" "$INSTALL_SCRIPT"; then
        # 使用sed替换整个数组
        sed -i '/^GITHUB_MIRRORS=(/,/^)/c\
'"$(echo -e "$NEW_MIRRORS_ARRAY")" "$INSTALL_SCRIPT"
        log_success "Install.sh 镜像源已更新"
    else
        log_warning "Install.sh 中未找到 GITHUB_MIRRORS 数组"
    fi
else
    log_warning "未找到 Install.sh 文件"
fi

# ==== 更新Install_优化版.sh脚本 ====
INSTALL_OPT_SCRIPT="$HOME/Install_优化版.sh"
if [ -f "$INSTALL_OPT_SCRIPT" ]; then
    log_info "更新 Install_优化版.sh 中的镜像源..."

    # 备份原始脚本
    cp "$INSTALL_OPT_SCRIPT" "${INSTALL_OPT_SCRIPT}.backup.$(date '+%Y%m%d_%H%M%S')"

    # 替换镜像源数组
    if grep -q "GITHUB_MIRRORS=(" "$INSTALL_OPT_SCRIPT"; then
        sed -i '/^GITHUB_MIRRORS=(/,/^)/c\
'"$(echo -e "$NEW_MIRRORS_ARRAY")" "$INSTALL_OPT_SCRIPT"
        log_success "Install_优化版.sh 镜像源已更新"
    else
        log_warning "Install_优化版.sh 中未找到 GITHUB_MIRRORS 数组"
    fi
else
    log_warning "未找到 Install_优化版.sh 文件"
fi

# ==== 显示更新摘要 ====
echo ""
echo -e "${GREEN}${BOLD}========================================"
echo "       镜像源更新完成！"
echo "========================================${NC}"
echo ""

log_info "更新摘要:"
echo -e "${CYAN}  - 配置文件: $CONFIG_FILE${NC}"
echo -e "${CYAN}  - 备份文件: $BACKUP_FILE${NC}"
echo -e "${CYAN}  - 可用镜像源: ${#MIRROR_URLS[@]} 个${NC}"
echo ""

log_info "推荐的Git Clone镜像源（前5个）:"
for i in "${!MIRROR_URLS[@]}"; do
    if [ $i -lt 5 ]; then
        domain=$(echo "${MIRROR_URLS[$i]}" | sed 's|https://||' | cut -d'/' -f1)
        echo -e "${GREEN}  ✅ $domain: ${MIRROR_URLS[$i]}${NC}"
    fi
done

echo ""
log_info "下次更新建议: 每月运行一次此脚本以保持镜像源最新"
log_info "使用方法: bash ~/Update_Mirror_Sources_Termux.sh"

echo ""
log_success "镜像源同步完成！Mio保证与官方源保持同步！😸💕"
