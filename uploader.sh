#!/bin/bash

# -----------------------------------------------------
# 名称：KindleEar安装脚本
# 作者：bookfere.com
# 页面：https://bookfere.com/post/19.html
# 更新：2020.04.24
# -----------------------------------------------------

r_color="\033[1;91m"
g_color="\033[1;92m"
y_color="\033[0;93m"
c_color="\033[0;36m"
w_color="\033[0;37m"
b_color="\033[1;90m"
e_color="\033[0m"

divid_1="${b_color}==============================================${e_color}"
divid_2="${b_color}----------------------------------------------${e_color}"

source_url="https://github.com/cdhigh/KindleEar.git"
if [[ $1 ]]; then
    http_code=$(curl -o /dev/null -s -w "%{http_code}" $1)
    if [ $http_code == '000' ]; then
        echo -e $divid_1
        echo -e "${r_color}指定连接有问题，请检查"
        echo -e $divid_1
        exit 0
    fi
    source_url=$1;
fi

source_path=./$(echo $source_url | sed 's/.*\/\(.*\)/\1/;s/\.git//')
config_py=$source_path/config.py
app_yaml=$source_path/app.yaml
module_worker_yaml=$source_path/module-worker.yaml
parameters=(
    "COLOR_TO_GRAY"
    "GENERATE_TOC_THUMBNAIL"
    "GENERATE_TOC_DESC"
    "GENERATE_HTML_TOC"
    "PINYIN_FILENAME"
    # more...
)
descriptions=(
    "是否将图片转换为灰度？"
    "是否为目录生成缩略图？"
    "是否为目录添加摘要？"
    "是否生成HTML格式目录？"
    "是否将中文名转为拼音？"
    # more...
)
interrupt() {
    echo -e $1$divid_2
    echo -e "${r_color}已中止上传"
    echo -e $divid_1
    exit 0
}


cd ~ && clear
trap "interrupt \"\n\"" SIGINT
echo -e $divid_1
echo "准备上传 KindleEar 源代码"
echo -e $divid_1
echo -e "${w_color}来源: $source_url${e_color}"
echo -e $divid_2

get_version() {
    version='未知'
    version_file=$source_path/apps/__init__.py
    if [ -f $version_file ]; then
        version=$(sed -n "s/^__Version__\ =\ '\(.*\)'/\1/p" $version_file)
    fi
    echo $version
}

clone_code() {
    echo -e "${c_color}开始拉取 KindleEar 源代码"
    rm -rf $source_path && git clone $source_url
    if [ ! -d $source_path -o ! -f $config_py -o ! $app_yaml -o ! $module_worker_yaml ]; then
        echo -e $divid_2
        echo -e "${r_color}上传过程出问题，请重新操作"
        echo -e $divid_1
        exit 0
    fi
    echo "源代码拉取完毕，版本号：$(get_version)"
}

if [ ! -d $source_path -o ! -f $config_py -o ! $app_yaml -o ! $module_worker_yaml ]; then
    clone_code
else
    response="y"
    echo -n -e ${y_color}"已存在 $(get_version) 版本，重新拉取？[y/N]${e_color} "
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        bak_email=$(sed -n "s/^SRC_EMAIL\ =\ \"\(.*\)\".*#.*/\1/p" $config_py)
        bak_appid=$(sed -n "s/^DOMAIN\ =\ \"http\(\|s\):\/\/\(.*\)\.appspot\.com\/\".*#.*/\2/p" $config_py)
        for parameter in ${parameters[@]}; do
            eval $parameter=$(sed -n "s/^$parameter\ =\ \(.*\)/\1/p" $config_py)
        done

        echo -e $divid_2
        clone_code

        sed -i "s/^SRC_EMAIL\ =\ \".*\"/SRC_EMAIL\ =\ \"$bak_email\"/g" $config_py
        sed -i "s/^DOMAIN\ =\ \"http\(\|s\):\/\/.*\.appspot\.com\/\"/DOMAIN\ =\ \"http:\/\/$bak_appid\.appspot\.com\/\"/g" $config_py
        for parameter in ${parameters[@]}; do
            eval sed -i "s/^$parameter\ =\ .*/$parameter\ =\ \$$parameter/g" $config_py
        done
    fi
fi

sed -i "s/^application:.*//g;s/^version:.*//g" $app_yaml $module_worker_yaml
sed -i "s/^module: worker/service: worker/g" $module_worker_yaml

email=$(sed -n "s/^SRC_EMAIL\ =\ \"\(.*\)\".*#.*/\1/p" $config_py)
appid=$(sed -n "s/^DOMAIN\ =\ \"http\(\|s\):\/\/\(.*\)\.appspot\.com\/\".*#.*/\2/p" $config_py)

echo -e ${e_color}$divid_1
if [ $email = "akindleear@gmail.com" -o $appid = "kindleear" ]; then
    echo -e "${y_color}请按提示修改 APP 的账户信息${e_color}"
    echo -e $divid_2
fi
echo -e "当前的 Gmail 为："${g_color}$email${e_color}
echo -e "当前的 APPID 为："${g_color}$appid${e_color}

response="y"
if [ ! $email = "akindleear@gmail.com" -o ! $appid = "kindleear" ]; then
    echo -e $divid_2
    echo -n -e "${y_color}是否重新修改 APP 的账户信息? [y/N]${e_color} "
    read -r response
fi

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e $divid_2
    while true; do
        read -r -p "请输入你的 Gmail 地址：" email
        if [ -n "$email" ]; then
            break
        fi
        echo -e $divid_2
        echo -e "${r_color}Gmail 不能为空，请重新输入${e_color}"
        echo -e $divid_2
    done
    while true; do
        read -r -p "请输入你的 APP ID：" appid
        if [ -n "$appid" ]; then
            break
        fi
        echo -e $divid_2
        echo -e "${r_color}APP ID 不能为空，请重新输入${e_color}"
        echo -e $divid_2
    done
    sed -i "s/^SRC_EMAIL\ =\ \".*\"/SRC_EMAIL\ =\ \"$email\"/g" $config_py
    pattern="^DOMAIN\ =\ \"http\(\|s\):\/\/.*\.appspot\.com\/\""
    replace="DOMAIN\ =\ \"http:\/\/$appid\.appspot\.com\/\""
    sed -i "s/$pattern/$replace/g" $config_py
fi
echo -e $divid_1


response="N"
echo -n -e "${y_color}是否修改其它相关配置参数？[y/N]${e_color} "
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e $divid_2
    index=0
    for parameter in ${parameters[@]}; do
        old_value=$(sed -n "s/^$parameter\ =\ \(.*\)/\1/p" $config_py)
        notice="否"; if [[ $old_value = "True" ]]; then notice="是"; fi
        response="N"
        read -r -p ${descriptions[index]}"当前（${notice}）[y/N] " response
        if [[ $response ]]; then
            new_value="False"
            if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then new_value="True"; fi
            sed -i "s/^$parameter\ =\ $old_value/$parameter\ =\ $new_value/g" $config_py
        fi
        let index+=1
    done
fi
echo -e $divid_1


echo -n -e "${y_color}准备完毕，是否确认上传 [y/N]${e_color} "
read -r response
echo -e $divid_2
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    trap interrupt SIGINT
    echo -e "${c_color}正在上传，请稍候……"
    gcloud app deploy $source_path/*.yaml --version=1 --quiet
    echo -e $divid_2
    echo -e "应用访问地址：https://$appid.appspot.com"
else
    echo "已放弃上传"
fi
echo -e $divid_1
