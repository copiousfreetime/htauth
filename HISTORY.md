# Changelog
## Version 2.1.1 - 2020-04-02

* Update minimum ruby versions to modern versions
* Support bcrypt password entries [#12](https://github.com/copiousfreetime/htauth/issues/12)
* Support authentication at the password file level
* implement --verify commandline option (-v in apache htpasswd)
* implement --stdin commandline option (-i in apache htpasswd)

## Version 2.0.0 - 2015-09-13

* Remove highline dependency - [#9](https://github.com/copiousfreetime/htauth/pull/9)
* Tomdoc the public interface - [#10](https://github.com/copiousfreetime/htauth/issues/10)
* Extract the commandline objects to their own module - [#2](https://github.com/copiousfreetime/htauth/issues/2)
* Use a secure comparison when comparing digests - [#11](https://github.com/copiousfreetime/htauth/issues/11)

## Version 1.2.0 2015-07-18

* Clarify project license (its MIT) - [#7](https://github.com/copiousfreetime/htauth/issues/7)
* Cleanup travis ci config - [#8](https://github.com/copiousfreetime/htauth/issues/8)
* performance improvement in large passwd files - [#4](https://github.com/copiousfreetime/htauth/pull/4)
* Update dependencies
* Update project layout/tooling
* Official notation that this project uses [Semantic Versioning](http://semver.org/)
* Add [Chulki Lee](https://github.com/chulkilee) as contributor.

## Version 1.1.0 2014-03-10

* Update highline dependency
* Change the default algorithm in htpasswd-ruby to be MD5
* Convert tests to minitest
* Update to [fixme](http://github.com/copiousfreetime/fixme) project structure
* General update to ruby 1.9/2.0
* Fix all -w warnings

## Version 1.0.3 2008-12-20

* update highline dependency

## Version 1.0.2 2008-11-30

### Minor enhancement 

* Change project layout 

## Version 1.0.1 2008-02-06

### Bugfixes

* fix require dependency chain
* fix gem dependency on rake

## Version 1.0.0 2008-02-05

* Initial public release

### Release Notes

* Look at 'htpasswd-ruby' and 'htdigest-ruby' to get started.

