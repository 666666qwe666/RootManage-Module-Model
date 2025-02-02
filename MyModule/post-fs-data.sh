# 可选文件
# 这个脚本将会在 post-fs-data 模式下运行
# 
# 说明:
# post-fs-data.sh 是一个可选的启动脚本文件，它将在 post-fs-data 模式下运行。
# 在这个模式下，脚本会在任何模块被挂载之前执行，这使得模块开发者可以在模块被挂载之前动态地调整它们的模块。
# 这个阶段发生在 Zygote 启动之前，并且是阻塞的，在执行完成之前或者 10 秒钟之后，启动过程会暂停。
# 请注意，使用 setprop 会导致启动过程死锁，建议使用 resetprop -n <prop_name> <prop_value> 代替。
#清理缓存
rm -rf /data/system/package_cache/*

#禁用I/O调试
echo 0 > /sys/block/dm-0/queue/iostats
echo 0 > /sys/block/mmcblk0/queue/iostats
echo 0 > /sys/block/mmcblk0rpmb/queue/iostats
echo 0 > /sys/block/mmcblk1/queue/iostats
echo 0 > /sys/block/loop0/queue/iostats
echo 0 > /sys/block/loop1/queue/iostats
echo 0 > /sys/block/loop2/queue/iostats
echo 0 > /sys/block/loop3/queue/iostats
echo 0 > /sys/block/loop4/queue/iostats
echo 0 > /sys/block/loop5/queue/iostats
echo 0 > /sys/block/loop6/queue/iostats
echo 0 > /sys/block/loop7/queue/iostats
echo 0 > /sys/block/sda/queue/iostats

