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
    echo "=========================================="
    echo "     正在下载最新版 Xray 到当前目录       "
    echo "=========================================="

    # 1. 检查必要工具 (curl/wget 与 unzip)
    DOWNLOADER=""
    if command -v curl >/dev/null 2>&1; then
        DOWNLOADER="curl"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOADER="wget"
    else
        echo "[-] 错误：系统中未检测到 curl 或 wget。"
        return 1
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo "[-] 错误：解压 Xray 需要 unzip，请先安装 (例如: apt install -y unzip 或 yum install -y unzip)。"
        return 1
    fi

    # 2. 映射系统架构
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            XRAY_ARCH="64"
            ;;
        aarch64|arm64)
            XRAY_ARCH="arm64-v8a"
            ;;
        armv7l|armhf)
            XRAY_ARCH="arm32-v7a"
            ;;
        i386|i686)
            XRAY_ARCH="32"
            ;;
        *)
            echo "[-] 错误：当前系统架构 ($ARCH) 暂无预编译支持。"
            return 1
            ;;
    esac

    ZIP_NAME="Xray-linux-${XRAY_ARCH}.zip"
    DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/latest/download/${ZIP_NAME}"
    TMP_ZIP="./xray_archive.tmp.zip"
    TMP_DIR="./xray_extract_tmp"
    TARGET_BIN="./rrr"

    echo "[+] 系统架构: ${ARCH} (对应资源: ${ZIP_NAME})"
    echo "[+] 下载地址: ${DOWNLOAD_URL}"

    # 3. 下载压缩包
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fL --progress-bar -o "$TMP_ZIP" "$DOWNLOAD_URL"
    else
        wget -q --show-progress -O "$TMP_ZIP" "$DOWNLOAD_URL"
    fi

    if [ $? -ne 0 ] || [ ! -s "$TMP_ZIP" ]; then
        echo "[-] 下载失败，请检查网络。"
        rm -f "$TMP_ZIP"
        return 1
    fi

    # 4. 解压并提取二进制文件
    echo "[+] 解压并提取核心二进制文件..."
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    unzip -q -o "$TMP_ZIP" -d "$TMP_DIR"

    if [ -f "${TMP_DIR}/xray" ]; then
        mv -f "${TMP_DIR}/xray" "$TARGET_BIN"
        chmod +x "$TARGET_BIN"
        echo "[+] 成功提取到: $(pwd)/xray"
    else
        echo "[-] 未在压缩包内找到 xray 可执行文件。"
        rm -rf "$TMP_DIR" "$TMP_ZIP"
        return 1
    fi

    # 5. 清理多余临时文件 (文档、geoip.dat、规则库及压缩包)
    rm -rf "$TMP_DIR" "$TMP_ZIP"

    # 6. 验证
    echo "[+] 验证运行结果:"
    "$TARGET_BIN" version
}

get_singbox() {
    echo "=========================================="
    echo "   正在下载最新版 sing-box 到当前目录     "
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

    # 2. 映射系统架构
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            SB_ARCH="amd64"
            ;;
        aarch64|arm64)
            SB_ARCH="arm64"
            ;;
        armv7l|armhf)
            SB_ARCH="armv7"
            ;;
        i386|i686)
            SB_ARCH="386"
            ;;
        *)
            echo "[-] 错误：当前系统架构 ($ARCH) 暂无预编译支持。"
            return 1
            ;;
    esac

    # 3. 动态获取最新 Release Tag (避免 API 速率限制)
    echo "[+] 获取最新版本号..."
    if [ "$DOWNLOADER" = "curl" ]; then
        LATEST_URL=$(curl -sIL -o /dev/null -w '%{url_effective}' "https://github.com/SagerNet/sing-box/releases/latest")
    else
        LATEST_URL=$(wget -q -S -O /dev/null "https://github.com/SagerNet/sing-box/releases/latest" 2>&1 | awk '/Location:/{print $2}' | tail -n 1)
    fi

    TAG="${LATEST_URL##*/}"
    VERSION="${TAG#v}"

    if [ -z "$VERSION" ]; then
        echo "[-] 无法获取最新版本号，请检查网络。"
        return 1
    fi

    TAR_NAME="sing-box-${VERSION}-linux-${SB_ARCH}.tar.gz"
    DOWNLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${TAG}/${TAR_NAME}"
    TMP_TAR="./sing-box_archive.tmp.tar.gz"
    TMP_DIR="./sing-box_extract_tmp"
    TARGET_BIN="./sss"

    echo "[+] 检测到最新版本: ${VERSION} (${ARCH} -> ${SB_ARCH})"
    echo "[+] 下载地址: ${DOWNLOAD_URL}"

    # 4. 下载压缩包
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fL --progress-bar -o "$TMP_TAR" "$DOWNLOAD_URL"
    else
        wget -q --show-progress -O "$TMP_TAR" "$DOWNLOAD_URL"
    fi

    if [ $? -ne 0 ] || [ ! -s "$TMP_TAR" ]; then
        echo "[-] 下载失败，请检查网络。"
        rm -f "$TMP_TAR"
        return 1
    fi

    # 5. 解压并递归提取 sing-box 二进制文件
    echo "[+] 正在解压并清理..."
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    tar -xzf "$TMP_TAR" -C "$TMP_DIR"

    # 在解压出的多层子目录中匹配二进制执行文件
    FOUND_BIN=$(find "$TMP_DIR" -type f -name "sing-box" | head -n 1)

    if [ -n "$FOUND_BIN" ] && [ -f "$FOUND_BIN" ]; then
        mv -f "$FOUND_BIN" "$TARGET_BIN"
        chmod +x "$TARGET_BIN"
        echo "[+] 成功提取到: $(pwd)/sing-box"
    else
        echo "[-] 未在压缩包内找到 sing-box 文件。"
        rm -rf "$TMP_DIR" "$TMP_TAR"
        return 1
    fi

    # 6. 删除解压目录和压缩包
    rm -rf "$TMP_DIR" "$TMP_TAR"

    # 7. 验证
    echo "[+] 验证运行结果:"
    "$TARGET_BIN" version
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
