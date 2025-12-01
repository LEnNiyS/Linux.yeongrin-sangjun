#!/bin/bash

# user-monitor.sh
# 서버 로그인/로그 기록 모니터링 메뉴

while true; do
    echo "==============================="
    echo "        User Monitor"
    echo "==============================="
    echo "1) 현재 로그인한 사용자 목록"
    echo "2) 현재 로그인 중인 세션 수"
    echo "3) 최근 로그인 기록 N개 보기"
    echo "4) 특정 사용자 로그인 기록 보기"
    echo "5) 종료"
    echo "==============================="
    read -p "메뉴 번호를 선택하세요: " choice

    case "$choice" in
        1)
            echo "[현재 로그인한 사용자 목록]"
            # who: 접속 사용자, TTY, 로그인 시간 등
            who
            echo
            ;;
        2)
            echo "[현재 로그인 중인 세션 수]"
            # 세션 수 = who 출력 줄 수
            session_count=$(who | wc -l)
            echo "현재 로그인 세션 수: $session_count"
            echo
            ;;
        3)
            read -p "최근 로그인 기록 몇 개를 볼까요? (N): " N
            if [[ "$N" =~ ^[0-9]+$ ]] && [ "$N" -gt 0 ]; then
                echo "[최근 로그인 기록 상위 $N개]"
                last | head -n "$N"
            else
                echo "N은 1 이상의 정수여야 합니다."
            fi
            echo
            ;;
        4)
            read -p "로그인 기록을 보고 싶은 사용자 ID를 입력하세요: " user
            if [ -z "$user" ]; then
                echo "사용자 ID가 비어 있습니다."
            else
                echo "[사용자 '$user' 로그인 기록]"
                # last user명으로 필터링
                last "$user"
            fi
            echo
            ;;
        5)
            echo "User Monitor를 종료합니다."
            exit 0
            ;;
        *)
            echo "잘못된 입력입니다. 1~5 중에서 선택하세요."
            echo
            ;;
    esac
done