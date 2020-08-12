#!/bin/sh
# 使用方法
# 1.将shell.sh和附件中的plist，放在一起，新建文件夹为Shell，将这几文件复制进去，然后复制Shell文件夹到工程的根目录
# 2.终端cd到Shell下，执行脚本 格式为 sh 脚本名字.sh

# 配置信息

#这里配置完参数则下方不用进行手动输入（用于参数化构建）
#是否为工作组
parameter_workspace=""
#打包模式
parameter_configuration=""
#打包类型
parameter_type=""
#上传类型
parameter_upload=""
#上传appstore
#账号
parameter_username=""
#独立密码
parameter_password=""

echo "\033[32m****************\n开始自动打包\n****************\033[0m\n"

# ==========自动打包配置信息部分========== #

#返回上一级目录,进入项目工程目录
cd ..
#获取项目名称
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

#获取工程plist配置文件
info_plist_path="${project_name}/Info.plist"

#设置build版本号（可以不进行设置）
date=`date +"%Y%m%d%H%M"`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $date" "$info_plist_path"

#获取版本号
bundle_version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${info_plist_path}`
#获取build版本号
bundle_build_version=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${info_plist_path}`

#指定输出ipa路径
export_path_ipa=./$project_name-IPA
#指定输出归档文件地址
export_path_archive="$export_path_ipa/$project_name.xcarchive"

#指定输出ipa名称 : project_name + bundle_version + bundle_build_version
ipa_name="$project_name-V$bundle_version($bundle_build_version)"
#ipa最终路径
path_ipa=$export_path_ipa/$ipa_name.ipa

echo "\033[32m****************\n自动打包选择配置部分\n****************\033[0m\n"

# ==========自动打包可选择信息部分========== #
# 输入是否为工作空间
archiveRun () {
    #是否是工作空间
    echo "\033[36;1m是否是工作空间(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 是 \033[0m"
    echo "\033[33;1m2. 否 \033[0m"
    
    if [ ${#parameter_workspace} == 0 ]
    then
        #读取用户输入
        read parameter_workspace
        sleep 0.5
    fi

    if [ "$parameter_workspace" == "1" ]
    then
        echo "\n\033[32m****************\n将采用：xcworkspace\n****************\033[0m\n"
    elif [ "$parameter_workspace" == "2" ]
    then
        echo "\n\033[32m****************\n将采用：xcodeproj\n****************\033[0m\n"
    else
        parameterInvalid
        parameter_workspace
        archiveRun
    fi
}
archiveRun

# 输入打包模式
configurationRun () {
    echo "\033[36;1m请选择打包模式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. Release \033[0m"
    echo "\033[33;1m2. Debug \033[0m"
    
    if [ ${#parameter_configuration} == 0 ]
    then
        #读取用户输入
        read parameter_configuration
        sleep 0.5
    fi

    if [ "$parameter_configuration" == "1" ];
    then
        parameter_configuration="Release"
    elif [ "$parameter_configuration" == "2" ];
    then
        parameter_configuration="Debug"
    else
        echo "\n\033[31;1m****************\n您输入的参数,无效请重新输入!!! \n****************\033[0m\n"
        parameter_configuration=""
        configurationRun
    fi
    
    echo "\n\033[32m****************\n打包模式：${parameter_configuration} \n****************\033[0m\n"
}
configurationRun


# 输入打包类型
methodRun () {
    # 输入打包类型
    echo "\033[36;1m请选择打包方式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. AdHoc(预发) \033[0m"
    echo "\033[33;1m2. AppStore(发布) \033[0m"
    echo "\033[33;1m3. Enterprise(企业) \033[0m"
    echo "\033[33;1m4. Development(测试) \033[0m\n"
    
    if [ ${#parameter_type} == 0 ]
    then
        #读取用户输入
        read parameter_type
        sleep 0.5
    fi
      
    if [ "$parameter_type" == "1" ]; then
        parameter_type="AdHoc"
    elif [ "$parameter_type" == "2" ]; then
        parameter_type="AppStore"
    elif [ "$parameter_type" == "3" ]; then
        parameter_type="Enterprise"
    elif [ "$parameter_type" == "4" ]; then
        parameter_type="Development"
    else
        parameter_type=""
        methodRun
    fi
    
    echo "\033[32m****************\n您选择了 ${parameter_type} 打包类型\n****************\033[0m\n"
}
methodRun

# 输入上传类型
publishRun () {
    # 输入打包类型
    echo "\033[36;1m请选择上传类型(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 蒲公英 \033[0m"
    echo "\033[33;1m2. AppStore \033[0m"
    echo "\033[33;1m3. 不上传 \033[0m"
    
    if [ ${#parameter_upload} == 0 ]
    then
        #读取用户输入
        read parameter_upload
        sleep 0.5
    fi

    if [ "$parameter_upload" == "1" ]; then
        echo "\033[32m****************\n您选择了上传 蒲公英\n****************\033[0m\n"
    elif [ "$parameter_upload" == "2" ]; then
        echo "\033[32m****************\n您选择了上传 AppStore\n****************\033[0m\n"
    elif [ "$parameter_upload" == "3" ]; then
        echo "\033[32m****************\n您选择了不上传\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        parameter_upload=""
        publishRun
    fi
}
publishRun

echo "\n\033[32m****************\n打包信息配置完毕，开始进行打包\n****************\033[0m\n"
echo "\n\033[32m****************\n开始清理工程\n****************\033[0m\n"

#强制删除旧的文件夹
rm -rf $export_path_ipa

# 指定输出文件目录不存在则创建
if test -d "$export_path_ipa" ;
then
    echo $export_path_ipa
else
    mkdir -pv $export_path_ipa
fi

# 清理工程
xcodebuild clean -configuration "$parameter_configuration" -alltargets

echo "\n\033[32m****************\n清理工程完毕\n****************\033[0m\n"
echo "\n\033[32m****************\n开始编译项目\n****************\033[0m\n"

# 开始编译
if [ "$parameter_workspace" == "1" ]
then
    #工作空间
    xcodebuild archive \
    -workspace ${project_name}.xcworkspace \
    -scheme ${project_name} \
    -configuration ${build_configuration} \
    -destination generic/platform=ios \
    -archivePath ${export_path_archive}
else
    #不是工作空间
    xcodebuild archive \
    -project ${project_name}.xcodeproj \
    -scheme ${project_name} \
    -configuration ${build_configuration} \
    -archivePath ${export_path_archive}
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$export_path_archive" ; then
    echo "\n\033[32m****************\n项目编译成功\n****************\033[0m\n"
else
    echo "\n\033[32m****************\n项目编译失败\n****************\033[0m\n"
    exit 1
fi

echo "\n\033[32m****************\n开始导出ipa文件\n****************\033[0m\n"

#1、打包命令
#2、归档文件地址
#3、ipa输出地址
#4、ipa打包plist文件地址
xcodebuild -exportArchive \
-archivePath ${export_path_archive} \
-configuration ${parameter_configuration} \
-exportPath ${export_path_ipa}  \
-exportOptionsPlist "./Shell/${parameter_type}_ExportOptions.plist"

# 修改ipa文件名称
mv $export_path_ipa/$project_name.ipa $path_ipa

# 检查文件是否存在
if test -f "$path_ipa" ; then
    echo "\n\033[32m****************\n导出 $ipa_name.ipa 包成功\n****************\033[0m\n"
else
    echo "\n\033[32m****************\n导出 $ipa_name.ipa 包失败\n****************\033[0m\n"
    exit 1
fi

echo "\n\033[32m****************\n使用Shell脚本打包完毕\n****************\033[0m\n"

#上传 蒲公英
if [ "$parameter_upload" == "1" ]
then
    echo "\033[32m****************\n开始上传蒲公英\n****************\033[0m\n"

    curl -F "file=@$path_ipa" \
    -F "uKey=e5a9331a3fd25bc36646f831e4d42f2d" \
    -F "_api_key=ce1874dcf4523737c9c1d3eafd99164f" \
    https://qiniu-storage.pgyer.com/apiv1/app/upload

    echo "\033[32m****************\n上传蒲公英完毕\n****************\033[0m\n"
fi


#上传 AppStore
if [ "$parameter_upload" == "2" ]
then
    #验证账号密码
    if [ ${#parameter_username} != 0 -a ${#parameter_username} != 0 ]
    then
        echo "\n\033[32m****************\n开始上传AppStore\n****************\033[0m\n"
        
        #验证APP
        altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
        "${altoolPath}" --validate-app \
        -f "$path_ipa" \
        -u "$parameter_username" \
        -p "$parameter_password" \
        --output-format xml
        #上传APP
        "${altoolPath}" --upload-app \
        -f "$path_ipa" \
        -u "$parameter_username" \
        -p "$parameter_password" \
        --output-format xml
        
        echo "\n\033[32m****************\n上传AppStore完毕\n****************\033[0m\n"
    fi
fi

