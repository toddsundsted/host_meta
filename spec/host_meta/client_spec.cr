require "uri"
require "../spec_helper"

class HTTP::Client
  @@history = [] of URI

  @@next_response : {Int32, HTTP::Headers, String}? = nil

  def self.history
    @@history
  end

  def self.clear_history
    @@history = [] of URI
  end

  def self.set_next_response(status, headers : HTTP::Headers, body : String)
    @@next_response = {status, headers, body}
  end

  def self.get(url : String | URI, h : HTTP::Headers? = nil, b : BodyType = nil, t = nil)
    url = url.is_a?(String) ? URI.parse(url) : url
    @@history << url
    case url.host
    when /not-found/
      yield HTTP::Client::Response.new(404)
    when /internal-server-error/
      yield HTTP::Client::Response.new(500)
    else
      if (next_response = @@next_response)
        code, headers, body = next_response
        @@next_response = nil
      else
        code = 200
        headers = HTTP::Headers.new
        body = <<-XML
          <?xml version="1.0"?>
          <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"/>
          XML
      end
      yield HTTP::Client::Response.new(code, headers: headers, body_io: IO::Memory.new(body))
    end
  end
end

def with_json
  HTTP::Client.set_next_response(
    200,
    HTTP::Headers{"Content-Type" => "application/jrd+json"},
    "{}"
  )
  yield
end

def with_xml
  HTTP::Client.set_next_response(
    200,
    HTTP::Headers{"Content-Type" => "application/xrd+xml"},
    <<-XML
      <?xml version="1.0"?>
      <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"/>
      XML
  )
  yield
end

Spec.before_each do
  HTTP::Client.clear_history
end

describe HostMeta::Client do
  describe ".query" do
    it "raises an error if host doesn't exist" do
      expect_raises(HostMeta::NotFoundError) do
        HostMeta::Client.query("not-found.com")
      end
    end

    it "raises an error if request fails for any reason" do
      expect_raises(HostMeta::Error) do
        HostMeta::Client.query("internal-server-error.com")
      end
    end

    with_json do
      it "returns a result" do
        HostMeta::Client.query("example.com").should be_a(HostMeta::Result)
      end
    end

    with_xml do
      it "returns a result" do
        HostMeta::Client.query("example.com").should be_a(HostMeta::Result)
      end
    end

    it "makes an HTTP request to the host domain" do
      HostMeta::Client.query("example.com")
      HTTP::Client.history.map(&.host).should contain("example.com")
    end

    it "makes an HTTP request with the host meta path" do
      HostMeta::Client.query("example.com")
      HTTP::Client.history.map(&.path).should contain("/.well-known/host-meta")
    end
  end
end