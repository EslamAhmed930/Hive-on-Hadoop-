
# Apache Hive on Hadoop High Availability Cluster (Docker-Based)

This project integrates Apache Hive into a Hadoop 3.x High Availability (HA) cluster using Docker containers. The Hive metastore and HiveServer2 are deployed to interact with the Hadoop Distributed File System (HDFS) and YARN resource management system.

## System Components

- **HDFS (HA)**: 3 NameNodes, 3 JournalNodes, automatic failover via ZooKeeper
- **YARN (HA)**: 3 ResourceManagers with automatic failover
- **ZooKeeper Ensemble**: 3 nodes
- **Apache Hive**:
  - Hive Metastore
  - HiveServer2
  - Backed by MySQL for metastore persistence

## Hive Configuration

### Hive Services

- `hive-metastore`: Handles metadata persistence and query planning
- `hiveserver2`: Enables JDBC/ODBC access for querying Hive tables

### Metastore Database

- **Database**: PostegreSQL
- **Schema**: Initialized using `schematool`
- **Connectivity**: Configured in `hive-site.xml` via `javax.jdo.option.ConnectionURL`

## Environment Variables

- `HIVE_HOME=/opt/hive`
- `HADOOP_HOME=/opt/hadoop`
- `JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64`

## Docker Integration

### Required Containers

- `hive-metastore`
- `hiveserver2`
- `mysql` (for Hive metastore database)

### Build and Startup

```bash
docker-compose -f docker-compose.yml -f docker-compose-hive.yml build
docker-compose -f docker-compose.yml -f docker-compose-hive.yml up -d
````

### Initialization

1. Initialize MySQL container and create Hive metastore schema.
2. Run `schematool` from the Hive container to initialize the metastore DB.
3. Start `hive-metastore` and `hiveserver2` containers.

### Sample Initialization (Manual Steps)

```bash
docker exec -it hive-metastore bash
schematool -dbType mysql -initSchema
```

## Hive Client Access

* **JDBC URL**:

  ```
  jdbc:hive2://<hiveserver-host>:10000/default
  ```

* **Default Ports**:

  * HiveServer2: `10000`
  * Metastore Thrift: `9083`
  * MySQL: `3306`

## Notes

* Ensure NameNode and YARN services are fully initialized before starting Hive.
* Use persistent volumes for MySQL if long-term metadata is required.
* Include `hive-site.xml` in all Hive containers.

## License

Apache License 2.0

```

---

Would you like this to be exported as a `README_HIVE.md` file or added to the original README as a new section? Let me know if you'd like me to extract the `docker-compose-hive.yml` or config files from the ZIP for completeness.
```
