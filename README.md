# KindleEar上传脚本

打开 Google 云端 Shell，复制粘贴以下命令，按照脚本的提示输入 Gmail 和 APPID 等信息即可轻松上传。

```
rm -f uploader.sh* && \
wget https://raw.githubusercontent.com/bookfere/KindleEar-Uploader/master/uploader.sh && \
chmod +x uploader.sh && \
./uploader.sh
```

脚本默认拉取的是 KindleEar 官方源代码，如果想要指定其它 KindleEar 项目分支（比如上传自己修改后的源代码），可在指令的 uploader.sh 后附加 Github 源代码的 URL，如下所示：

```
rm -f uploader.sh* && \
wget https://raw.githubusercontent.com/bookfere/KindleEar-Uploader/master/uploader.sh && \
chmod +x uploader.sh && \
./uploader.sh https://github.com/bookfere/KindleEar.git
```

* KindleEar 上传教程：https://bookfere.com/post/19.html
* KindleEar 项目地址：https://github.com/cdhigh/KindleEar

---

书伴 - 为静心阅读而生
https://bookfere.com
