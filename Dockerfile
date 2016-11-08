FROM jenkins:2.19.1
MAINTAINER jr00n 
USER root
RUN apt-get update \
      && apt-get install -y sudo \
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

# remove download archive files
RUN apt-get clean

USER jenkins
ENV JAVA_OPTS="-Xmx8192m -Djenkins.install.runSetupWizard=false"
#ENV JAVA_OPTS="-Xmx8192m"

#Add reference config to disable security
ADD JENKINS_HOME /usr/share/jenkins/ref

#Add plugins
RUN /usr/local/bin/install-plugins.sh workflow-aggregator:2.2 ssh-slaves:1.11 htmlpublisher:1.11 windows-slaves:1.2 email-ext:2.52 ldap:1.13 
RUN /usr/local/bin/install-plugins.sh external-monitor-job:1.6 jobConfigHistory:2.15 robot:1.6.4 hp-application-automation-tools-plugin:4.5.0 
RUN /usr/local/bin/install-plugins.sh vsphere-cloud:2.14 script-security:1.24 changelog-history:1.6 disk-usage:0.28 branch-api:1.11 git:3.0.0 
RUN /usr/local/bin/install-plugins.sh greenballs:1.15 credentials-binding:1.9 lastfailureversioncolumn:1.1 lastsuccessversioncolumn:1.1 ldapemail:0.8 
RUN /usr/local/bin/install-plugins.sh maven-info:0.2.0 monitoring:1.62.0 next-build-number:1.4 versionnumber:1.8.1

