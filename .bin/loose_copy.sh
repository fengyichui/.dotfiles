#!/bin/bash

time_start_s=`date +%s`

from='./'
to='./__lq_bak__'
extended=''

usage()
{
    echo "copy from-dir & its-sub-dir to to-dir loosely. default is current folder"
    echo "Usage: "
    echo "Parameter: -f[rom-dir] -t[o-dir] -e[xtended]"
    echo "by lq 2013/5/7 23:00:16"
}

#获取参数
while getopts f:t:e: opt
do
    case $opt in
        f)  from=$OPTARG
            ;;
        t)  to=$OPTARG
            ;;
        e)  extended='\.('"$OPTARG"')$'
            ;;
        '?')
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ ! -d "$from" ]
then
    usage
    exit 1
fi

if [ ! -d "$to" ]
then
    mkdir $to
fi

awk_param='/'"$extended"'/'
list=`find "$from" -type f | awk "$awk_param"`

max=`find "$from" -type f | awk "$awk_param" | wc -l`

n=0
IFS=$'\n'  #指定字段分割符号

printf "\r0/$max ------- 0%% ------- 0s"
for of in $list
do
    filename=`echo $of | sed 's;^.*/;;'`  #正则表达式的贪婪模式
    tofile="$to""/""$filename"

    i=2
    while [ -f $tofile ]
    do
        sed_param='s;\.\([^.]*\)$;'"$i"'\.\1;'
        tofile=`echo $tofile | sed "$sed_param"`  #正则表达式的贪婪模式
        i=$(($i+1))
    done
    cp "$of" "$tofile"
    
    #统计
    n=$(($n+1))
    time_s=`date +%s`
    time_s=$(($time_s-$time_start_s))
    printf "\r%d/$max ------- %d%% ------- %ds" $n $(($n*100/$max)) $time_s
done

echo " "

