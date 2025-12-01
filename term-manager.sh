#!/bin/bash

# --- 함수 정의: 파일 존재 여부 확인 ---
check_file() {
    if [ ! -e "$1" ]; then
        echo "🚨 오류: 파일 또는 디렉토리 '$1'이(가) 존재하지 않습니다."
        return 1
    fi
    return 0
}

# --- 메뉴 출력 함수 ---
display_menu() {
    echo ""
    echo "=============================="
    echo "   [ Perm Manager 메뉴 ]"
    echo "=============================="
    echo "1. 파일/디렉토리 권한 확인 (ls -l, stat)"
    echo "2. 파일/디렉토리 소유자/그룹 변경 (chown)"
    echo "3. 파일/디렉토리 권한 변경 (chmod)"
    echo "4. 특정 사용자/그룹이 소유한 파일 목록 조회 (find)"
    echo "5. 종료"
    echo "=============================="
    read -p "메뉴 선택 (1-5): " CHOICE
}

# --- while + if : 메뉴 루프 및 조건문 처리 ---
while true; do
    display_menu

    # if 조건문을 사용한 메뉴 선택 처리
    if [ "$CHOICE" == "1" ]; then
        # 메뉴 1: 권한 확인 (ls -l, stat)
        read -p "확인할 파일/디렉토리 경로를 입력하세요: " PATH_NAME
        if check_file "$PATH_NAME"; then
            echo ""
            echo "--- [1-1. 간략 권한 정보 (ls -l)] ---"
            # ls -ld: 디렉토리 내용이 아닌 디렉토리 자체 정보를 출력
            ls -ld "$PATH_NAME"
            echo ""
            echo "--- [1-2. 세부 파일 정보 (stat)] ---"
            # stat: 세부 파일 정보 확인
            stat "$PATH_NAME"
        fi

    elif [ "$CHOICE" == "2" ]; then
        # 메뉴 2: 소유자, 그룹 변경 (chown)
        read -p "변경할 파일/디렉토리 경로를 입력하세요: " PATH_NAME
        if check_file "$PATH_NAME"; then
            read -p "새 소유자 (변경 없으면 Enter): " NEW_OWNER
            read -p "새 그룹 (변경 없으면 Enter): " NEW_GROUP
            
            OWNER_GROUP="${NEW_OWNER}:${NEW_GROUP}"
            # chown 명령어를 사용하여 소유자/그룹 변경. sudo 권한이 필요할 수 있습니다.
            echo "sudo chown ${OWNER_GROUP} ${PATH_NAME} 실행 시도..."
            sudo chown "$OWNER_GROUP" "$PATH_NAME"
            if [ $? -eq 0 ]; then
                echo "✅ 소유자/그룹 변경 완료."
            else
                echo "❌ 소유자/그룹 변경 실패. sudo 권한을 확인하세요."
            fi
        fi

    elif [ "$CHOICE" == "3" ]; then
        # 메뉴 3: 권한 변경 (chmod)
        read -p "변경할 파일/디렉토리 경로를 입력하세요: " PATH_NAME
        if check_file "$PATH_NAME"; then
            read -p "새 권한 (예: 755)을 입력하세요: " NEW_PERM
            
            # chmod 명령어를 사용하여 권한 변경.
            echo "chmod ${NEW_PERM} ${PATH_NAME} 실행 시도..."
            chmod "$NEW_PERM" "$PATH_NAME"
            if [ $? -eq 0 ]; then
                echo "✅ 권한 변경 완료."
            else
                echo "❌ 권한 변경 실패. 권한 형식을 확인하세요."
            fi
        fi

    elif [ "$CHOICE" == "4" ]; then
        # 메뉴 4: 특정 사용자/그룹이 접근 가능한 파일 목록 조회 (find)
        read -p "소유자를 기준으로 검색하려면 'user', 그룹을 기준으로 검색하려면 'group'을 입력하세요: " CRITERIA
        
        if [ "$CRITERIA" == "user" ]; then
            read -p "조회할 사용자 이름(Owner)을 입력하세요: " SEARCH_USER
            echo ""
            echo "--- [사용자 ${SEARCH_USER}가 소유한 파일/디렉토리 목록] ---"
            # find 명령어를 사용하여 특정 사용자 소유 파일 검색
            find . -type f -user "$SEARCH_USER" -ls
            find . -type d -user "$SEARCH_USER" -ls
            
        elif [ "$CRITERIA" == "group" ]; then
            read -p "조회할 그룹 이름(Group)을 입력하세요: " SEARCH_GROUP
            echo ""
            echo "--- [그룹 ${SEARCH_GROUP}이 소유한 파일/디렉토리 목록] ---"
            # find 명령어를 사용하여 특정 그룹 소유 파일 검색
            find . -type f -group "$SEARCH_GROUP" -ls
            find . -type d -group "$SEARCH_GROUP" -ls
            
        else
            echo "🚨 오류: 잘못된 기준입니다. 'user' 또는 'group'을 입력하세요."
        fi

    elif [ "$CHOICE" == "5" ]; then
        # 메뉴 5: 종료
        echo "Perm Manager를 종료합니다."
        break # while 루프 종료

    else
        echo "🚨 오류: 1부터 5 사이의 숫자를 입력해 주세요."
    fi
done