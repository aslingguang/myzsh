#!/bin/bash


if [[ -n $(grep -Po "\s\-(ic?|r)(\s|$)" <<< " $@") ]]; then
    system_info=$(uname -a)
    if [[ $system_info != *Android* && "$(id -u)" -ne 0 && -z $(grep -Po "\s\-m\s+brew(\s|$)" <<< " $@") ]]; then
        echo -e "\e[31m以非root用户运行。切换到root权限...\e[0m"
        exec sudo "$0" "$@"
    fi
elif [[ -n $(echo " $@" | grep -Po '\s\-[^\s]+' | awk '{ if (length($0) > 3) { print length($0); exit} } ') ]]; then
    echo "参数错误"
    exit 1
fi

helpinfo="    package-installer使用方法
    pi [options] [...] package1 package2 ... 
    eg: pi -m apt -i package_name -f packages_file
    -s                            检索软件包    
    -i                            安装软件包    
    -ic                           安装软件包(检查对应包命令是否存在)    
    -f, --file <packages_file>    指定软件包列表文件   
    -r                            卸载软件包    
    -m <package_manager>          指定包管理器
    -h, --help                    帮助信息
    
    软件包列表文件格式说明:
    #为注释符,每行一个软件包名，可选择在软件包后以空格隔开写入软件包的对应启动命令(eg: git git)。
    若包后有启动命令,可使用./package_install.sh -ic packages命令在安装软件时检查软件启动命令是否存在,若存在,则不会安装该包。
    支持的包管理器: pacman, paru, yay, apt, dnf, yum, apk, brew"


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
        query_command="dpkg -L \${package_name} 2>/dev/null"
        uninstall_command="apt-get purge -y \${package_name} 2>&1 >/dev/null"
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
    elif [[ "$package_manager" == "brew" ]]; then
        search_command="brew search \${package_name} | grep ^\${package_name}$"
        install_command="brew install \${package_name} 2>&1 >/dev/null"
        query_command="brew list \${package_name} 2>/dev/null" 
        uninstall_command="brew uninstall \${package_name} 2>&1 >/dev/null"
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
        query_command="dpkg -L \${package_name} 2>/dev/null"
        uninstall_command="apt-get purge -y \${package_name} 2>&1 >/dev/null"
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
    elif command -v brew &>/dev/null; then
        search_command="brew search \${package_name} | grep ^\${package_name}$"
        install_command="brew install \${package_name} 2>&1 >/dev/null"
        query_command="brew list \${package_name} 2>/dev/null" 
        uninstall_command="brew uninstall \${package_name} 2>&1 >/dev/null"
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

# 检索软件
search_package()
{
    # 获取正确的包名
    get_package_name

    if [[ $is_package == false ]]; then
        return
    fi
    
    # 使用指定包管理器进行软件包搜索
    search_result=$(eval "${search_command}")

    # 检查搜索结果是否为空
    if [[ -z "$search_result" ]]; then
        error_results+="\e[31m软件包 $package_name 未找到\e[0m\n"
    else
        echo -e "\e[32m软件包 $package_name 已找到\e[0m"
    fi

}


# 安装软件
install_package()
{
    # 获取正确的包名
    get_package_name

    if [[ $is_package == false ]]; then
        return
    fi

    # 检查对应软件包的启动命令是否已存在
    if [[ "$check_command_option" == "install_package_with_check_command" ]]; then
        if [[ -n "$start_conmand" ]]; then
            if command -v $start_conmand &>/dev/null; then
                echo -e "软件包 $package_name 的启动命令 $start_conmand 已存在\e[0m"
                return
            fi
        fi
    fi

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
        error_results+="\n\e[31m软件包 $package_name 未找到\e[0m"
        return
    fi

    # 安装软件包
    install_result=$(eval "${install_command}" )
    if [[ -z "$install_result" ]]; then
        echo -e "\e[32m软件包 $package_name 安装成功\e[0m"
    else
        error_results+="\n\e[31m软件包 $package_name 安装失败\e[0m\n"
    fi
}


# 卸载软件
uninstall_package()
{

    # 获取正确的包名
    get_package_name

    if [[ $is_package == false ]]; then
        return
    fi
    
    # 查询本地是否已安装软件包
    query_result=$(eval "${query_command}")
    if [[  -z "$query_result" ]]; then
        echo -e "软件包 $package_name 未安装\e[0m"
        return
    fi

    # 卸载软件包
    uninstall_result=$(eval "${uninstall_command}")
    if [[ -z "$uninstall_result" ]]; then
        echo -e "\e[32m软件包 $package_name 卸载成功\e[0m"
    else
        error_results+="\n\e[31m软件包 $package_name 卸载失败\e[0m\n"
    fi
}


#-o或--options选项后面接可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
#-l或--long选项后面接可接受的长选项，用逗号分开，冒号的意义同短选项。
#-n选项后接选项解析错误时提示的脚本名字
# ARGS=`getopt -o srhm:f:i:: --long help,file:`
ARGS=`getopt -o srhm:f:i:: --long help,file: -n "$0" -- "$@"`
if [ $? != 0 ]; then
    echo "参数错误..."
    exit 1
fi

#echo $ARGS
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"

while true
do
    case "$1" in
        -h|--help) 
            echo "${helpinfo}";
            shift
            ;;
        -i) 
            case "$2" in
                "")
                    check_command_option="install_package_without_check_command";
                    package_manager_option="install_package";
                    shift 2  
                    ;;
                *)
                    if [[ "$2" == "c" ]];then
                        check_command_option="install_package_with_check_command"
                        package_manager_option="install_package";
                    fi
                    shift 2;
                    ;;
            esac
            ;;
        -s)
            package_manager_option="search_package";
            shift
            ;;
        -r)
            package_manager_option="uninstall_package";
            shift
            ;;            
        -m)
            package_manager="$2";
            shift 2
            ;;
        -f|--file)
            package_file="$2";
            shift 2
            ;;
        --)
            shift
            break
            ;;
        # *)
        #     echo "Internal error!"
        #     exit 1
        #     ;;
    esac
done

if [[ -n $package_manager ]];then
    load_custom_package_manager
else
    load_default_package_manager
fi

if [[ -f "$package_file" ]];then
    # 使用while循环逐行读取文件中的软件包名称
    while IFS= read -r package || [[ -n "$package" ]]; do
        eval "${package_manager_option}"
    done <"$package_file"
elif [[ -n $package ]];then
    echo -e "\e[31m文件 $package_file 不存在\e[0m"
fi

#处理剩余的参数
for arg in $@
do
    package="$arg"
    eval "${package_manager_option}"
done

if [[ -n "$error_results" ]]; then
    echo -e "$error_results"
fi
