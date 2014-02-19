jjulien-trac
============

Overview
------------
Puppet module for managing trac instances


TODOs
------------
* Add support for other database backends (currently only supports postgresql)
* Abstract ini parameter management for the defined type trac::project and allow users to pass in a hash of override or additional parameters
* Add spec tests
* Support different web authentication mechanisms (currently only supports basic auth)
