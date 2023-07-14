# Dockerfile for Atomic Deployment

This Dockerfile sets up an environment for an Atomic deployment on a Ubuntu 20.04 system. It installs and configures the required software packages including Node.js, PostgreSQL, Redis, and pm2. 

## Dockerfile Breakdown

1. **Base Image**: Starts from the official Ubuntu 20.04 base image.

2. **ARGs & ENVs**: Defines environment variables and arguments required for the Postgres configuration.

3. **Required tools installation**: Updates and upgrades the system packages and installs necessary tools like npm, curl, wget, htop, git, vim.

4. **Node.js Installation**: Installs Node.js v16 and cleans up the apt lists to keep the image small.

5. **Postgres Setup**: Prepares for the Postgres installation by importing the GPG key and setting up the repository.

6. **Postgres Installation**: Installs PostgreSQL 14 and sets up the necessary permissions on the data directory.

7. **Postgres Configuration**: This step involves the configuration of the PostgreSQL installation for performance tuning. 

    - Firstly, it fetches the installed PostgreSQL version number using `pg_config --version` and saves it to the `PG_VERSION` variable.

    - The `listen_addresses` configuration is set to allow connections from any network interface, rather than only localhost. It is achieved by replacing the line `#listen_addresses = 'localhost'` with `listen_addresses = '*'` in the `postgresql.conf` file. This will allow you to connect remotely through pgadmin.

    - A new line is appended to `pg_hba.conf`, a configuration file that determines which hosts are allowed to connect. Here, it allows the `waxuser <- derived from arguments` to connect from any host IP address with a password using md5 hashing.

    - Next, it replaces the default PostgreSQL data directory (`/var/lib/postgresql/$PG_VERSION/main`) with the one specified by `PGDATA` in the `postgresql.conf` file.

    - Following this, it calculates various memory parameters to optimize PostgreSQL performance. These parameters are dynamically set based on the available system memory (`MemTotal` in `/proc/meminfo`):
        - `shared_buffers`: This determines how much memory is dedicated to PostgreSQL to use for caching data. It's set to a percentage (20% by default) of the total system memory.
        - `work_mem`: This defines the amount of memory to be used by internal sort operations and hash tables before switching to disk. It's set to a calculated value based on the total system memory and the maximum allowed connections.
        - `maintenance_work_mem`: This configures the maximum amount of memory to be used for maintenance operations, such as VACUUM, CREATE INDEX, and others. It's set to 5% of the total system memory.
        - `effective_cache_size`: This setting gives the planner information to make better decisions on the use of indexed vs. sequential scan. It's typically set to 50% of the total memory.

8. **Database Initialization**: Initializes the PostgreSQL data directory as the postgres user.

9. **PostgreSQL Service Start and Initial Setup**: This command block starts the PostgreSQL service and sets up the initial database and user with their permissions.

    - `service postgresql start`: This command starts the PostgreSQL service. If PostgreSQL is not already running, this command will start it. 

    - `sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PW}';"`: PostgreSQL operations can be executed as the 'postgres' superuser. This command creates a new user (specified by the `POSTGRES_USER` argument) with the password provided by `POSTGRES_PW`.

    - `sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"`: This command creates a new database (specified by the `POSTGRES_DB` argument) and sets the owner to the user created in the previous step.

    - `sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};"`: This command grants all privileges on the newly created database to the new user. Essentially, the new user now has full access rights to the database.

    - `sudo -u postgres psql -d ${POSTGRES_DB} -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"`: Extensions are modules that add functionality to PostgreSQL. The `pg_trgm` extension provides functions and operators for determining the similarity of ASCII alphanumeric text based on trigram matching. This command adds the `pg_trgm` extension to the newly created database, if it does not already exist.

10. **Redis Installation**: Installs the Redis server.

11. **Redis Configuration**: Configures Redis for supervised operation under systemd. Also, performance parameters for Redis are set.

12. **Atomic API Setup**: Installs Yarn globally, clones the Atomic API from its Github repository, and installs its dependencies.

13. **Copy Configuration Files**: Copies your specific configuration files to the Atomic API config directory.

14. **PM2 Installation**: Installs pm2, a process manager for Node.js applications.

15. **Ports Exposure**: Exposes port 5432, the default PostgreSQL port.

16. **Health Checks**: Adds health checks for PostgreSQL and Redis, to ensure they're running properly.

17. **Start-Up Command**: Defines the start-up command for the container to start PostgreSQL, Redis, and the Atomic API using pm2.

## Build & Run

> It is important to note that the 3 files in the `files` directory be updated to your preferences. `The current ones` are based off a `test` deployment I performed, for which the output is available in the `test` folder. 
> * connections.config.json
> * readers.config.json
> * server.config.json

```bash
$ docker build -t my-atomic-deployment .
$ docker run -d --name atomic-deployment -p 5432:5432 my-atomic-deployment
