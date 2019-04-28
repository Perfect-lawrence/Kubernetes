# 这里选择离线安装
Download binaries of **[Harbor release ](https://github.com/vmware/harbor/releases)**

```
[root@node_6 xiangxh]# mkdir /app
[root@node_6 xiangxh]# tar -xf harbor-offline-installer-v1.7.5.tgz -C /app/
[root@node_6 app]# cd /app/harbor/
[root@node_6 harbor]# vim harbor.cfg 
...
#hostname = reg.mydomain.com
hostname = node_6.12306ai.cn   # 修改了这一行
.....


[root@node_6 harbor]# ./install.sh 

[Step 0]: checking installation environment ...

Note: docker version: 18.03.1

Note: docker-compose version: 1.24.0

[Step 1]: loading Harbor images ...
f60840e24dbf: Loading layer  33.23MB/33.23MB
ea7b46fcd541: Loading layer  8.959MB/8.959MB
79b1bab71f92: Loading layer   15.6MB/15.6MB
e44aff944dd8: Loading layer  18.94kB/18.94kB
7f6318c65689: Loading layer   15.6MB/15.6MB
Loaded image: goharbor/harbor-adminserver:v1.7.5
a9e2f8050aff: Loading layer  3.515MB/3.515MB
33c3ed1298dd: Loading layer  4.725MB/4.725MB
d9326e3fe30d: Loading layer  3.584kB/3.584kB
Loaded image: goharbor/harbor-portal:v1.7.5
bba4328a1afb: Loading layer  63.33MB/63.33MB
88104b063567: Loading layer  45.14MB/45.14MB
60a742ac57d5: Loading layer  6.656kB/6.656kB
a5e7e5b02919: Loading layer  2.048kB/2.048kB
47382653700b: Loading layer   7.68kB/7.68kB
278d536f49a9: Loading layer   2.56kB/2.56kB
451b3ca8ec09: Loading layer   2.56kB/2.56kB
8829a7f0eb3e: Loading layer   2.56kB/2.56kB
Loaded image: goharbor/harbor-db:v1.7.5
15c334a58c66: Loading layer  8.959MB/8.959MB
f4577ff967f1: Loading layer  3.072kB/3.072kB
0a274c30569d: Loading layer   2.56kB/2.56kB
6478376fb5c7: Loading layer   2.56kB/2.56kB
a00d1b417512: Loading layer  2.048kB/2.048kB
66058b4b675b: Loading layer   22.8MB/22.8MB
04c23a054a22: Loading layer   22.8MB/22.8MB
Loaded image: goharbor/registry-photon:v2.6.2-v1.7.5
ff8c6a8291ea: Loading layer  657.9MB/657.9MB
b5df13342087: Loading layer   7.68kB/7.68kB
f2df39c3d9a8: Loading layer    212kB/212kB
Loaded image: goharbor/harbor-migrator:v1.7.5
13440ce75e7f: Loading layer  8.959MB/8.959MB
59af227e2ec0: Loading layer  27.25MB/27.25MB
67c2dde4d9fa: Loading layer  5.632kB/5.632kB
d46b0aa196b6: Loading layer  27.25MB/27.25MB
Loaded image: goharbor/harbor-core:v1.7.5
1c90cc04d636: Loading layer  50.49MB/50.49MB
4ab52f94a5c1: Loading layer  3.584kB/3.584kB
857a7831437e: Loading layer  3.072kB/3.072kB
a42683cf65f0: Loading layer   2.56kB/2.56kB
099bf8be91db: Loading layer  3.072kB/3.072kB
583bef7f2e8c: Loading layer  3.584kB/3.584kB
36b35ebc1af0: Loading layer  12.29kB/12.29kB
Loaded image: goharbor/harbor-log:v1.7.5
6dcab6ef5eae: Loading layer  69.42MB/69.42MB
cad37c7902e8: Loading layer  3.072kB/3.072kB
62a0e214a142: Loading layer   59.9kB/59.9kB
b43f9b054f76: Loading layer  61.95kB/61.95kB
Loaded image: goharbor/redis-photon:v1.7.5
e95514e23db7: Loading layer  3.515MB/3.515MB
Loaded image: goharbor/nginx-photon:v1.7.5
a3d38b1212fc: Loading layer  8.959MB/8.959MB
e548b043b8af: Loading layer   22.8MB/22.8MB
ae82274010c4: Loading layer  3.072kB/3.072kB
37c8f4520efa: Loading layer  7.465MB/7.465MB
995f2989db3b: Loading layer  30.26MB/30.26MB
Loaded image: goharbor/harbor-registryctl:v1.7.5
d0fead86c346: Loading layer  8.964MB/8.964MB
a5ec4a361969: Loading layer  35.77MB/35.77MB
4e1010831905: Loading layer  2.048kB/2.048kB
14a7910436b1: Loading layer  3.072kB/3.072kB
2a8b4f2779f0: Loading layer  35.77MB/35.77MB
Loaded image: goharbor/chartmuseum-photon:v0.8.1-v1.7.5
ac0610543c4c: Loading layer  8.959MB/8.959MB
d16400686860: Loading layer  21.51MB/21.51MB
85d9a56758c0: Loading layer  21.51MB/21.51MB
Loaded image: goharbor/harbor-jobservice:v1.7.5
192bfe0da32e: Loading layer  8.958MB/8.958MB
7dc705554ad5: Loading layer  5.143MB/5.143MB
1344e4f0362f: Loading layer  15.13MB/15.13MB
5b1814241e00: Loading layer  26.47MB/26.47MB
875868e70220: Loading layer  22.02kB/22.02kB
b77cbc94dd40: Loading layer  3.072kB/3.072kB
b85ebfd783cc: Loading layer  46.74MB/46.74MB
Loaded image: goharbor/notary-server-photon:v0.6.1-v1.7.5
29b39ebec3e7: Loading layer  13.72MB/13.72MB
609e23b66d11: Loading layer  26.47MB/26.47MB
8ce88310d375: Loading layer  22.02kB/22.02kB
602eedb3335f: Loading layer  3.072kB/3.072kB
56dd592d20de: Loading layer  45.33MB/45.33MB
Loaded image: goharbor/notary-signer-photon:v0.6.1-v1.7.5
df2cb2cf198e: Loading layer    113MB/113MB
e3f619b84905: Loading layer  10.94MB/10.94MB
89efce1acffc: Loading layer  2.048kB/2.048kB
62d0ab2efbea: Loading layer  48.13kB/48.13kB
25f3904dc4c6: Loading layer  3.072kB/3.072kB
f2f432f47d0c: Loading layer  10.99MB/10.99MB
Loaded image: goharbor/clair-photon:v2.0.8-v1.7.5


[Step 2]: preparing environment ...
Generated and saved secret to file: /data/secretkey
Generated configuration file: ./common/config/nginx/nginx.conf
Generated configuration file: ./common/config/adminserver/env
Generated configuration file: ./common/config/core/env
Generated configuration file: ./common/config/registry/config.yml
Generated configuration file: ./common/config/db/env
Generated configuration file: ./common/config/jobservice/env
Generated configuration file: ./common/config/jobservice/config.yml
Generated configuration file: ./common/config/log/logrotate.conf
Generated configuration file: ./common/config/registryctl/env
Generated configuration file: ./common/config/core/app.conf
Generated certificate, key file: ./common/config/core/private_key.pem, cert file: ./common/config/registry/root.crt
The configuration files are ready, please use docker-compose to start the service.


[Step 3]: checking existing instance of Harbor ...


[Step 4]: starting Harbor ...
Creating network "harbor_harbor" with the default driver
Creating harbor-log ... done
Creating harbor-adminserver ... done
Creating registryctl        ... done
Creating harbor-db          ... done
Creating redis              ... done
Creating registry           ... done
Creating harbor-core        ... done
Creating harbor-portal      ... done
Creating harbor-jobservice  ... done
Creating nginx              ... done

✔ ----Harbor has been installed and started successfully.----

Now you should be able to visit the admin portal at http://node_6.12306ai.cn. 
For more details, please visit https://github.com/goharbor/harbor .

```

