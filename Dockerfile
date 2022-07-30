FROM alpine:3.16.1 AS stage1
RUN apk update && apk add git
WORKDIR /usr/multi/
RUN git clone https://github.com/Prashant-100/java_repo1.git
RUN git clone https://github.com/Prashant-100/tomcat-config-1.git

FROM maven:amazoncorretto AS stage2
COPY --from=stage1 /usr/multi/java_repo1/src /usr/app/src
COPY --from=stage1 /usr/multi/java_repo1/pom.xml /usr/app/
RUN mvn -f /usr/app/pom.xml clean install


FROM tomcat AS stage3
RUN cp -r webapps.dist/* webapps/
COPY --from=stage2 /usr/app/target/*.war /usr/local/tomcat/webapps/demo.war/
COPY --from=stage1 /usr/multi/tomcat-config-1/context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
COPY --from=stage1 /usr/multi/tomcat-config-1/context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
COPY --from=stage1 /usr/multi/tomcat-config-1/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
