#!/bin/bash

# env-manager.sh
# 환경변수 존재 여부 확인 및 기본값 설정, 조회/변경 메뉴

TARGET_VAR=""
DEFAULT_VALUE=""

check_and_set_default() {
    if [ -z "$TARGET_VAR" ]; then
        echo "먼저 메뉴 1에서 관리할 환경변수 이름과 기본값을 설정하세요."
        return
    fi

    # ${VAR+x} : 설정되어 있으면 'x', 아니면 빈 문자열
    if [ -z "${!TARGET_VAR+x}" ]; then
        echo "환경변수 '$TARGET_VAR'가 설정되어 있지 않습니다."
        echo "기본값 '$DEFAULT_VALUE' 로 설정합니다."
        export "$TARGET_VAR=$DEFAULT_VALUE"
    else
        echo "환경변수 '$TARGET_VAR'는 이미 설정되어 있습니다."
    fi
}

show_value() {
    if [ -z "$TARGET_VAR" ]; then
        echo "먼저 메뉴 1에서 관리할 환경변수 이름과 기본값을 설정하세요."
        return
    fi

    if [ -z "${!TARGET_VAR+x}" ]; then
        echo "환경변수 '$TARGET_VAR'가 아직 설정되어 있지 않습니다."
    else
        echo "$TARGET_VAR=${!TARGET_VAR}"
    fi
}

change_value() {
    if [ -z "$TARGET_VAR" ]; then
        echo "먼저 메뉴 1에서 관리할 환경변수 이름과 기본값을 설정하세요."
        return
    fi

    read -p "새로운 값 입력: " new_val
    export "$TARGET_VAR=$new_val"
    echo "환경변수 '$TARGET_VAR' 값을 '$new_val' 로 변경했습니다."
}

unset_var() {
    if [ -z "$TARGET_VAR" ]; then
        echo "먼저 메뉴 1에서 관리할 환경변수 이름과 기본값을 설정하세요."
        return
    fi

    unset "$TARGET_VAR"
    echo "환경변수 '$TARGET_VAR' 를 제거했습니다."
}

while true; do
    echo "==============================="
    echo "        Env Manager"
    echo "==============================="
    echo "1) 관리할 환경변수 이름/기본값 설정"
    echo "2) 환경변수 값 확인 (필요 시 기본값으로 설정)"
    echo "3) 환경변수 값 변경"
    echo "4) 환경변수 제거(unset)"
    echo "5) 종료"
    echo "==============================="
    read -p "메뉴 번호를 선택하세요: " choice

    case "$choice" in
        1)
            read -p "관리할 환경변수 이름을 입력하세요 (예: MY_VAR): " TARGET_VAR
            read -p "기본값을 입력하세요: " DEFAULT_VALUE
            echo "관리 대상: $TARGET_VAR (기본값: $DEFAULT_VALUE)"
            echo
            ;;
        2)
            check_and_set_default
            show_value
            echo
            ;;
        3)
            change_value
            echo
            ;;
        4)
            unset_var
            echo
            ;;
        5)
            echo "Env Manager를 종료합니다."
            exit 0
            ;;
        *)
            echo "잘못된 입력입니다. 1~5 중에서 선택하세요."
            echo
            ;;
    esac
done