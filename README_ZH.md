# Tiny Image

> 出于知识产权角度考虑，应用名修改为 Tiny Image，因为原名包含 TinyPNG 和 macOS。

![preview](./preview/banner.png)



TinyPNG for macOS 是 [TinyPNG](https://tinypng.com) 的第三方客户端，使用它，无需打开浏览器即可压缩图片。

[English](./README.md)



### 2.1.0 更新说明

> 2.0.0 及以后版本支持 macOS 13 Ventura 及更新的系统。更低版本的系统请使用历史版本。

1. 修复 issue #65：当应用关闭时，将图片拖到 Dock 图标导致任务错误的问题。
2. 禁用 SandBox 模式。现在 Tiny Image 可以在输出文件夹不存在时自动创建文件夹。
3. 在主窗口显示当前的保存模式（覆写模式 / 另存为模式）。
4. 在主窗口新增输出文件夹图标，支持点击打开文件夹。
5. 在任务列表添加常用功能入口。

[更新日志](./CHANGE_LOG_ZH.md)



### 使用方法

1. 在 [这里](https://tinypng.com/developers) 注册 **API key**。
2. 将 API key 粘贴到 `设置` 窗口中。（如果需要，您可以随时修改）
3. 将图片或包含图片的文件夹拖拽到窗口中。




### 下载

通过 [发布页面](https://github.com/kyleduo/TinyPNG4Mac/releases) 下载。

如果无法打开该应用，请检查 `系统设置 -> 安全性与隐私` 页面。



### 感谢

[droptogif](https://github.com/mortenjust/droptogif) —— 一个非常实用的将视频转换为 gif 的客户端。我从这个项目中学会了如何创建窗口。



### 许可

Developed by [@kyleduo](https://github.com/kyleduo) and available under the [MIT](http://opensource.org/licenses/MIT) license.
