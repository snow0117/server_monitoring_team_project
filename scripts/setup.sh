#!/usr/bin/env bash
# 서버 모니터링 대시보드 - 통합 VM 설치 스크립트 (우분투)
#
# 하는 일
#   1) Prometheus, Node Exporter, Alertmanager, Nginx 설치
#   2) Grafana 공식 저장소를 추가하고 Grafana 설치
#   3) 저장소의 설정 파일을 각 위치에 복사
#   4) Discord 웹후크 주소를 VM에 있는 사본에만 입력 (저장소에는 올리지 않음)
#   5) 설정 문법 검사 후 서비스 재시작
#
# 사용법 (저장소 폴더에서)
#   bash scripts/setup.sh
#
# 주의
#   - 저장소의 alertmanager/alertmanager.yml에는 YOUR_WEBHOOK_URL 이라는 자리표시만 있어야 한다.
#   - 웹후크 주소는 스크립트 실행 중 물어볼 때만 입력한다 (화면에 표시되지 않는다).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "저장소 위치: ${REPO_DIR}"

echo
echo "[1/6] 기본 패키지 설치"
sudo apt-get update
sudo apt-get install -y \
  prometheus prometheus-node-exporter prometheus-alertmanager \
  nginx stress-ng curl wget gpg apt-transport-https

echo
echo "[2/6] Grafana 공식 저장소 추가 및 설치"
sudo mkdir -p /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
sudo apt-get update
sudo apt-get install -y grafana

echo
echo "[3/6] 설정 파일 복사"
sudo cp "${REPO_DIR}/prometheus/prometheus.yml" /etc/prometheus/prometheus.yml
sudo cp "${REPO_DIR}/alertmanager/alert.rules.yml" /etc/prometheus/alert.rules.yml
sudo cp "${REPO_DIR}/alertmanager/alertmanager.yml" /etc/prometheus/alertmanager.yml
sudo cp "${REPO_DIR}/nginx/default.conf" /etc/nginx/sites-available/default
if [ -f "${REPO_DIR}/grafana/provisioning/datasources/prometheus.yml" ]; then
  sudo mkdir -p /etc/grafana/provisioning/datasources
  sudo cp "${REPO_DIR}/grafana/provisioning/datasources/prometheus.yml" /etc/grafana/provisioning/datasources/prometheus.yml
fi

echo
echo "[4/6] Discord 웹후크 주소 입력 (VM 사본에만 적용)"
read -r -s -p "Discord 웹후크 주소 (건너뛰려면 Enter): " WEBHOOK_URL
echo
if [ -n "${WEBHOOK_URL}" ]; then
  sudo sed -i "s|YOUR_WEBHOOK_URL|${WEBHOOK_URL}|" /etc/prometheus/alertmanager.yml
  echo "웹후크 주소를 /etc/prometheus/alertmanager.yml 에 적용했습니다."
else
  echo "건너뜀: 나중에 sudo nano /etc/prometheus/alertmanager.yml 에서 직접 입력하세요."
fi

echo
echo "[5/6] 설정 문법 검사"
promtool check config /etc/prometheus/prometheus.yml
sudo nginx -t

echo
echo "[6/6] 서비스 재시작"
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus-node-exporter prometheus prometheus-alertmanager grafana-server nginx
sudo systemctl restart prometheus-node-exporter prometheus prometheus-alertmanager grafana-server nginx

echo
echo "서비스 상태:"
systemctl is-active prometheus-node-exporter prometheus prometheus-alertmanager grafana-server nginx

echo
echo "완료. 아래를 확인하세요."
echo "  - http://localhost:9090/classic/targets  (node, prometheus 가 UP)"
echo "  - http://localhost          (Nginx를 거쳐 Grafana 화면)"
echo "  - http://localhost:3000     (Grafana 직접 접속, 처음 admin / admin)"
