# 注意事项
本程序刚刚进入开发阶段，所以功能较少，或者部分功能尚待商榷。   
施主，您就过几天再来看吧。

* Xcode 4.4及以上
* iOS 5.0及以上
* 完全使用 ARC
* 使用了Core Data
* 使用了金山词霸公开的API

# 依赖关系
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
* [MKNetworkKit](https://github.com/MugunthKumar/MKNetworkKit)
* [TouchXML](https://github.com/TouchCode/TouchXML)

# 编译步骤
>### 注意！！！！
>TouchXML需要下载ARC版本！！！   

如图在Vocabulary文件夹下建立lib文件夹，并在Lib下建立MBProgressHUD, MKNetworkKit, TouchXML三个文件夹（如图）。

![dir](https://gitcafe.com/hikui/Vocabulary/blob/master/docs/img/dir.png?raw=true)

将依赖关系中提到的各个项目的代码，按照各个项目的说明分别拷贝到对应文件夹下。

打开Xcode即可编译。
