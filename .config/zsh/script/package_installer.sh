#!/bin/bash

helpinfo="    package-installer使用方法
    pi [options] [...] <input_file>
    eg: pi -i apt packages or pi -i packages
    -s              批量检索软件包    [选项] [包管理器(可选)]
    -i              批量安装软件包    [选项] [包管理器(可选)]
    -ic             批量安装软件包(检查对应包命令是否存在)    [选项] [包管理器(可选)]
    -r              批量卸载软件包    [选项] [包管理器(可选)]
    -h, --help      帮助信息
    input_file    软件包列表文件
    
    软件包列表文件格式说明:
    #为注释符，每行一个软件包名，可选择在软件包后以空格隔开写入软件包的对应启动命令(eg: git git)。
    若包后有启动命令，可使用./package_install.sh -ic packages命令在安装软件时检查软件启动命令是否存在，若存在，则不会安装该包。"



load_custom_package_manager()
{
    if [[ "$package_manager" == "pacman" ]]; then
        search_command="pacman -Ss ^\${package_name}\\\$"
        install_command="pacman -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="pacman -Qs ^\${package_name}\\\$"
        uninstall_command="pacman -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
	elif [[ "$package_manager" == "paru" ]]; then
		search_command="paru -Ss -x ^\${package_name}\\\$"
        install_command="paru -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="paru -Qs ^\${package_name}\\\$"
        uninstall_command="paru -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
	elif [[ "$package_manager" == "yay" ]]; then
		search_command="yay -Ss \${package_name}"
        install_command="yay -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="yay -Qs ^\${package_name}\\\$"
        uninstall_command="yay -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
    elif [[ "$package_manager" == "apt" || "$package_manager" == "apt-get" ]]; then
        search_command="apt-cache search ^\${package_name}\\\$"
        install_command="apt-get install -y \${package_name} 2>&1 >/dev/null"
        query_command="dpkg -l \${package_name} 2>/dev/null"
        uninstall_command="apt-get remove -y \${package_name} 2>&1 >/dev/null"
    elif [[ "$package_manager" == "dnf" ]]; then
        search_command="dnf repoquery \${package_name} 2>/dev/null"
        install_command="dnf install -y \${package_name} 2>&1 >/dev/null"
        query_command="dnf  list --installed \${package_name} 2>/dev/null"
        uninstall_command="dnf remove -y \${package_name} 2>&1 >/dev/null"
    elif [[ "$package_manager" == "yum" ]]; then
        search_command="yum repoquery \${package_name} 2>/dev/null"
        install_command="yum install -y \${package_name} 2>&1 >/dev/null"
        query_command="yum list --installed \${package_name} 2>/dev/null"
        uninstall_command="yum remove -y \${package_name} 2>&1 >/dev/null"
    elif [[ "$package_manager" == "apk" ]]; then
        search_command="apk search \${package_name} | sed -E 's/(-[0-9].*)//' | grep \${package_name}"
        install_command="apk add \${package_name} 2>&1 >/dev/null"
        query_command="apk info \${package_name}"
        uninstall_command="apk del \${package_name} 2>&1 >/dev/null"
    else
        echo -e "\e[31m无法使用包管理器 ${package_manager}\e[0m"
        exit 1
	fi
	echo -e "\e[34m包管理器为 ${package_manager}\e[0m"
}



load_default_package_manager() 
{
    # 使用默认包管理器

    if command -v pacman &>/dev/null; then
        search_command="pacman -Ss ^\${package_name}\\\$"
        install_command="pacman -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="pacman -Qs ^\${package_name}\\\$"
        uninstall_command="pacman -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
	elif command -v paru &>/dev/null; then
		search_command="paru -Ss -x ^\${package_name}\\\$"
        install_command="paru -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="paru -Qs ^\${package_name}\\\$"
        uninstall_command="paru -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
    elif command -v yay &>/dev/null; then
		search_command="yay -Ss \${package_name}"
        install_command="yay -S --noconfirm \${package_name} 2>&1 >/dev/null"
        query_command="yay -Qs ^\${package_name}\\\$"
        uninstall_command="yay -Rns --noconfirm \${package_name} 2>&1 >/dev/null"
    elif command -v apt-get &>/dev/null; then
        search_command="apt-cache search ^\${package_name}\\\$"
        install_command="apt-get install -y \${package_name} 2>&1 >/dev/null"
        query_command="dpkg -l \${package_name} 2>/dev/null"
        uninstall_command="apt-get remove -y \${package_name} 2>&1 >/dev/null"
    elif command -v dnf &>/dev/null; then
        search_command="dnf repoquery \${package_name} 2>/dev/null"
        install_command="dnf install -y \${package_name} 2>&1 >/dev/null"
        query_command="dnf list --installed \${package_name} 2>/dev/null"
        uninstall_command="dnf remove -y \${package_name} 2>&1 >/dev/null"
    elif command -v yum &>/dev/null; then
        search_command="yum repoquery \${package_name} 2>/dev/null"
        install_command="yum install -y \${package_name} 2>&1 >/dev/null"
        query_command="yum list --installed \${package_name} 2>/dev/null"
        uninstall_command="yum remove -y \${package_name} 2>&1 >/dev/null"
    elif command -v apk &>/dev/null; then
        search_command="apk search \${package_name} | sed -E 's/(-[0-9].*)//' | grep \${package_name}"
        install_command="apk add \${package_name} 2>&1 >/dev/null"
        query_command="apk info \${package_name}"
        uninstall_command="apk del \${package_name} 2>&1 >/dev/null"
    else
        echo -e "\e[31m无法找到默认包管理器,请手动写入包管理器和规则\e[0m"
        exit 1
	fi
}

get_package_name()
{
    # 跳过以#开头的注释行和空行
    if [[ $package =~ ^#.*$|^$ ]]; then
        is_package=false
        return
    else
        is_package=true
    fi

    # 跳过以#开头的注释行和空行，性能不如上面的方式
    # if [[ -z "${package}" || ${package:0:1} == "#" ]]; then
    #     is_package=false
    #     return
    # else
    #     is_package=true
    # fi

    # 去除注释
    if [[ $package == *"#"* ]]; then
        package=${package%%#*}
    fi

    # 去除字符串两端空格
    # package=$(echo -e "${package}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # 性能不如下面的方式
    package=${package%%[[:space:]]}
    package=${package##[[:space:]]}

    if [[ -z "$package" ]]; then
        is_package=false
        return
    else
        is_package=true
    fi

    read -r package_name start_conmand <<< "$package"

    
}

load_package_manager()
{
    if [[ -z "$3" && -f "$2" ]]; then
        # 读取输入文件中的软件包名称
        input_file="$2"
        load_default_package_manager
    elif [[ -n "$3" && -f "$3" ]]; then
        # 读取输入文件中的软件包名称
        input_file="$3"
        package_manager="$2"
        load_custom_package_manager 
    else
        echo "请输入正确的参数"
        exit 1
    fi
}

# 批量检索软件
search_package()
{
    # 使用while循环逐行读取文件中的软件包名称
    while IFS= read -r package || [[ -n "$package" ]]; do

        # 获取正确的包名
        get_package_name

        if [[ $is_package == false ]]; then
            continue
        fi
        
        # 使用指定包管理器进行软件包搜索
        result=$(eval "${search_command}")

        # 检查搜索结果是否为空
        if [[ -z "$result" ]]; then
            error_search_results+="\e[31m软件包 $package_name 未找到\e[0m\n"
        fi
    done <"$input_file"
    if [[ -z "$error_search_results" ]]; then
        echo -e "\e[32m找到全部软件包\e[0m"
    else
        echo -e "$error_search_results"
    fi
}

# 安装软件
install_package()
{
    # 查询本地是否已安装软件包
    query_result=$(eval "${query_command}")
    if [[ -n "$query_result" ]]; then
        echo -e "软件包 $package_name 已安装\e[0m"
        return
    fi

    # 使用指定包管理器进行软件包搜索
    search_result=$(eval "${search_command}")
    # 检查搜索结果是否为空
    if [[ -z "$search_result" ]]; then
        error_search_results+="\n\e[31m软件包 $package_name 未找到\e[0m"
        return
    fi

    # 安装软件包
    install_result=$(eval "${install_command}")
    if [[ -z "$install_result" ]]; then
        echo -e "\e[32m软件包 $package_name 安装成功\e[0m"
    else
        error_install_results+="\n\e[31m软件包 $package_name 安装失败\e[0m\n"$install_result
    fi
}

# 批量安装软件
install_package_without_check_command()
{
    # 使用while循环逐行读取文件中的软件包名称
    while IFS= read -r package || [[ -n "$package" ]]; do

        # 获取正确的包名
        get_package_name

        if [[ $is_package == false ]]; then
            continue
        fi

        # 安装软件包
        install_package

    done <"$input_file"
    if [[ -n "$error_search_results" ]]; then
        echo -e "$error_search_results"
    fi
    if [[ -n "$error_install_results" ]]; then
        echo -e "$error_install_results"
    fi
}

# 批量安装软件(检查对应软件包的启动命令是否已存在)
install_package_with_check_command()
{
    # 使用while循环逐行读取文件中的软件包名称
    while IFS= read -r package || [[ -n "$package" ]]; do

        # 获取正确的包名
        get_package_name

        if [[ $is_package == false ]]; then
            continue
        fi

        if [[ -n "$start_conmand" ]]; then
            if command -v $start_conmand &>/dev/null; then
                echo -e "软件包 $package_name 的启动命令 $start_conmand 已存在\e[0m"
                continue
            fi
        fi

        # 安装软件包
        install_package


    done <"$input_file"
    if [[ -n "$error_search_results" ]]; then
        echo -e "$error_search_results"
    fi
    if [[ -n "$error_install_results" ]]; then
        echo -e "$error_install_results"
    fi   
}

# 批量卸载软件
uninstall_package()
{
    # 使用while循环逐行读取文件中的软件包名称
    while IFS= read -r package || [[ -n "$package" ]]; do

        # 获取正确的包名
        get_package_name

        if [[ $is_package == false ]]; then
            continue
        fi
        
        # 查询本地是否已安装软件包
        query_result=$(eval "${query_command}")
        if [[  -z "$query_result" ]]; then
            echo -e "软件包 $package_name 未安装\e[0m"
            continue
        fi

        # 卸载软件包
        uninstall_result=$(eval "${uninstall_command}")
        if [[ -z "$uninstall_result" ]]; then
            echo -e "\e[32m软件包 $package_name 卸载成功\e[0m"
        else
            error_uninstall_results+="\n\e[31m软件包 $package_name 卸载失败\e[0m\n"$uninstall_result
        fi

    done <"$input_file"
    if [[ -n "$error_uninstall_results" ]]; then
        echo -e "$error_uninstall_results"
    fi
}



# 检查参数是否为空
if [[ -z "$1" ]]; then
	echo "请输入正确的参数"
elif [[ "$1" == "-h"  ||  "$1" == "--help" ]]; then
    echo "${helpinfo}"
elif [[ $1 == "-s" ]]; then
    load_package_manager  "$1" "$2" "$3"
    search_package 
elif [[ $1 == "-i" ]]; then
    load_package_manager  "$1" "$2" "$3"
    install_package_without_check_command 
elif [[ $1 == "-ic" ]]; then
    load_package_manager  "$1" "$2" "$3"
    install_package_with_check_command 
elif [[ $1 == "-r" ]]; then
    load_package_manager  "$1" "$2" "$3"
    uninstall_package 
else
	echo "请输入正确的参数"
fi
