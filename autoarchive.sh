#!/bin/sh
# 使用方法
# 1.将autoarchive.sh和附件中的plist，放在一起，新建文件夹为Shell，将这几文件复制进去，然后复制Shell文件夹到工程的根目录
# 2.终端cd到Shell下，执行脚本 格式为 sh 脚本名字.sh

# 配置信息
#工程名字
target_name="xxx"

echo "\033[32m****************\n开始自动打包\n****************\033[0m\n"

# ==========自动打包配置信息部分========== #

#工程中Target对应的配置plist文件名称, Xcode默认的配置文件为Info.plist
info_plist_name="Info"
#返回上一级目录,进入项目工程目录
cd ..
#获取项目名称
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`
#获取工程plist配置文件
info_plist_path="$project_name/$info_plist_name.plist"

#获取版本号
bundle_version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $info_plist_path`

#设置build版本号（可以不进行设置）
date=`date +"%Y%m%d%H%M"`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $date" "$info_plist_path"

#获取build版本号
bundle_build_version=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $info_plist_path`

#强制删除旧的文件夹
rm -rf ./$target_name-IPA
#指定输出ipa路径
export_path=./$target_name-IPA
#指定输出归档文件地址
export_archive_path="$export_path/$target_name.xcarchive"
#指定输出ipa地址
export_ipa_path="$export_path"
#指定输出ipa名称 : target_name + bundle_version + bundle_build_version
ipa_name="$target_name-V$bundle_version($bundle_build_version)"

echo "\033[32m****************\n自动打包选择配置部分\n****************\033[0m\n"

# ==========自动打包可选择信息部分========== #

# 输入是否为工作空间
archiveRun () {
    #是否是工作空间
    echo "\033[36;1m是否是工作空间(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 是 \033[0m"
    echo "\033[33;1m2. 否 \033[0m"
    #读取用户输入
    read is_workspace_parame
    sleep 0.5

    if [ "$is_workspace_parame" == "1" ]
    then
        echo "\033[32m****************\n您选择了是工作空间 将采用：xcworkspace\n****************\033[0m\n"
    elif [ "$is_workspace_parame" == "2" ]
    then
        echo "\033[32m****************\n您选择了不是工作空间 将采用：xcodeproj\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        archiveRun
    fi
}
archiveRun

# 输入打包模式
configurationRun () {
    echo "\033[36;1m请选择打包模式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. Release \033[0m"
    echo "\033[33;1m2. Debug \033[0m"
    #读取用户输入
    read build_configuration_param
    sleep 0.5

    if [ "$build_configuration_param" == "1" ]; then
        build_configuration="Release"
    elif [ "$build_configuration_param" == "2" ]; then
        build_configuration="Debug"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        configurationRun
    fi
}
configurationRun

echo "\033[32m****************\n您选择了 $build_configuration 模式\n****************\033[0m\n"

# 输入打包类型
methodRun () {
    # 输入打包类型
    echo "\033[36;1m请选择打包方式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. AdHoc \033[0m"
    echo "\033[33;1m2. AppStore \033[0m"
    echo "\033[33;1m3. Enterprise \033[0m"
    echo "\033[33;1m4. Development \033[0m\n"
    #读取用户输入
    read method_param
    sleep 0.5

    if [ "$method_param" == "1" ]; then
        exportOptionsPlistPath="AdHocExportOptions"
        echo "\033[32m****************\n您选择了 AdHoc 打包类型\n****************\033[0m\n"
    elif [ "$method_param" == "2" ]; then
        exportOptionsPlistPath="AppStoreExportOptions"
        echo "\033[32m****************\n您选择了 AppStore 打包类型\n****************\033[0m\n"
    elif [ "$method_param" == "3" ]; then
        exportOptionsPlistPath="EnterpriseExportOptions"
        echo "\033[32m****************\n您选择了 Enterprise 打包类型\n****************\033[0m\n"
    elif [ "$method_param" == "4" ]; then
        exportOptionsPlistPath="DevelopmentExportOptions"
        echo "\033[32m****************\n您选择了 Development 打包类型\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        methodRun
    fi
}
methodRun

# 输入上传类型
publishRun () {
    # 输入打包类型
    echo "\033[36;1m请选择上传类型(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 不上传 \033[0m"
    echo "\033[33;1m2. AppStore \033[0m"
    #读取用户输入
    read publish_param
    sleep 0.5

    if [ "$publish_param" == "1" ]; then
        echo "\033[32m****************\n您选择了不上传\n****************\033[0m\n"
    elif [ "$publish_param" == "2" ]; then
        echo "\033[32m****************\n您选择了上传 AppStore\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        publishRun
    fi
}
publishRun

#选择了2、Release、AppStore
if [ "$method_param" == "2" -a "$build_configuration" == "Release" -a "$publish_param" == "2" ]
then
    #上传App Store
    echo "请输入开发者账号："
    read username_param
    sleep 0.5

    echo "请输入开发者账号密码："
    read password_param
    sleep 0.5
fi

echo "\033[32m****************\n打包信息配置完毕，输入回车开始进行打包\n****************\033[0m\n"
read start
sleep 0.5

echo "\033[32m****************\n开始清理工程\n****************\033[0m\n"

# 删除旧的文件
rm -rf "$export_path"
# 指定输出文件目录不存在则创建
if test -d "$export_path" ; then
    echo $export_path
else
    mkdir -pv $export_path
fi

# 清理工程
xcodebuild clean -configuration "$build_configuration" -alltargets

echo "\033[32m****************\n开始编译项目 ${build_configuration}  ${exportOptionsPlistPath}\n****************\033[0m\n"

# 开始编译
if [ "$is_workspace_parame" == "1" ]
then
    #工作空间
    xcodebuild archive \
    -workspace ${project_name}.xcworkspace \
    -scheme ${target_name} \
    -configuration ${build_configuration} \
    -destination generic/platform=ios \
    -archivePath ${export_archive_path}
else
    #不是工作空间
    xcodebuild archive \
    -project ${project_name}.xcodeproj \
    -scheme ${target_name} \
    -configuration ${build_configuration} \
    -archivePath ${export_archive_path}
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$export_archive_path" ; then
    echo "\033[32m****************\n项目编译成功\n****************\033[0m\n"
else
    echo "\033[32m****************\n项目编译失败\n****************\033[0m\n"
    exit 1
fi

echo "\033[32m****************\n开始导出ipa文件\n****************\033[0m\n"

#1、打包命令
#2、归档文件地址
#3、ipa输出地址
#4、ipa打包设置文件地址
xcodebuild -exportArchive \
-archivePath ${export_archive_path} \
-configuration ${build_configuration} \
-exportPath ${export_ipa_path}  \
-exportOptionsPlist "./Shell/${exportOptionsPlistPath}.plist"

# 修改ipa文件名称
mv $export_ipa_path/$target_name.ipa $export_ipa_path/$ipa_name.ipa

# 检查文件是否存在
if test -f "$export_ipa_path/$ipa_name.ipa" ; then
    echo "\033[32m****************\n导出 $ipa_name.ipa 包成功\n****************\033[0m\n"
else
    echo "\033[32m****************\n导出 $ipa_name.ipa 包失败\n****************\033[0m\n"
    exit 1
fi

# 打开打包文件目录
open $export_path

# 输出
echo "\033[32m****************\n使用Shell脚本打包完毕\n****************\033[0m\n"

#上传 AppStore
if [ -n "$username_param" -a -n "$password_param" -a "$method_param" == "2" -a "$build_configuration" == "Release" -a "$publish_param" == "2" ]
then
    echo "\033[32m****************\n开始上传AppStore\n****************\033[0m\n"
    #验证APP
    altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
    "${altoolPath}" --validate-app \
    -f "${export_ipa_path}/${ipa_name}.ipa" \
    -u "$username_param" \
    -p "$password_param" \
    --output-format xml
    #上传APP
    "${altoolPath}" --upload-app \
    -f "${export_ipa_path}/${ipa_name}.ipa" \
    -u "$username_param" \
    -p "$password_param" \
    --output-format xml
    echo "\033[32m****************\n上传AppStore完毕\n****************\033[0m\n"
fi
