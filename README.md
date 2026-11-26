# Server Monitoring Team Project

오픈소스 SW 팀 프로젝트 - 서버 모니터링 대시보드 및 Discord 경고 시스템

## 1. 프로젝트 소개

Linux 서버의 CPU, 메모리, 디스크 등의 자원 사용량을
실시간으로 모니터링하고, 이상 상태가 발생하면
Discord를 통해 관리자에게 경고를 전달하는 시스템을 구축한다.

## 2. 개발 환경

- OS: Ubuntu Linux
- Virtualization: VMware
- Version Control: Git, GitHub

## 3. 사용 기술

| 기술 | 역할 |
|---|---|
| Node Exporter | 서버 자원 사용량 수집 |
| Prometheus | 메트릭 수집 및 저장 |
| Grafana | 모니터링 대시보드 시각화 |
| Alertmanager | 경고 관리 및 알림 전송 |
| Nginx | 웹 서버 및 리버스 프록시 |
| Discord | 경고 메시지 수신 |

## 4. 프로젝트 구조

```text
server_monitoring_team_project/
├── node-exporter/
├── prometheus/
├── grafana/
├── alertmanager/
├── nginx/
├── scripts/
├── .gitignore
└── README.md
```

## 5. 주요 기능

- CPU, 메모리, 디스크 사용량 모니터링
- 실시간 모니터링 대시보드
- 임계값 초과 시 Discord 경고 전송
- 서버 부하 테스트

## 6. GitHub 협업 규칙

- main 브랜치에 직접 Push하지 않는다.
- 기능별 feature 브랜치를 생성하여 작업한다.
- 작업 내용을 Commit하고 Push한다.
- Pull Request를 생성한다.
- 팀원 1명 이상의 승인을 받은 후 main에 병합한다.
- 비밀번호, 토큰, Discord Webhook URL은 업로드하지 않는다.

## 7. 팀원 및 역할 분담
 
| 이름 | 담당 역할 | 담당 기술 | 작업 폴더 | 브랜치 | PR |
|---|---|---|---|---|---|
| 신해찬 | 수집·협업 관리 | Node Exporter, Prometheus | `node-exporter/`, `prometheus/` | `feature/collect`, `feature/alert-connect` | #2, #5 |
| 허재훈 | 시각화·저장소 개설 | Grafana | `grafana/` | `feature/init`, `feature/dashboard` | #1, #6 |
| 김하얀 | 알림·Discord 개설 및 관리 | Alertmanager, Discord 웹후크 | `alertmanager/` | `feature/alert` | #4 |
| 손수진 | 접속·통합·PPT | Nginx, 통합 설치 스크립트 | `nginx/`, `scripts/` | `feature/web` | #3 |
 
- 역할별로 브랜치를 나눠 작업하고, 모든 변경은 Pull Request로 올려 팀원의 승인을 받은 뒤 `main`에 병합했다.
- 소통은 Discord로 했고, 코드 리뷰는 GitHub Pull Request에서 했다.
- PR #5(`feature/alert-connect`): 알림 규칙을 Prometheus에 연결하는 설정을 보완했고, 팀원 리뷰를 거쳐 merge했다.
## 8. 설치 및 실행 방법
 
### 8-1. 준비
 
- Ubuntu가 설치된 컴퓨터 또는 VMware 가상 머신
- 인터넷 연결, `sudo` 권한
- 디스크 여유 공간 약 8GB, 메모리 4GB 이상 권장 (Grafana 설치에 약 1.4GB가 필요하다)
- Discord 웹후크 주소 (경고를 받으려는 경우에만 필요하고, 없어도 설치는 된다)
### 8-2. 설치
 
```bash
git clone https://github.com/snow0117/server_monitoring_team_project.git
cd server_monitoring_team_project
bash scripts/setup.sh
```
 
`scripts/setup.sh`가 하는 일은 다음과 같다.
 
1. Prometheus, Node Exporter, Alertmanager, Nginx, stress-ng를 `apt`로 설치한다.
2. Grafana 공식 저장소를 추가하고 Grafana를 설치한다.
3. 저장소의 설정 파일을 각 프로그램의 설정 위치(`/etc/...`)로 복사한다.
4. Discord 웹후크 주소를 물어보고, 입력하면 VM에 복사된 `alertmanager.yml`에만 적용한다. (건너뛰려면 Enter)
5. 설정 문법을 검사하고(`promtool`, `nginx -t`) 서비스를 시작한다.
끝나면 서비스 5개의 상태가 모두 `active`로 출력된다.
 
### 8-3. 동작 확인
 
브라우저는 설치한 Ubuntu 안에서 연다.
 
| 확인할 것 | 주소 | 정상 상태 |
|---|---|---|
| 수집 | `http://localhost:9090/classic/targets` | `node`, `prometheus`가 UP |
| 알림 규칙 | `http://localhost:9090/classic/alerts` | `HighCpuUsage`가 보임 |
| Grafana | `http://localhost:3000` | 로그인 화면 (처음 `admin` / `admin`) |
| Nginx 경유 | `http://localhost` | Grafana와 같은 화면 |
 
### 8-4. 대시보드 불러오기
 
1. Grafana에 로그인한다.
2. **Dashboards → New → Import**를 누른다.
3. `grafana/server-monitoring-dashboard.json`을 업로드한다.
4. 데이터 소스로 `Prometheus`를 선택하고 **Import**를 누른다.
CPU, 메모리, 디스크 사용률 게이지 3개와 시간별 그래프 3개가 나온다.
 
### 8-5. 경고 시험
 
```bash
stress-ng --cpu 0 --timeout 300s
```
 
CPU 사용률이 80%를 넘는 상태가 1분 이상 이어지면 `HighCpuUsage`가 FIRING이 되고, 약 2~3분 뒤 Discord로 알림이 온다.
 
### 8-6. Discord 웹후크를 나중에 넣을 때
 
```bash
sudo nano /etc/prometheus/alertmanager.yml
sudo systemctl restart prometheus-alertmanager
```
 
`YOUR_WEBHOOK_URL`을 실제 주소로 바꾼다. 웹후크 주소는 비밀번호와 같아서 저장소, Pull Request, 캡처에 올리지 않는다. 이 저장소의 `alertmanager/alertmanager.yml`에는 `YOUR_WEBHOOK_URL`만 남겨 둔다.
 
### 8-7. 구성 요약
 
| 프로그램 | 포트 | 설정 파일 (저장소 → 설치 위치) |
|---|---|---|
| Node Exporter | 9100 | (기본 설정 사용) |
| Prometheus | 9090 | `prometheus/prometheus.yml` → `/etc/prometheus/prometheus.yml` |
| 알림 규칙 | - | `alertmanager/alert.rules.yml` → `/etc/prometheus/alert.rules.yml` |
| Alertmanager | 9093 | `alertmanager/alertmanager.yml` → `/etc/prometheus/alertmanager.yml` |
| Grafana | 3000 | `grafana/provisioning/datasources/prometheus.yml` → `/etc/grafana/provisioning/datasources/prometheus.yml` |
| Nginx | 80 | `nginx/default.conf` → `/etc/nginx/sites-available/default` |
