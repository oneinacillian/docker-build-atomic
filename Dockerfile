FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG POSTGRES_USER=waxuser
ARG POSTGRES_DB=atomic
ARG POSTGRES_PW=waxuserpass
ARG START_FILLER=true
ARG START_API=true
ENV PGDATA /data/postgresql/data
ENV SHARED_BUFFERS_PERCENTAGE 20
WORKDIR /apps
RUN apt-get update && apt-get -y upgrade && apt-get -y install npm curl wget htop git vim
RUN apt remove -y libnode-dev

# Install Node.js 16.x
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
apt-get -y install nodejs && \
rm -rf /var/lib/apt/lists/*

# Add Dump file for restore
# ARG RESTORE_DB=false
# COPY dump.tar.gz .

# COPY project_1 .
# COPY postgresql.sql .
# RUN npm install ./fastify
#RUN curl -LO $(curl -s https://backup.wecan.dev/wax/atomic/testnet/ | grep -oP 'href="\K[^"]+' | grep .dump | sort -V | tail -n 1 | sed 's|^|https://backup.wecan.dev/wax/atomic/testnet/|')
#ENV RESTORE_FILE=$(curl -s https://backup.wecan.dev/wax/atomic/testnet/ | grep -oP 'href="\K[^"]+' | grep .dump | sort -V | tail -n 1 | sed 's|^|/apps/|')

RUN apt-get update && apt-get -y install lsb-release sudo
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
apt-get update

# install of postgresql
RUN apt-get update && apt-get install -y postgresql-14
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
# RUN PG_VERSION=$(pg_config --version | awk '{split($NF, a, "."); print a[1]}') && \
#     echo "PostgreSQL version: $PG_VERSION" && \
#     sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
#     echo "host all waxuser 0.0.0.0/0 md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf && \
#     sed -i "s|/var/lib/postgresql/$PG_VERSION/main|$PGDATA|g" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
#     sed -i "s|/var/lib/postgresql/$PG_VERSION/main|$PGDATA|g" /etc/postgresql/$PG_VERSION/main/start.conf && \
#     total_memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}') && \
#     shared_buffers_kb=$((total_memory_kb * SHARED_BUFFERS_PERCENTAGE / 100)) && \
#     sed -i "s/#shared_buffers = 128MB/shared_buffers = ${shared_buffers_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
#     max_connections=$(sed -n 's/^[^#]*max_connections = \(\S*\).*$/\1/p' /etc/postgresql/$PG_VERSION/main/postgresql.conf) && \
#     work_mem_kb=$((total_memory_kb / max_connections * 256 / 1000)) && \
#     sed -i "s/#work_mem = 4MB/work_mem = ${work_mem_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
#     maintenance_work_mem_kb=$((total_memory_kb * 5 / 100)) && \
#     sed -i "s/#maintenance_work_mem = 64MB/maintenance_work_mem = ${maintenance_work_mem_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
#     effective_cache_size_kb=$((total_memory_kb * 50 / 100)) && \
#     sed -i "s/#effective_cache_size = 128MB/effective_cache_size = ${effective_cache_size_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf 

# Configure PostgreSQL settings
RUN PG_VERSION=$(pg_config --version | awk '{split($NF, a, "."); print a[1]}') && \
    echo "PostgreSQL version: $PG_VERSION" && \
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    echo "host all waxuser 0.0.0.0/0 md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf && \
    sed -i "s|/var/lib/postgresql/$PG_VERSION/main|$PGDATA|g" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    total_memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}') && \
    shared_buffers_kb=$((total_memory_kb * SHARED_BUFFERS_PERCENTAGE / 100)) && \
    sed -i "s/^#*shared_buffers = .*/shared_buffers = ${shared_buffers_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    max_connections=$(sed -n 's/^#*max_connections = \(\S*\).*$/\1/p' /etc/postgresql/$PG_VERSION/main/postgresql.conf) && \
    work_mem_kb=$((total_memory_kb / max_connections * 256 / 1000)) && \
    sed -i "s/^#*work_mem = .*/work_mem = ${work_mem_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    maintenance_work_mem_kb=$((total_memory_kb * 5 / 100)) && \
    sed -i "s/^#*maintenance_work_mem = .*/maintenance_work_mem = ${maintenance_work_mem_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    effective_cache_size_kb=$((total_memory_kb * 50 / 100)) && \
    sed -i "s/^#*effective_cache_size = .*/effective_cache_size = ${effective_cache_size_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf

USER postgres

# Initialize the PostgreSQL data directory
RUN PG_VERSION=$(pg_config --version | awk '{split($NF, a, "."); print a[1]}') && \
    echo "PostgreSQL version: $PG_VERSION" && \
    /usr/lib/postgresql/$PG_VERSION/bin/initdb -D "$PGDATA"

USER root

# Start PostgreSQL service
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PW}';" && \
    sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};" && \
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};" && \
    sudo -u postgres psql -d ${POSTGRES_DB} -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    # sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PW}';" && \
    # sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};" && \
    # sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};" && \
    # sudo -u postgres psql -d atomic -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"    
    #sudo -u postgres psql -c "CREATE USER wecan_user;"
    # cd /data/atomictest && \
    # sudo -u postgres pg_restore --verbose -Fc -d atomic atomic.testnet.1682167921.dump.1





# Install redis
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install redis-server && \
    rm -rf /var/lib/apt/lists/*

# Replace supervised auto with supervised systemd
RUN sed -i 's/^supervised auto$/supervised systemd/g' /etc/redis/redis.conf

# Add supervised systemd if it does not exist
RUN echo -e "\n# Set supervised systemd if not already set\nif [ ! -z \"\$(grep -E '^supervised' /etc/redis/redis.conf | grep -E -v '^(#|;|//)')\" ]; then\n  echo 'supervised is already set in /etc/redis/redis.conf';\nelse\n  echo 'supervised systemd' >> /etc/redis/redis.conf;\nfi" >> /usr/local/bin/start-redis.sh && \
    chmod +x /usr/local/bin/start-redis.sh

# Configure Redis performance parameters
RUN total_memory=$(free -m | awk '/^Mem:/{print $2}') \
    && max_memory=$(expr $total_memory / 4)M \
    && sed -i "s/^# maxmemory .*/maxmemory $max_memory/" /etc/redis/redis.conf

    
# Configure shared_buffers
# RUN total_memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}') && \
#     shared_buffers_kb=$((total_memory_kb * SHARED_BUFFERS_PERCENTAGE / 100)) && \
#     sed -i "s/#shared_buffers = 128MB/shared_buffers = ${shared_buffers_kb}kB/" /etc/postgresql/$PG_VERSION/main/postgresql.conf

RUN npm install --global yarn && \
    git clone https://github.com/pinknetworkx/eosio-contract-api.git && \
    cd /apps/eosio-contract-api && \
    yarn install

COPY ./files/ /apps/eosio-contract-api/config

#RUN service postgresql
#sudo -u postgres psql -f ./postgresql.sql > output.log 2>&1
# sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PW}';" && \
# sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};" && \
# sudo -u postgres psql -c "CREATE SCHEMA ${POSTGRES_DB};" && \
# echo "CREATE TABLE ${POSTGRES_DB}.producer ( id SERIAL PRIMARY KEY, owner_name VARCHAR(12) UNIQUE);" | sudo -u postgres psql -d $POSTGRES_DB && \
# echo "CREATE TABLE ${POSTGRES_DB}.missingblocks ( id SERIAL PRIMARY KEY, producer_id INTEGER NOT NULL, block_number INTEGER, date TIMESTAMP WITH TIME ZONE, round_missed BOOLEAN, blocks_missed BOOLEAN, FOREIGN KEY (producer_id) REFERENCES ${POSTGRES_DB}.producer(id));" | sudo -u postgres psql -d $POSTGRES_DB && \
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};" && \
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON SCHEMA ${POSTGRES_DB} TO ${POSTGRES_USER};" && \
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${POSTGRES_DB} TO ${POSTGRES_USER};" && \
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${POSTGRES_DB} TO ${POSTGRES_USER};"

#RUN npm install pg

# Install pm2
RUN npm install pm2@latest -g

# Expose PostgreSQL default port
EXPOSE 5432

# Add health check
HEALTHCHECK --interval=30s --timeout=5s CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD redis-cli ping || exit 1

# Start PostgreSQL service on container startup
#CMD service postgresql start && pm2 start streamingBlocks-oiac.mjs --interpreter="node" --name="streamingBlocks" && npm start --prefix ./fastify && pm2 healthcheck && tail -f /dev/null

CMD service postgresql start && service redis-server start && cd /apps/eosio-contract-api && pm2 start ecosystems.config.json --only eosio-contract-api-filler && pm2 logs

