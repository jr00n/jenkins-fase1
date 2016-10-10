FROM jenkins:2.7.3
MAINTAINER jr00n 
USER root
RUN apt-get update \
      && apt-get install -y sudo supervisor \
      && rm -rf /var/lib/apt/lists/*

#RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers


#install wget
RUN apt-get install -y wget

# get maven v3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9-bin.tar.gz http://apache.cs.utah.edu/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

#verify checksum
RUN echo "516923b3955b6035ba6b0a5b031fbd8b /tmp/apache-maven-3.3.9-bin.tar.gz" | md5sum -c

#install maven
RUN tar zxf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.9 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-magen-3.3.9-bin.tar.gz
RUN chown -R jenkins:jenkins /opt/maven


# Install docker-engine
# According to Petazzoni's article:
# ---------------------------------
# "Former versions of this post advised to bind-mount the docker binary from
# the host to the container. This is not reliable anymore, because the Docker
# Engine is no longer distributed as (almost) static libraries."
ARG docker_version=1.11.2
RUN curl -sSL https://get.docker.com/ | sh && \
    apt-get purge -y docker-engine && \
    apt-get install docker-engine=${docker_version}-0~jessie

# Make sure jenkins user has docker privileges
RUN usermod -aG docker jenkins
# Make sure jenkins user may use docker.sock 
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# remove download archive files
RUN apt-get clean

USER jenkins
ENV JAVA_OPTS="-Xmx8192m -Djenkins.install.runSetupWizard=false"
#ENV JAVA_OPTS="-Xmx8192m"

#Add reference config to disable security
ADD JENKINS_HOME /usr/share/jenkins/ref
RUN /usr/local/bin/install-plugins.sh workflow-aggregator:2.2 docker-workflow:1.7 copyartifact:1.38 greenballs:1.15 git:2.5.3 

ENV JENKINS_DOWNLOAD=http://updates.jenkins-ci.org/experimental/latest/
RUN /usr/local/bin/install-plugins.sh blueocean

# supervisord
USER root

# Create log folder for supervisor and jenkins
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/jenkins

# Copy the supervisor.conf file into Docker
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord when running the container
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
