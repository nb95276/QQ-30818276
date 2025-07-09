@echo off
chcp 65001 >nul
title Git状态检查 - QQ-30818276 Termux版

echo ========================================
echo    Git状态检查 - QQ-30818276 Termux版
echo ========================================
echo.

echo 📱 当前目录: %CD%
echo 🎯 项目类型: SillyTavern-Termux Android版本
echo.

REM 检查是否在正确目录
if not "%CD:~-22%" == "SillyTavern-Termux-2.0.0" (
    echo ❌ 错误：不在正确的目录中
    echo 💡 请确保在: E:\SillyTavern\SillyTavern-Termux-2.0.0
    echo.
    pause
    exit /b 1
)

echo ✅ 目录位置正确
echo.

REM 检查是否已初始化Git
if not exist ".git" (
    echo ❌ Git仓库未初始化
    echo 💡 请先运行: git init
    echo.
    pause
    exit /b 1
)

echo ✅ Git仓库已初始化
echo.

echo 📋 当前Git状态:
echo ----------------------------------------
git status
echo.

echo 📁 将要添加的文件列表:
echo ----------------------------------------
git add . --dry-run
echo.

echo 🚫 被.gitignore排除的文件:
echo ----------------------------------------
git status --ignored | findstr "!!"
echo.

echo ✅ 应该推送的Termux核心文件:
echo ----------------------------------------
echo 📱 安装脚本:
echo   - Install.sh
echo   - Install_Latest_AutoUpdate.sh
echo   - Install_优化版.sh
echo.
echo 🔄 更新脚本:
echo   - Update_Mirror_Sources_Termux.sh
echo   - Apply_Mirror_Updates.sh
echo   - 一键更新镜像源.sh
echo.
echo 🧪 测试工具:
echo   - 测试镜像源速度.sh
echo   - 测试脚本.sh
echo   - 网络测试脚本.sh
echo.
echo 🎮 菜单系统:
echo   - menu.sh
echo   - menu_优化版.sh
echo.
echo 🛠️ 辅助工具:
echo   - emergency-rollback.sh
echo   - 准备部署文件.sh
echo   - 多源字体下载脚本.sh
echo   - 改进版字体安装脚本.sh
echo.
echo 📄 配置文件:
echo   - 一键安装命令.txt
echo   - 新用户一键安装命令.txt
echo   - .gitignore
echo.

echo ❌ 应该排除的文件:
echo ----------------------------------------
echo 📚 所有 .md 文档文件
echo 📁 docs/ 目录
echo 📖 README 相关文件
echo 📋 说明文档和指南
echo 📊 分析报告和流程图
echo.

echo 🔧 Git配置检查:
echo ----------------------------------------
echo 用户名: 
git config user.name
echo 邮箱: 
git config user.email
echo 远程仓库: 
git remote -v
echo.

echo 📊 文件统计:
echo ----------------------------------------
echo 总文件数: 
dir /b | find /c /v ""
echo .sh脚本文件: 
dir /b *.sh | find /c /v ""
echo .txt文件: 
dir /b *.txt | find /c /v ""
echo .md文档文件: 
dir /b *.md 2>nul | find /c /v ""
echo.

echo 💡 推送前检查清单:
echo ----------------------------------------
echo [ ] 确认在 SillyTavern-Termux-2.0.0 目录
echo [ ] 确认 .gitignore 正确配置
echo [ ] 确认没有 .md 文档文件被添加
echo [ ] 确认所有 .sh 脚本文件都被包含
echo [ ] 确认 Git 用户信息已配置
echo [ ] 确认远程仓库地址正确
echo.

echo 🚀 下一步操作:
echo ----------------------------------------
echo 1. 如果文件列表正确，运行: git add .
echo 2. 提交更改: git commit -m "Initial commit: SillyTavern-Termux Android安装脚本集合"
echo 3. 推送到GitHub: git push -u origin main
echo.

echo 🎯 推送后的8个安装命令:
echo ----------------------------------------
echo curl -fsSL https://ghproxy.net/https://github.com/你的用户名/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh ^| bash
echo curl -fsSL https://gh.ddlc.top/https://github.com/你的用户名/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh ^| bash
echo curl -fsSL https://ghfast.top/https://github.com/你的用户名/QQ-30818276/raw/main/Install_Latest_AutoUpdate.sh ^| bash
echo ... (共8个加速源)
echo.

echo 🚨 重要提醒:
echo ----------------------------------------
echo - 推送后记得更新脚本中的仓库地址
echo - 将 "你的用户名" 替换为实际GitHub用户名
echo - 测试安装命令确保可以正常下载
echo - 只推送脚本文件，不推送说明文档
echo.

pause
