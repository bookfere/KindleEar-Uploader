#!/bin/bash

# ------------------------------------------
# 名称：KindleEar安装脚本
# 作者：kindlefere.com
# 页面：http://kindlefere.com/post/19.html
# 更新：2017.02.09
# ------------------------------------------

cd ~

if [ ! -d "./KindleEar" ]
then
    git clone https://github.com/cdhigh/KindleEar.git
else
    response='y'
    read -r -p '已存在 KindleEar 源码，是否更新？[y/N]' response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        # rm -rf ./KindleEar
        # git clone https://github.com/cdhigh/KindleEar.git
        cd ./KindleEar
        git pull ./KindleEar
        cd ..
    fi
fi

cd KindleEar

cemail=$(sed -n "s/^SRC_EMAIL = \"\(.*\)\".*#.*/\1/p" ./config.py)
cappid=$(sed -n "s/^DOMAIN = \"https:\/\/\(.*\)\.appspot.com\".*#.*/\1/p" ./config.py)
response='y'

echo '当前的 Gmail 为：'$cemail
echo '当前的 APPID 为：'$cappid

if [ ! $cemail = "akindleear@gmail.com" -o ! $cappid = "kindleear" ]
then
    read -r -p "是否修改 APP 信息? [y/N] " response
fi

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo -n "请输入你的 Gmail 地址："
    read email
    echo "您输入的 Gmail 地址是：'$email'"
    sed -i "s/^SRC_EMAIL = \".*\"/SRC_EMAIL = \"$email\"/g" ./config.py
    echo -n "请输入你的 APP ID："
    read appid
    echo "您输入的 APP ID 是：'$appid'"
    sed -i "s/^application: .*/application: $appid/g" ./app.yaml ./module-worker.yaml
    sed -i "s/^DOMAIN = \"https:\/\/.*\.appspot.com\"/DOMAIN = \"https:\/\/$appid\.appspot.com\"/g" ./config.py
fi

appcfg.py update app.yaml module-worker.yaml --no_cookie --noauth_local_webserver
appcfg.py update . --no_cookie --noauth_local_webserver