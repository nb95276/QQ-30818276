#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# Termux 镜像源状态检查工具 - 宝子专用版 😸
# 快速检查当前使用的镜像源和下载速度
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 清屏并显示标题 ====
clear
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🔍 Termux 镜像源状态检查工具 🔍"
echo "💕 快速了解你的下载源配置"
echo "✨ 宝子专用版 - 简单易懂！"
echo "=================================================="
echo -e "${NC}"

# ==== 检查当前镜像源配置 ====
echo -e "${YELLOW}${BOLD}📋 当前镜像源配置:${NC}"
echo ""

if [ -f "$PREFIX/etc/apt/sources.list" ]; then
    echo -e "${CYAN}📄 配置文件: $PREFIX/etc/apt/sources.list${NC}"
    echo ""
    
    # 提取主要镜像源
    main_mirror=$(grep -E "^deb.*termux-main" "$PREFIX/etc/apt/sources.list" | head -1 | sed 's/deb https:\/\///' | cut -d'/' -f1)
    
    if [ -n "$main_mirror" ]; then
        echo -e "${GREEN}✅ 主镜像源: ${BOLD}$main_mirror${NC}"
        
        # 判断是否为中国镜像源
        if echo "$main_mirror" | grep -qE "(tuna\.tsinghua|aliyun|pku\.edu|nju\.edu|zju\.edu|ustc\.edu|hit\.edu|bfsu\.edu)"; then
            echo -e "${GREEN}🇨🇳 类型: ${BOLD}中国镜像源${NC} 🎉"
            mirror_type="中国"
        else
            echo -e "${YELLOW}🌍 类型: ${BOLD}国外镜像源${NC} ⚠️"
            mirror_type="国外"
        fi
    else
        echo -e "${RED}❌ 无法识别镜像源配置${NC}"
        main_mirror="未知"
        mirror_type="未知"
    fi
    
    echo ""
    echo -e "${CYAN}📝 完整配置内容:${NC}"
    echo -e "${YELLOW}$(cat "$PREFIX/etc/apt/sources.list" | grep -v "^#" | grep -v "^$")${NC}"
    
else
    echo -e "${RED}❌ 配置文件不存在: $PREFIX/etc/apt/sources.list${NC}"
    main_mirror="未配置"
    mirror_type="未知"
fi

echo ""
echo "=================================================="

# ==== 测试镜像源连接速度 ====
echo -e "${YELLOW}${BOLD}⚡ 镜像源连接测试:${NC}"
echo ""

if [ "$main_mirror" != "未知" ] && [ "$main_mirror" != "未配置" ]; then
    echo -ne "${CYAN}正在测试 $main_mirror ... ${NC}"
    
    start_time=$(date +%s%N)
    if timeout 10 curl -fsSL --connect-timeout 5 \
        "https://$main_mirror/termux/apt/termux-main/dists/stable/Release" >/dev/null 2>&1; then
        end_time=$(date +%s%N)
        response_time=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒
        
        echo -e "${GREEN}✅ ${response_time}ms${NC}"
        
        # 评估速度
        if [ $response_time -lt 500 ]; then
            speed_rating="🚀 极快"
            speed_color="${GREEN}"
        elif [ $response_time -lt 1000 ]; then
            speed_rating="⚡ 快速"
            speed_color="${GREEN}"
        elif [ $response_time -lt 2000 ]; then
            speed_rating="🐌 一般"
            speed_color="${YELLOW}"
        else
            speed_rating="🐢 较慢"
            speed_color="${RED}"
        fi
        
        echo -e "${speed_color}📊 速度评级: ${BOLD}$speed_rating${NC}"
        
    else
        echo -e "${RED}❌ 连接失败${NC}"
        speed_rating="❌ 无法连接"
        speed_color="${RED}"
    fi
else
    echo -e "${RED}⚠️ 无法测试，镜像源配置异常${NC}"
    speed_rating="⚠️ 配置异常"
    speed_color="${RED}"
fi

echo ""
echo "=================================================="

# ==== 系统信息 ====
echo -e "${YELLOW}${BOLD}📱 系统信息:${NC}"
echo ""
echo -e "${CYAN}📦 Termux版本: ${NC}$(dpkg -l termux-tools 2>/dev/null | tail -1 | awk '{print $3}' || echo '未知')"
echo -e "${CYAN}🐧 Android版本: ${NC}$(getprop ro.build.version.release 2>/dev/null || echo '未知')"
echo -e "${CYAN}📡 网络状态: ${NC}$(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo '✅ 正常' || echo '❌ 异常')"

echo ""
echo "=================================================="

# ==== 建议和操作 ====
echo -e "${YELLOW}${BOLD}💡 建议和操作:${NC}"
echo ""

if [ "$mirror_type" = "国外" ]; then
    echo -e "${RED}⚠️ 检测到使用国外镜像源，可能下载较慢${NC}"
    echo -e "${GREEN}🔧 建议操作:${NC}"
    echo -e "${CYAN}   1. 运行: bash ~/强制切换中国镜像源.sh${NC}"
    echo -e "${CYAN}   2. 或重新安装SillyTavern${NC}"
elif [ "$mirror_type" = "中国" ]; then
    if echo "$speed_rating" | grep -qE "(极快|快速)"; then
        echo -e "${GREEN}🎉 恭喜！你的镜像源配置很棒！${NC}"
        echo -e "${CYAN}✨ 当前配置已经是最优状态${NC}"
    else
        echo -e "${YELLOW}⚠️ 虽然使用中国镜像源，但速度不够理想${NC}"
        echo -e "${GREEN}🔧 建议操作:${NC}"
        echo -e "${CYAN}   1. 检查网络连接${NC}"
        echo -e "${CYAN}   2. 尝试切换其他中国镜像源${NC}"
        echo -e "${CYAN}   3. 运行: bash ~/强制切换中国镜像源.sh${NC}"
    fi
else
    echo -e "${RED}❌ 镜像源配置异常${NC}"
    echo -e "${GREEN}🔧 建议操作:${NC}"
    echo -e "${CYAN}   1. 运行: bash ~/强制切换中国镜像源.sh${NC}"
    echo -e "${CYAN}   2. 或重新安装SillyTavern${NC}"
fi

echo ""

# ==== 快速操作菜单 ====
echo -e "${CYAN}${BOLD}🚀 快速操作:${NC}"
echo -e "${YELLOW}1. 🔄 立即切换到最佳中国镜像源${NC}"
echo -e "${YELLOW}2. 📊 测试所有中国镜像源速度${NC}"
echo -e "${YELLOW}3. 🔍 查看详细配置文件${NC}"
echo -e "${YELLOW}4. ❌ 退出${NC}"
echo ""

echo -ne "${CYAN}${BOLD}请选择操作 (1-4): ${NC}"
read -n1 choice; echo
echo ""

case "$choice" in
    1)
        echo -e "${GREEN}🔄 正在切换到最佳中国镜像源...${NC}"
        if [ -f "$HOME/强制切换中国镜像源.sh" ]; then
            bash "$HOME/强制切换中国镜像源.sh"
        else
            echo -e "${RED}❌ 镜像源切换脚本不存在${NC}"
            echo -e "${CYAN}💡 请重新下载完整的SillyTavern安装包${NC}"
        fi
        ;;
    2)
        echo -e "${GREEN}📊 测试所有中国镜像源...${NC}"
        echo ""
        
        MIRRORS=(
            "mirrors.tuna.tsinghua.edu.cn"
            "mirrors.aliyun.com"
            "mirrors.pku.edu.cn"
            "mirrors.nju.edu.cn"
            "mirrors.zju.edu.cn"
            "mirrors.ustc.edu.cn"
        )
        
        for mirror in "${MIRRORS[@]}"; do
            echo -ne "${CYAN}测试 $mirror ... ${NC}"
            start_time=$(date +%s%N)
            if timeout 8 curl -fsSL --connect-timeout 5 \
                "https://$mirror/termux/apt/termux-main/dists/stable/Release" >/dev/null 2>&1; then
                end_time=$(date +%s%N)
                response_time=$(( (end_time - start_time) / 1000000 ))
                echo -e "${GREEN}✅ ${response_time}ms${NC}"
            else
                echo -e "${RED}❌ 连接失败${NC}"
            fi
        done
        ;;
    3)
        echo -e "${GREEN}🔍 详细配置文件内容:${NC}"
        echo ""
        if [ -f "$PREFIX/etc/apt/sources.list" ]; then
            echo -e "${CYAN}文件路径: $PREFIX/etc/apt/sources.list${NC}"
            echo -e "${YELLOW}$(cat "$PREFIX/etc/apt/sources.list")${NC}"
        else
            echo -e "${RED}❌ 配置文件不存在${NC}"
        fi
        ;;
    4)
        echo -e "${GREEN}👋 再见！${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}⚠️ 无效选择，退出${NC}"
        ;;
esac

echo ""
echo -e "${CYAN}${BOLD}💖 感谢使用镜像源检查工具！${NC}"
echo -e "${YELLOW}🌸 让下载变得飞快，这就是我们的目标！${NC}"
