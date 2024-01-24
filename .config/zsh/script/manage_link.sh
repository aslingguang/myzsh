#!/bin/bash 
# 本脚本用于批量管理软链接

# source_root_dir 为软链接目标文件所在目录
# link_root_dir 为软链接所在目录
# links_array 为目标文件相对路径及需要创建的软链接相对路径的集合
# eg: links_array=("users/.ssh .ssh") 则会创建软链接 $link_root_dir/.ssh -> $source_root_dir/users/.ssh

remove_link()
{
    if [[ -n "${link_root_dir}" ]]; then
        link_path="${link_root_dir}/$1"
    else
        link_path="$1"
    fi

    if [[ -h "${link_path}" ]]; then
        rm "${link_path}"
    elif [[ -e "${link_path}" ]]; then
        echo "${link_path} 不是软链接"
    fi
}

make_link()
{
    if [[ -n "${source_root_dir}" ]]; then
        source_path="${source_root_dir}/$1"
    else
        source_path="$1"
    fi

    if [[ -n "${link_root_dir}" ]]; then
        link_path="${link_root_dir}/$2"
    else
        link_path="$2"
    fi

    if [[ -e "${source_path}" ]]; then
        if [[ ! -e "${link_path}" ]]; then
            link_dir=$(dirname "${link_path}")
            if [[ ! -d "$link_dir" ]]; then
                mkdir -p "$link_dir"
            fi
            ln -s ${source_path} ${link_path}
            echo "创建软链接 ${link_path} -> ${source_path}"
        fi   
    else
        echo "源文件 ${source_path} 不存在"
    fi
}

check_file()
{
    if [[ -n "${link_root_dir}" ]]; then
        link_path="${link_root_dir}/$1"
    else
        link_path="$1"
    fi

    if [[ -h "${link_path}" ]]; then
        echo "已存在软链接 ${link_path}"
    elif [[ -f "${link_path}" ]]; then
        echo "已存在文件 ${link_path}"
    elif [[ -d "${link_path}" ]]; then
        echo "已存在目录 ${link_path}"
    else
        echo "文件 ${link_path} 不存在"
    fi
}

remove_links()
{
    for link in "${links_array[@]}"; do
    read -r relative_source_path relative_link_path <<< "$link"
    remove_link "$relative_link_path"
    done
}


make_links()
{
    for link in "${links_array[@]}"; do
    read -r relative_source_path relative_link_path <<< "$link"
    make_link "$relative_source_path" "$relative_link_path" 
    done
}


check_links()
{
    for link in "${links_array[@]}"; do
    read -r relative_source_path relative_link_path <<< "$link"
    check_file "$relative_link_path"
    done
}

gen_link_config()
{   
    config_path=$(pwd)/link_config
    echo "# source_root_dir 为软链接目标文件所在目录" > "${config_path}"
    echo "# link_root_dir 为软链接所在目录" >> "${config_path}"
    echo "# links_array 为目标文件相对路径及需要创建的软链接相对路径的集合" >> "${config_path}"
    echo "# eg: links_array=("users/.ssh .ssh") 则会创建软链接 \$link_root_dir/.ssh -> \$source_root_dir/users/.ssh" >> "${config_path}"
    echo "source_root_dir=\"\"" >> "${config_path}"
    echo "link_root_dir=\"\"" >> "${config_path}"
    echo "links_array=(\"source_path link_path\")" >> "${config_path}"
}

if [[ "$1" == "-r" && -f "$2" ]]; then
    source "$2"
    remove_links 
elif [[ "$1" == "-m" && -f "$2" ]]; then
    source "$2"
    make_links
elif [[ "$1" == "-c" && -f "$2" ]]; then
    source "$2"
    check_links
elif [[ "$1" == "-g" ]]; then
    gen_link_config
else
    echo "manage_link.sh 用法:"
    echo "-m : 生成软链接"
    echo "-r : 删除软链接"
    echo "-c : 检查软链接"
    echo "-g : 在当前目录下生成软链接配置文件(link_config)"

    echo -e "\nlink_config 说明:"
    echo "# source_root_dir 为软链接目标文件所在目录"
    echo "# link_root_dir 为软链接所在目录"
    echo "# links_array 为目标文件相对路径及需要创建的软链接相对路径的集合"
    echo "# eg: links_array=("users/.ssh .ssh") 则会创建软链接 \$link_root_dir/.ssh -> \$source_root_dir/users/.ssh"
fi 
