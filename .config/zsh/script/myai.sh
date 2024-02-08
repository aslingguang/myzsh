#!/usr/bin/bash

if [[ ! -f ~/.myai_history ]]; then
    touch ~/.myai_history
fi
history -r ~/.myai_history
# 初始化变量
previous_input=""

if [[ -n "$1" ]]; then
    previous_input="$1"
    if ! grep -Fxq "$previous_input" ~/.myai_history; then
        history -s ${previous_input}
        history -a
    fi
    echo "question: $previous_input"
fi

while true; do
    # 如果 previous_input 有值，则使用它作为本次问题
    if [[ -n "$previous_input" ]]; then
        input=$previous_input
        # echo "input: $input"
    else
        # 提示用户输入问题
        # echo -n "question: "
        read -e -p "question: " input
    fi

    # 判断输入是否为空
    if [[ -z "$input" ]]; then
        continue
    elif ! grep -Fxq "$input" $HOME/.myai_history; then
        history -s ${input}
        history -a
    fi

    # 执行命令并获取结果
    result=$(aichat -r sh ""$input"")

    # 判断返回结果是否为空
    if [[ -n "$result" ]]; then
        echo "answer: $result"
        echo "c:复制 e:执行 r:重复问题 q:退出 other(question)"

        # 获取用户选择
        # echo -n "input: "
        read -e -p "input: " choice

        case "$choice" in
            c) 
                echo "$result" | xclip -sel clip # 将结果复制到剪贴板
                ;;
            e)
                eval "$result" # 执行结果中的命令
                ;;
            r)
                # 保存当前问题以备下次循环使用
                previous_input=$input
                ;;
            q)
                echo "退出交互环境"
                break
                ;;
            *)
                previous_input="$choice"
                ;;
        esac
    else
        echo "没有返回结果。"
    fi

    # 清空 previous_input，以便在用户输入新问题时不被旧问题覆盖
    if [[ "$choice" == "c" || "$choice" == 'e' ]]; then
        previous_input=""
    fi

    result=""
    
done

history -w ~/.myai_history


