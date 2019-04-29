# 搭建Harbor企业级docker仓库
* 1.Harbor介绍

Harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源Docker Distribution。作为一个企业级私有Registry服务器，Harbor提供了更好的性能和安全。提升用户使用Registry构建和运行环境传输镜像的效率。Harbor支持安装在多个Registry节点的镜像资源复制，镜像全部保存在私有Registry中， 确保数据和知识产权在公司内部网络中管控。另外，Harbor也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等。

* 2.Harbor特性

    基于角色的访问控制 ：用户与Docker镜像仓库通过“项目”进行组织管理，一个用户可以对多个镜像仓库在同一命名空间（project）里有不同的权限。
    镜像复制 ： 镜像可以在多个Registry实例中复制（同步）。尤其适合于负载均衡，高可用，混合云和多云的场景。
    图形化用户界面 ： 用户可以通过浏览器来浏览，检索当前Docker镜像仓库，管理项目和命名空间。
    AD/LDAP 支持 ： Harbor可以集成企业内部已有的AD/LDAP，用于鉴权认证管理。
    审计管理 ： 所有针对镜像仓库的操作都可以被记录追溯，用于审计管理。
    国际化 ： 已拥有英文、中文、德文、日文和俄文的本地化版本。更多的语言将会添加进来。
    RESTful API ： RESTful API 提供给管理员对于Harbor更多的操控, 使得与其它管理软件集成变得更容易。
    部署简单 ： 提供在线和离线两种安装工具， 也可以安装到vSphere平台(OVA方式)虚拟设备。

* 3.Harbor组件

Harbor在架构上主要由6个组件构成：

    Proxy：Harbor的registry, UI, token等服务，通过一个前置的反向代理统一接收浏览器、Docker客户端的请求，并将请求转发给后端不同的服务。

    Registry： 负责储存Docker镜像，并处理docker push/pull 命令。由于我们要对用户进行访问控制，即不同用户对Docker image有不同的读写权限，Registry会指向一个token服务，强制用户的每次docker pull/push请求都要携带一个合法的token, Registry会通过公钥对token 进行解密验证。

    Core services： 这是Harbor的核心功能，主要提供以下服务：

    UI：提供图形化界面，帮助用户管理registry上的镜像（image）, 并对用户进行授权。

    webhook：为了及时获取registry 上image状态变化的情况， 在Registry上配置webhook，把状态变化传递给UI模块。

    token 服务：负责根据用户权限给每个docker push/pull命令签发token. Docker 客户端向Regiøstry服务发起的请求,如果不包含token，会被重定向到这里，获得token后再重新向Registry进行请求。

    Database：为core services提供数据库服务，负责储存用户权限、审计日志、Docker image分组信息等数据。

    Job Services：提供镜像远程复制功能，可以把本地镜像同步到其他Harbor实例中。

    Log collector：为了帮助监控Harbor运行，负责收集其他组件的log，供日后进行分析。


* 4.Harbor实现

Harbor的每个组件都是以Docker容器的形式构建的，官方也是使用Docker Compose来对它进行部署。用于部署Harbor的Docker Compose模板位于 harbor/docker-compose.yml,打开这个模板文件，发现Harbor是由7个容器组成的；

```
[root@node_6 harbor]# docker-compose ps
       Name                   Command                State                 Ports
-------------------------------------------------------------------------------------------
harbor-adminserver   /harbor/start.sh             Up (healthy)
harbor-core          /harbor/start.sh             Up (healthy)
harbor-db            /entrypoint.sh postgres      Up (healthy)   5432/tcp
harbor-jobservice    /harbor/start.sh             Up
harbor-log           /bin/sh -c /usr/local/bin/   Up (healthy)   127.0.0.1:1514->10514/tcp
                     ...
harbor-portal        nginx -g daemon off;         Up (healthy)   80/tcp
nginx                nginx -g daemon off;         Up (healthy)   0.0.0.0:443->443/tcp,
                                                                 0.0.0.0:4443->4443/tcp,
                                                                 0.0.0.0:80->80/tcp
redis                docker-entrypoint.sh redis   Up             6379/tcp
                     ...
registry             /entrypoint.sh /etc/regist   Up (healthy)   5000/tcp
                     ...
registryctl          /harbor/start.sh             Up (healthy)


nginx：nginx负责流量转发和安全验证，对外提供的流量都是从nginx中转，所以开放https的443端口，它将流量分发到后端的ui和正在docker镜像存储的docker registry。
harbor-jobservice：harbor-jobservice 是harbor的job管理模块，job在harbor里面主要是为了镜像仓库之前同步使用的;
harbor-ui：harbor-ui是web管理页面，主要是前端的页面和后端CURD的接口;
registry：registry就是docker原生的仓库，负责保存镜像。
harbor-adminserver：harbor-adminserver是harbor系统管理接口，可以修改系统配置以及获取系统信息。
这几个容器通过Docker link的形式连接在一起，在容器之间通过容器名字互相访问。对终端用户而言，只需要暴露proxy （即Nginx）的服务端口。
harbor-db：harbor-db是harbor的数据库，这里保存了系统的job以及项目、人员权限管理。由于本harbor的认证也是通过数据，在生产环节大多对接到企业的ldap中；
harbor-log：harbor-log是harbor的日志服务，统一管理harbor的日志。通过inspect可以看出容器统一将日志输出的syslog。

这几个容器通过Docker link的形式连接在一起，这样，在容器之间可以通过容器名字互相访问。对终端用户而言，只需要暴露proxy （即Nginx）的服务端口。
```
