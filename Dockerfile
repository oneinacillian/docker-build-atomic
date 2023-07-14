FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG POSTGRES_USER=waxuser
ARG POSTGRES_DB=atomic
ARG POSTGRES_PW=waxuserpass
ENV PGDATA /data/postgresql/data
ENV SHARED_BUFFERS_PERCENTAGE 20
WORKDIR /apps
RUN apt-get update && apt-get -y upgrade && apt-get -y install npm curl wget htop git vim
RUN apt remove -y libnode-dev

# Install Node.js 16.x
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
apt-get -y install nodejs && \
rm -rf /var/lib/apt/lists/*

# Prepare for Postgres install
RUN apt-get update && apt-get -y install lsb-release sudo
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
apt-get update

# install of postgresql
RUN apt-get update && apt-get install -y postgresql-14
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"

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

# Pull Atomic API and install
RUN npm install --global yarn && \
    git clone https://github.com/pinknetworkx/eosio-contract-api.git && \
    cd /apps/eosio-contract-api && \
    yarn install

# Copy your required Atomic conf files (your own config)
COPY ./files/ /apps/eosio-contract-api/config

# Install pm2
RUN npm install pm2@latest -g

# Expose PostgreSQL default port
EXPOSE 5432

# Add health check
HEALTHCHECK --interval=30s --timeout=5s CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD redis-cli ping || exit 1

# Start PostgreSQL service on container startup
# Start redis-server
# Register and start the API Filler
CMD service postgresql start && service redis-server start && cd /apps/eosio-contract-api && pm2 start ecosystems.config.json --only eosio-contract-api-filler && pm2 logs

