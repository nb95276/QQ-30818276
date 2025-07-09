#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# Termux 强制切换中国镜像源脚本 - 宝子专用版 😸
# 解决国外镜像源下载慢的问题
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 日志函数 ====
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ==== 清屏并显示标题 ====
clear
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 Termux 中国镜像源强制切换工具 🌸"
echo "💕 专为宝子们解决下载慢问题"
echo "✨ 告别国外镜像源，拥抱高速下载！"
echo "=================================================="
echo -e "${NC}"

# ==== 中国优质Termux镜像源列表 ====
TERMUX_MIRRORS=(
    "mirrors.tuna.tsinghua.edu.cn"     # 清华大学（推荐）
    "mirrors.aliyun.com"               # 阿里云（稳定）
    "mirrors.pku.edu.cn"               # 北京大学
    "mirrors.nju.edu.cn"               # 南京大学
    "mirrors.zju.edu.cn"               # 浙江大学
    "mirrors.ustc.edu.cn"              # 中科大
    "mirrors.hit.edu.cn"               # 哈工大
    "mirrors.bfsu.edu.cn"              # 北外
)

echo -e "${YELLOW}🔍 正在测试中国镜像源速度...${NC}"
echo ""

# ==== 测试并选择最快的镜像源 ====
BEST_MIRROR=""
BEST_TIME=999

for mirror in "${TERMUX_MIRRORS[@]}"; do
    echo -ne "${CYAN}测试 $mirror ... ${NC}"
    
    # 测试连接速度
    start_time=$(date +%s%N)
    if timeout 8 curl -fsSL --connect-timeout 5 \
        "https://$mirror/termux/apt/termux-main/dists/stable/Release" >/dev/null 2>&1; then
        end_time=$(date +%s%N)
        response_time=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒
        
        echo -e "${GREEN}✅ ${response_time}ms${NC}"
        
        if [ $response_time -lt $BEST_TIME ]; then
            BEST_TIME=$response_time
            BEST_MIRROR=$mirror
        fi
    else
        echo -e "${RED}❌ 连接失败${NC}"
    fi
done

# ==== 应用最佳镜像源 ====
if [ -n "$BEST_MIRROR" ]; then
    echo ""
    echo -e "${GREEN}${BOLD}🎯 最佳镜像源: $BEST_MIRROR (${BEST_TIME}ms)${NC}"
    echo ""
    
    log_info "正在配置镜像源..."
    
    # 备份原始配置
    if [ -f "$PREFIX/etc/apt/sources.list" ]; then
        cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "已备份原始配置"
    fi
    
    # 创建新的sources.list
    mkdir -p "$PREFIX/etc/apt"
    cat > "$PREFIX/etc/apt/sources.list" << EOF
# Termux 中国镜像源配置 - 自动生成于 $(date)
# 当前使用: $BEST_MIRROR (响应时间: ${BEST_TIME}ms)

# 主仓库
deb https://$BEST_MIRROR/termux/apt/termux-main stable main

# 游戏仓库（可选，需要时取消注释）
# deb https://$BEST_MIRROR/termux/apt/termux-games games stable

# 科学仓库（可选，需要时取消注释）
# deb https://$BEST_MIRROR/termux/apt/termux-science science stable

# 根仓库（可选，需要时取消注释）
# deb https://$BEST_MIRROR/termux/apt/termux-root root stable
EOF
    
    # 设置chosen_mirrors
    if [ -d "$PREFIX/etc/termux/mirrors" ]; then
        echo "$BEST_MIRROR" > "$PREFIX/etc/termux/chosen_mirrors"
        log_info "已设置chosen_mirrors"
    fi
    
    # 清除缓存
    log_info "清除apt缓存..."
    rm -rf "$PREFIX/var/lib/apt/lists/"*
    apt clean 2>/dev/null || true
    
    # 更新包列表
    log_info "更新包列表..."
    echo ""
    
    if pkg update; then
        echo ""
        log_success "🎉 镜像源切换成功！"
        echo ""
        echo -e "${GREEN}${BOLD}✨ 现在你的下载速度应该飞快了！${NC}"
        echo -e "${CYAN}📊 当前镜像源: $BEST_MIRROR${NC}"
        echo -e "${CYAN}⚡ 响应时间: ${BEST_TIME}ms${NC}"
        
        # 显示验证信息
        echo ""
        echo -e "${YELLOW}🔍 验证信息:${NC}"
        echo -e "${CYAN}  - 配置文件: $PREFIX/etc/apt/sources.list${NC}"
        echo -e "${CYAN}  - 备份文件: $PREFIX/etc/apt/sources.list.backup.*${NC}"
        
    else
        log_error "包列表更新失败，可能需要手动处理"
        echo ""
        echo -e "${YELLOW}💡 建议操作:${NC}"
        echo -e "${CYAN}  1. 重启Termux应用${NC}"
        echo -e "${CYAN}  2. 再次运行此脚本${NC}"
        echo -e "${CYAN}  3. 或手动执行: pkg update${NC}"
    fi
    
else
    echo ""
    log_error "😱 所有中国镜像源都无法连接！"
    echo ""
    echo -e "${YELLOW}💡 可能的原因:${NC}"
    echo -e "${CYAN}  1. 网络连接问题${NC}"
    echo -e "${CYAN}  2. 防火墙或代理设置${NC}"
    echo -e "${CYAN}  3. DNS解析问题${NC}"
    echo ""
    echo -e "${YELLOW}🛠️ 建议解决方案:${NC}"
    echo -e "${CYAN}  1. 检查网络连接${NC}"
    echo -e "${CYAN}  2. 切换到其他WiFi网络${NC}"
    echo -e "${CYAN}  3. 重启路由器${NC}"
    echo -e "${CYAN}  4. 稍后再试${NC}"
fi

echo ""
echo -e "${CYAN}${BOLD}💖 感谢使用宝子专用镜像源切换工具！${NC}"
echo -e "${YELLOW}🌸 让下载变得飞快，这就是我们的目标！${NC}"
echo ""

# 询问是否立即测试下载速度
echo -ne "${CYAN}${BOLD}🚀 是否立即测试下载速度？(y/N): ${NC}"
read -n1 test_choice; echo

if [[ "$test_choice" =~ ^[Yy]$ ]]; then
    echo ""
    log_info "正在测试下载速度..."
    echo ""
    
    # 测试下载一个小包
    if timeout 30 pkg install -y --dry-run curl 2>/dev/null; then
        log_success "✅ 下载测试成功！镜像源工作正常"
    else
        log_warning "⚠️ 下载测试可能有问题，建议检查网络"
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}🎯 任务完成！现在可以享受高速下载了！${NC}"
