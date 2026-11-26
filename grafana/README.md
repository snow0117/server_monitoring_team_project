# Grafana 서버 모니터링

Node Exporter가 Linux 지표를 제공하고, Prometheus가 15초마다 수집합니다. Grafana는 Prometheus에 질의해 CPU, 메모리, 디스크 사용률을 표시합니다.

## 대시보드

| 파일 | 용도 |
| --- | --- |
| [server-monitoring-dashboard.json](server-monitoring-dashboard.json) | 팀에서 제작한 Server Monitoring Dashboard입니다. Classic JSON으로 가져올 수 있습니다. |
| [node-exporter-full.json](node-exporter-full.json) | Grafana Labs의 [Node Exporter Full(ID 1860)](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) 원본입니다. 시스템별 상세 지표를 살펴볼 때 사용합니다. |

## Ubuntu 설치 및 설정

1. Ubuntu APT에서 `sudo apt update`와 `sudo apt install prometheus prometheus-node-exporter`를 실행합니다. 두 패키지는 지표를 수집·저장하는 Prometheus와 Linux 지표를 제공하는 Node Exporter를 설치합니다.
2. Grafana 공식 APT 저장소와 서명 키를 등록한 뒤 `sudo apt update`와 `sudo apt install grafana`를 실행합니다. 서명 키는 APT가 패키지 출처를 확인하는 데 사용합니다. [Grafana OSS 설치 절차](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)
3. 저장소 루트에서 아래 명령을 실행합니다. `promtool`은 팀 수집 설정의 문법을 검사하고, `cp`는 덮어쓰기 전 설정을 백업합니다. `install`은 설정을 각 서비스가 읽는 위치에 복사합니다. 기존 백업 파일이 있으면 새 이름으로 백업합니다.

   ```bash
   promtool check config prometheus/prometheus.yml
   sudo cp -an /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.before-grafana
   sudo install -m 0644 prometheus/prometheus.yml /etc/prometheus/prometheus.yml
   sudo install -D -m 0644 grafana/provisioning/datasources/prometheus.yml /etc/grafana/provisioning/datasources/prometheus.yml
   ```

   `prometheus/prometheus.yml`은 수집 담당 PR이 병합된 브랜치의 파일입니다. 현재 체크아웃에 없으면 `git show origin/main:prometheus/prometheus.yml`로 내용을 임시 파일에 저장한 뒤, 위 두 명령의 수집 설정 원본 경로에 그 임시 파일을 사용합니다. 설치 대상 경로에 기존 Grafana 데이터 소스 YAML이 있으면 복사 전에 백업합니다.
4. 개인 노트북에서 테스트할 때는 Grafana의 `GF_SERVER_HTTP_ADDR`을 `127.0.0.1`로, Prometheus와 Node Exporter의 `--web.listen-address`를 각각 `127.0.0.1:9090`, `127.0.0.1:9100`으로 설정합니다. `sudo systemctl restart prometheus-node-exporter prometheus grafana-server`로 설정을 적용하고, `ss -ltn`으로 세 포트의 수신 주소를 확인합니다. `http://localhost:9090/targets`에서는 `node`와 `prometheus`가 `UP`인지 확인합니다.
5. `http://localhost:3000`에 로그인하고 **Dashboards → New → Import**에서 `server-monitoring-dashboard.json`을 업로드하고 데이터 소스로 `Prometheus`를 선택한 뒤 **Import**를 누릅니다. 저장소의 데이터 소스 YAML은 같은 호스트에서 실행되는 Prometheus(`http://localhost:9090`)를 Grafana에 등록합니다. [Grafana 가져오기 문서](https://grafana.com/docs/grafana/latest/visualizations/dashboards/build-dashboards/import-dashboards/)

## PromQL 쿼리

Gauge와 Time series는 각 지표에 같은 쿼리를 사용합니다. 세 쿼리 모두 팀의 `node` 수집 작업에서 데이터를 가져옵니다.

| 지표 | PromQL | 계산 방식 |
| --- | --- | --- |
| CPU | `100 - (avg(rate(node_cpu_seconds_total{job="node",mode="idle"}[1m])) * 100)` | 최근 1분 동안 수집 대상 전체의 CPU 코어가 유휴 상태였던 평균 비율을 빼서 사용률로 환산합니다. |
| 메모리 | `100 * (1 - node_memory_MemAvailable_bytes{job="node"} / node_memory_MemTotal_bytes{job="node"})` | 전체 메모리 중 새 작업에 사용할 수 있는 메모리의 비율을 뺍니다. |
| 디스크 | `100 * (1 - node_filesystem_avail_bytes{job="node",mountpoint="/"} / node_filesystem_size_bytes{job="node",mountpoint="/"})` | 루트 파일시스템(`/`)의 전체 공간 중 일반 사용자가 사용할 수 있는 공간의 비율을 뺍니다. |

[Prometheus Node Exporter 가이드](https://prometheus.io/docs/guides/node-exporter/)

## 구현 및 테스트 결과

Classic JSON에서 다음 구성을 확인했습니다.

- CPU, 메모리, 디스크 사용률 Gauge 3개와 시간에 따른 사용률을 보여주는 Time series 3개를 구성했습니다.
- 주의 70%, 위험 90%로 표시 임계값을 설정했고 자동 새로고침을 5초로 설정했습니다. 새로고침은 Grafana의 조회 주기이며 Prometheus의 수집 주기는 15초입니다.
- Gauge는 임계값 마커를 표시합니다. Time series에도 같은 임계값이 저장되어 있으며 임계선 표시는 꺼져 있습니다. 기본 조회 범위는 최근 15분입니다.

프로젝트 담당자는 Ubuntu 노트북에서 Prometheus와 Node Exporter를 연결하고, 실제 디스크 사용량 증가가 원본 대시보드에 반영되는 것을 확인했습니다.

## 팀 대시보드 JSON 내보내기

Grafana에 로그인해 **Server Monitoring Dashboard**를 열고 **Export → Export as code**를 선택합니다. 모델은 **Classic**, **Share dashboard with another instance**는 켜고 **Download file**로 다운로드합니다. 파일 이름은 `server-monitoring-dashboard.json`을 사용합니다. PR에 추가하기 전에 JSON의 데이터 소스 참조, 패널 쿼리와 링크에 토큰, 비밀번호, 웹후크, 개인 호스트 이름 또는 IP가 포함되어 있는지 확인합니다. [Grafana 내보내기 문서](https://grafana.com/docs/grafana/latest/visualizations/dashboards/share-dashboards-panels/)
