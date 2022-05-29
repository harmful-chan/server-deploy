## Overview

Linux 服务器软件部署 集成脚本。

当前包含 : mongodb、nginx、php(php-fpm)、openldap(sladp, phpldapadmin)

一般来说 `.env`文件开头声明了可用的设置。`bash.sh` 声明了全局可用的函数。

每个文件夹相当于可部署的一个组件，多数情况下，搭建起一个服务需要好几个部件一起运行.



由于华为的证书申请比较久，先自己签了了ssl用于实验环境，直接改host文件指向我的服务器。

Windows 10 `C:\Windows\System32\drivers\etc`

Linux `/etc/hosts`

```shell
124.71.46.212       sexhansc.com
124.71.46.212       ldap.sexhansc.com
124.71.46.212       zabbix.sexhansc.com
124.71.46.212       test.sexhansc.com
```

+ **域名:  sexhansc.com**
+ **证书: nginx/cert/sexhansc.com/sexhansc.com.crt**





#### 当前的组件架构：2022年5月29日19点59分

```shell
服务 : 依赖组件

phpldapadmin : nginx slapd php
             : mongodb （闲置）
```





#### 当前域名端口映射: 2022年5月29日19点59分

可修改`nginx/tables.txt` 自动生成nginx配置 `nginx/conf/not_ssl.conf` 

更新配置文件时回自动识别`tables.txt` 生成对应的 `server`

```shell
https://ldap.sexhansc.com:8443/phpldapadmin  -> http://localhost:8000 -> phpldapadmin 管理页面

https://test.sexhansc.com:8443/  -> http://localhost:8999 -> nginx 默认页面

https://zabbix.sexhansc.com:8443/  -> http://localhost:8010 -> zabbix 管理页面
```



#### 当前组件详情: 2022年5月29日19点59分

| 软件         | 安装方式 | 支持系统               | 配置文件 | 服务文件 | 包含模块                |
| ------------ | -------- | ---------------------- | -------- | -------- | ----------------------- |
| nginx        | source   | CentOS7.8, Ubuntu18.04 | √        | √        | ssl, stream             |
| mongodb      | bin      | CentOS7.8, Ubuntu18.04 | √        | √        |                         |
| php          | source   | CentOS7.8, Ubuntu18.04 | √        |          | php-fpm, ldap, freetype |
| phpldapadmin | bin      | CentOS7.8, Ubuntu18.04 | √        | √        |                         |
| slapd        | source   | CentOS7.8, Ubuntu18.04 | √        | √        |                         |

## Log



#### 2022年5月29日19点47分


+ bin/ : 执行脚本存放目录
	+ settrue.sh : 自动生成变量。$./settrue update config server1 server2 ...  # 生成 SERVER1_UPDATE_CONFIG=true ...  
  + status.sh : 服务监控. $./status.sh
+ nginx/

  + tables.txt: 域名映射配置文件

