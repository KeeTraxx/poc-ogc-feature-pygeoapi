# pygeoapi PoC - Findings

Evaluation findings from the pygeoapi proof of concept for serving OGC API - Features.

## Property Exposure and Queryables

The `properties` list on a provider controls **both** which properties are returned in responses **and** which properties appear as queryables. There is no way to expose a property in responses but hide it from queryables, or vice versa. It is all or nothing per property.

- If `properties` is omitted, all properties are exposed and queryable.
- If `properties` is set, only listed properties are returned and queryable.

**This is a pygeoapi implementation choice, not an OGC API requirement.** The OGC API spec treats queryables (Part 3) and response properties as independent concerns. A compliant server can expose all properties in responses while only allowing filtering on a subset, or vice versa. Other implementations (e.g., ldproxy, GeoServer OGC API module) handle them independently.

In pygeoapi, for use cases where certain fields should be visible but not queryable (or queryable but not returned), a workaround at the proxy/middleware level or a custom provider plugin would be needed.

## CRS Support (LV95 / EPSG:2056)

pygeoapi supports CRS negotiation via OGC API - Features Part 2.

- The `storage_crs` setting declares the native CRS of the data source.
- The `crs` list advertises which CRS a client can request via the `crs=` query parameter.
- pygeoapi handles reprojection automatically between storage CRS and requested CRS.
- The default output CRS is always CRS84 (WGS84, lon/lat), per OGC API spec.
- The `bbox` in `extents.spatial` must always be expressed in CRS84, even when the data is stored in a projected CRS like LV95.

Tested and confirmed working: LV95 (EPSG:2056) data stored natively, served as CRS84 by default, and as EPSG:2056 on request.

## GeoJSON Provider Limitations

The GeoJSON provider is the simplest but also the most limited:

- No datetime/temporal filtering
- No sorting (`sortby`)
- No CQL filtering (only simple property equality filters like `?canton=BE`)
- No transactions (read-only)
- Data is loaded fully into memory

For production use with larger datasets or advanced query needs, PostgreSQL/PostGIS or Elasticsearch would be necessary. The GeoJSON provider is suitable for small, static reference datasets.

## Property Filtering Behavior

The GeoJSON provider supports simple property equality filters as query parameters (e.g., `?type=mountain&canton=VS`). However:

- Only exact match is supported -- no wildcards, ranges, or partial matching.
- Multiple filters are combined with AND logic.
- For advanced filtering (comparisons, OR logic, spatial operators), a provider with CQL support (PostgreSQL, Elasticsearch, OpenSearch, MySQL) is required.

## Output Formats

pygeoapi serves three output formats out of the box:

- **JSON** (`?f=json`) -- standard GeoJSON responses
- **HTML** (`?f=html`) -- browsable HTML UI with an interactive map (OpenStreetMap tiles)
- **JSON-LD** (`?f=jsonld`) -- linked data format with schema.org context for semantic web interoperability

The HTML output provides a functional data explorer without any additional frontend development. The built-in map uses OpenStreetMap tiles by default but can be configured to use other tile sources.

## Docker Deployment

- The official `geopython/pygeoapi` image runs Gunicorn on port 80 internally.
- Configuration is mounted to `/pygeoapi/local.config.yml` which overrides the built-in default config.
- The config supports environment variable substitution with defaults: `${VAR:-default}`.
- The number of Gunicorn workers can be tuned via the `WSGI_WORKERS` environment variable (default: 4).

## Provider Ecosystem

pygeoapi ships with 16 built-in feature providers. See [pygeoapi-providers.md](pygeoapi-providers.md) for a full comparison. Key observations:

- **PostgreSQL/PostGIS** is the most full-featured provider (CQL, transactions, CRS reprojection, datetime, sorting).
- **OGR** is the most versatile for format support (wraps GDAL -- shapefiles, WFS, KML, etc.) but lacks advanced query capabilities.
- **Elasticsearch/OpenSearch** offer full-text search combined with spatial queries.
- There is no built-in provider for cloud-native formats like FlatGeobuf or PMTiles.
- Custom providers can be implemented as Python plugins.

## OpenAPI / Swagger

pygeoapi auto-generates an OpenAPI 3.0 specification at `/openapi`. This can be consumed by standard API tools (Swagger UI, Postman, etc.) and enables client code generation. The spec is derived entirely from the YAML configuration -- no manual API documentation is needed.

## Considerations for Production

- The GeoJSON provider loads entire files into memory -- not suitable for large datasets.
- No built-in authentication or authorization. Would need a reverse proxy (nginx, Traefik) or API gateway for access control.
- No built-in rate limiting.
- CORS is configurable (`cors: true` in server config).
- The `limits.max_items` setting caps the maximum number of features per response but does not protect against expensive spatial queries on large datasets.
