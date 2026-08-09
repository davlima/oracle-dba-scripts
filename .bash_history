exit
cd /u01/app/oracle/product/19.0.0/dbhome_1
ls
unzip Oracle_19c_Linux.zip
./runInstaller
sqlplus / as sysdba
. oraenv
sqlplus / as sysdba
cd /u01/app/oracle/product/19.0.0/dbhome_1/demo/schema/human_resources
@hr_main.sql
sqlplus / as sysdba
cd
cd $ORACLE_HOME/network/admin
vi tnsnames.ora
vi listener.ora 
sqlplus / as sysdba
shutdown now
tail -f /tmp/InstallActions2025-07-02_09-11-38AM/installActions2025-07-02_09-11-38AM.log
. oraenv
lsnrctl start
sqlplus / as sysdba
shutdown now
. oraenv
lsnrctl start
sqlplus / as sysdba
shutdown now
cat /etc/oracle-release
. oraenv
sqlplus / as sysdba
ip a
nmcli device
nmcli con mod enp0s3 ipv4.address 192.168.1.75/24
nmcli con mod enp0s3 ipv4.gateway 192.168.1.200
nmcli con mod enp0s3 ipv4.dns "192.168.1.200, 1.1.1.3"
nmcli con mo
nmcli con mod enp0s3 connection.autoconnect yes
nmcli con up enp0s3
$ORACLE_HOME/OPatch/opatch lsinventory
shutdown -h now
lsnrctl start
sqlplus / as sysdba
lsnrctl status;
sqlplus / as sysdba
shutdown -h now
sudo shutdown -h now
sudo su
su root
senha
su root
. oraenv
lsnrctl start
ps -ef | grep pmon
sqlplus / as sysdba
sudo su
su root
. oraenv
sqlplus / as sysdba
expdp \"sys/sua_senha_sys@192.168.1.75:1521/ORCLPDB as sysdba\"       SCHEMAS=HR       DIRECTORY=DATA_PUMP_DIR       DUMPFILE=expdp_hr_orclpdb_%U.dmp       LOGFILE=expdp_hr_orclpdb.log       COMPRESSION=ALL
lsnrctl start
expdp \"sys@192.168.1.75:1521/ORCLPDB as sysdba\"       SCHEMAS=HR       DIRECTORY=DATA_PUMP_DIR       DUMPFILE=expdp_hr_orclpdb_%U.dmp       LOGFILE=expdp_hr_orclpdb.log       COMPRESSION=ALL
sqlplus / as sysdba
    expdp \"/ as sysdba\"           SCHEMAS=HR           DIRECTORY=DATA_PUMP_DIR           DUMPFILE=expdp_hr_orclpdb_%U.dmp           LOGFILE=expdp_hr_orclpdb.log           COMPRESSION=ALL
export ORACLE_PDB_SID=ORCLPDB
    expdp \"/ as sysdba\"           SCHEMAS=HR           DIRECTORY=DATA_PUMP_DIR           DUMPFILE=expdp_hr_orclpdb_%U.dmp           LOGFILE=expdp_hr_orclpdb.log           COMPRESSION=ALL
expdp \"sys/dbaocm@192.168.1.75:1521/ORCLPDB as sysdba\"       SCHEMAS=HR       DIRECTORY=DATA_PUMP_DIR       DUMPFILE=expdp_hr_orclpdb_%U2.dmp       LOGFILE=expdp_hr_orclpdb2.log \
scp /u01/app/oracle/admin/ORCLPDB/dpdump/expdp_hr_orclpdb_*.dmp david@192.168.1.11:~
scp /u01/app/oracle/admin/ORCLPDB/dpdump/expdp_hr_orclpdb_*.dmp david@192.168.1.9:~
scp /u01/app/oracle/admin/ORCLPDB/dpdump/expdp_hr_orclpdb_*.dmp david@192.168.1.9:/home
ls /u01/app/oracle/admin/ORCLPDB/dpdump/expdp_hr_orclpdb_*.dmp
ls /u01/app/oracle/admin/ORCLPDB/dpdump/
ls /u01/app/oracle/admin/ORCLPDB/dpdump/38F296B75D115DE4E0639706A8C03B1A/
# 1. Parar o listener deliberadamente
lsnrctl stop
# 2. Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
-- Provocar erro de conexão com data pump
# Provocar erro de conexão com data pump
# 2. Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
#  Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
lsnrctl start
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# 1. Parar o listener deliberadamente
lsnrctl stop
# 2. Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba\ " \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba\ "       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba "       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba\"  \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp

/

/
\



lsnrctl stART
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp / "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp / "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"    /   SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp / "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as / sysdba"    /   SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp / "sys/sua_senha@//192.168.1.75:1521/ORCLPDB /as / sysdba"    /   SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp / "sys/sua_senha@//192.168.1.75:1521/ORCLPDB / as / sysdba"    /   SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as \ sysdba" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as \ sysdba\" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
;




\
/
expdp \ "sys/senha@//192.168.1.75:1521/ORCLPDB as \ sysdba" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/senha@//192.168.1.75:1521/ORCLPDB" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/senha@//192.168.1.75:1521/ORCLPDB / as \ sysdba" \      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys \ as sysdba/senha@//192.168.1.75:1521/ORCLPDB"      SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@/192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys/senha@//192.168.1.75:1521/ORCLPDB  as  sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys/senha@//192.168.1.75:1521/ORCLPDB  / as  sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys/senha@//192.168.1.75:1521/ORCLPDB    sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys/senha@//192.168.1.75:1521/ORCLPDB  \ as  sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp  "sys/senha@//192.168.1.75:1521/ORCLPDB  \ as \ sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp \ "sys/senha@//192.168.1.75:1521/ORCLPDB  \ as \ sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba" SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp / as sysdba SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
https://www.adzuna.com.br/details/5805287837?utm_medium=api&utm_source=3b9a47a7expdp system/Senha@ORCL SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp "'/ as sysdba'" SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba" SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp "'/ as sysdba'" SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp \/ as sysdba       SCHEMAS=HR       DIRECTORY=DATA_PUMP_DIR       DUMPFILE=teste_%U.dmp       LOGFILE=expdp_hr.log
# Tentativa 1 — aspas duplas comuns, delimitação correta no bash
expdp "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
# Saída real:
# LRM-00108: invalid positional parameter value 'sysdba'
# Tentativa 2 — aspas simples DENTRO de aspas duplas
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
ase 19.0.0.0.0 - Production on ...
# 1. Parar o listener deliberadamente
lsnrctl stop
# 2. Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# Saída esperada:
# ORA-12541: TNS:no listener
# 3. Correção
lsnrctl start
# 4. Reexecutar o mesmo comando para confirmar sucesso
# 1. Parar o listener deliberadamente
lsnrctl stop
# 2. Tentar exportar via EZConnect (vai falhar)
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# Saída esperada:
# ORA-12541: TNS:no listener
# 3. Correção
lsnrctl start
# 4. Reexecutar o mesmo comando para confirmar sucesso
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# 1. Parar o listener deliberadamente
lsnrctl stop
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
lsnrctl stop
# 1. Parar o listener deliberadamente
lsnrctl stop
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp LOGFILE=expdp_hr.log
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%Ul.dmp LOGFILE=expdp_hr1.log
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%Ul.dmp LOGFILE=expdp_hr1.logexpdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
expdp "sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# String incorreta — falta a dupla barra antes do IP
expdp "sys/senha@192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%U.dmp
# 1. Reiniciar a instância sem forçar registro
sqlplus / as sysdba
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste_%Ul.dmp LOGFILE=expdp_hr1.logexpdp "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=teste2_%U.dmp
# 1. Reiniciar a instância sem forçar registro
sqlplus / as sysdba
expdp "'/ as sysdba'"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=test_%U2.dmp LOGFILE=expdp_hr1.logexpdp "sys/senha@//192.168.1.75:1521/ORCLPDB as sysdba"       SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=test2_%U.dmp
sqlplus / as sysdba
expdp "'/ as sysdba'" SCHEMAS=HR DIRECTORY=DATA_PUMP_DIR DUMPFILE=test_%U2.dmp LOGFILE=expdp_hr1.log
sudo shutdown -h now
su root
df -h
sqlplus / as sysdba
. oraenv
sqlplus / as sysdba
