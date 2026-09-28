#!/bin/sh

# ==================== 具体任务执行函数 ====================
get_cloudflared() {
    echo ">>> [TODO] 正在获取/安装 cloudflared..."
    # 可以在这里添加 curl/wget 下载逻辑
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
