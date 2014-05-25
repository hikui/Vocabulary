# 注意事项
由于本人时间有限，不保证没有逻辑上的错误。有兴趣的同学可以根据自己的需求来修改功能。   
软件在91助手上面发布，可搜索“记词助手”。 
软件在AppStore发布，可搜索“记词助手”  

不得将本软件直接用于毕业设计、大作业！！！

#技术要点
* Xcode 5.0及以上
* iOS 6.0及以上
* 完全使用 ARC
* 使用了Core Data
* 使用了金山词霸公开的API
* 加了友盟的统计

#编译
本工程使用cocoapods进行三方库管理。编译前请确保[安装了cocoapods](http://cocoapods.org)(可能需要翻墙)。

打开命令行执行：

	$ cd Vocabulary
	$ pod install

完成后，打开`Vocabulary.xcworkspace`即可编译。

注意，xcode 5.1以上的版本，需修改workspace中的`pods`工程里面的`Architectures`的值为`armv7和armv7s`，而不能使用默认值，并确保主工程的编译选项也跟这个一致。这是因为**友盟的SDK并没有arm64的section**。

####友情提示
如果在安装cocoapods时觉得比较慢，可以将gem的源改为淘宝镜像，[详见这里](https://ruby.taobao.org)。

#说明
功能如下:

* 根据艾宾浩斯记忆法管理word list的学习进度。
* 学习（乱序、读音、解释），评估。
* 手动批量输入新单词，或者用iTunes导入。
* 根据编辑距离和最长子串，求易混淆单词。
* 每日定时提醒

[点此捐赠](https://me.alipay.com/hikui)


