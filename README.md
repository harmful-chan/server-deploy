## Overview

Linux 服务器软件部署 集成脚本。

当前包含 : mongodb、nginx、php(php-fpm)、openldap(sladp, phpldapadmin) ... 等

一般来说 `.env`文件开头声明了可用的设置。`bash.sh` 声明了全局可用的函数。

可以设置`xx_xxx_xxx=true`运行该步骤

每个文件夹相当于可部署的一个组件，多数情况下，搭建起一个服务需要好几个部件一起运行.



**访问域名:  sexhansc.com**
**ssl证书: server-deploy/nginx/cert/sexhansc.com/sexhansc.com.crt**

由于华为的证书申请比较久，先自己签了了ssl用于实验环境，直接改host文件指向我的服务器。

Windows 10 `C:\Windows\System32\drivers\etc`

Linux `/etc/hosts`

```shell
124.71.46.212       sexhansc.com
124.71.46.212       ldap.sexhansc.com
124.71.46.212       zabbix.sexhansc.com
124.71.46.212       test.sexhansc.com
```

**或**：设置设置dns服务器 `124.71.46.212`，已添加A记录可解析`*.sexhansc.com` 下的所有子域名。



###  当前的组件 - 2022年6月1日21点29分

+ `nginx`： 按照访问域名，转发http请求到不同端口
+ `bind9`：域名解析
+ `slapd`：LDAP后端服务
+ `phpldapadmin`：LDAP前端web页面
+ `mongodb`（闲置）：非关系型数据库
+ `php`：php开发环境
+ `openvpn`：vpn连接服务端
+ `mysql8`：数据库

```shell
         服务 : 依赖组件
phpldapadmin : nginx slapd php
     mongodb :
       bind9 :
     openvpn :
      mysql8 :
```



| 软件         | 安装方式 | 支持系统               | 配置文件 | 服务文件                                       | 包含模块                |
| ------------ | -------- | ---------------------- | -------- | ---------------------------------------------- | ----------------------- |
| nginx        | source   | CentOS7.8, Ubuntu18.04 | √        | √                                              | ssl, stream             |
| mongodb      | pkg      | CentOS7.8, Ubuntu18.04 | √        | √                                              |                         |
| php          | source   | CentOS7.8, Ubuntu18.04 | √        | ×                                              | php-fpm, ldap, freetype |
| phpldapadmin | bin      | CentOS7.8, Ubuntu18.04 | √        | √                                              |                         |
| slapd        | source   | CentOS7.8, Ubuntu18.04 | √        | √                                              |                         |
| bind9        | source   | Ubuntu18.04            | √        | √                                              |                         |
| openvpn      | bin      | CentOS8.5, Ubuntu18.04 | √        | openvpn-client@node1<br/>openvpn-server@server |                         |
| mysql8       | pkg      | Ubuntu18.04            | √        | √                                              |                         |



###  当前组件详情- 2022年5月31日20点20分

+ **域名映射**

可修改`nginx/tables.txt` 自动生成nginx配置 `nginx/conf/not_ssl.conf` 

更新配置文件时回自动识别`tables.txt` 生成对应的 `server`

```shell
https://ldap.sexhansc.com:8443/phpldapadmin  -> http://localhost:8000 -> phpldapadmin 管理页面
https://test.sexhansc.com:8443/  -> http://localhost:8999 -> nginx 默认页面
https://zabbix.sexhansc.com:8443/  -> http://localhost:8010 -> zabbix 管理页面
```

+ **开放端口** 

``` shell
vpn   : 1194
dns   : 53
https : 8443
```

+ **域名解析**

```shell
; sexhansc.com
; 公网
@          IN  A     124.71.46.212
ns         IN  A     124.71.46.212
ldap       IN  A     124.71.46.212
test       IN  A     124.71.46.212
zabbix     IN  A     124.71.46.212
vpn        IN  A     124.71.46.212
; 集群内网
ctl        IN  A     192.168.0.10
node1      IN  A     192.168.1.11
node2      IN  A     192.168.1.12
node3      IN  A     192.168.1.13
node4      IN  A     192.168.1.14
node5      IN  A     192.168.1.15
```

+ **集群连接**

```shell
                                    node1 (centos8.5 虚拟机)
                                    node1.sexhansc.com
                       /            192.168.1.11(vpn内网)
                                    192.168.137.11(hyper-v内网)
                                            ...
server (ubuntu18)                   node3
ctl.sexhansc.com        _           node3.sexhansc.com
124.71.46.212                       192.168.1.13
192.168.1.1/2                       192.168.137.13
                                            ...  
                                    node5
                        \           node5.sexhansc.com
                                    192.168.1.15
                                    192.168.137.15
```



## Log

#### 2022年6月1日21点29分

+ bin/
    + gend.sh : 读取.env文件，生成 <可用配置> 到README.md末尾
+ mysql8/

#### 2022年5月31日16点48分

+ bin/
    + stop.sh：运行systemctl stop xxx 停止所有正在运行的服务（仅包括server-deploy内的）
+ openvpn/
+ bind9/

#### 2022年5月29日19点47分


+ bin/ : 执行脚本存放目录
	+ settrue.sh : 自动生成变量。$./settrue update config server1 server2 ...  # 生成 SERVER1_UPDATE_CONFIG=true ...  
  + status.sh : 服务监控. $./status.sh
+ nginx/

  + tables.txt: 域名映射配置文件

#### snapshot

+ mongodb/
+ nginx/
+ php/
+ phpldapamin/
+ slapd/
+ bin/

## <可用配置>


+ bin<br>
`PACKAGE_INFO_SHOW`: 安装信息放在 install.msg<br>
`TAR_DIR`: 压缩包存放目录<br>
`SRC_DIR`: 解压存放目录<br>
`RELEASE`: 系统版本<br>
`S`: sudo<br>
`SERVICE_DIR`: 服务配置文件存放目录<br>
`INSTALLER`: apt-get 或 yum<br>
`DistribuID`: ubuntu 或 centos<br>
`D`: $D可以获取当前脚本路径<br>

+ phpldapadmin<br>
`PHPLDAPADMIN_INSTALL_BIN`: 二进制安装<br>
`PHPLDAPADMIN_UPDATE_CONFIG`: 更新配置文件<br>
`PHPLDAPADMIN_UPDATE_SERVICE`: 更新服务文件<br>

+ openvpn<br>
`OPENVPN_INSTALL_BIN`: 二进制安装<br>
`OPENVPN_GEN_CERT`: 用easy-rsa生成 ca，server，client等的证书和密钥<br>
`OPENVPN_UPDATE_CONFIG`: 更新配置文件<br>
`OPENVPN_UPDATE_SERVICE`: 更新服务文件<br>

+ mongod<br>
`MONGOD_NAME`: mongodb包名<br>
`MONGOD_INSTALL_PKG`: 包安装<br>
`MONGOD_UPDATE_CONFIG`: 更新配置文件<br>
`MONGOD_UPDATE_SERVICE`: 更新服务文件<br>

+ nginx<br>
`NGINX_NAME`: 包名<br>
`NGINX_INSTALL_SRC`: 源码安装<br>
`NGINX_UPDATE_CONFIG`: 更新配置文件<br>
`NGINX_UPDATE_CERT`: 更新证书<br>
`NGINX_UPDATE_SERVICE`: 更新服务文件<br>

+ slapd<br>
`OPENSSL_BUILD`: 系统额外编译安装openssl<br>
`LDAP_CONF_OPENSSL`: openldap编译openssl模块<br>
`LDAP_NAME`: 包名<br>
`LDAP_INSTALL_SRC`: 源码安装<br>
`LDAP_UPDATE_CONFIG`: 更新配置文件<br>
`LDAP_UPDATE_SERVICE`: 更新服务文件<br>
`LDAP_LOAD_DEMO`: 加载demo数据<br>

+ bind9<br>
`BIND9_INSTALL_SRC`: 源码安装<br>
`BIND9_UPDATE_CONFIG`: 更新配置文件<br>
`BIND9_UPDATE_SERVICE`: 更新服务文件<br>

+ mysql8<br>
`MYSQL8_NAME`: mysql8包名<br>
`MYSQL8_INSTALL_PKG`: 包安装<br>
`MYSQL8_UPDATE_CONFIG`: 更新配置文件<br>
`MYSQL8_UPDATE_SERVICE`: 更新服务文件<br>
`MYSQL8_INIT_ROOT`: 初始化root账号密码<br>

+ php<br>
`FREETYPE_BUILD`: 系统额外编译安装freetype<br>
`PHP_CONF_FREETYPE`: PHP编译freetype模块<br>
`PHP_CONF_LDAP`: PHP编译ldap模块<br>
`PHP_NAME`: 包名<br>
`PHP_INSTALL_SRC`: 源码安装<br>
`PHP_UPDATE_CONFIG`: 更新配置文件<br>
