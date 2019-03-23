#!/bin/sh
git config --global user.email "819046834@qq.com" #登录邮箱，注册git时用的邮箱

git config --global user.email "819046834" #登录用户名

git remote add origin https://github.com/819046834/ubuntu-linux.git #链接本地仓库和远程服务器仓库

git clone https://github.com/819046834/ubuntu-linux.git #从git网站克隆下ubuntu-linux.git

git add . #添加当前目录到仓库中,git status:查看状态

git commit -a -m "test" #提交所有文件

git push origin master #把文件推到git服务器上

