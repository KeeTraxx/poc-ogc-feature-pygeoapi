#!/bin/sh
set -e

OS_URL="http://opensearch:9200"
INDEX="swiss-places"

echo "Waiting for OpenSearch..."
until curl -s "$OS_URL/_cluster/health" | grep -q '"status"'; do
  sleep 1
done
echo "OpenSearch is ready."

# Delete index if it already exists (idempotent reload)
curl -s -X DELETE "$OS_URL/$INDEX" > /dev/null 2>&1 || true

echo "Creating index with mapping..."
curl -sS -X PUT "$OS_URL/$INDEX" -H 'Content-Type: application/json' -d '{
  "mappings": {
    "properties": {
      "id": { "type": "integer" },
      "type": { "type": "keyword" },
      "geometry": { "type": "geo_shape" },
      "properties": {
        "type": "object",
        "properties": {
          "id": { "type": "integer" },
          "name": { "type": "text", "fields": { "raw": { "type": "keyword" } } },
          "type": { "type": "keyword" },
          "canton": { "type": "keyword" },
          "population": { "type": "integer" },
          "elevation_m": { "type": "integer" },
          "area_km2": { "type": "float" },
          "description": { "type": "text" }
        }
      }
    }
  }
}'
echo ""

echo "Indexing documents..."

curl -sS -X PUT "$OS_URL/$INDEX/_doc/1" -H 'Content-Type: application/json' -d '{
  "id": 1, "type": "Feature",
  "properties": { "id": 1, "name": "Bern", "type": "city", "canton": "BE", "population": 134794, "description": "Federal capital of Switzerland" },
  "geometry": { "type": "Point", "coordinates": [7.4474, 46.9480] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/2" -H 'Content-Type: application/json' -d '{
  "id": 2, "type": "Feature",
  "properties": { "id": 2, "name": "Zurich", "type": "city", "canton": "ZH", "population": 421878, "description": "Largest city in Switzerland" },
  "geometry": { "type": "Point", "coordinates": [8.5417, 47.3769] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/3" -H 'Content-Type: application/json' -d '{
  "id": 3, "type": "Feature",
  "properties": { "id": 3, "name": "Geneva", "type": "city", "canton": "GE", "population": 203856, "description": "Second largest city, international hub" },
  "geometry": { "type": "Point", "coordinates": [6.1432, 46.2044] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/4" -H 'Content-Type: application/json' -d '{
  "id": 4, "type": "Feature",
  "properties": { "id": 4, "name": "Basel", "type": "city", "canton": "BS", "population": 177595, "description": "Cultural capital at the Rhine" },
  "geometry": { "type": "Point", "coordinates": [7.5886, 47.5596] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/5" -H 'Content-Type: application/json' -d '{
  "id": 5, "type": "Feature",
  "properties": { "id": 5, "name": "Lausanne", "type": "city", "canton": "VD", "population": 139408, "description": "Olympic capital on Lake Geneva" },
  "geometry": { "type": "Point", "coordinates": [6.6323, 46.5197] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/6" -H 'Content-Type: application/json' -d '{
  "id": 6, "type": "Feature",
  "properties": { "id": 6, "name": "Lucerne", "type": "city", "canton": "LU", "population": 82620, "description": "Gateway to central Switzerland" },
  "geometry": { "type": "Point", "coordinates": [8.3093, 47.0502] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/7" -H 'Content-Type: application/json' -d '{
  "id": 7, "type": "Feature",
  "properties": { "id": 7, "name": "Matterhorn", "type": "mountain", "canton": "VS", "elevation_m": 4478, "description": "Iconic pyramid-shaped peak in the Alps" },
  "geometry": { "type": "Point", "coordinates": [7.6586, 45.9764] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/8" -H 'Content-Type: application/json' -d '{
  "id": 8, "type": "Feature",
  "properties": { "id": 8, "name": "Jungfrau", "type": "mountain", "canton": "BE", "elevation_m": 4158, "description": "One of the main summits of the Bernese Alps" },
  "geometry": { "type": "Point", "coordinates": [7.9614, 46.5372] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/9" -H 'Content-Type: application/json' -d '{
  "id": 9, "type": "Feature",
  "properties": { "id": 9, "name": "Lake Zurich", "type": "lake", "canton": "ZH", "area_km2": 88.17, "description": "Glacial lake extending southeast of Zurich" },
  "geometry": { "type": "Polygon", "coordinates": [[[8.5200,47.3700],[8.5800,47.3500],[8.6500,47.3200],[8.7200,47.2800],[8.7800,47.2400],[8.8000,47.2200],[8.7700,47.2100],[8.7100,47.2300],[8.6400,47.2700],[8.5700,47.3100],[8.5100,47.3400],[8.5200,47.3700]]] }
}'

curl -sS -X PUT "$OS_URL/$INDEX/_doc/10" -H 'Content-Type: application/json' -d '{
  "id": 10, "type": "Feature",
  "properties": { "id": 10, "name": "Lake Geneva", "type": "lake", "canton": "VD", "area_km2": 580.03, "description": "Largest lake in Western Europe" },
  "geometry": { "type": "Polygon", "coordinates": [[[6.1500,46.2200],[6.2000,46.2400],[6.3000,46.2600],[6.4500,46.3000],[6.5500,46.3300],[6.6500,46.3700],[6.8000,46.4000],[6.8500,46.4200],[6.9000,46.4000],[6.8500,46.3800],[6.7000,46.3500],[6.5500,46.3000],[6.4000,46.2600],[6.2500,46.2200],[6.1500,46.2000],[6.1500,46.2200]]] }
}'

echo ""
echo "Done! Indexed 10 documents into '$INDEX'"
