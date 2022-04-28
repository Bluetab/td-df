# Changelog

## [Unreleased]

### Changed

- [TD-3569] Only admin and service users can manage templates

## [4.40.0] 2022-03-14

### Changed

- [TD-2501] Database timeout and pool size can now be configured using
  `DB_TIMEOUT_MILLIS` and `DB_POOL_SIZE` environment variables
- [TD-4491] Compatibility with new permissions cache model

## [4.25.0] 2021-07-26

### Changed

- Updated dependencies

## [4.21.0] 2021-05-31

### Changed

- [TD-3753] Build using Elixir 1.12 and Erlang/OTP 24

## [4.20.0] 2021-05-17

### Changed

- Security patches from `alpine:3.13`
- Update dependencies

## [4.19.0] 2021-05-04

### Added

- [TD-3628] Force release to update base image

## [4.17.0] 2021-04-05

### Changed

- [TD-3445] Postgres port configurable through `DB_PORT` environment variable

## [4.15.0] 2021-03-08

### Added

- [TD-3063] Store subscribable fields

### Changed

- [TD-3341] Build with `elixir:1.11.3-alpine`, runtime `alpine:3.13`

## [4.14.0] 2021-02-22

### Changed

- [TD-3245] Tested compatibility with PostgreSQL 9.6, 10.15, 11.10, 12.5 and
  13.1. CI pipeline changed to use `postgres:12.5-alpine`.

## [4.12.0] 2021-01-21

### Changed

- [TD-3163] Auth tokens now include `role` claim instead of `is_admin` flag
- [TD-3182] Allow to use redis with password

## [4.11.0] 2021-01-11

### Changed

- [TD-3170] Build docker image which runs with non-root user

## [4.6.0] 2020-10-19

### Added

- [TD-2955] Migration inserting the template `config_metabase`

## [4.0.0] 2020-07-01

### Changed

- Update to Phoenix 1.5

## [3.20.0] 2020-04-20

### Changed

- [TD-2508] Update to Elixir 1.10

## [3.14.0] 2020-01-27

### Changed

- [TD-2269] New template format for groups

## [3.13.0] 2020-12-13

### Changed

- [TD-2255] Migrate fields in content having `depends` key

## [3.10.0] 2019-11-11

### Changed

- [TD-2137] Template scope set as required

## [3.8.0] 2019-10-14

### Changed

- [TD-1721] Cache 3.7.2 with template events

## [3.7.0] 2019-09-31

### Added

- [TD-1993] Validate template names and types on creation/update

## [3.5.0] 2019-09-03

### Changed

- Use td-cache 3.5.1

## [3.2.0] 2019-07-24

### Changed

- [TD-2002] Update td-cache and delete permissions list from config

## [3.1.0] 2019-07-08

### Changed

- [TD-1618] Cache improvements (use td-cache instead of td-perms)
- [TD-1924] Use Jason instead of Poison for JSON encoding/decoding

## [3.0.0] 2019-06-25

### Changed

- [TD-1855] Allow template names to have spaces

## [2.19.0] 2019-05-14

### Fixed

- [TD-1774] Newline is missing in logger format

## [2.16.0] 2019-04-01

### Added

- [TD-1571] Elixir's Logger config will check for EX_LOGGER_FORMAT variable to
  override format

## [2.15.0] 2019-03-18

### Changed

- [TD-1548] When preprocessing template, role_users are stored in a different
  attribute to avoid overwriting the role value, needed for editing the template
- [TD-1468] Updated td-perms version to 2.15.0. Writes scope to Redis cache

## [2.14.0] 2019-03-02

### Fixed

- Manage confidential field for super admin user
- Updated alpine docker base image to 3.8 instead of latest

### Changed

- Template is always preprocessed on show

## [2.12.0] 2019-01-29

### Removed

- Removed unused TemplateRelation schema. (Made obsolete by scope property)
- Removed unused Hypermedia

### Changed

- [TD-1101] Changed formater and preprocessor to the new template format

## [2.11.1] 2019-01-09

### Change

- Refactor template preprocessing, include tests

## [2.11.0] 2019-01-09

### Change

- [TD-1223] remove id_default field from template

## [2.8.4] 2018-12-11

### Fixed

- Check for parent domain's roles while preprocessing templates

## [2.8.3] 2018-11-29

### Fixed

- Check for confidential permissions had wrong pattern matching

## [2.8.1] 2018-11-22

### Changed

- Update to td_perms 2.8.1
- Use environment variable REDIS_HOST instead of REDIS_URI
- Configure Ecto to use UTC datetime for timestamps

## [2.8.0] 2018-11-22

### Changed

- Align major/minor version with other services (2.8.x)

## [1.0.2] 2018-11-13

### Added

- New field scope in templates entity
- Test support for field scope in backend and controllers

## [1.0.1] 2018-11-07

### Added

- Clean cache on start-up
- Mocked Cache test on controller

### Fixed

- Fix deleting cache when template is deleted
