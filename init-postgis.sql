CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE swiss_places (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    canton VARCHAR(10) NOT NULL,
    population INTEGER,
    elevation_m INTEGER,
    area_km2 NUMERIC(10,2),
    description TEXT,
    geom GEOMETRY(Geometry, 4326)
);

INSERT INTO swiss_places (id, name, type, canton, population, description, geom) VALUES
(1, 'Bern', 'city', 'BE', 134794, 'Federal capital of Switzerland', ST_GeomFromText('POINT(7.4474 46.9480)', 4326)),
(2, 'Zurich', 'city', 'ZH', 421878, 'Largest city in Switzerland', ST_GeomFromText('POINT(8.5417 47.3769)', 4326)),
(3, 'Geneva', 'city', 'GE', 203856, 'Second largest city, international hub', ST_GeomFromText('POINT(6.1432 46.2044)', 4326)),
(4, 'Basel', 'city', 'BS', 177595, 'Cultural capital at the Rhine', ST_GeomFromText('POINT(7.5886 47.5596)', 4326)),
(5, 'Lausanne', 'city', 'VD', 139408, 'Olympic capital on Lake Geneva', ST_GeomFromText('POINT(6.6323 46.5197)', 4326)),
(6, 'Lucerne', 'city', 'LU', 82620, 'Gateway to central Switzerland', ST_GeomFromText('POINT(8.3093 47.0502)', 4326));

INSERT INTO swiss_places (id, name, type, canton, elevation_m, description, geom) VALUES
(7, 'Matterhorn', 'mountain', 'VS', 4478, 'Iconic pyramid-shaped peak in the Alps', ST_GeomFromText('POINT(7.6586 45.9764)', 4326)),
(8, 'Jungfrau', 'mountain', 'BE', 4158, 'One of the main summits of the Bernese Alps', ST_GeomFromText('POINT(7.9614 46.5372)', 4326));

INSERT INTO swiss_places (id, name, type, canton, area_km2, description, geom) VALUES
(9, 'Lake Zurich', 'lake', 'ZH', 88.17, 'Glacial lake extending southeast of Zurich',
  ST_GeomFromText('POLYGON((8.5200 47.3700, 8.5800 47.3500, 8.6500 47.3200, 8.7200 47.2800, 8.7800 47.2400, 8.8000 47.2200, 8.7700 47.2100, 8.7100 47.2300, 8.6400 47.2700, 8.5700 47.3100, 8.5100 47.3400, 8.5200 47.3700))', 4326)),
(10, 'Lake Geneva', 'lake', 'VD', 580.03, 'Largest lake in Western Europe',
  ST_GeomFromText('POLYGON((6.1500 46.2200, 6.2000 46.2400, 6.3000 46.2600, 6.4500 46.3000, 6.5500 46.3300, 6.6500 46.3700, 6.8000 46.4000, 6.8500 46.4200, 6.9000 46.4000, 6.8500 46.3800, 6.7000 46.3500, 6.5500 46.3000, 6.4000 46.2600, 6.2500 46.2200, 6.1500 46.2000, 6.1500 46.2200))', 4326));

SELECT setval('swiss_places_id_seq', 10);

CREATE INDEX idx_swiss_places_geom ON swiss_places USING GIST (geom);
