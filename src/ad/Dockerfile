# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
#
# Multi-stage build for the Astronomy Shop ad service (Java 21, gRPC).
#
# Build from the repository root. The protobuf sources live in pb/, so the
# context has to be the root rather than src/ad:
#
#   docker build -f src/ad/Dockerfile -t otel-demo-ad:local .
#
# Stages:
#   1. builder  - JDK + Gradle. Dependency download is its own layer so a
#                 source-only change does not re-download every jar.
#   2. agent    - fetches the pinned OpenTelemetry Java agent.
#   3. runtime  - JRE only. No Gradle, no JDK, no source tree.

ARG JAVA_VERSION=21
ARG OTEL_JAVA_AGENT_VERSION=2.25.0

FROM eclipse-temurin:${JAVA_VERSION}-jdk AS builder

WORKDIR /usr/src/app

# Wrapper, build file, and version catalog change much less often than the
# Java sources. Docker layer cache (and the GitHub Actions cache) reuses this
# layer until a dependency changes.
COPY src/ad/gradlew src/ad/gradlew.bat src/ad/settings.gradle src/ad/build.gradle ./
COPY src/ad/gradle ./gradle

RUN chmod +x ./gradlew \
    && ./gradlew --no-daemon downloadRepos

COPY src/ad/ ./
COPY pb/ ./proto

RUN chmod +x ./gradlew \
    && ./gradlew --no-daemon installDist -PprotoSourceDir=./proto

FROM eclipse-temurin:${JAVA_VERSION}-jdk AS agent

ARG OTEL_JAVA_AGENT_VERSION

# Downloaded here so the runtime stage does not need curl or a package manager.
# Plain ADD, not ADD --chmod: --chmod needs BuildKit, and a laptop `docker build`
# should work with the default builder as well as GitHub Actions.
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar /opentelemetry-javaagent.jar

FROM eclipse-temurin:${JAVA_VERSION}-jre AS runtime

# A normal user, not --system: a uid above 999 makes useradd warn when
# --system is set, and 10001 keeps the process well clear of system accounts.
RUN groupadd --gid 10001 app \
    && useradd --uid 10001 --gid app --home-dir /usr/src/app --shell /usr/sbin/nologin --no-log-init app

WORKDIR /usr/src/app

# installDist produces a self-contained directory: bin/Ad plus lib/*.jar.
# Copy only that directory, not the Gradle cache or the JDK from the builder.
COPY --from=builder --chown=app:app /usr/src/app/build/install/opentelemetry-demo-ad/ ./
COPY --from=agent --chown=app:app /opentelemetry-javaagent.jar /usr/src/app/opentelemetry-javaagent.jar

# The agent instruments the service without changing its source. The heap cap
# matches what the deployment requests so the JVM cannot overshoot the pod limit.
ENV JAVA_TOOL_OPTIONS="-javaagent:/usr/src/app/opentelemetry-javaagent.jar -Xmx200m"

USER app

EXPOSE 8080

ENTRYPOINT ["./bin/Ad"]
