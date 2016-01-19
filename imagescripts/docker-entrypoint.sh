#!/bin/bash -x
set -o errexit

configfile="/home/letsencrypt/.jobber"

letsencrypt_testcert=""

if [ "${LETSENCRYPT_TESTCERT}" = "true" ]; then
  letsencrypt_testcert="--test-cert"
fi

letsencrypt_email=""

if [ -n "${LETSENCRYPT_EMAIL}" ]; then
  letsencrypt_email=${LETSENCRYPT_EMAIL}
fi

letsencrypt_domains=""

for (( i = 1; ; i++ ))
do
  VAR_LETSENCRYPT_DOMAIN="LETSENCRYPT_DOMAIN$i"

  if [ ! -n "${!VAR_LETSENCRYPT_DOMAIN}" ]; then
    break
  fi

  letsencrypt_domains=$letsencrypt_domains" -d "${!VAR_LETSENCRYPT_DOMAIN}
done

letsencrypt_http_enabled="true"
letsencrypt_https_enabled="true"

if [ -n "${HTTP_ENABLED}" ]; then
  letsencrypt_http_enabled=${HTTP_ENABLED}
fi

if [ -n "${HTTPS_ENABLED}" ]; then
  letsencrypt_https_enabled=${HTTPS_ENABLED}
fi

letsencrypt_account_id=""

if [ -n "${LETSENCRYPT_ACCOUNT_ID}" ]; then
  letsencrypt_account_id="--account "${LETSENCRYPT_ACCOUNT_ID}
fi

protocoll_command=""

if  [ "${letsencrypt_http_enabled}" = "false" ]; then
  protocoll_command="--standalone-supported-challenges tls-sni-01"
fi

if  [ "${letsencrypt_https_enabled}" = "false" ]; then
  protocoll_command="--standalone-supported-challenges http-01"
fi

letsencrypt_debug=""

if  [ "${LETSENCRYPT_DEBUG}" = "true" ]; then
  letsencrypt_debug="--debug"
fi

if [ ! -f "${configfile}" ]; then
  touch ${configfile}
fi

cat > ${configfile} <<_EOF_
---
_EOF_

job_on_error="Continue"

if [ -n "${JOB_ON_ERROR}" ]; then
  job_on_error=${JOB_ON_ERROR}
fi

job_time="0 0 1 15 * *"

if [ -n "${JOB_TIME}" ]; then
  job_time=${JOB_TIME}
fi

cat >> ${configfile} <<_EOF_
- name: letsencryt_renewal
  cmd: bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --renew-by-default ${letsencrypt_account_id} ${letsencrypt_domains}"
  time: ${job_time}
  onError: ${job_on_error}
  notifyOnError: false
  notifyOnFailure: false
_EOF_

cat ${configfile}

if [ "$1" = 'jobberd' ]; then
  sudo /opt/jobber/sbin/jobberd
fi

if [ "$1" = 'install' ]; then
  bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --email ${letsencrypt_email} --agree-tos ${letsencrypt_domains}"
  exit
fi

if [ "$1" = 'newcert' ]; then
  bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} ${letsencrypt_account_id} ${letsencrypt_domains}"
  exit
fi

if [ "$1" = 'renewal' ]; then
  bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --renew-by-default ${letsencrypt_account_id} ${letsencrypt_domains}"
  exit
fi

if [ "$1" = 'manualrenewal' ]; then
  bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} ${letsencrypt_account_id} ${letsencrypt_domains}"
  exit
fi


if [ -n "${CERTIFICATE_OWNER}" ] || [ -n "${CERTIFICATE_GROUP}" ]; then
  bash -c "sudo chown ${CERTIFICATE_OWNER}:${CERTIFICATE_GROUP} /etc/letsencrypt"
fi

exec "$@"
