#!/bin/sh

pause() {
    printf "\n按 [回车键] 返回菜单..."
    read -r _ < /dev/tty
}

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
    clear
    echo "=========================================="
    echo "    正在下载 xtunnel 到当前目录           "
    echo "=========================================="

    # 1. 检查基础下载工具
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
            XT_ARCH="amd64"
            ;;
        aarch64|arm64)
            XT_ARCH="arm64"
            ;;
        i386|i686)
            XT_ARCH="386"
            ;;
        *)
            echo "[-] 错误：当前系统架构 ($ARCH) 暂无预编译支持（仅支持 386/amd64/arm64）。"
            return 1
            ;;
    esac

    FILE_NAME="x-tunnel-linux-${XT_ARCH}"
    DOWNLOAD_URL="https://github.com/carithers001/g_docker_nodejs/releases/download/V0.01/${FILE_NAME}"
    TARGET_BIN="./xxx"
    TMP_FILE="./xtunnel.tmp"

    echo "[+] 系统架构: ${ARCH} (匹配文件: ${FILE_NAME})"
    echo "[+] 下载地址: ${DOWNLOAD_URL}"

    # 3. 下载到临时文件
    echo "[+] 正在下载..."
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fL --progress-bar -o "$TMP_FILE" "$DOWNLOAD_URL"
    else
        wget -q --show-progress -O "$TMP_FILE" "$DOWNLOAD_URL"
    fi

    if [ $? -ne 0 ] || [ ! -s "$TMP_FILE" ]; then
        echo "[-] 下载失败，请检查网络连接或目标地址是否存在。"
        rm -f "$TMP_FILE"
        return 1
    fi

    # 4. 重命名并赋予可执行权限
    mv -f "$TMP_FILE" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"

    # 5. 验证文件
    if [ -x "$TARGET_BIN" ]; then
        echo "[+] 下载成功！文件路径: $(pwd)/xtunnel"
        ls -lh "$TARGET_BIN"
    else
        echo "[-] 文件下载异常。"
        return 1
    fi
}

get_xray() {
    clear
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
    clear
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

# ==================== 运行任务函数 ====================
run_cloudflared() {
    # 1. 检查二进制文件
    if [ ! -x "./ccc" ]; then
        echo "[-] 未检测到可执行文件 ./ccc，请先执行下载！"
        return 1
    fi

    # 2. 接收输入并自动过滤出 ey 开头的 token
    printf "请输入或粘贴 Token / 启动指令: "
    read -r raw_input < /dev/tty

    # 仅提取以 ey 开头、长度大于 20 位的 Base64 字符串，忽略前后其他命令
    cf_token=$(echo "$raw_input" | grep -o 'ey[A-Za-z0-9_=-]\{20,\}' | head -n 1)

    if [ -z "$cf_token" ]; then
        echo "[-] 错误：未识别到有效 Token（必须以 ey 开头）！"
        return 1
    fi

    # 3. 后台静默启动（不生成任何日志文件，完全丢弃到 /dev/null）
    echo "[+] 正在后台启动 ccc..."
    nohup ./ccc tunnel run --edge-ip-version 4 --protocol http2 --no-autoupdate --token "$cf_token" > /dev/null 2>&1 &
    pid=$!

    # 4. 检验进程是否存活
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo "[+] ccc 启动成功！"
        echo "[+] 后台 PID: ${pid}"
    else
        echo "[-] 启动失败，进程未正常驻留。"
    fi
}

run_xtunnel() {
    clear
    # 1. 检查当前目录下是否存在 xxx
    if [ ! -x "./xxx" ]; then
        echo "[-] 未检测到可执行文件 ./xxx，请先选择 [2] 下载！"
        return 1
    fi

    # 2. 交互式接收 Token 输入
    printf "请输入 xtunnel Token (例如 free): "
    read -r xt_token < /dev/tty

    # 去除可能误输入的首尾空格
    xt_token=$(echo "$xt_token" | tr -d '[:space:]')

    if [ -z "$xt_token" ]; then
        echo "[-] 错误：Token 不能为空！"
        return 1
    fi

    # 3. 后台启动进程
    echo "[+] 正在后台启动 xxx..."
    nohup ./xxx -l ws://127.0.0.1:8081 -token "$xt_token" > /dev/null 2>&1 &
    pid=$!

    # 4. 验证进程是否成功驻留
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo "[+] xxx 启动成功！"
        echo "[+] 后台 PID: ${pid}"
    else
        echo "[-] 启动异常，进程已退出。可尝试直接运行排查: ./xxx -l ws://127.0.0.1:8081 -token $xt_token"
    fi
}

run_xray() {
    # 1. 检查二进制文件（优先检测 rrr，兼容 xray）
    BIN="./rrr"
    if [ ! -x "$BIN" ]; then
        if [ -x "./xray" ]; then
            BIN="./xray"
        else
            echo "[-] 未检测到可执行文件 ./rrr (或 ./xray)，请先下载！"
            return 1
        fi
    fi

    # 2. 交互式获取端口（默认 8088）
    DEFAULT_PORT="8088"
    printf "请输入监听端口 (直接回车默认: %s): " "$DEFAULT_PORT"
    read -r input_port < /dev/tty
    input_port=$(echo "$input_port" | tr -d '[:space:]')
    PORT="${input_port:-$DEFAULT_PORT}"

    # 3. 交互式获取 UUID（默认 32124d66-a097-417e-bdfe-4e80f7f460e5）
    DEFAULT_UUID="32124d66-a097-417e-bdfe-4e80f7f460e5"
    printf "请输入 UUID (直接回车默认: %s): " "$DEFAULT_UUID"
    read -r input_uuid < /dev/tty
    input_uuid=$(echo "$input_uuid" | tr -d '[:space:]')
    UUID="${input_uuid:-$DEFAULT_UUID}"

    # 4. 动态生成 config.json
    cat <<EOF > config.json
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/v1"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

    # 5. 后台静默启动（不生成任何日志）
    echo "[+] 正在后台启动 ${BIN}..."
    nohup "$BIN" run > /dev/null 2>&1 &
    pid=$!

    # 6. 校验运行状态
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo "[+] Xray 启动成功！"
        echo "[+] 监听地址: 127.0.0.1:${PORT}"
        echo "[+] 协议类型: VLESS + WebSocket"
        echo "[+] Path路径: /v1"
        echo "[+] 当前UUID: ${UUID}"
        echo "[+] 后台 PID: ${pid}"
    else
        echo "[-] 启动失败，进程未正常驻留（请确认端口 ${PORT} 未被占用）。"
        return 1
    fi
}

run_singbox() {
    # 1. 检查二进制文件（优先检测 sss，兼容 sing-box）
    BIN="./sss"
    if [ ! -x "$BIN" ]; then
        if [ -x "./sing-box" ]; then
            BIN="./sing-box"
        else
            echo "[-] 未检测到可执行文件 ./sss (或 ./sing-box)，请先下载！"
            return 1
        fi
    fi

    # 2. 交互式获取端口（默认 8088）
    DEFAULT_PORT="8088"
    printf "请输入监听端口 (直接回车默认: %s): " "$DEFAULT_PORT"
    read -r input_port < /dev/tty
    input_port=$(echo "$input_port" | tr -d '[:space:]')
    PORT="${input_port:-$DEFAULT_PORT}"

    # 3. 交互式获取 UUID（默认 32124d66-a097-417e-bdfe-4e80f7f460e5）
    DEFAULT_UUID="32124d66-a097-417e-bdfe-4e80f7f460e5"
    printf "请输入 UUID (直接回车默认: %s): " "$DEFAULT_UUID"
    read -r input_uuid < /dev/tty
    input_uuid=$(echo "$input_uuid" | tr -d '[:space:]')
    UUID="${input_uuid:-$DEFAULT_UUID}"

    # 4. 动态生成 sing-box 配置文件 config.json
    cat <<EOF > config.json
{
  "log": {
    "disabled": true
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "127.0.0.1",
      "listen_port": $PORT,
      "users": [
        {
          "name": "default",
          "uuid": "$UUID"
        }
      ],
      "transport": {
        "type": "ws",
        "path": "/v1"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

    # 5. 后台静默启动（不生成任何日志）
    echo "[+] 正在后台启动 ${BIN}..."
    nohup "$BIN" run > /dev/null 2>&1 &
    pid=$!

    # 6. 校验运行状态
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo "[+] sing-box 启动成功！"
        echo "[+] 监听地址: 127.0.0.1:${PORT}"
        echo "[+] 协议类型: VLESS + WebSocket"
        echo "[+] Path路径: /v1"
        echo "[+] 当前UUID: ${UUID}"
        echo "[+] 配置文件: $(pwd)/config.json"
        echo "[+] 后台 PID: ${pid}"
    else
        echo "[-] 启动失败，进程未正常驻留（请确认端口 ${PORT} 未被占用）。"
        return 1
    fi
}

# ==================== 二级菜单：fly ====================
fly_menu() {
    while true; do
        clear
        echo ""
        echo "=================================="
        echo "           Fly 子菜单             "
        echo "=================================="
        echo " [下载区]"
        echo "  1) 获取 cloudflared"
        echo "  2) 获取 xtunnel"
        echo "  3) 获取 xray"
        echo "  4) 获取 sing-box"
        echo "----------------------------------"
        echo " [运行区]"
        echo " 51) 运行 cloudflared"
        echo " 52) 运行 xtunnel"
        echo " 53) 运行 xray"
        echo " 54) 运行 sing-box"
        echo "----------------------------------"
        echo "  0) 返回上一级菜单"
        echo "=================================="
        printf "请输入数字: "
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
            51)
                run_cloudflared
                ;;
            52)
                run_xtunnel
                ;;
            53)
                run_xray
                ;;
            54)
                run_singbox
                ;;
            0)
                echo "返回主菜单..."
                break
                ;;
            *)
                echo "输入无效，请重新输入！"
                ;;
        esac
        pause
    done
}
# ======================================================================================================================================================
# ==================== 软件包管理辅助函数 ====================
detect_pm() {
    [ "$(id -u)" -ne 0 ] && SUDO="sudo" || SUDO=""

    if command -v apt-get >/dev/null 2>&1; then
        PM="apt"
        PM_INSTALL="$SUDO apt-get update -y && $SUDO apt-get install -y"
    elif command -v dnf >/dev/null 2>&1; then
        PM="dnf"
        PM_INSTALL="$SUDO dnf install -y"
    elif command -v yum >/dev/null 2>&1; then
        PM="yum"
        PM_INSTALL="$SUDO yum install -y"
    elif command -v apk >/dev/null 2>&1; then
        PM="apk"
        PM_INSTALL="$SUDO apk add --no-cache"
    elif command -v pacman >/dev/null 2>&1; then
        PM="pacman"
        PM_INSTALL="$SUDO pacman -Sy --noconfirm"
    else
        echo "[-] 未识别到受支持的包管理器 (apt/dnf/yum/apk/pacman)！"
        return 1
    fi
}

install_epel_if_needed() {
    # CentOS / RHEL 系列需要启用 EPEL 源才能安装 vnstat / iftop
    if [ "$PM" = "yum" ] || [ "$PM" = "dnf" ]; then
        echo "[+] 检测到 RHEL/CentOS 系列，正在确保 EPEL 源已启用..."
        $PM_INSTALL epel-release >/dev/null 2>&1
    fi
}

# ==================== 具体安装功能 ====================
install_curl_wget() {
    echo "[+] 正在安装 curl 和 wget..."
    detect_pm || return 1
    sh -c "$PM_INSTALL curl wget ca-certificates"
    echo "[+] 安装完成！"
}

install_ps_proc() {
    echo "[+] 正在安装 ps (procps) 及系统排查工具..."
    detect_pm || return 1

    # 包名兼容处理
    case "$PM" in
        apt|apk)
            PKGS="procps htop lsof net-tools"
            ;;
        yum|dnf)
            PKGS="procps-ng htop lsof net-tools"
            ;;
        pacman)
            PKGS="procps-ng htop lsof net-tools"
            ;;
    esac

    sh -c "$PM_INSTALL $PKGS"
    echo "[+] 安装完成！当前 ps 状态："
    ps -V || ps --version
}

install_traffic_tools() {
    echo "[+] 正在安装网络流量监控与统计工具 (vnstat / iftop)..."
    detect_pm || return 1
    install_epel_if_needed

    sh -c "$PM_INSTALL vnstat iftop"

    # 如果有 systemd，自动启用并启动 vnstat 后台流量统计守护进程
    if command -v systemctl >/dev/null 2>&1; then
        echo "[+] 正在启动并设置 vnstat 流量统计开机自启..."
        $SUDO systemctl enable --now vnstat >/dev/null 2>&1
    fi

    echo "[+] 流量工具安装完成！"
    echo "----------------------------------------"
    echo "常用命令："
    echo "  - 查看历史流量统计: vnstat (需运行一段时间后生成数据)"
    echo "  - 查看实时网络吞吐: vnstat -l"
    echo "  - 查看实时连接连接与带宽消耗: iftop"
    echo "----------------------------------------"
}

install_archive_tools() {
    echo "[+] 正在安装常见解压缩工具 (tar, unzip, gzip, bzip2, xz)..."
    detect_pm || return 1

    case "$PM" in
        apt)
            PKGS="tar unzip gzip bzip2 xz-utils"
            ;;
        yum|dnf|apk|pacman)
            PKGS="tar unzip gzip bzip2 xz"
            ;;
    esac

    sh -c "$PM_INSTALL $PKGS"
    echo "[+] 解压工具安装完成！"
}

install_all_common() {
    echo "[+] 开始一键安装全部常用工具合集..."
    detect_pm || return 1
    install_epel_if_needed

    case "$PM" in
        apt|apk)
            PKGS="curl wget procps vnstat iftop htop lsof unzip tar ca-certificates net-tools"
            ;;
        yum|dnf)
            PKGS="curl wget procps-ng vnstat iftop htop lsof unzip tar ca-certificates net-tools"
            ;;
        pacman)
            PKGS="curl wget procps-ng vnstat iftop htop lsof unzip tar ca-certificates net-tools"
            ;;
    esac

    sh -c "$PM_INSTALL $PKGS"

    if command -v systemctl >/dev/null 2>&1; then
        $SUDO systemctl enable --now vnstat >/dev/null 2>&1
    fi

    echo "[+] 全部常用工具安装完成！"
}

# ==================== 二级菜单：install ====================
install_menu() {
    while true; do
        clear
        echo ""
        echo "=================================="
        echo "          Install 常用工具        "
        echo "=================================="
        echo "  1) 安装 下载工具 (curl, wget)"
        echo "  2) 安装 进程/系统工具 (ps/procps, htop, lsof)"
        echo "  3) 安装 流量统计与监控 (vnstat, iftop)"
        echo "  4) 安装 解压缩工具 (unzip, tar, gzip, xz)"
        echo " 99) 一键安装推荐全部工具"
        echo "----------------------------------"
        echo "  0) 返回上一级菜单"
        echo "=================================="
        printf "请输入数字 [0-4, 99]: "
        read -r ins_choice < /dev/tty

        case "$ins_choice" in
            1)
                install_curl_wget
                pause
                ;;
            2)
                install_ps_proc
                pause
                ;;
            3)
                install_traffic_tools
                pause
                ;;
            4)
                install_archive_tools
                pause
                ;;
            99)
                install_all_common
                pause
                ;;
            0)
                break
                ;;
            *)
                echo "输入无效，请重新输入！"
                pause
                ;;
        esac
    done
}

# =======================================================================================================================================================

# ==================== 一级主菜单 ====================
main_menu() {
    while true; do
        clear
        echo ""
        echo "=================================="
        echo "            主菜单                "
        echo "=================================="
        echo " 1) fly"
        echo " 2) install"
        echo " 0) 退出程序"
        echo "=================================="
        printf "请输入数字 [0-2]: "
        read -r main_choice < /dev/tty

        case "$main_choice" in
            1)
                fly_menu
                ;;
            2)
                install_menu
                ;;
            0)
                echo "已退出脚本。"
                exit 0
                ;;
            *)
                echo "输入无效，请输入 0 到 2 之间的数字！"
                pause
                ;;
        esac
    done
}

# 启动主菜单
main_menu
