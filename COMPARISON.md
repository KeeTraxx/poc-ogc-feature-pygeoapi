# pygeoapi vs MapServer - OGC API Features Comparison

Comparison performed on 2026-02-20 using the same PostGIS datasource (geodata database with Swiss geospatial data).

| | **pygeoapi** | **MapServer** |
|---|---|---|
| Version | pygeoapi (Python) | MapServer 8.7-dev (C/FastCGI) |
| Base URL | `http://localhost:5000/` | `http://localhost:8080/swiss-geodata/ogcapi` |
| Port | 5000 | 8080 |
| Image | `pygeoapi-custom` (custom build) | `camptocamp/mapserver:8.0-gdal3.7` |

## Core Endpoints

| Endpoint | pygeoapi | MapServer | Notes |
|---|---|---|---|
| Landing page (`/`) | 200 | 200 | Both return JSON with title, description, links |
| OpenAPI spec | `/openapi?f=json` | `/api?f=json` | **Different paths** - both return OpenAPI 3.0.2 |
| Conformance | 200 | 200 | pygeoapi declares more conformance classes (see below) |
| Collections | 200 | 200 | pygeoapi: many collections (PostGIS + OpenSearch + LV95); MapServer: 6 collections (PostGIS only) |

## Conformance Classes

| Conformance Class | pygeoapi | MapServer |
|---|:---:|:---:|
| ogcapi-common-1 core | Y | Y |
| ogcapi-common-1 html | Y | - |
| ogcapi-common-1 json | Y | - |
| ogcapi-common-1 landing-page | Y | - |
| ogcapi-common-1 oas30 | Y | - |
| ogcapi-common-2 collections | Y | Y |
| ogcapi-features-1 core | Y | Y |
| ogcapi-features-1 oas30 | Y | Y |
| ogcapi-features-1 html | Y | Y |
| ogcapi-features-1 geojson | Y | Y |
| ogcapi-features-2 crs | Y | Y |
| ogcapi-features-3 queryables | Y | - |
| ogcapi-features-3 queryables-query-parameters | Y | - |
| ogcapi-features-4 create-replace-delete | Y | - |
| ogcapi-features-5 core-roles-features | Y | - |
| ogcapi-features-5 schemas | Y | - |

pygeoapi declares **16** conformance classes vs MapServer's **7**.

Note: The absence of Part 3 conformance classes (`queryables`, `queryables-query-parameters`) in MapServer means property filtering and sorting are not supported in the current image. The `queryables` endpoint does return a JSON Schema response, but without the corresponding conformance classes the server does not actually accept these as query parameters. Clients should check the conformance response to determine what features are available.

## Feature Querying Capabilities

| Capability | pygeoapi | MapServer | Notes |
|---|:---:|:---:|---|
| List items | Y | Y | Both return GeoJSON FeatureCollections |
| Single feature by ID | Y | Y | |
| `limit` parameter | Y | Y | |
| `offset` parameter | Y | Y | Pagination works on both |
| `bbox` filter | Y | Y | Both return correct spatial results |
| Property filter (e.g. `KTKZ=BE`) | Y | **N** | Not yet in `camptocamp/mapserver:8.6.0`. Coming in a future release ([commit](https://github.com/MapServer/MapServer/commit/d61a2654dcb45ab04bcbc6ed7d0c4dc8cf7d1356)). |
| `sortby` ascending | Y | **N** | Parameter silently ignored in current MapServer image |
| `sortby` descending (`-field`) | Y | **N** | Parameter silently ignored in current MapServer image |
| `queryables` endpoint | Y | Y | Both return JSON Schema |
| CRS output (`crs=EPSG:2056`) | Y | Y | Both reproject to LV95 |
| CRS bbox input (`bbox-crs`) | Y | Y | Both accept LV95 bbox coordinates |

## Default Behavior Differences

| Behavior | pygeoapi | MapServer |
|---|---|---|
| Default items limit | **50** | **10** |
| Max items limit | 1000 (configured) | 1000+ |
| `numberMatched` field | Y | Y |
| `numberReturned` field | Y | Y |
| `timeStamp` field | Y | **Not included** |

## Response Format Differences

### FeatureCollection response

pygeoapi includes a `timeStamp` field in every FeatureCollection response (e.g. `"2026-02-20T09:34:46.309996Z"`). MapServer omits this field.

### Links in responses

| Link relation | pygeoapi | MapServer |
|---|:---:|:---:|
| `self` | Y | Y |
| `alternate` (HTML) | Y | Y |
| `alternate` (JSON-LD) | Y | - |
| `alternate` (CSV) | Y | - |
| `next` (pagination) | Y | Y |
| `collection` | Y | - |

pygeoapi provides richer link relations, including CSV and JSON-LD alternates and a back-link to the parent collection.

## Output Formats

| Format | pygeoapi | MapServer |
|---|:---:|:---:|
| GeoJSON (`f=json`) | Y | Y |
| HTML (`f=html`) | Y | Y |
| JSON-LD (`f=jsonld`) | Y | Y |
| CSV | Y | - |
| OpenAPI JSON | Y | Y |

### JSON-LD differences

- pygeoapi uses Schema.org vocabulary with GeoSPARQL (`@context` includes `schema:`, `gsp:`)
- MapServer uses GeoJSON-LD context (`https://geojson.org/geojson-ld/geojson-context.jsonld`)

## Additional Services (MapServer only)

MapServer also exposes legacy OGC services from the same data:

| Service | Endpoint |
|---|---|
| WFS 1.1.0 | `/mapserv?map=...&SERVICE=WFS&REQUEST=GetCapabilities` |
| WMS 1.3.0 | `/mapserv?map=...&SERVICE=WMS&REQUEST=GetCapabilities` |

pygeoapi is a pure OGC API server and does not serve WFS/WMS.

## URL Structure

- **pygeoapi**: Flat URL structure - `http://localhost:5000/collections/{id}/items`
- **MapServer**: Map alias prefix - `http://localhost:8080/{map-alias}/ogcapi/collections/{id}/items`. A single MapServer instance can serve multiple mapfiles under different aliases.

## HTML Templates

Both servers render HTML pages (landing page, collections, items, etc.) when `f=html` is requested. Both use their built-in default templates out of the box.

| Aspect | pygeoapi | MapServer |
|---|---|---|
| **Templating engine** | Jinja2 | Jinja2-like (custom MapServer syntax) |
| **CSS framework** | Bootstrap | Bootstrap 5.3.8 |
| **Map library** | Leaflet 1.3.1 | Leaflet 1.9.4 |
| **Template location (in container)** | `/pygeoapi/pygeoapi/templates/` | `/usr/local/share/mapserver/ogcapi/templates/html-bootstrap/` |
| **Built-in template sets** | 1 (default) | 4 (`html-bootstrap`, `html-plain`, `html-index-bootstrap`, `html-index-plain`) |
| **Configuration** | Mount custom templates via Docker volume, override in `server` config | Set `OGCAPI_HTML_TEMPLATE_DIRECTORY` in `mapserver.conf` |

### pygeoapi

Templates are Jinja2 files organized in subdirectories (`collections/`, `jobs/`, `processes/`, etc.) extending a shared `_base.html`. To customize, set the `server.templates` section in the pygeoapi config YAML:

```yaml
server:
  templates:
    path: /path/to/custom/templates
    static: /path/to/custom/static
```

Only the templates you want to override need to be present - pygeoapi falls back to the defaults for any missing files. The default templates are at `/pygeoapi/pygeoapi/templates/` inside the container. Mount the custom templates directory into the container as a Docker volume. See the [pygeoapi HTML templating docs](https://docs.pygeoapi.io/en/latest/html-templating.html) for details.

### MapServer

Templates are configured via the `OGCAPI_HTML_TEMPLATE_DIRECTORY` environment variable in `mapserver.conf`:

```
OGCAPI_HTML_TEMPLATE_DIRECTORY "/usr/local/share/mapserver/ogcapi/templates/html-bootstrap/"
```

MapServer ships with 4 template sets to choose from. To customize, copy one of the built-in sets, modify it, mount it as a Docker volume, and point `OGCAPI_HTML_TEMPLATE_DIRECTORY` to the custom path.

## Summary

| Aspect | pygeoapi | MapServer |
|---|---|---|
| **Conformance breadth** | Broader (Parts 1-5) | Core (Parts 1-2) |
| **Output formats** | More (JSON, HTML, JSON-LD, CSV) | Fewer (JSON, HTML, JSON-LD) |
| **Backend flexibility** | Multiple (PostGIS, OpenSearch, GeoJSON, etc.) | PostGIS, Shapefile, OGR sources |
| **Legacy OGC services** | No | Yes (WFS, WMS) |
| **Configuration** | YAML config | Mapfile (.map) + config |
| **Response metadata** | Richer (timeStamp, more links) | Leaner |
| **Multi-map support** | Single server | Multiple map aliases |
| **CRS reprojection** | Yes | Yes |
| **Queryables** | Yes (Part 3) | Endpoint only (no filtering yet, [coming soon](https://github.com/MapServer/MapServer/commit/d61a2654dcb45ab04bcbc6ed7d0c4dc8cf7d1356)) |
| **Transactional (CRUD)** | Yes (Part 4) | No |
