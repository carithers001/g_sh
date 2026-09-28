#!/bin/sh

# ==================== 具体任务执行函数 ====================
get_cloudflared() {
    echo "=========================================="
    echo "    正在下载最新版 cloudflared 到当前目录 "
    echo "=========================================="

    # 1. 检查下载工具
    DOWNLOADER=""
    if command -v curl >/dev/null 2>&1; then
        DOWNLOADER="curl"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOADER="wget"
    else
        echo "[-] 错误：系统中未检测到 curl 或 wget。"
        return 1
    fi

    # 2. 识别系统架构并映射
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            CF_ARCH="amd64"
            ;;
        aarch64|arm64)
            CF_ARCH="arm64"
            ;;
        armv7l|armhf)
            CF_ARCH="arm"
            ;;
        i386|i686)
            CF_ARCH="386"
            ;;
        *)
            echo "[-] 错误：当前系统架构 ($ARCH) 暂无预编译支持。"
            return 1
            ;;
    esac

    FILE_NAME="cloudflared-linux-${CF_ARCH}"
    DOWNLOAD_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/${FILE_NAME}"
    TARGET_BIN="./ccc"
    TMP_FILE="./cloudflared.tmp"

    echo "[+] 系统架构: ${ARCH} (对应资源: ${FILE_NAME})"
    echo "[+] 保存位置: $(pwd)/cloudflared"

    # 3. 下载到当前目录临时文件
    echo "[+] 正在下载..."
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fL --progress-bar -o "$TMP_FILE" "$DOWNLOAD_URL"
    else
        wget -q --show-progress -O "$TMP_FILE" "$DOWNLOAD_URL"
    fi

    if [ $? -ne 0 ] || [ ! -s "$TMP_FILE" ]; then
        echo "[-] 下载失败，请检查网络连接。"
        rm -f "$TMP_FILE"
        return 1
    fi

    # 4. 覆盖命名并赋予执行权限
    mv -f "$TMP_FILE" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"

    # 5. 验证运行
    echo "[+] 下载完成！"
    "$TARGET_BIN" --version
}

get_xtunnel() {
    echo ">>> [TODO] 正在获取/安装 xtunnel..."
}

get_xray() {
    echo ">>> [TODO] 正在获取/安装 xray..."
}

get_singbox() {
    echo ">>> [TODO] 正在获取/安装 sing-box..."
}

# ==================== 二级菜单：fly ====================
fly_menu() {
    while true; do
        echo ""
        echo "=================================="
        echo "           Fly 子菜单             "
        echo "=================================="
        echo " 1) 获取 cloudflared"
        echo " 2) 获取 xtunnel"
        echo " 3) 获取 xray"
        echo " 4) 获取 sing-box"
        echo " 0) 返回上一级菜单"
        echo "=================================="
        printf "请输入数字 [0-4]: "
        read -r sub_choice

        case "$sub_choice" in
            1)
                get_cloudflared
                ;;
            2)
                get_xtunnel
                ;;
            3)
                get_xray
                ;;
            4)
                get_singbox
                ;;
            0)
                echo "返回主菜单..."
                break  # 跳出当前 while 循环，返回上一层
                ;;
            *)
                echo "输入无效，请输入 0 到 4 之间的数字！"
                ;;
        esac
    done
}

# ==================== 一级主菜单 ====================
main_menu() {
    while true; do
        echo ""
        echo "=================================="
        echo "            主菜单                "
        echo "=================================="
        echo " 1) fly"
        echo " 2) 功能待添加..."
        echo " 0) 退出程序"
        echo "=================================="
        printf "请输入数字 [0-2]: "
        read -r main_choice

        case "$main_choice" in
            1)
                fly_menu
                ;;
            2)
                echo "功能 2 尚未实现。"
                ;;
            0)
                echo "已退出脚本。"
                exit 0
                ;;
            *)
                echo "输入无效，请输入 0 到 2 之间的数字！"
                ;;
        esac
    done
}

# 启动主菜单
main_menu
