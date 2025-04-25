import json, os, subprocess
from sys import argv

hosts = argv[1].split(',')
#-------------------------------------------------------
print( "Choose host for installing ..." )

filter = '\'\"' + argv[1].replace(',', "\"|\"") + '\"\''
command = "ansible-playbook -u root -i " + argv[1] + " playbooks/choose_host.yml | grep -P " + filter 
str1 = str( subprocess.check_output( command, shell=True), errors='ignore' )
str2 = '{' + str1.replace('\n', ',', 1) + '}'
host_idle = json.loads(str2)

print( hosts[0] + "\'s \%idle: " + host_idle[hosts[0]] + "   " +
       hosts[1] + "\'s \%idle: " + host_idle[hosts[1]] )
if host_idle[hosts[0]] > host_idle[hosts[1]]:
  target_host = hosts[0]
else:
  target_host = hosts[0]
print( "...... host " + target_host + " chosen!" )
#-------------------------------------------------------
print( "Installing PostgreSQL ..." )
command = "ansible-playbook -u root -i " + target_host + ", playbooks/install_postgresql.yml --extra-vars \"second_host_ip_address=" + hosts[1] + "\" > /dev/null 2> /dev/null"
if os.system( command ) == 0:
  print( "...... PostgreSQL installed!" )
else:
  print( "  Error! PostgreSQL not installed :(" )
  exit()
#-------------------------------------------------------
print( "Checking PostgreSQL (sending SELECT 1)" )
command = "ansible-playbook -u root -i " + target_host + ", playbooks/check_postgresql.yml > /dev/null 2> /dev/null"
if os.system( command ) == 0:
  print( "...... PostgreSQL checked!" )
else:
  print( "  Error! PostgreSQL check failed :(" )
  exit()
