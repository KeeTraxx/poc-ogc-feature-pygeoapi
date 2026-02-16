# pygeoapi Feature Providers

pygeoapi ships with **16 built-in providers** for OGC API - Features (`type: feature`).

## Provider Capability Matrix

| Provider | Property Filters | BBox | DateTime | SortBy | CQL | Transactions |
|---|---|---|---|---|---|---|
| CSV | Yes | Yes | No | No | No | No |
| Elasticsearch | Yes | Yes | Yes | Yes | Yes | Yes |
| ERDDAPTabledap | No | Yes | Yes | No | No | No |
| ESRI | Yes | Yes | Yes | Yes | No | No |
| GeoJSON | Yes | Yes | No | No | No | No |
| MongoDB | Yes | Yes | Yes | Yes | No | No |
| MySQL | Yes | Yes | Yes | Yes | Yes | Yes |
| OGR | Yes | Yes | No | No | No | No |
| OpenSearch | Yes | Yes | Yes | Yes | Yes | Yes |
| OracleDB | Yes | Yes | No | Yes | No | No |
| Parquet | Yes | Yes | Yes | No | No | No |
| PostgreSQL | Yes | Yes | Yes | Yes | Yes | Yes |
| SQLiteGPKG | Yes | Yes | No | No | No | No |
| SensorThings | Yes | Yes | Yes | Yes | No | Yes |
| Socrata | Yes | Yes | Yes | Yes | No | No |
| TinyDB | Yes | Yes | Yes | Yes | No | Yes |

## File-Based Providers

### GeoJSON

The simplest provider. Reads a GeoJSON FeatureCollection from disk.

```yaml
providers:
  - type: feature
    name: GeoJSON
    data: /path/to/file.geojson
    id_field: id
    title_field: name
```

Best for small, static datasets and quick prototyping.

### CSV

Reads CSV files with x/y coordinate columns (point data only).

```yaml
providers:
  - type: feature
    name: CSV
    data: /path/to/file.csv
    id_field: id
    geometry:
      x_field: longitude
      y_field: latitude
```

### Parquet (GeoParquet)

Reads Apache Parquet / GeoParquet files, including from S3.

```yaml
providers:
  - type: feature
    name: Parquet
    data:
      source: /path/to/data.parquet  # or s3://bucket/path
    id_field: id
    time_field: datetime
    x_field: longitude
    y_field: latitude
```

Requires `pyarrow`. For GeoParquet with native geometry, also requires `geopandas`.

### TinyDB

Lightweight file-based JSON document database. Supports transactions (CRUD).

```yaml
providers:
  - type: feature
    name: TinyDB
    editable: true
    data: /path/to/tinydb.json
    id_field: id
    time_field: datetime
```

Requires `tinydb`. Good for editable collections without a full database.

### SQLiteGPKG

Reads SQLite databases and OGC GeoPackage (.gpkg) files.

```yaml
providers:
  - type: feature
    name: SQLiteGPKG
    data: /path/to/data.gpkg
    id_field: id
    table: my_table
```

Requires SpatiaLite installed on the system.

## Database Providers

### PostgreSQL (PostGIS)

The most full-featured database provider. Supports CQL, transactions, CRS reprojection.

```yaml
providers:
  - type: feature
    name: PostgreSQL
    data:
      host: localhost
      port: 5432
      dbname: mydb
      user: myuser
      password: mypass
      search_path: [myschema, public]
    id_field: id
    table: my_table
    geom_field: geom
```

Requires `sqlalchemy`, `geoalchemy2`, `psycopg2-binary`, and PostGIS.

### MySQL

MySQL / MariaDB with spatial columns. Supports CQL and transactions.

```yaml
providers:
  - type: feature
    name: MySQL
    data:
      host: localhost
      port: 3306
      dbname: mydb
      user: myuser
      password: mypass
    id_field: id
    table: my_table
    geom_field: geom
```

Requires `sqlalchemy`, `geoalchemy2`, `pymysql`.

### OracleDB

Oracle Spatial databases. Supports wallet-based external authentication.

```yaml
providers:
  - type: feature
    name: OracleDB
    data:
      host: localhost
      port: 1521
      service_name: ORCLPDB1
      user: myuser
      password: mypass
    id_field: ID
    table: MY_TABLE
    geom_field: GEOMETRY
```

Requires `oracledb`. Supports connection via host+SID, host+SERVICE_NAME, or TNS_NAME.

### MongoDB

MongoDB 5+ document collections containing GeoJSON features.

```yaml
providers:
  - type: feature
    name: MongoDB
    data: mongodb://localhost:27017/mydb
    collection: my_collection
```

Requires `pymongo`. Property filters support exact match only.

## Search Engine Providers

### Elasticsearch

Elasticsearch 8+ with spatial indexing. Full CQL and transaction support.

```yaml
providers:
  - type: feature
    name: Elasticsearch
    editable: true
    data: http://localhost:9200/my_index
    id_field: id
    time_field: datetimefield
```

Supports basic auth via URL: `http://user:pass@host:9200/index`. Requires `elasticsearch`, `elasticsearch-dsl`.

### OpenSearch

OpenSearch (Elasticsearch fork). Nearly identical configuration.

```yaml
providers:
  - type: feature
    name: OpenSearch
    editable: true
    data: http://localhost:9200/my_index
    id_field: id
    time_field: datetimefield
```

Requires `opensearch-py`.

## Remote Service Providers

### ESRI

Connects to ArcGIS Feature Services and Map Services.

```yaml
providers:
  - type: feature
    name: ESRI
    data: https://services.arcgis.com/.../FeatureServer/0
    id_field: OBJECTID
    time_field: date_field
    # optional auth for private services:
    username: user
    password: pass
```

Works with both public and authenticated services.

### OGR

Wraps the entire GDAL/OGR library. Supports Shapefiles, WFS, KML, GPX, DXF, and many more.

```yaml
providers:
  - type: feature
    name: OGR
    data:
      source_type: "ESRI Shapefile"
      source: /path/to/data.shp
      source_capabilities:
        paging: true
    id_field: id
    layer: layer_name
```

The most versatile provider. Requires GDAL 3+ and the `gdal` Python package.

### SensorThings

Connects to OGC SensorThings API endpoints for IoT sensor data.

```yaml
providers:
  - type: feature
    name: SensorThings
    data: https://example.com/sta/v1.1
    entity: Things  # Things, Datastreams, or Observations
    time_field: resultTime
```

### Socrata

Connects to Socrata Open Data API (SODA) endpoints.

```yaml
providers:
  - type: feature
    name: Socrata
    data: data.cityofchicago.org
    resource_id: ydr8-5enu
    id_field: id
    geom_field: location
    token: my_app_token  # optional
```

Requires `sodapy`.

### ERDDAPTabledap

Connects to ERDDAP scientific data servers (e.g. NOAA).

```yaml
providers:
  - type: feature
    name: ERDDAPTabledap
    data: https://coastwatch.pfeg.noaa.gov/erddap/tabledap/datasetID
    id_field: id
    time_field: time
    options:
      max_age_hours: 24
```

## Quick Selection Guide

| Use Case | Provider |
|---|---|
| Quick prototyping with files | GeoJSON, CSV |
| Production spatial database | PostgreSQL (PostGIS) |
| Full-text + spatial search | Elasticsearch, OpenSearch |
| Existing ESRI infrastructure | ESRI |
| Multiple legacy vector formats | OGR |
| Lightweight editable collections | TinyDB |
| Cloud-native columnar data | Parquet |
| IoT sensor data | SensorThings |
| Enterprise Oracle database | OracleDB |
| Scientific/oceanographic data | ERDDAPTabledap |
| Open data portals | Socrata |
| GeoPackage files | SQLiteGPKG |
| Document store | MongoDB |

## Cross-Cutting Options

These options work across all providers:

- **`properties`** - Control which properties are exposed and their order
- **`crs`** - Array of supported CRS URIs
- **`storage_crs`** - Native CRS of the data source
- **`id_field`** - Property used as unique feature identifier
- **`title_field`** - Property used as display label in the HTML view
- **`time_field`** - Property for temporal/datetime filtering
- **`uri_field`** - Property for Linked Data `@id` values

Default CRS when none configured: `http://www.opengis.net/def/crs/OGC/1.3/CRS84` (WGS84, lon/lat).

## References

- [pygeoapi OGC API - Features docs](https://docs.pygeoapi.io/en/latest/data-publishing/ogcapi-features.html)
- [pygeoapi Plugins docs](https://docs.pygeoapi.io/en/latest/plugins.html)
