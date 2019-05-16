# 升级Centos 7/6内核版本到5.1.1/4.4.179 的方法
=====================================

Introduction   ELRepo
------------------------

* Welcome to ELRepo, an RPM repository for Enterprise Linux packages. ELRepo supports Red Hat Enterprise Linux (RHEL) and its derivatives (Scientific Linux, CentOS & others) : `http://elrepo.org/tiki/tiki-index.php`_
 
* 公司打算上Docker服务，目前需要安装运行环境，Docker新的功能除了需要Centos 7系统之外，内核的版本高低也决定着使用的效果，所以在此记录下系统内核版本升级过程。

* 注：对于线上环境的内核版本还需要根据实际情况谨慎选择，越新的版本未来可能遇到的问题越多，此文只是记录升级方法而已。

* 关于内核版本的定义：

* 版本性质：主分支ml(mainline)，稳定版(stable)，长期维护版lt(longterm)

* 版本命名格式为 “A.B.C”：

* 数字 A 是内核版本号：版本号只有在代码和内核的概念有重大改变的时候才会改变，历史上有两次变化：
* 第一次是1994年的 1.0 版，第二次是1996年的 2.0 版，第三次是2011年的 3.0 版发布，但这次在内核的概念上并没有发生大的变化
数字 B 是内核主版本号：主版本号根据传统的奇-偶系统版本编号来分配：奇数为开发版，偶数为稳定版
* 数字 C 是内核次版本号：次版本号是无论在内核增加安全补丁、修复bug、实现新的特性或者驱动时都会改变
*  下载指定版本 kernel： http://rpm.pbone.net/index.php3?stat=3&limit=1&srodzaj=3&dl=40&search=kernel

* 下载指定版本 kernel-devel：

官方 Centos 6: ` http://elrepo.org/linux/kernel/el6/x86_64/RPMS/`_

官方 Centos 7: `http://elrepo.org/linux/kernel/el7/x86_64/RPMS/`_

# 启用 ELRepo 仓库

* To install ELRepo for RHEL-8 or CentOS-8:

```
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo yum install https://www.elrepo.org/elrepo-release-8.0-1.el8.elrepo.noarch.rpm
sudo yum --disablerepo="*" --enablerepo="elrepo-kernel" list available   #查看可用的系统内核包
sudo yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64  # 安装最新内核
```

* To install ELRepo for RHEL-7, SL-7 or CentOS-7:

```
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo yum install https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum --disablerepo="*" --enablerepo="elrepo-kernel" list available   # 查看可用的系统内核包
sudo yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64 # 安装最新内核
```

*  To install ELRepo for RHEL-6, SL-6 or CentOS-6:

```
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install https://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
sudo yum --disablerepo="*" --enablerepo="elrepo-kernel" list available  # 查看可用的系统内核包
sudo yum -y --enablerepo=elrepo-kernel install kernel-lt.x86_64 kernel-lt.devel.x86_64  # 安装最新内核

```
# 设置 grub2

* 查看系统上的所有可以内核：

```
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg

```

*  设置 grub2    注：Centos 6 更改的文件相同，使用命令确定新内核位置后，然后将参数default更改为0即可

```
sudo grub2-set-default 0
sudo vi /etc/default/grub
GRUB_TIMEOUT=5 > GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)" 
 GRUB_DEFAULT=saved    #改成    GRUB_DEFAULT=0
 GRUB_DISABLE_SUBMENU=true > GRUB_TERMINAL_OUTPUT="console"
 .......
 ```
 
# on Centos6 

```
cat /etc/grub.conf 
....
default=0
timeout=5
splashimage=(hd0,0)/grub/splash.xpm.gz
hiddenmenu
title CentOS (4.4.179-1.el6.elrepo.x86_64)
	root (hd0,0)
	kernel /vmlinuz-4.4.179-1.el6.elrepo.x86_64 ro root=UUID=1a3674cd-0011-4568-b7c5-79ef77c50194 rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet
	initrd /initramfs-4.4.179-1.el6.elrepo.x86_64.img

...
把以前的都注释掉 ---> reboot---> uname -r

uname -r
4.4.179-1.el6.elrepo.x86_64

```
 
* 运行grub2-mkconfig命令来重新创建内核配置

```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot
```

# 重启系统并查看系统内核

```
uname -r
5.1.1-1.el7.elrepo.x86_64
```
