#ref https://linux.die.net/man/1/ash
pid=-1
cnt=0
while true
do
# ref https://www.opensourceforu.com/2018/10/how-to-monitor-and-manage-linux-processes/
#ref https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon
    if [ $pid = -1 ]; then
        err=2
    else
        kill -0 $pid
        err=$?
    fi
    du -b /tmp/daemon.log
    if test $err -ne 0; then
        printf "start daemon"
        nohup ./mockd.sh 0<&- &>/dev/null &
        printf "Daemon restarted\n" >> /tmp/watchdog.log
    fi
    pid=$!
    err=$?
    sleep 10
    cnt=($cnt +1)
    size= `du -b /tmp/daemon.log`
    printf "size %u" $size
    if test $cnt -eq 30; then
        cnt=0
        size= du -b /tmp/daemon.log
        #if [test -]
        rm /tmp/daemon.log.old
        mv /tmp/daemon.log /tmp/daemon.log.old
    fi
done