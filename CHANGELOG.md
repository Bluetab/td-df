# Changelog

## [7.7.0] 2025-06-30

### Added

- [TD-7299] Refactor gitlab-ci pipeline and add Trivy check

## [7.5.2] 2025-06-10

### Changed

- [TD-7311] Remove group name validation

## [7.5.1] 2025-06-06

### Fixed

- [TD-7285] Fix default secret section for configuration template

## [7.5.0] 2025-04-30

### Added

- [TD-5800] Add validations for mandatory fields in templates

### Fixed

- [TD-7226] Enhance SSL configuration handling in production

## [7.4.0] 2025-04-09

### Changed

- License and libraries

## [7.0.0] 2025-01-13

### Changed

- [TD-6911]
  - update Elixir 1.18
  - update dependencies
  - update Docker RUNTIME_BASE=alpine:3.21
  - remove unused dependencies
  - remove swagger

## [6.12.0] 2024-09-23

### Added

- [TD-6184] Agent template management

## [6.9.0] 2024-07-26

### Changed

- [TD-6602] Update td-cache

## [6.8.0] 2024-07-03

### Added

- [TD-6499] Migration of template default values with metadata

## [6.3.0] 2024-03-18

### Added

- [TD-4110] Allow structure scoped permissions management

## [6.2.0] 2024-02-26

### Fixed

- [TD-6425] Ensure SSL if configured for release migration

## [6.0.0] 2024-01-17

## Added

- [TD-6336] Get test-truedat-eks config on deploy stage

### Changed

- [TD-6197] Add migration for "df_description" in bussiness concept templates

## [5.18.0] 2023-11-13

## Added

- [TD-3062] TemplateView returns updated_at field

## [5.17.0] 2023-11-02

## Added

- [TD-6059] Support for td-cluster contract

## [5.10.0] 2023-07-06

## Changed

- [TD-5912] `.gitlab-ci.yml` adaptations for develop and main branches

## [5.9.0] 2023-06-20

### Added

- [TD-5770] Add database TSL configuration

## [5.8.0] 2023-06-05

### Added

- [TD-3916] Migrations for new structure for hierarchy widget

## [5.5.0] 2023-04-18

### Added

- [TD-5650] Path for hierarchy nodes
- [TD-5297] Added `DB_SSL` environment variable for Database SSL connection

## [5.3.0] 2023-03-13

### Added

- [TD-3806] Hierarchy template cache implementation

## [5.0.0] 2023-01-30

### Added

- [TD-3805] Hierarchy functionality

## [4.58.1] 2022-12-27

### Added

- [TD-3919] Add subscope to template
- [TD-5368] Add editable boolean to existing templates content fields

## [4.54.0] 2022-10-31

### Changed

- [TD-5284] Phoenix 1.6.x

## [4.52.0] 2022-10-03

### Added

- [TD-4903] Include `sobelow` static code analysis in CI pipeline

## [4.48.0] 2022-07-26

### Changed

- [TD-5011] Force load templates into cache on startup
- [TD-3614] Support for access token revocation

## [4.47.0] 2022-07-04

### Added

- [TD-4412] Tests for preprocessing user_group fields

## [4.46.0] 2022-06-20

### Fixed

- [TD-4896] `GET /api/templates/:id` was failing for empty request variables
  (`domain_id` or `domain_ids`)

## [4.45.0] 2022-06-06

### Changed

- Updated dependencies

## [4.44.0] 2022-05-23

### Changed

- [TD-4230] Moved templates preprocessing functionality to `td-cache` and allows for multiple domain_ids

## [4.43.0] 2022-05-09

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
