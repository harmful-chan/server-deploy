

## Quick Start
完整安装并启动
```sh
./install
```
脚本通过环境变量来指定部署步骤，`.env`文件开头声明了可用的设置<br>
脚本执行最后会自动调用`clean`函数会清除`.env`中定义的全部变量。<br>
注意：请效仿 **install.sh**，**update.sh**..等。先定义`XXX_XXX=true`，然后执行**deploy.sh**

## Example
example：源码安装nginx并运行
```sh
#!/bin/bash
NGINX_MAKE=true              # 下载源码并编译,默认下载目录用 TAR_DIR设置
NGINX_INSTALL=true           # 拷贝到 /usr/local/nginx
NGINX_UPDATE_CONFIG=true     # 配置文件连接到 ./nginx/nginx.conf
NGINX_UPDATE_SERVICE=true    # 服务文件链接带 ./nginx/nginx.servce
NGINX_RESTART=true           # 启动服务

source deploy.sh
```




