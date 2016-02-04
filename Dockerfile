# Warning: This is a test base image, please do not use in production!!
FROM nghiant2710/device-sync:jessie

# Install Java
# with sources from https://launchpad.net/~webupd8team/+archive/ubuntu/java
# using the fix described at http://www.all4pages.com/2014/03/23/wie-installieren-wir-oracle-java-8-auf-wheezy-ueber-die-debian-sourcelist/
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get update && \
    apt-get install -y oracle-java8-installer --no-install-recommends && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# These env vars enable sync_mode on all devices.
ENV SYNC_MODE=on
ENV INITSYSTEM=on

# resin-sync will always sync to /usr/src/app, so code needs to be here.
WORKDIR /usr/src/app

# copy current directory into WORKDIR
COPY app/ ./

RUN javac Hello.java
CMD java -cp . Hello
