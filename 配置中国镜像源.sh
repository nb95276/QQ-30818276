#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 中国镜像源配置脚本 - Termux版 - Mio's Edition
# 专门配置中国优质镜像源，提升下载速度 😸
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
echo "🌸 中国镜像源配置工具 - Termux版 🌸"
echo "💕 配置最快的中国镜像源"
echo "✨ 包含Termux、npm、Git等镜像源"
echo "=================================================="
echo -e "${NC}"

# ==== 环境检测 ====
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    log_error "本脚本仅适用于 Termux 环境！"
    exit 1
fi

log_success "Termux环境检测通过"

# ==== 配置Termux镜像源 ====
log_info "配置Termux包管理器镜像源..."

# 中国优质Termux镜像源列表（按速度和稳定性排序）
TERMUX_MIRRORS=(
    "mirrors.tuna.tsinghua.edu.cn"     # 清华大学 - 最稳定
    "mirrors.aliyun.com"               # 阿里云 - 速度快
    "mirrors.pku.edu.cn"               # 北京大学 - 教育网优化
    "mirrors.nju.edu.cn"               # 南京大学 - 华东地区优化
    "mirrors.zju.edu.cn"               # 浙江大学 - 华东地区
    "mirrors.ustc.edu.cn"              # 中科大 - 老牌镜像站
    "mirrors.hit.edu.cn"               # 哈工大 - 东北地区
    "mirrors.neusoft.edu.cn"           # 东软 - 企业镜像
)

# 测试并设置最快的Termux镜像源
termux_mirror_set=false
for mirror in "${TERMUX_MIRRORS[@]}"; do
    log_info "测试Termux镜像源: $mirror"
    
    # 测试镜像源可用性
    if timeout 8 curl -fsSL --connect-timeout 5 "https://$mirror/termux/" >/dev/null 2>&1; then
        log_info "设置Termux镜像源: $mirror"
        
        # 尝试使用官方镜像配置
        if [ -d "/data/data/com.termux/files/usr/etc/termux/mirrors/chinese_mainland" ]; then
            if [ -f "/data/data/com.termux/files/usr/etc/termux/mirrors/chinese_mainland/$mirror" ]; then
                ln -sf "/data/data/com.termux/files/usr/etc/termux/mirrors/chinese_mainland/$mirror" \
                       "/data/data/com.termux/files/usr/etc/termux/chosen_mirrors"
                log_success "已设置官方镜像配置: $mirror"
            else
                # 手动创建镜像源配置
                echo "deb https://$mirror/termux/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
                log_success "已手动设置镜像源: $mirror"
            fi
        else
            # 手动创建镜像源配置
            echo "deb https://$mirror/termux/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
            log_success "已手动设置镜像源: $mirror"
        fi
        
        termux_mirror_set=true
        break
    else
        log_warning "$mirror 连接失败，尝试下一个"
    fi
done

if [ "$termux_mirror_set" = false ]; then
    log_error "所有Termux镜像源都无法连接！"
    log_info "将使用默认镜像源"
fi

# 更新包列表
log_info "更新Termux包列表..."
if pkg --check-mirror update 2>/dev/null; then
    log_success "Termux包列表更新成功"
else
    log_warning "使用备用方式更新包列表"
    pkg update
fi

# ==== 配置npm镜像源 ====
log_info "配置npm镜像源..."

# 中国优质npm镜像源列表
NPM_MIRRORS=(
    "https://registry.npmmirror.com/"          # 阿里云npm镜像（推荐）
    "https://mirrors.cloud.tencent.com/npm/"   # 腾讯云npm镜像
    "https://mirrors.huaweicloud.com/repository/npm/" # 华为云npm镜像
    "https://registry.npm.taobao.org/"         # 淘宝npm镜像（备用）
    "https://mirrors.ustc.edu.cn/npm/"         # 中科大npm镜像
)

# 测试并设置最快的npm镜像源
npm_mirror_set=false
for npm_mirror in "${NPM_MIRRORS[@]}"; do
    mirror_name=$(echo "$npm_mirror" | sed 's|https://||' | cut -d'/' -f1)
    log_info "测试npm镜像源: $mirror_name"
    
    if timeout 8 curl -fsSL --connect-timeout 5 "$npm_mirror" >/dev/null 2>&1; then
        if command -v npm >/dev/null 2>&1; then
            npm config set registry "$npm_mirror"
            log_success "已设置npm镜像源: $mirror_name"
        else
            log_warning "npm未安装，跳过npm镜像源配置"
        fi
        npm_mirror_set=true
        break
    else
        log_warning "$mirror_name 连接失败，尝试下一个"
    fi
done

if [ "$npm_mirror_set" = false ]; then
    log_warning "所有npm镜像源都无法连接，将使用默认源"
fi

# 设置其他npm优化配置（只设置有效的配置项）
if command -v npm >/dev/null 2>&1; then
    log_info "配置npm优化设置..."
    npm config set disturl https://npmmirror.com/mirrors/node/ 2>/dev/null || true
    npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/ 2>/dev/null || true
    log_success "npm优化配置完成"
fi

# ==== 配置Git镜像源（可选） ====
log_info "配置Git镜像源（用于加速GitHub访问）..."

# 中国GitHub镜像源
GITHUB_MIRRORS=(
    "https://ghproxy.net/https://github.com"
    "https://gh.ddlc.top/https://github.com"
    "https://ghfast.top/https://github.com"
    "https://hub.gitmirror.com/https://github.com"
)

# 测试GitHub镜像源
working_github_mirrors=()
for github_mirror in "${GITHUB_MIRRORS[@]}"; do
    mirror_name=$(echo "$github_mirror" | sed 's|https://||' | cut -d'/' -f1)
    
    if timeout 5 curl -fsSL --connect-timeout 3 "$github_mirror/octocat/Hello-World" >/dev/null 2>&1; then
        working_github_mirrors+=("$github_mirror")
        log_success "GitHub镜像源可用: $mirror_name"
    else
        log_warning "GitHub镜像源不可用: $mirror_name"
    fi
done

if [ ${#working_github_mirrors[@]} -gt 0 ]; then
    log_success "找到 ${#working_github_mirrors[@]} 个可用的GitHub镜像源"
    log_info "可以在安装脚本中使用这些镜像源加速GitHub访问"
else
    log_warning "没有找到可用的GitHub镜像源"
fi

# ==== 显示配置结果 ====
echo ""
echo -e "${GREEN}${BOLD}"
echo "========================================"
echo "       镜像源配置完成！"
echo "========================================"
echo -e "${NC}"

log_info "配置摘要:"
if [ "$termux_mirror_set" = true ]; then
    echo -e "${GREEN}  ✅ Termux镜像源: 已配置${NC}"
else
    echo -e "${YELLOW}  ⚠️ Termux镜像源: 使用默认${NC}"
fi

if [ "$npm_mirror_set" = true ]; then
    echo -e "${GREEN}  ✅ npm镜像源: 已配置${NC}"
else
    echo -e "${YELLOW}  ⚠️ npm镜像源: 使用默认${NC}"
fi

echo -e "${GREEN}  ✅ GitHub镜像源: ${#working_github_mirrors[@]} 个可用${NC}"

echo ""
log_info "使用建议:"
echo -e "${CYAN}  1. 现在可以使用 pkg install 安装软件包${NC}"
echo -e "${CYAN}  2. npm安装速度将显著提升${NC}"
echo -e "${CYAN}  3. 如需重新配置，可重新运行此脚本${NC}"

echo ""
log_success "中国镜像源配置完成！享受飞一般的下载速度吧！😸💕"
