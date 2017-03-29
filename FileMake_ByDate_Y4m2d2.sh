#=================================================================#
#           利用日期进行文件的创建                                #
#=================================================================#
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# 1. 请使用者输入文件名，并取得fileuser这个变量；
echo -e "I will use 'touch' command to create 3 files." # 纯粹显示信息
read -p "Please input your filename: " fileuser         # 提示用户输入
# 2. 为了避免用户随意按Enter ，利用变量的功能分析文件名是否有设置
filename=${fileuser:-"filename"}           # 判断是否配置文件名
# 3. 开始利用date命令获取新建文件名所需要的日期(Y4m2d2)；
date1=$(date --date='2 days ago' +%Y%m%d)  # 前两天的日期
date2=$(date --date='1 days ago' +%Y%m%d)  # 前一天的日期
date3=$(date +%Y%m%d)                      # 今天的日期
# 设定文件名
file1=${filename}${date1}                  # 底下设定文件名
file2=${filename}${date2}
file3=${filename}${date3}
# 4. 开始创建文件夹！
touch "$file1"                             # 底下三行在建立文件
touch "$file2"
touch "$file3"
