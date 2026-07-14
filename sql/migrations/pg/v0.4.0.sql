-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------UNRELEASED-PG-MIGRATIONS------------------------
-- Append schema changes for the next release here. At release time this file is renamed
-- to vX.Y.Z.sql by scripts/release.sh and becomes immutable.
--
-- Required format for every appended block:
--
--   -- Issue #NNN: short description
--   <SQL statements>
--
-- Pre-commit hook (and the matching CI job) rejects any statement that is not preceded by
-- an `-- Issue #NNN:` header line.
-- Issue #56: Unify CRS to EPSG:4326 across all spatial tables.
-- Roads and intersections originally declared EPSG:32734 (WGS 84 / UTM Zone 34S)
-- while every other spatial table used EPSG:4326. Bring them onto the same
-- declared CRS so the canonical schema is uniform; users that need metric
-- accuracy reproject at build time via scripts/build_gpkg.sh --crs.

-- Issue #0: [DUMMY/TEST] Cap length of two lookup-table name columns.
-- Placeholder migration for exercising the fork's release pipeline end-to-end.
-- Bounds segment_type.type_name and segment_status.status_name, previously
-- unbounded VARCHAR, to VARCHAR(100). The underlying column type (character
-- varying) is unchanged and existing lookup values ("National", "In Use", ...)
-- are far under the new limit, so this is non-invasive.
ALTER TABLE segment_type ALTER COLUMN type_name TYPE VARCHAR(100);
ALTER TABLE segment_status ALTER COLUMN status_name TYPE VARCHAR(100);
