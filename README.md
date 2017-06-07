# 编译问题处理

当你在编译出现问题时，请尝试删除Derived Data。

方法：进入`Window->Projects`，找到你的工程，在Derived Data一行点击`Delete`

# 注意事项
业余项目，用于尝试iOS新版本的新功能，以及一些三方库。   
软件在AppStore发布，可搜索“记词助手”  

# 技术要点
* Xcode 8.3及以上
* iOS 9.0及以上
* 使用了Core Data
* 使用了金山词霸公开的API

# 编译
本工程使用cocoapods进行三方库管理。编译前请确保[安装了cocoapods](http://cocoapods.org)(可能需要翻墙)。

打开命令行执行：

	$ cd Vocabulary
	$ pod install

完成后，打开`Vocabulary.xcworkspace`即可编译。

#### 友情提示
如果在安装cocoapods时觉得比较慢，可以将gem的源改为淘宝镜像，[详见这里](https://ruby.taobao.org)。

# 说明
功能如下:

* 根据艾宾浩斯记忆法管理word list的学习进度。
* 学习（乱序、读音、解释），评估。
* 手动批量输入新单词，或者用iTunes导入。
* 根据编辑距离和最长子串，求易混淆单词。
* 每日定时提醒


