#!/bin/sh
#ref https://linux.die.net/man/1/ash
#Linux man page for pgrep
#Verify if we have the daemon already running. Must not have several copies!
DLOGFILE="/tmp/daemon.log"
DLOGFILEO="/tmp/daemon.log.old"
DEBUG=false
cnt=0
while true
do
# ref https://www.opensourceforu.com/2018/10/how-to-monitor-and-manage-linux-processes/
#ref https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon

#Verify that daemon is still working by checking that it accepts signals. If there is not yet
#daemon running we dont do the checking. 
#dash pgrep pid comparison fails if there is not running precess, assigning
#explicitly value 0
    if pgrep -x mockd.sh ; then
        # there is running process, get the pid   
        pid=`pgrep -x mockd.sh`
        if $DEBUG ; then
            printf "22: pid '%u'\n" $pid
        fi
        if ! kill -18 $pid ; then
            pid=0
            if $DEBUG ; then
                printf "27: terminated pid\n"
            fi
        fi
    else
        pid=0
    fi

    if $DEBUG ; then
        printf "35:err: '%u pid '%u'\n" $? $pid
    fi
    if [ $pid -eq 0 ]; then
        err=nohup ./mockd.sh 0<&- &>/dev/null &
        pid=$!
        date +'%Y-%m-%d %T Daemon restarted\n' >> /tmp/watchdog.log
    fi
   
    sleep 10
    cnt=$(($cnt +1))
    #Five minutes is 30 * 10 seconds
    if test $cnt -eq 30; then
        cnt=0
        #https://unix.stackexchange.com/questions/16640/how-can-i-get-the-size-of-a-file-in-a-bash-script
        #if File does not exist use size 0
        if [ -f $DLOGFILE ]; then
            size=`du -b $DLOGFILE | cut -f1`
        else
            size=0
        fi 
    
        if test $size -gt 1000; then
        #Remove old log only if there is current log and old log
            if [ -f $DLOGFILEO ] && [ -f $DLOGFILE ]; then
                date +'%Y-%m-%d %T removing old log' >> /tmp/watchdog.log
                rm $DLOGFILEO
            fi
            if [ -f  $DLOGFILE ]; then
                date +'%Y-%m-%d %T renaming current log as old' >> /tmp/watchdog.log
                mv $DLOGFILE $DLOGFILEO
            fi
        fi
    fi
done