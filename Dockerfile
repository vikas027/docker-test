FROM centos:7.2.1511
MAINTAINER Vikas Kumar "vikas@reachvikas.com"

# Upgrade
RUN yum upgrade -y
RUN yum install -y wget tar curl tree gcc vim telnet lsof net-tools bind-utils && \
    echo 'syntax on' >> /root/.vimrc

# Set timezone
ENV TIMEZONE Australia/Sydney
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Additional Repos
RUN yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

# Supervisord
RUN yum -y install python-pip && \
    pip install --upgrade pip && \
    pip install --upgrade supervisor supervisor-stdout && \
    mkdir -p /var/log/supervisor

# install crond
RUN yum install -y cronie-noanacron
# no PAM
RUN cp -a /etc/pam.d/crond /etc/pam.d/crond.org
RUN sed -i -e 's/^\(session\s\+required\s\+pam_loginuid\.so\)/#\1/' /etc/pam.d/crond

# Make ssh, scp work
RUN yum install -y openssh-server openssh-clients shadow-utils
# no PAM http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
ENV ROOT_PASS password
RUN sed -i 's/UsePAM\syes/UsePAM no/' /etc/ssh/sshd_config && \
    ssh-keygen -q -b 1024 -N '' -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -b 1024 -N '' -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -b 521 -N '' -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
    sed -i -r 's/.?UseDNS\syes/UseDNS no/' /etc/ssh/sshd_config && \
    sed -i -r 's/.?ChallengeResponseAuthentication.+/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config && \
    sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "root:${ROOT_PASS}" | chpasswd

# Make sudo work
ENV SUDO_USER appuser
ENV SUDO_USER_PASS appuser27
RUN yum install sudo -y && \
    useradd -g wheel ${SUDO_USER} && \
    echo "${SUDO_USER}:${SUDO_USER_PASS}" | chpasswd && \
    sed -i -e 's/^\(%wheel\s\+.\+\)/#\1/gi' /etc/sudoers && \
    echo -e '\n%wheel ALL=(ALL) ALL' >> /etc/sudoers && \
    echo -e '\nDefaults:root   !requiretty' >> /etc/sudoers && \
    echo -e '\nDefaults:%wheel !requiretty' >> /etc/sudoers


# Tweaks for sshd, timezone, root password and sudo user
ADD setup_env.sh /setup_env.sh

# BASH Tweaks
ADD bash_tweaks.sh /etc/profile.d/bash_tweaks.sh

# Clean up, reduces container size
RUN rm -rf /var/cache/yum/* && yum clean all

EXPOSE 22

ADD supervisord.conf /etc/
CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
