require "http/client"

module HostMeta
  # General error.
  class Error < Exception
  end

  # Address not found error.
  class NotFoundError < Error
  end

  # The client.
  module Client
    # Returns the result of querying the specified host.
    #
    #     h = HostMeta.query("epiktistes.com") # => #<HostMeta::Result:0x10e99...>
    #     h.links("lrdd").first.template # => "https://epiktistes.com/.well-known/webfinger?resource={uri}"
    #
    # Raises `HostMeta::NotFoundError` if the host does not
    # exist. Otherwise, returns `HostMeta::Result`.
    #
    def self.query(host)
      url = "https://#{host}/.well-known/host-meta"
      HTTP::Client.get(url) do |response|
        case (code = response.status_code)
        when 200
          mt = response.mime_type.try(&.media_type)
          if ["application/jrd+json", "application/json"].includes?(mt)
            Result.from_json(response.body_io)
          else
            # application/xrd+xml, application/xml, text/xml and everything else
            Result.from_xml(response.body_io)
          end
        when 404
          raise NotFoundError.new("not found [#{code}]: #{url}")
        else
          raise Error.new("error [#{code}]: #{url}")
        end
      end
    end
  end
end
