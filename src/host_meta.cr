# A [Web Host Metadata](https://tools.ietf.org/html/rfc6415)
# client for Crystal.
module HostMeta
  # Returns the result of querying the specified host.
  #
  #     h = HostMeta.query("epiktistes.com") # => #<HostMeta::Result:0x10e99...>
  #     h.links("lrdd").first.template # => "https://epiktistes.com/.well-known/webfinger?resource={uri}"
  #
  # Raises `HostMeta::NotFoundError` if the host does not exist and
  # `HostMeta::RedirectionError` if redirection fails. Otherwise,
  # returns `HostMeta::Result`.
  #
  def self.query(host)
    HostMeta::Client.query(host)
  end
end

require "./host_meta/client"
require "./host_meta/result"
