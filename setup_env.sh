#!/bin/bash
## Set password if passed as environment variable
if [ ! -z "${ROOT_PASS}" ]
then
  echo "root:${ROOT_PASS}" | chpasswd
fi

## Set sudo user
if [ ! -z "${SUDO_USER}" -a ! -z "${SUDO_USER_PASS}" ]
then
  userdel -r appuser
  useradd -g wheel ${SUDO_USER}
  echo "${SUDO_USER}:${SUDO_USER_PASS}" | chpasswd
fi

## Set password if passed as environment variable
if [ ! -z "${TIMEZONE}" ]
then
  rm -f /etc/localtime
  ln -sf /usr/share/zoneinfo/"${TIMEZONE}" /etc/localtime
fi

/usr/sbin/sshd -D
