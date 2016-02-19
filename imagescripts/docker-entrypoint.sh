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

if [ -n "${LETSENCRYP_HTTP_ENABLED}" ]; then
  letsencrypt_http_enabled=${LETSENCRYP_HTTP_ENABLED}
fi

if [ -n "${LETSENCRYPT_HTTPS_ENABLED}" ]; then
  letsencrypt_https_enabled=${LETSENCRYPT_HTTPS_ENABLED}
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

if [ -n "${LETSENCRYPT_JOB_ON_ERROR}" ]; then
  job_on_error=${LETSENCRYPT_JOB_ON_ERROR}
fi

job_time="0 0 1 15 * *"

if [ -n "${LETSENCRYPT_JOB_TIME}" ]; then
  job_time=${LETSENCRYPT_JOB_TIME}
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

case "$1" in

  install)
    bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --email ${letsencrypt_email} --agree-tos ${letsencrypt_domains}"
    ;;

  manualinstall)
    bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --email ${letsencrypt_email} ${letsencrypt_domains}"
    ;;

  newcert)
    bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} ${letsencrypt_account_id} ${letsencrypt_domains}"
    ;;

  renewal)
    bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --renew-by-default ${letsencrypt_account_id} ${letsencrypt_domains}"
    ;;

  manualrenewal)
    bash -c "/opt/letsencrypt/letsencrypt/letsencrypt-auto certonly --standalone ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} ${letsencrypt_account_id} ${letsencrypt_domains}"
    ;;

  *)
    exec "$@"

esac

if [ -n "${LETSENCRYP_CERTIFICATE_OWNER}" ] || [ -n "${LETSENCRYPT_CERTIFICATE_GROUP}" ]; then
  bash -c "sudo chown -R ${LETSENCRYP_CERTIFICATE_OWNER}:${LETSENCRYPT_CERTIFICATE_GROUP} /etc/letsencrypt"
fi
