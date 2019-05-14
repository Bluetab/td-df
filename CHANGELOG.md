# Changelog

## [2.19.0] 2019-05-14

### Fixed

- [TD-1774] Newline is missing in logger format

## [2.16.0] 2019-04-01

### Added

- [TD-1571] Elixir's Logger config will check for EX_LOGGER_FORMAT variable to override format

## [2.15.0] 2019-03-18

### Changed

- [TD-1548] When preprocessing template, role_users are stored in a different attribute to avoid overwriting the role value, needed for editing the template
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
