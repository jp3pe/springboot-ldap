FROM gradle:alpine AS gradle
WORKDIR /build
COPY build.gradle settings.gradle ./
RUN gradle build -x test --parallel --continue > /dev/null 2>&1 || true

COPY . /build
RUN gradle build -x test --parallel

FROM azul/zulu-openjdk-alpine:19-latest AS jdk
COPY --from=gradle /build/build/libs/authenticating-ldap-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
USER nobody
ENTRYPOINT [                                        \
   "java",                                          \
   "-jar",                                          \
   "-Djava.security.egd=file:/dev/./urandom",       \
   "-Dsun.net.inetaddr.ttl=0",                      \
   "authenticating-ldap-0.0.1-SNAPSHOT.jar"         \
]