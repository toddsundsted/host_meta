require "http/client"

module HostMeta
  # General error.
  class Error < Exception
  end

  # Address not found error.
  class NotFoundError < Error
  end

  # Redirection failed.
  class RedirectionError < Error
  end

  # The client.
  module Client
    # Returns the result of querying the specified host.
    #
    #     h = HostMeta.query("epiktistes.com") # => #<HostMeta::Result:0x10e99...>
    #     h.links("lrdd").first.template # => "https://epiktistes.com/.well-known/webfinger?resource={uri}"
    #
    # Raises `HostMeta::NotFoundError` if the host does not exist and
    # `HostMeta::RedirectionError` if redirection failed. Otherwise,
    # returns `HostMeta::Result`.
    #
    def self.query(host, attempts = 10)
      url = "https://#{host}/.well-known/host-meta"
      attempts.times do |i|
        HTTP::Client.get(url) do |response|
          case (code = response.status_code)
          when 200
            mt = response.mime_type.try(&.media_type)
            result =
              if mt =~ /xml/
                Result.from_xml(response.body_io)
              elsif mt =~ /json/
                Result.from_json(response.body_io)
              elsif response.body_io.peek.try(&.first) == 123 # sniff for '{'
                Result.from_json(response.body_io)
              else
                Result.from_xml(response.body_io)
              end
            return result
          when 300, 301, 302, 303, 307, 308
            if (tmp = response.headers["Location"]?) && (url = tmp)
              next
            else
              break
            end
          when 404
            raise NotFoundError.new("not found [#{code}]: #{url}")
          else
            raise Error.new("error [#{code}]: #{url}")
          end
        end
      end
      raise RedirectionError.new("redirection failed: #{url}")
    rescue ex : Socket::Addrinfo::Error
      raise NotFoundError.new(ex.message)
    end
  end
end
