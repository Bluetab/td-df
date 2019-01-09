# Changelog

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
