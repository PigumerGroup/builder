FROM amazonlinux as download

ENV GRAALVM_VERSION 19.3.1
ENV MAVEN_VERSION 3.6.3

RUN yum -y install tar gzip &&\
    curl -o /opt/graalvm-ce.tgz\
         -L https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-java11-linux-amd64-${GRAALVM_VERSION}.tar.gz &&\
    /bin/bash -c "(cd /opt; tar -xvzf graalvm-ce.tgz)" &&\
    mv /opt/graalvm-ce-java11-${GRAALVM_VERSION} /opt/graalvm-ce &&\
    curl -o /opt/maven.tgz\
         -L https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz &&\
    /bin/bash -c "(cd /opt; tar -xvzf maven.tgz)" &&\
    mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven

FROM amazonlinux

ENV JAVA_HOME    /usr/lib/jvm/java-11-amazon-corretto.x86_64
ENV GRAALVM_HOME /opt/graalvm-ce
ENV MAVEN_HOME   /opt/maven

COPY --from=download /opt/graalvm-ce /opt/graalvm-ce/
COPY --from=download /opt/maven      /opt/maven/

RUN yum -y update &&\
    yum -y install java-11-amazon-corretto which gcc gcc-c++ glibc-devel zlib-devel &&\
    ${GRAALVM_HOME}/bin/gu install native-image

