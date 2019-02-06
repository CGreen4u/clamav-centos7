#clamav

FROM centos:7
#install clamav and edit script out
RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
&& yum -y install epel-release \
&& yum -y update \
&& yum -y install clamav-data-empty clamav-scanner \
&& yum clean all
RUN set -x \
&& cd /var/lib/clamav \
&& curl -O http://database.clamav.net/main.cvd \
&& curl -O http://database.clamav.net/daily.cvd \
&& curl -O http://database.clamav.net/bytecode.cvd \
&& curl -O http://database.clamav.net/safebrowsing.cvd \
&& chown clamupdate:clamupdate main.cvd daily.cvd bytecode.cvd safebrowsing.cvd \
\
&& sed -ri ' \
s/Example/#Example/g; \
s/#Foreground/Foreground/g; \
s/#LogTime/LogTime/g; \
s/#TCPSocket/TCPSocket/g; \
s/#StreamMaxLength 10M/StreamMaxLength 50M/g; \
s/#MaxThreads 20/MaxThreads 50/g; \
s/#ReadTimeout/ReadTimeout/g; \
s/#DetectBrokenExecutables/DetectBrokenExecutables/g; \
' /etc/clamd.d/scan.conf \
\
&& ln -s /etc/clamd.d/scan.conf /etc/clamd.conf

# Update ClamAV Definitions
RUN mkdir -p /opt/malice \
  && chown malice /opt/malice \
  && freshclam

# Add EICAR Test Virus File to malware folder
ADD http://www.eicar.org/download/eicar.com.txt /malware/EICAR

RUN chown malice -R /malware

WORKDIR /malware

ENTRYPOINT ["/bin/avscan"]
CMD ["--help"]


#VOLUME ["/var/lib/clamav"]
#EXPOSE 3310
#ENTRYPOINT ["clamd"]
#CMD []


