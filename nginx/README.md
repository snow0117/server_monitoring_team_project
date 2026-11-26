# Nginx
- 설치: sudo apt install -y nginx
- 역할: 80번 포트로 들어온 요청을 Grafana(localhost:3000)로 전달하는 리버스 프록시
- 설정 파일: nginx/default.conf (적용 위치: /etc/nginx/sites-available/default)
- 확인: sudo nginx -t, 브라우저에서 localhost 접속
- 버전: nginx/1.28.3
