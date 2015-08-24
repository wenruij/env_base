#!/bin/bash
#
# Produce a report for system status
# @author Wenrui Jiang (wenruij@gmail.com)

#Set script variables
DATE=`date +%m%d%Y`
REPORT=/tmp/Snapshot_Stats_$DATE.rpt

# create report file
exec 3>&1 2>/dev/null
exec 1> $REPORT

echo -e "Daily System Report\n"
echo -e "Checkpoint: " `date +"%Y-%m-%d %H:%M:%S"`

# gather system uptime statistics
echo -e "\nSystem has been \c"
uptime | sed -n '/,/s/,/ /gp' | gawk '{if ($4 == "days" || $4 == "day")
  {print $2,$3,$4,$5} else {print $2,$3}}'

# gather disk usage stats
echo
df -h | sed -n '/\/dev\//p' | gawk '{print $1 " usage: " $5 "\tleft: " $4}'

echo -e "\nTop 10 usage spaces on disk:"
cd /
sudo du -sh * | sort -hr | sed '{11,$D; =}' | sed 'N; s/\n/ /' |
  gawk '{printf $1 ":\t" $3  "\t" $2 "\n"}'

# gather memory usage
echo -e "\nMemory usage: \c"
free | sed -n '2p' | gawk 'x = int(($3 /$2) *100) {print x}' |
  sed 's/$/%/'

# check existence of zombie processes
echo -e "\nCheck existence of zombie processes:"
ZOMBIC_CHECK=`ps -al | gawk '{print $2,$4}' | grep Z`
if [ "$ZOMBIC_CHECK" = "" ]
then
  echo "NO zombie process on system"
else
  echo "Current zombie processes:"
  echo $ZOMBIC_CHECK
  # kill all zombie processes
  # we connot kill all zomnies directly, kill all of a zombie's parents and the zombie dies
  # pPids=$(ps -A -ostat,ppid | grep -e '[zZ]'| awk '{ print $2 }')
  # sudo kill -9 $pPids
fi
echo

exec 1>&3
cat $REPORT
rm -r $REPORT
