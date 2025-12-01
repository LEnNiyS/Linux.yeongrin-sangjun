#!/bin/bash

# --- 입력 파라미터 체크 ---
# $#은 전달된 인자의 개수입니다.
if [ "$#" -ne 2 ]; then
    echo "사용법: $0 <반복 주기(초)> <총 반복 횟수>"
    exit 1
fi

INTERVAL=$1
COUNT=$2
CURRENT_COUNT=0
THRESHOLD_MEM=80 # 메모리 경고 임계치(%)

echo "--- Resource Watcher 시작 (주기: ${INTERVAL}초, 총 ${COUNT}회) ---"

# --- while + sleep: 주기적 모니터링 ---
while [ "$CURRENT_COUNT" -lt "$COUNT" ]; do
    
    CURRENT_COUNT=$((CURRENT_COUNT + 1))
    echo ""
    echo "### [${CURRENT_COUNT}/${COUNT}] 모니터링 시간: $(date '+%Y-%m-%d %H:%M:%S') ###"
    
    # --- 1. 메모리 사용량 (free 명령어 사용) ---
    # free -m 명령어로 결과를 가져와 awk로 특정 값 추출
    MEM_USED_MB=$(free -m | grep 'Mem:' | awk '{print $3}') # 사용된 메모리
    MEM_TOTAL_MB=$(free -m | grep 'Mem:' | awk '{print $2}') # 전체 메모리

    # 정수 연산으로 백분율 계산
    if [ "$MEM_TOTAL_MB" -gt 0 ]; then
        # $((...))는 셸의 산술 연산 문법입니다.
        MEM_PERC=$((MEM_USED_MB * 100 / MEM_TOTAL_MB))
    else
        MEM_PERC=0
    fi
    
    echo "메모리 사용률: ${MEM_PERC}% (${MEM_USED_MB}MB / ${MEM_TOTAL_MB}MB)"
    
    # --- 2. CPU 사용률 (vmstat 명령어 사용) ---
    # vmstat 1 2 : 1초 간격으로 2회 정보 출력. tail -n 1로 마지막 라인 사용
    # awk '{print $15}'로 idle(유휴) 시간 추출
    CPU_IDLE=$(vmstat 1 2 | tail -n 1 | awk '{print $15}')
    CPU_USAGE=$((100 - CPU_IDLE))

    echo "CPU 사용률: ${CPU_USAGE}%"

    # --- 3. 디스크 사용률 (df 명령어 사용) ---
    # df -h / : 루트(/) 파티션 정보. tail -n 1로 데이터 라인만 사용
    # awk '{print $5}'로 사용률(Use%) 추출 후 sed로 % 문자 제거
    DISK_PERC=$(df -h / | tail -n 1 | awk '{print $5}' | sed 's/%//g')

    echo "디스크 사용률(/): ${DISK_PERC}%"
    
    # --- 4. 조건문(if): 임계치 경고 출력 ---
    # -ge (greater than or equal to): 크거나 같음
    if [ "$MEM_PERC" -ge "$THRESHOLD_MEM" ]; then
        echo "🚨 경고: 메모리 사용률이 임계치 (${THRESHOLD_MEM}%)를 초과했습니다! (${MEM_PERC}%)"
    fi

    # 지정된 횟수를 모두 채웠다면 sleep을 건너뜁니다.
    if [ "$CURRENT_COUNT" -lt "$COUNT" ]; then
        sleep "$INTERVAL" # sleep 명령어
    fi
done

echo "--- Resource Watcher 종료 ---"