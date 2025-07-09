#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern 宝子专用一键安装脚本 - Mio's Edition (修复版)
# 复制粘贴回车，就这么简单！😸
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

# ==== 创建缓存目录 ====
CACHE_DIR="$HOME/.cache"
mkdir -p "$CACHE_DIR"

# ==== 清屏并显示欢迎信息 ====
clear
echo -e "${CYAN}${BOLD}"
echo "=================================================="
echo "🌸 欢迎小白用户！🌸"
echo "💕 SillyTavern 超简单安装工具 (修复版)"
echo "✨ 复制粘贴回车，就能和AI聊天！"
echo "=================================================="
echo -e "${NC}"

echo -e "${GREEN}${BOLD}🎯 小白须知（重要！）：${NC}"
echo -e "${YELLOW}  📱 整个过程大约15-20分钟${NC}"
echo -e "${YELLOW}  📶 请确保连接WiFi网络${NC}"
echo -e "${YELLOW}  🔋 请确保手机电量充足${NC}"
echo -e "${YELLOW}  ⏰ 安装过程中不要关闭Termux${NC}"
echo -e "${YELLOW}  🎮 安装完成后会自动进入菜单${NC}"
echo ""

echo -e "${BRIGHT_MAGENTA}${BOLD}💡 这是什么？${NC}"
echo -e "${CYAN}  SillyTavern是一个AI聊天软件${NC}"
echo -e "${CYAN}  可以和各种AI角色聊天${NC}"
echo -e "${CYAN}  支持角色扮演、创意写作等${NC}"
echo -e "${CYAN}  完全免费，功能强大${NC}"
echo ""

# ==== 环境检测增强版 ====
echo -e "${CYAN}${BOLD}🔍 正在检查你的手机环境...${NC}"

# 1. 检查是否在Termux中
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    echo -e "${RED}${BOLD}❌ 错误：请在Termux应用中运行此脚本！${NC}"
    echo -e "${YELLOW}${BOLD}💡 解决方法：${NC}"
    echo -e "${GREEN}  1. 下载并安装Termux应用${NC}"
    echo -e "${GREEN}  2. 打开Termux应用${NC}"
    echo -e "${GREEN}  3. 重新运行安装命令${NC}"
    exit 1
fi

# 2. 检查并安装curl
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}${BOLD}🔧 curl未安装，正在自动安装...${NC}"
    if ! pkg install curl -y; then
        echo -e "${RED}${BOLD}❌ curl安装失败，请检查网络连接${NC}"
        exit 1
    fi
    echo -e "${GREEN}${BOLD}✅ curl安装成功！${NC}"
fi

# 3. 检查网络连接
echo -e "${CYAN}${BOLD}🌐 检查网络连接...${NC}"
if ! ping -c 1 8.8.8.8 &> /dev/null && ! ping -c 1 114.114.114.114 &> /dev/null; then
    echo -e "${RED}${BOLD}❌ 网络连接异常，请检查以下事项：${NC}"
    echo -e "${YELLOW}  📶 确保连接WiFi网络${NC}"
    echo -e "${YELLOW}  🔄 尝试切换网络或重启路由器${NC}"
    echo -e "${YELLOW}  📱 检查手机是否有网络权限${NC}"
    exit 1
fi

echo -e "${GREEN}${BOLD}✅ 环境检测通过！${NC}"
echo -e "${GREEN}${BOLD}✅ 网络连接正常！${NC}"
echo ""

# ==== 询问用户是否继续（增强版） ====
echo -e "${YELLOW}${BOLD}🤔 准备开始安装SillyTavern，继续吗？${NC}"
echo -e "${GREEN}${BOLD}输入 y/Y/yes/是 继续，输入其他内容取消：${NC}"
read -p "> " user_choice

# 支持更多输入方式
if [[ ! "$user_choice" =~ ^[YyYES是]$ ]] && [[ "$user_choice" != "yes" ]] && [[ "$user_choice" != "YES" ]]; then
    echo -e "${YELLOW}${BOLD}👋 安装已取消，随时欢迎回来！${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}${BOLD}🚀 太好了！开始安装...${NC}"
echo -e "${CYAN}${BOLD}💕 接下来全部自动化，你只需要等待就行！${NC}"
echo ""

# ==== 显示进度提示 ====
echo -e "${BRIGHT_MAGENTA}${BOLD}📋 安装步骤预览：${NC}"
echo -e "${CYAN}  1. 🔧 配置中国镜像源（更快下载）${NC}"
echo -e "${CYAN}  2. 📦 安装必要工具${NC}"
echo -e "${CYAN}  3. 🟢 安装Node.js运行环境${NC}"
echo -e "${CYAN}  4. 📥 下载SillyTavern程序${NC}"
echo -e "${CYAN}  5. 🎮 创建菜单系统${NC}"
echo -e "${CYAN}  6. 📦 安装程序依赖（最耗时）${NC}"
echo -e "${CYAN}  7. ⚙️ 配置自动启动${NC}"
echo -e "${CYAN}  8. 🎉 完成安装${NC}"
echo ""

echo -e "${YELLOW}${BOLD}⏰ 开始倒计时...${NC}"
for i in 3 2 1; do
    echo -e "${GREEN}${BOLD}$i...${NC}"
    sleep 1
done
echo -e "${GREEN}${BOLD}🚀 开始安装！${NC}"
echo ""

# ==== 调用主安装脚本（增强版） ====
echo -e "${CYAN}${BOLD}📥 正在下载并运行主安装脚本...${NC}"

# 多个镜像源，确保下载成功
INSTALL_MIRRORS=(
    "https://ghfast.top/https://github.com/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh"
    "https://gh.ddlc.top/https://github.com/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh"
    "https://ghproxy.net/https://github.com/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh"
    "https://hub.gitmirror.com/https://github.com/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh"
)

install_success=false
error_log="$CACHE_DIR/install_error.log"

for mirror in "${INSTALL_MIRRORS[@]}"; do
    mirror_name=$(echo "$mirror" | sed 's|https://||' | cut -d'/' -f1)
    echo -e "${YELLOW}${BOLD}🔄 尝试镜像源: $mirror_name${NC}"
    
    # 下载到缓存目录
    install_script="$CACHE_DIR/install_core.sh"
    rm -f "$install_script" # 清理旧文件
    
    if curl -fsSL --connect-timeout 15 --max-time 60 "$mirror" -o "$install_script"; then
        # 设置执行权限
        chmod +x "$install_script"
        
        # 执行安装脚本并记录错误
        if bash "$install_script" 2>"$error_log"; then
            install_success=true
            echo -e "${GREEN}${BOLD}✅ 安装成功！使用镜像源: $mirror_name${NC}"
            rm -f "$install_script" "$error_log" # 清理临时文件
            break
        else
            echo -e "${RED}${BOLD}❌ 安装脚本执行失败${NC}"
            if [ -f "$error_log" ] && [ -s "$error_log" ]; then
                echo -e "${YELLOW}${BOLD}📝 错误详情：${NC}"
                head -10 "$error_log" 2>/dev/null || echo "无法读取错误日志"
            fi
        fi
    else
        echo -e "${RED}${BOLD}❌ 下载失败: $mirror_name${NC}"
    fi

    echo -e "${YELLOW}${BOLD}🔄 尝试下一个镜像源...${NC}"
    rm -f "$install_script" # 清理失败的下载
    sleep 2 # 短暂等待
done

# ==== 安装结果处理（增强版） ====
if [ "$install_success" = true ]; then
    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "🎉🎉🎉 恭喜小白！安装成功！🎉🎉🎉"
    echo "✨ 你现在可以和AI聊天了！"
    echo "💕 是不是很简单？"
    echo "=================================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}${BOLD}🎯 下一步操作（超简单）：${NC}"
    echo -e "${GREEN}${BOLD}1. 重启Termux应用${NC}"
    echo -e "${GREEN}${BOLD}2. 选择"1. 🚀 启动 SillyTavern"${NC}"
    echo -e "${GREEN}${BOLD}3. 在浏览器中打开 http://localhost:8000${NC}"
    echo -e "${GREEN}${BOLD}4. 开始和AI聊天！${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}💡 小贴士：${NC}"
    echo -e "${YELLOW}  📱 以后打开Termux会自动显示菜单${NC}"
    echo -e "${YELLOW}  🌐 聊天地址永远是：http://localhost:8000${NC}"
    echo -e "${YELLOW}  🔄 如需重启，选择菜单中的启动选项${NC}"
    
else
    echo ""
    echo -e "${RED}${BOLD}"
    echo "💔 安装失败了..."
    echo "=================================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}${BOLD}🔧 可能的解决方法：${NC}"
    echo -e "${GREEN}${BOLD}1. 检查网络连接是否稳定${NC}"
    echo -e "${GREEN}${BOLD}2. 确保连接WiFi网络而非移动数据${NC}"
    echo -e "${GREEN}${BOLD}3. 尝试更换网络环境${NC}"
    echo -e "${GREEN}${BOLD}4. 重新运行安装命令${NC}"
    echo ""
    
    # 显示详细错误信息
    if [ -f "$error_log" ] && [ -s "$error_log" ]; then
        echo -e "${CYAN}${BOLD}📝 详细错误信息：${NC}"
        echo -e "${YELLOW}$(head -20 "$error_log")${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}${BOLD}📞 需要帮助？${NC}"
    echo -e "${YELLOW}  可以尝试手动运行以下命令：${NC}"
    echo -e "${GREEN}  curl -fsSL https://ghfast.top/https://github.com/nb95276/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh | bash${NC}"
    echo ""
    echo -e "${YELLOW}  或者联系技术支持获取帮助${NC}"
fi

# 清理临时文件
rm -f "$CACHE_DIR/install_core.sh" "$error_log"

echo ""
echo -e "${BRIGHT_MAGENTA}${BOLD}💖 感谢使用小白专用安装脚本！${NC}"
echo -e "${CYAN}${BOLD}🌸 让AI聊天变得简单，这就是我们的目标！${NC}" 