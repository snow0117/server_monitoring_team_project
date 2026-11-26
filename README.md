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
 
### 준비물
 
- Ubuntu (VMware 가상 머신도 가능), 인터넷 연결, `sudo` 권한
- 디스크 여유 공간 약 8GB, 메모리 4GB 이상 권장
- Discord 웹후크 주소 (알림을 받으려는 경우에만 필요, 없어도 설치됨)
### 설치
 
```bash
git clone https://github.com/snow0117/server_monitoring_team_project.git
cd server_monitoring_team_project
bash scripts/setup.sh
```
 
`scripts/setup.sh` 하나로 Prometheus, Node Exporter, Alertmanager, Grafana, Nginx를 설치하고 저장소의 설정 파일을 적용한 뒤 서비스를 시작한다. 중간에 Discord 웹후크 주소를 물어보는데, 지금 없으면 Enter로 건너뛰면 된다.
 
### 확인
 
Ubuntu 안의 브라우저에서 확인한다.
 
- `http://localhost:9090/classic/targets`: `node`, `prometheus`가 UP
- `http://localhost:3000`: Grafana 로그인 (처음에는 `admin` / `admin`)
- `http://localhost`: Nginx를 거쳐 Grafana가 열림
대시보드는 Grafana에서 **Dashboards → New → Import**로 `grafana/server-monitoring-dashboard.json`을 올리고, 데이터 소스를 `Prometheus`로 고르면 된다.
 
### 알림 테스트
 
```bash
stress-ng --cpu 0 --timeout 300s
```
 
CPU 사용률이 80%를 넘는 상태가 1분 넘게 이어지면 `HighCpuUsage` 경고가 발생하고, 웹후크를 넣었다면 Discord로 알림이 온다.
 
웹후크를 나중에 넣으려면 `/etc/prometheus/alertmanager.yml`의 `YOUR_WEBHOOK_URL`을 실제 주소로 바꾸고 `sudo systemctl restart prometheus-alertmanager`를 실행한다. 웹후크 주소는 비밀번호와 같아서 저장소나 Pull Request에는 올리지 않는다.
