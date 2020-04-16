# TinyPNG4Mac
![preview](./preview/preview.png)

这是[TinyPNG](https://tinypng.com)的Mac客户端。TinyPNG提供了PNG图片的“几乎无损”压缩服务。使用TinyPNG4Mac，你可以通过简单的拖拽完成对PNG图片的压缩，无需打开浏览器，无需手动下载图片。

[English](./README.md)



### 使用

1. 到[这里](https://tinypng.com/developers)注册API Key. 你也可以在打开TinyPNG4Mac的时候注册。
2. 将API Key粘贴到界面上。
3. 拖拽图片到窗口中。




### 下载

Homebrew

```
brew cask install tinypng4mac
```

[Release Page](https://github.com/kaishiqi/TinyPNG4Mac/releases) 

[CDN下载](https://static.kaishiqi.com/project/release/tinypng4mac/tinypng4mac_1_0_4.zip)

第一次打开可能出现“无法打开”的提示，请到`设置 -> 安全性与隐私`里面勾选`所有来源`。出于安全考虑，建议打开之后关闭这个选项。

### 致谢

[droptogif](https://github.com/mortenjust/droptogif) -- 实用的视频转Gif的工具。我在里面学习了如何创建Window。

### 更新信息

**Version 1.0.4**

1. 增加重试功能

**Version 1.0.3**

1. 支持压缩目录下的所有图片 [#14](https://github.com/kyleduo/TinyPNG4Mac/issues/14) [#33](https://github.com/kyleduo/TinyPNG4Mac/issues/33)

----

**Version 1.0.2**

1. 修复 [#29](https://github.com/kyleduo/TinyPNG4Mac/issues/29)
2. 修复一处拼写错误

**Version 1.0.1**

1. 迁移到Swift 5.0
2. 向下兼容macOS 10.10
3. 修复问题  [#19](https://github.com/kyleduo/TinyPNG4Mac/issues/19), [#22](https://github.com/kyleduo/TinyPNG4Mac/issues/22)

**Version 1.0.0**

1. 新设计的icon和界面
2. 支持“替换原图”
3. 修复bug，提升稳定性

**Version 0.9.3**

1. 升级到Swift 3
2. 将`Pod/`添加到`.gitignore`
3. 上传和下载时显示进度

**Version 0.9.2**

1. 支持 **JPG** 和 **JPEG**.

**0.9版本带来了很多更新**

1. 重新设计的UI；
2. 新的流程更加易用，安全；
3. 支持自定义保存路径；
4. 任务列表排序；
5. 支持中文。

### 协议

Developed by [@kyleduo](https://github.com/kyleduo) and available under the [MIT](http://opensource.org/licenses/MIT) license.
