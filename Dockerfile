FROM adoptopenjdk/openjdk11:alpine-slim AS overlay

RUN mkdir -p cas-overlay
COPY ./src cas-overlay/src/
COPY ./gradle/wrapper/ cas-overlay/gradle/wrapper/
COPY ./gradlew ./settings.gradle ./build.gradle /cas-overlay/

RUN mkdir -p ~/.gradle \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
    && cd cas-overlay \
    && chmod 750 ./gradlew \
    && ./gradlew clean build --parallel;

FROM adoptopenjdk/openjdk11:alpine-jre AS cas

LABEL "Organization"="Apereo"
LABEL "Description"="Apereo CAS"

RUN cd / \
    && mkdir -p /etc/cas/config \
    && mkdir -p /etc/cas/services \
    && mkdir -p /etc/cas/saml \
    && mkdir -p cas-overlay;

COPY etc/cas/ /etc/cas/
COPY etc/cas/config/ /etc/cas/config/
COPY etc/cas/services/ /etc/cas/services/
COPY --from=overlay cas-overlay/build/libs/cas.war cas-overlay/

EXPOSE 8080 8443

ENV PATH $PATH:$JAVA_HOME/bin:.

CMD ["exec java -jar cas-overlay/cas.war"]
