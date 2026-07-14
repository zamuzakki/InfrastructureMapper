-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------UNRELEASED-GPKG-MIGRATIONS----------------------
-- Append SQLite/GeoPackage schema changes for the next release here. Paired with the PG
-- equivalent in sql/migrations/pg/UNRELEASED.sql.
--
-- Required format for every appended block:
--
--   -- Issue #NNN: short description
--   <SQL statements>
--
-- Notes on GPKG dialect:
--   * SQLite ALTER TABLE is limited; for constraint changes use the SQLite 12-step
--     recreate pattern (CREATE new table, INSERT … SELECT, DROP old, RENAME).
--   * If a migration adds, renames, or drops a spatial table, also update
--     gpkg_contents and gpkg_geometry_columns and (re)build the rtree index.
-- Issue #56: Unify CRS to EPSG:4326 across all spatial tables (GPKG side).
-- The PG migration uses ST_Transform; SQLite/GPKG has no built-in equivalent
-- without SpatiaLite. Rebuild the GPKG from PG instead:
--     scripts/build_gpkg.sh [--crs EPSG:NNNN]
-- and re-import any captured field data. For records, also stamp this
-- migration as applied:

-- Issue #0: [DUMMY/TEST] Cap length of two lookup-table name columns (GPKG side).
-- Mirrors the PG-side VARCHAR(100) bound on segment_type.type_name and
-- segment_status.status_name. SQLite has no ALTER COLUMN TYPE and no
-- enforced length limit either way (type affinity only), so this is a
-- schema-declaration-only change via the 12-step recreate pattern, not a
-- behavioral one.
PRAGMA foreign_keys=OFF;

CREATE TABLE segment_type_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE NOT NULL,
    last_update DATETIME NOT NULL,
    last_update_by TEXT NOT NULL,
    type_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);
INSERT INTO segment_type_new (id, uuid, last_update, last_update_by, type_name, description)
SELECT id, uuid, last_update, last_update_by, type_name, description FROM segment_type;
DROP TABLE segment_type;
ALTER TABLE segment_type_new RENAME TO segment_type;

CREATE TABLE segment_status_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE NOT NULL,
    last_update DATETIME NOT NULL,
    last_update_by TEXT NOT NULL,
    status_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);
INSERT INTO segment_status_new (id, uuid, last_update, last_update_by, status_name, description)
SELECT id, uuid, last_update, last_update_by, status_name, description FROM segment_status;
DROP TABLE segment_status;
ALTER TABLE segment_status_new RENAME TO segment_status;

PRAGMA foreign_keys=ON;
