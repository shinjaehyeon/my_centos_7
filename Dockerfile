# 센토스 OS로 지정
FROM centos:7

# 라벨 지정
LABEL "MAINTAINER"="Shin Jae Hyeon"
LABEL "DESCRIPTION"="Install what you need on centos:7"

# yum update 진행
RUN yum update -y
RUN yum upgrade -y

# 기본적인 패키지 설치
RUN yum install -y wget curl cmake make c++ gcc-c++ net-tools

# 서버 언어셋 UTF-8 적용
RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8
RUN sed -i'' -r -e "/\# Environment stuff goes in \/etc\/profile/a\export LANG=ko_KR.utf8\nexport LC_ALL=ko_KR.utf8" /etc/bashrc

# 서버 시간대 한국시간대로 적용
RUN ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# node.js 14.x 설치
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs

# 주요 npm 전역 패키지 설치
RUN echo 'N' | npm i -g pm2 @angular/core @angular/cli

# git 설치
RUN yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
RUN yum install -y git

# MariaDB 10.5 설치
COPY mariadb.repo /etc/yum.repos.d/
RUN yum makecache
RUN yum install -y MariaDB-server MariaDB-client

# MariaDB 기본 언어셋 UTF-8로 설정
RUN sed -i'' -r -e "/\[mysql\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysql_upgrade\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqladmin\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlbinlog\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlcheck\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \ 
&& sed -i'' -r -e "/\[mysqldump\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlimport\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlshow\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlslap\]/a\default-character-set = utf8mb4" /etc/my.cnf.d/mysql-clients.cnf
RUN sed -i'' -r -e "/\[mysqld\]/a\character\_set\_server = utf8mb4" /etc/my.cnf.d/server.cnf

# MariaDB bind-address 를 0.0.0.0 으로 변경 (호스트OS에서 컨테이너의 MariaDB에 HeidiSQL 같은 툴로 접근하기 위함)
RUN sed -i'' -r -e "/\#bind-address=0.0.0.0/a\bind-address=0.0.0.0" /etc/my.cnf.d/server.cnf

# MariaDB 자동 실행 설정
RUN sed -i'' -r -e "/export LC_ALL=ko_KR.utf8/a\systemctl start mariadb" /etc/bashrc

# 루트 경로로 이동
WORKDIR /

# 컨테이너가 시작될 때마다 실행할 명령어(커맨드) 설정
CMD ["init"]
