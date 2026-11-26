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

|이름|담당 역할|
|---|---|
|손수진|-|
|신해찬|-|
|허재훈|-|
|김하얀|-|



## 8. 설치 및 실행 방법

추후 작성 예정
