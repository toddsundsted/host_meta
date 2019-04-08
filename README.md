# host_meta

A [Web Host Metadata](https://tools.ietf.org/html/rfc6415) client for
Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

```
dependencies:
  host_meta:
    github: toddsundsted/host_meta
```

2. Run `shards install`

## Usage

```
require "host_meta"

h = HostMeta.query("epiktistes.com") # => #<HostMeta::Result:0x10e99...>
h.links("lrdd").first.template # => "https://epiktistes.com/.well-known/webfinger?resource={uri}"
```

## Contributors

- [Todd Sundsted](https://github.com/toddsundsted) - creator and maintainer
