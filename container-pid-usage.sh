function getcpid() {
    cpids=`pgrep -P $1|xargs`
    for cpid in $cpids;
    do
        ps --no-header -o pid,ppid,%cpu,time,%mem,rss,vsz,args $cpid
        getcpid $cpid
    done
}

for i in $(ps -e -o pid,args|grep containerd-shim|grep -v grep|awk '{print $1}')
do
        getcpid $i
        echo ---
done
