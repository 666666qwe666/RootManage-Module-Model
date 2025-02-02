#这个脚本将会在 late_start 服务模式下运行
# 获取模块的基本目录路径
MODDIR=${0%/*}

# 在此处编写您的服务脚本逻辑
# 例如，您可以在此处添加需要在 late_start 服务模式下运行的命令

# 示例：打印一条消息到日志
#echo "服务脚本已启动" >> /data/local/tmp/service.log

# 示例：设置系统属性
#resetprop ro.example.property "example_value"

# 示例：启动一个后台服务
#nohup some_background_service &

# 示例：执行一个耗时的任务 sleep 10等待10秒
#sleep 10

# 示例：打印一条消息到日志
#echo "服务脚本已完成" >> /data/local/tmp/service.log

# 请注意：
# - 避免使用可能阻塞或显著延迟启动过程的命令。
# - 确保此脚本启动的任何后台任务都得到妥善管理，以避免资源泄漏。

# 有关更多信息，请参阅 KernelSU 文档中的启动脚本部分。

# 示例：检查设备的架构并执行相应的操作
#if [ "$(uname -m)" = "aarch64" ]; then
    #echo "设备架构为 arm64" >> /data/local/tmp/service.log
    # 在此处添加针对 arm64 架构的命令
#else
    #echo "设备架构为其他" >> /data/local/tmp/service.log
    # 在此处添加针对其他架构的命令
#fi

# 示例：检查某个文件是否存

#if [ -f /data/local/tmp/some_file ]; then
    #echo "文件存在" >> /data/local/tmp/service.log
    # 在此处添加文件存在时的处理逻辑
#else
    #echo "文件不存在" >> /data/local/tmp/service.log
    # 在此处添加文件不存在时的处理逻辑
#fi

# 示例：设置权限
#chmod 644 /data/local/tmp/service.log

# 示例：创建一个目录
#mkdir -p /data/local/tmp/my_service_dir

# 示例：写入环境变量到文件
#echo "MY_ENV_VAR=my_value" > /data/local/tmp/my_service_dir/env_vars

# 示例：启动另一个脚本
#sh /data/local/tmp/my_service_dir/another_script.sh & Compare this snippet from MyModule/service.sh: # 这个脚本将在服务模式下运行
# Function to whitelist processes by the latest instance
function white_list() {
    pgrep -o "$1" | while read -r pid; do
        renice -n -20 -p "$pid"
        echo "$pid" > /dev/cpuset/top-app/cgroup.procs
        echo "$pid" > /dev/stune/top-app/cgroup.procs
    done
}

# Whitelist specific processes
white_list surfaceflinger
white_list webview_zygote

# Function to whitelist processes by matching full command line
function white() {
    pgrep -f "$1" | while read -r pid; do
        renice -n -20 -p "$pid"
        echo "$pid" > /dev/cpuset/top-app/cgroup.procs
        echo "$pid" > /dev/stune/top-app/cgroup.procs
    done
}

# Whitelist additional processes
white android.hardware.graphics.composer@2.2-service
white zygote
white zygote64
white com.android.systemui

# Scheduler tuning
echo 1 > /dev/stune/foreground/schedtune.prefer_idle
echo 1 > /dev/stune/background/schedtune.prefer_idle
echo 1 > /dev/stune/rt/schedtune.prefer_idle
echo 20 > /dev/stune/rt/schedtune.boost
echo 20 > /dev/stune/top-app/schedtune.boost
echo 1 > /dev/stune/schedtune.prefer_idle
echo 1 > /dev/stune/top-app/schedtune.prefer_idle

# Additional setup

# Delay for initialization
sleep 5

# Kill logd processes
am kill logd
killall -9 logd

am kill logd.rc
killall -9 logd.rc

# Release caches at startup
sleep 10
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/compact_memory

# Clean Wi-Fi logs
rm -rf /data/vendor/wlan_logs
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs

# Refresh storage
MODDIR=${0%/*}
wait_login() {
    local test_file="/sdcard/Android/.started"
    true > "$test_file"
    while [ ! -f "$test_file" ]; do
        true > "$test_file"
        sleep 0.5
    done
    rm "$test_file"
}
wait_login
setprop persist.sys.fboservice.ctrl true
setprop persist.sys.stability.miui_fbo_enable tru

# Android TCP optimization
while read -r route; do
    ip route change "$route" initcwnd 20
    ip route change "$route" initrwnd 20
done < <(ip route)

# Read-ahead optimization
echo 4096 > /sys/block/vda/queue/read_ahead_kb

# Max open files optimization
echo 2390251 > /proc/sys/fs/file-max

# IO scheduler optimization
echo noop > /sys/block/mmcblk0/queue/scheduler


