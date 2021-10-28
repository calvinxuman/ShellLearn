#!/bin/bash
if [ $('whoami') != 'root' ];then
  echo "请使用root用户执行！！!";
  sleep 1
  exit
fi

# 获取环境CPU 核数
CPU_N=`cat /proc/cpuinfo |grep processor|wc -l|tr -d "\n"`
#获取内存大小
mem_size=`awk '($1=="MemTotal:"){printf  "%0.0f",$2/1024/1024}' /proc/meminfo`

#更正内存大小
function resize_mem(){
    size=1
    while [[ $1 -ge $size ]]; do
        size=`expr $size \* 2`
        if [[ $1 -eq $size ]]; then
            break
        fi
    done
    return $size
}

resize_mem $mem_size
TOTAl_MEM=$?
USE_MEM=`echo "$TOTAl_MEM * 1024 * 0.8"|bc`
apt update
apt install -y g++
package_url="https://docs.deepin.com/f/6bc88b5aea/?raw=1"
if [[ ! -f "stressapptest-master.zip" ]];then
	wget -O stressapptest-master.zip $package_url
fi
if [[ -d stressapptest-master ]];then
	rm -rf stressapptest-master
fi
unzip stressapptest-master.zip
cd stressapptest-master
./configure
make
make install
echo "stressapp已安装完成，开始进行测试，测试时长48小时"
stressapptest -M $USE_MEM -C $CPU_N -W -s  172800 -l /root/stressapp.log
echo "测试完成，日志路径：/root/stressapp.log"
