> docker build -t atomic:atomic -f ./Dockerfile .

```
[+] Building 187.9s (24/24) FINISHED                                                                                                                                                                                                                                                                                                          
 => [internal] load .dockerignore                                                                                                                                                                                                                                                                                                        0.1s
 => => transferring context: 2B                                                                                                                                                                                                                                                                                                          0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                                                                                                     0.1s
 => => transferring dockerfile: 5.06kB                                                                                                                                                                                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/ubuntu:20.04                                                                                                                                                                                                                                                                          1.1s
 => [internal] load build context                                                                                                                                                                                                                                                                                                        0.1s
 => => transferring context: 1.90kB                                                                                                                                                                                                                                                                                                      0.0s
 => [ 1/19] FROM docker.io/library/ubuntu:20.04@sha256:c9820a44b950956a790c354700c1166a7ec648bc0d215fa438d3a339812f1d01                                                                                                                                                                                                                  0.1s
 => => resolve docker.io/library/ubuntu:20.04@sha256:c9820a44b950956a790c354700c1166a7ec648bc0d215fa438d3a339812f1d01                                                                                                                                                                                                                    0.0s
 => => sha256:8c38f4ea0b178a98e4f9f831b29b7966d6654414c1dc008591c6ec77de3bf2c9 424B / 424B                                                                                                                                                                                                                                               0.0s
 => => sha256:14be0685b7682b182af5b862c9638cb1cb4ca1a70bd5aa90deed96e9cca881e7 2.30kB / 2.30kB                                                                                                                                                                                                                                           0.0s
 => => sha256:c9820a44b950956a790c354700c1166a7ec648bc0d215fa438d3a339812f1d01 1.13kB / 1.13kB                                                                                                                                                                                                                                           0.0s
 => [ 2/19] WORKDIR /apps                                                                                                                                                                                                                                                                                                                0.0s
 => [ 3/19] RUN apt-get update && apt-get -y upgrade && apt-get -y install npm curl wget htop git vim                                                                                                                                                                                                                                  100.2s
 => [ 4/19] RUN apt remove -y libnode-dev                                                                                                                                                                                                                                                                                                2.0s
 => [ 5/19] RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get -y install nodejs && rm -rf /var/lib/apt/lists/*                                                                                                                                                                                                   11.6s 
 => [ 6/19] RUN apt-get update && apt-get -y install lsb-release sudo                                                                                                                                                                                                                                                                    4.7s 
 => [ 7/19] RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && apt-get update                                          2.5s 
 => [ 8/19] RUN apt-get update && apt-get install -y postgresql-14                                                                                                                                                                                                                                                                      18.4s 
 => [ 9/19] RUN mkdir -p "/data/postgresql/data" && chown -R postgres:postgres "/data/postgresql/data" && chmod 777 "/data/postgresql/data"                                                                                                                                                                                              0.4s 
 => [10/19] RUN PG_VERSION=$(pg_config --version | awk '{split($NF, a, "."); print a[1]}') &&     echo "PostgreSQL version: $PG_VERSION" &&     sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$PG_VERSION/main/postgresql.conf &&     echo "host all waxuser 0.0.0.0/0 md5" >> /etc/postgresql/$PG  0.5s 
 => [11/19] RUN PG_VERSION=$(pg_config --version | awk '{split($NF, a, "."); print a[1]}') &&     echo "PostgreSQL version: $PG_VERSION" &&     /usr/lib/postgresql/$PG_VERSION/bin/initdb -D "/data/postgresql/data"                                                                                                                    5.3s 
 => [12/19] RUN service postgresql start &&     sudo -u postgres psql -c "CREATE USER waxuser WITH PASSWORD 'waxuserpass';" &&     sudo -u postgres psql -c "CREATE DATABASE atomic OWNER waxuser;" &&     sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE atomic TO waxuser;" &&     sudo -u postgres psql -d atomic -c "CR  4.8s 
 => [13/19] RUN apt-get update &&     apt-get -y upgrade &&     apt-get -y install redis-server &&     rm -rf /var/lib/apt/lists/*                                                                                                                                                                                                       6.3s 
 => [14/19] RUN sed -i 's/^supervised auto$/supervised systemd/g' /etc/redis/redis.conf                                                                                                                                                                                                                                                  0.4s 
 => [15/19] RUN echo -e "\n# Set supervised systemd if not already set\nif [ ! -z "$(grep -E '^supervised' /etc/redis/redis.conf | grep -E -v '^(#|;|//)')" ]; then\n  echo 'supervised is already set in /etc/redis/redis.conf';\nelse\n  echo 'supervised systemd' >> /etc/redis/redis.conf;\nfi" >> /usr/local/bin/start-redis.sh &&  0.3s 
 => [16/19] RUN total_memory=$(free -m | awk '/^Mem:/{print $2}')     && max_memory=$(expr $total_memory / 4)M     && sed -i "s/^# maxmemory .*/maxmemory $max_memory/" /etc/redis/redis.conf                                                                                                                                            0.5s 
 => [17/19] RUN npm install --global yarn &&     git clone https://github.com/pinknetworkx/eosio-contract-api.git &&     cd /apps/eosio-contract-api &&     yarn install                                                                                                                                                                15.6s 
 => [18/19] COPY ./files/ /apps/eosio-contract-api/config                                                                                                                                                                                                                                                                                0.1s 
 => [19/19] RUN npm install pm2@latest -g                                                                                                                                                                                                                                                                                                8.1s 
 => exporting to image                                                                                                                                                                                                                                                                                                                   4.6s 
 => => exporting layers                                                                                                                                                                                                                                                                                                                  4.6s 
 => => writing image sha256:1d45c2075fa02202b22fec69f0a7e7a9ce8ff87a8a82e884d5d7ca23a4cd577f                                                                                                                                                                                                                                             0.0s 
 => => naming to docker.io/library/atomic:atomic
```

> docker run -d --name atomictest --publish 5433:5432 --mount source=atomictest,target=/data atomic:atomic

```
70424caa31eac0aa6c8d580d43d0a0fb83649c913c54e3959ea81930146994ef
```

> docker ps -a

```
CONTAINER ID   IMAGE                             COMMAND                  CREATED          STATUS                    PORTS                                                                                                                                                                            NAMES
70424caa31ea   atomic:atomic                     "/bin/sh -c 'service…"   58 seconds ago   Up 58 seconds (healthy)   0.0.0.0:5433->5432/tcp, :::5433->5432/tcp                                                                                                                                        atomictest
```

> docker logs 70424caa31ea

```
 * Starting PostgreSQL 14 database server
   ...done.
Starting redis-server: redis-server.

                        -------------

__/\\\\\\\\\\\\\____/\\\\____________/\\\\____/\\\\\\\\\_____
 _\/\\\/////////\\\_\/\\\\\\________/\\\\\\__/\\\///////\\\___
  _\/\\\_______\/\\\_\/\\\//\\\____/\\\//\\\_\///______\//\\\__
   _\/\\\\\\\\\\\\\/__\/\\\\///\\\/\\\/_\/\\\___________/\\\/___
    _\/\\\/////////____\/\\\__\///\\\/___\/\\\________/\\\//_____
     _\/\\\_____________\/\\\____\///_____\/\\\_____/\\\//________
      _\/\\\_____________\/\\\_____________\/\\\___/\\\/___________
       _\/\\\_____________\/\\\_____________\/\\\__/\\\\\\\\\\\\\\\_
        _\///______________\///______________\///__\///////////////__


                          Runtime Edition

        PM2 is a Production Process Manager for Node.js applications
                     with a built-in Load Balancer.

                Start and Daemonize any application:
                $ pm2 start app.js

                Load Balance 4 instances of api.js:
                $ pm2 start api.js -i 4

                Monitor in production:
                $ pm2 monitor

                Make pm2 auto-boot at server restart:
                $ pm2 startup

                To go further checkout:
                http://pm2.io/


                        -------------

[PM2] Spawning PM2 daemon with pm2_home=/root/.pm2
[PM2] PM2 Successfully daemonized
[PM2][WARN] Applications eosio-contract-api-filler not running, starting...
[PM2] App [eosio-contract-api-filler] launched (1 instances)
┌────┬──────────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name                         │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├────┼──────────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0  │ eosio-contract-api-filler    │ default     │ 1.3.20  │ fork    │ 76       │ 0s     │ 0    │ online    │ 0%       │ 31.9mb   │ root     │ disabled │
└────┴──────────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
[TAILING] Tailing last 15 lines for [all] processes (change the value with --lines option)
/root/.pm2/pm2.log last 15 lines:
PM2        | 2023-07-14T14:03:38: PM2 log: PM2 version          : 5.3.0
PM2        | 2023-07-14T14:03:38: PM2 log: Node.js version      : 16.20.1
PM2        | 2023-07-14T14:03:38: PM2 log: Current arch         : x64
PM2        | 2023-07-14T14:03:38: PM2 log: PM2 home             : /root/.pm2
PM2        | 2023-07-14T14:03:38: PM2 log: PM2 PID file         : /root/.pm2/pm2.pid
PM2        | 2023-07-14T14:03:38: PM2 log: RPC socket file      : /root/.pm2/rpc.sock
PM2        | 2023-07-14T14:03:38: PM2 log: BUS socket file      : /root/.pm2/pub.sock
PM2        | 2023-07-14T14:03:38: PM2 log: Application log path : /root/.pm2/logs
PM2        | 2023-07-14T14:03:38: PM2 log: Worker Interval      : 30000
PM2        | 2023-07-14T14:03:38: PM2 log: Process dump file    : /root/.pm2/dump.pm2
PM2        | 2023-07-14T14:03:38: PM2 log: Concurrent actions   : 2
PM2        | 2023-07-14T14:03:38: PM2 log: SIGTERM timeout      : 1600
PM2        | 2023-07-14T14:03:38: PM2 log: ===============================================================================
PM2        | 2023-07-14T14:03:38: PM2 log: App [eosio-contract-api-filler:0] starting in -fork mode-
PM2        | 2023-07-14T14:03:38: PM2 log: App [eosio-contract-api-filler:0] online

/root/.pm2/logs/eosio-contract-api-filler-out-0.log last 15 lines:
/root/.pm2/logs/eosio-contract-api-filler-error-0.log last 15 lines:
0|eosio-contract-api-filler  | 2023-07-14T14:03:38.630Z [PID:76] [info] : Starting workers... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:38.693Z [PID:76] [info] : Could not find base tables. Create them now... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:38.804Z [PID:76] [info] : Base tables successfully created 
0|eosio-contract-api-filler  | 2023-07-14T14:03:38.804Z [PID:76] [info] : Checking for available upgrades... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:38.808Z [PID:76] [info] : Could not find AtomicAssets tables. Create them now... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.195Z [PID:76] [info] : AtomicAssets tables successfully created 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.195Z [PID:76] [info] : Tables for handler atomicassets created. 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.198Z [PID:76] [info] : Found 26 available upgrades. Starting to upgradeDB... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.198Z [PID:76] [info] : Upgrade to 1.1.0 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.200Z [PID:76] [info] : Upgraded atomicassets to 1.1.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.201Z [PID:76] [info] : Successfully upgraded to 1.1.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.214Z [PID:76] [info] : Upgrade to 1.2.0 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.215Z [PID:76] [info] : Upgraded atomicassets to 1.2.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.215Z [PID:76] [info] : Successfully upgraded to 1.2.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.217Z [PID:76] [info] : Upgrade to 1.2.1 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.218Z [PID:76] [info] : Upgraded atomicassets to 1.2.1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.218Z [PID:76] [info] : Successfully upgraded to 1.2.1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.220Z [PID:76] [info] : Upgrade to 1.2.2 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.226Z [PID:76] [info] : Upgraded atomicassets to 1.2.2 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.226Z [PID:76] [info] : Successfully upgraded to 1.2.2 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.228Z [PID:76] [info] : Upgrade to 1.2.3 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.249Z [PID:76] [info] : Upgraded atomicassets to 1.2.3 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.249Z [PID:76] [info] : Successfully upgraded to 1.2.3 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.258Z [PID:76] [info] : Upgrade to 1.2.4 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.259Z [PID:76] [info] : Upgraded atomicassets to 1.2.4 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.259Z [PID:76] [info] : Successfully upgraded to 1.2.4 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.260Z [PID:76] [info] : Upgrade to 1.2.5 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.261Z [PID:76] [info] : Upgraded atomicassets to 1.2.5 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.261Z [PID:76] [info] : Successfully upgraded to 1.2.5 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.263Z [PID:76] [info] : Upgrade to 1.2.14 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.263Z [PID:76] [info] : Upgraded atomicassets to 1.2.14 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.264Z [PID:76] [info] : Successfully upgraded to 1.2.14 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.265Z [PID:76] [info] : Upgrade to 1.3.0 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.266Z [PID:76] [info] : Upgraded atomicassets to 1.3.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.266Z [PID:76] [info] : Successfully upgraded to 1.3.0 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.267Z [PID:76] [info] : Upgrade to 1.3.1 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.268Z [PID:76] [info] : Upgraded atomicassets to 1.3.1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.268Z [PID:76] [info] : Successfully upgraded to 1.3.1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.269Z [PID:76] [info] : Upgrade to 1.3.3 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.269Z [PID:76] [info] : Upgraded atomicassets to 1.3.3 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.270Z [PID:76] [info] : Successfully upgraded to 1.3.3 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.271Z [PID:76] [info] : Upgrade to 1.3.4 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.271Z [PID:76] [info] : Upgraded atomicassets to 1.3.4 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.271Z [PID:76] [info] : Successfully upgraded to 1.3.4 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.273Z [PID:76] [info] : Upgrade to 1.3.5 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.273Z [PID:76] [info] : Upgraded atomicassets to 1.3.5 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.273Z [PID:76] [info] : Successfully upgraded to 1.3.5 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.275Z [PID:76] [info] : Upgrade to 1.3.7 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.277Z [PID:76] [info] : Upgraded atomicassets to 1.3.7 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.277Z [PID:76] [info] : Successfully upgraded to 1.3.7 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.279Z [PID:76] [info] : Upgrade to 1.3.8 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.280Z [PID:76] [info] : Upgraded atomicassets to 1.3.8 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.280Z [PID:76] [info] : Successfully upgraded to 1.3.8 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.282Z [PID:76] [info] : Upgrade to 1.3.9 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.285Z [PID:76] [info] : Upgraded atomicassets to 1.3.9 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.285Z [PID:76] [info] : Successfully upgraded to 1.3.9 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.295Z [PID:76] [info] : Upgrade to 1.3.11 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.296Z [PID:76] [info] : Upgraded atomicassets to 1.3.11 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.296Z [PID:76] [info] : Successfully upgraded to 1.3.11 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.298Z [PID:76] [info] : Upgrade to 1.3.12 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.298Z [PID:76] [info] : Upgraded atomicassets to 1.3.12 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.298Z [PID:76] [info] : Successfully upgraded to 1.3.12 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.300Z [PID:76] [info] : Upgrade to 1.3.13 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.300Z [PID:76] [info] : Upgraded atomicassets to 1.3.13 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.300Z [PID:76] [info] : Successfully upgraded to 1.3.13 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.302Z [PID:76] [info] : Upgrade to 1.3.14 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.302Z [PID:76] [info] : Upgraded atomicassets to 1.3.14 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.302Z [PID:76] [info] : Successfully upgraded to 1.3.14 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.304Z [PID:76] [info] : Upgrade to 1.3.15 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.334Z [PID:76] [info] : Upgraded atomicassets to 1.3.15 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.334Z [PID:76] [info] : Successfully upgraded to 1.3.15 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.350Z [PID:76] [info] : Upgrade to 1.3.16 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.352Z [PID:76] [info] : Upgraded atomicassets to 1.3.16 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.352Z [PID:76] [info] : Successfully upgraded to 1.3.16 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.354Z [PID:76] [info] : Upgrade to 1.3.17 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.383Z [PID:76] [info] : Upgraded atomicassets to 1.3.17 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.383Z [PID:76] [info] : Successfully upgraded to 1.3.17 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.395Z [PID:76] [info] : Upgrade to 1.3.18 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.448Z [PID:76] [info] : Upgraded atomicassets to 1.3.18 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.448Z [PID:76] [info] : Successfully upgraded to 1.3.18 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.454Z [PID:76] [info] : Upgrade to 1.3.19 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.465Z [PID:76] [info] : Upgraded atomicassets to 1.3.19 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.465Z [PID:76] [info] : Successfully upgraded to 1.3.19 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.471Z [PID:76] [info] : Upgrade to 1.3.20 ... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.479Z [PID:76] [info] : Upgraded atomicassets to 1.3.20 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.479Z [PID:76] [info] : Successfully upgraded to 1.3.20 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.505Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_asset_counts 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.507Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_transfers_assets 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.511Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_schemas 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.516Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_assets 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.518Z [PID:76] [info] : Updated autovaccum settings for public.contract_codes 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.520Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_offers_assets 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.522Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_balances 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.527Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_collections 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.529Z [PID:76] [info] : Updated autovaccum settings for public.list_items 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.536Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_tokens 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.538Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_offers 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.544Z [PID:76] [info] : Updated autovaccum settings for public.dbinfo 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.546Z [PID:76] [info] : Updated autovaccum settings for public.reversible_queries 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.549Z [PID:76] [info] : Updated autovaccum settings for public.reversible_blocks 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.551Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_assets_backed_tokens 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.553Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_templates 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.556Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_mints 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.558Z [PID:76] [info] : Updated autovaccum settings for public.contract_abis 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.560Z [PID:76] [info] : Updated autovaccum settings for public.lists 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.562Z [PID:76] [info] : Updated autovaccum settings for public.contract_traces 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.564Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_transfers 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.567Z [PID:76] [info] : Updated autovaccum settings for public.atomicassets_config 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.569Z [PID:76] [info] : Updated autovaccum settings for public.contract_readers 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.572Z [PID:76] [info] : Finished setting autovacuum settings 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.972Z [PID:108] [info] : Worker 108 started 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.979Z [PID:108] [info] : 1 contract handlers registered 
0|eosio-contract-api-filler  | 2023-07-14T14:03:39.979Z [PID:108] [info] : Contract handler  registered {"atomicassets_account":"atomicassets","store_transfers":true,"store_logs":true}
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.015Z [PID:108] [info] : Init handler atomicassets for reader atomic-1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.067Z [PID:108] [info] : Check for missing mint numbers of atomicassets. Last irreversible block #226908736 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.086Z [PID:108] [info] : First run of reader. Initializing tables... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.088Z [PID:108] [info] : Starting reader: atomic-1 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.090Z [PID:108] [info] : Reader atomic-1 starting on block #35795440 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.096Z [PID:108] [info] : Connecting to ship endpoint ws://172.168.40.50:29876 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.096Z [PID:108] [info] : Ship connect options {"start_block_num":35795440,"end_block_num":4294967295,"max_messages_in_flight":50,"have_positions":"removed","irreversible_only":false,"fetch_block":true,"fetch_traces":true,"fetch_deltas":true} 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.102Z [PID:108] [info] : Receiving ABI from ship... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.228Z [PID:108] [info] : Launching deserialization worker... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.229Z [PID:108] [info] : Launching deserialization worker... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.230Z [PID:108] [info] : Launching deserialization worker... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.233Z [PID:108] [info] : Launching deserialization worker... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.271Z [PID:108] [warn] : Could not find ABI for eosio in cache, so requesting it... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.309Z [PID:108] [info] : Code updated for contract atomicassets at block #35795455 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.314Z [PID:108] [warn] : Could not find ABI for atomicassets in cache, so requesting it... 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.315Z [PID:108] [info] : ABI updated for contract atomicassets at block #35795455 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.323Z [PID:108] [info] : Received contract row from outdated ABI. Deserializing in sync mode. {"contract":"atomicassets","table":"config","scope":"atomicassets"}
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.479Z [PID:108] [info] : ABI updated for contract atomicmarket at block #35795760 
0|eosio-contract-api-filler  | 2023-07-14T14:03:40.492Z [PID:108] [info] : Code updated for contract atomicmarket at block #35795765 
0|eosio-contract-api-filler  | 2023-07-14T14:03:41.014Z [PID:108] [info] : Code updated for contract atomictoolsx at block #35796994 
0|eosio-contract-api-filler  | 2023-07-14T14:03:41.016Z [PID:108] [info] : ABI updated for contract atomictoolsx at block #35796994 
0|eosio-contract-api-filler  | 2023-07-14T14:03:50.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35807009 / 226909089 (0.00%) Speed: 1350.0 B/s 3408 W/s [DS:0|SH:29|JQ:1] (Syncs in 39 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:03:55.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35821829 / 226909099 (0.01%) Speed: 2964.0 B/s 0 W/s [DS:19|SH:32|JQ:0] (Syncs in 24 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:03:58.679Z [PID:108] [info] : Code updated for contract waxdecideapi at block #35832368 
0|eosio-contract-api-filler  | 2023-07-14T14:03:58.684Z [PID:108] [info] : ABI updated for contract waxdecideapi at block #35832368 
0|eosio-contract-api-filler  | 2023-07-14T14:04:00.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35836559 / 226909109 (0.02%) Speed: 2946.0 B/s 0 W/s [DS:0|SH:29|JQ:0] (Syncs in 21 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:05.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35851531 / 226909119 (0.03%) Speed: 2994.4 B/s 0 W/s [DS:0|SH:27|JQ:0] (Syncs in 20 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:10.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35866362 / 226909129 (0.03%) Speed: 2966.2 B/s 0 W/s [DS:0|SH:16|JQ:0] (Syncs in 20 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:15.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35881404 / 226909139 (0.04%) Speed: 3008.4 B/s 0 W/s [DS:0|SH:27|JQ:0] (Syncs in 19 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:20.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35896328 / 226909149 (0.05%) Speed: 2984.8 B/s 5 W/s [DS:0|SH:20|JQ:0] (Syncs in 19 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:25.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35911199 / 226909159 (0.06%) Speed: 2974.2 B/s 0 W/s [DS:0|SH:29|JQ:0] (Syncs in 19 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:30.097Z [PID:108] [info] : Reader atomic-1 - Progress: 35926169 / 226909169 (0.07%) Speed: 2994.0 B/s 0 W/s [DS:0|SH:9|JQ:0] (Syncs in 18 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:31.301Z [PID:108] [info] : Code updated for contract weosdttoken2 at block #35929752 
0|eosio-contract-api-filler  | 2023-07-14T14:04:31.303Z [PID:108] [info] : ABI updated for contract weosdttoken2 at block #35929752 
0|eosio-contract-api-filler  | 2023-07-14T14:04:35.098Z [PID:108] [info] : Reader atomic-1 - Progress: 35940839 / 226909179 (0.07%) Speed: 2934.0 B/s 0 W/s [DS:0|SH:29|JQ:0] (Syncs in 18 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:40.098Z [PID:108] [info] : Reader atomic-1 - Progress: 35955629 / 226909189 (0.08%) Speed: 2958.0 B/s 0 W/s [DS:0|SH:29|JQ:0] (Syncs in 18 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:45.098Z [PID:108] [info] : Reader atomic-1 - Progress: 35970478 / 226909199 (0.09%) Speed: 2969.8 B/s 0 W/s [DS:0|SH:30|JQ:0] (Syncs in 18 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:50.098Z [PID:108] [info] : Reader atomic-1 - Progress: 35985337 / 226909209 (0.10%) Speed: 2971.8 B/s 0 W/s [DS:0|SH:20|JQ:0] (Syncs in 18 hours) 
0|eosio-contract-api-filler  | 2023-07-14T14:04:55.098Z [PID:108] [info] : Reader atomic-1 - Progress: 36000481 / 226909219 (0.10%) Speed: 3028.8 B/s 0 W/s [DS:0|SH:27|JQ:0] (Syncs in 18 hours)
```