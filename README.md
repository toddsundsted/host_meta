# host_meta

[![GitHub Release](https://img.shields.io/github/release/toddsundsted/host_meta.svg)](https://github.com/toddsundsted/host_meta/releases)
[![Build Status](https://travis-ci.org/toddsundsted/host_meta.svg?branch=main)](https://travis-ci.org/toddsundsted/host_meta)
[![Documentation](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://toddsundsted.github.io/host_meta/)

A [Web Host Metadata](https://tools.ietf.org/html/rfc6415) client for
Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  host_meta:
    github: toddsundsted/host_meta
```

2. Run `shards install`

## Usage

```crystal
require "host_meta"

h = HostMeta.query("epiktistes.com") # => #<HostMeta::Result:0x10e99...>
h.links("lrdd").first.template # => "https://epiktistes.com/.well-known/webfinger?resource={uri}"
```

## Contributors

- [Todd Sundsted](https://github.com/toddsundsted) - creator and maintainer
