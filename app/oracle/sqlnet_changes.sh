#!/bin/bash
SQLNET_PATH="/opt/oracle/oradata/dbconfig/FREE/sqlnet.ora"
CHANGE="NAMES.DEFAULT_DOMAIN = oracle"
if ! grep "${CHANGE}" -q "${SQLNET_PATH}"; then
  echo "${CHANGE}" >> "${SQLNET_PATH}"
  sqlplus / as sysdba <<EOF > /dev/null
SHUTDOWN IMMEDIATE;
STARTUP;
EXIT;
EOF
fi