# Shell
xcode自动打包，一键上传appstore脚本

# 使用方法
# 1.将autoarchive.sh和附件中的plist，放在一起，新建文件夹为Shell，将这几文件复制进去，然后复制Shell文件夹到工程的根目录
# 2.终端cd到Shell下，执行脚本 格式为 sh autoarchive.sh

# 需要修改的地方有
# 将 target_name="demo" 修改成自己的工程名字
# 其中附件中的 AdHocExportOptions、AppStoreExportOptions、DevelopmentExportOptions、EnterpriseExportOptions为xcode手动打包过后 ExportOptions.plist 这个文件将文件名字修改替换即可
