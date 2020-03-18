require "../spec_helper"

XRD_ENV = <<-XRD
<?xml version='1.0'?>
<!-- This is the first child! -->
<XRD
  xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'
  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
%s
</XRD>
XRD

Spectator.describe HostMeta::Result do
  describe ".from_xml" do
    it "parses an application/xrd+xml result" do
      HostMeta::Result.from_xml("<XRD/>").should be_a(HostMeta::Result)
    end

    it "maps properties" do
      result = XRD_ENV % "<Property type='one'>1</Property><Property type='two' xsi:nil='true'/>"
      HostMeta::Result.from_xml(result).properties.should eq({"one" => "1", "two" => nil})
    end

    context "links" do
      it "parses links" do
        result = XRD_ENV % "<Link rel='one' href='1'/>"
        HostMeta::Result.from_xml(result).links.should be_a(Array(HostMeta::Result::Link))
      end

      it "maps rel" do
        result = XRD_ENV % "<Link rel='self'/>"
        links = HostMeta::Result.from_xml(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.rel).should eq("self")
      end

      it "maps type" do
        result = XRD_ENV % "<Link rel='self' type='text'/>"
        links = HostMeta::Result.from_xml(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.type).should eq("text")
      end

      it "maps template" do
        result = XRD_ENV % "<Link rel='self' template='https://example.com/?uri={uri}'/>"
        links = HostMeta::Result.from_xml(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.template).should eq("https://example.com/?uri={uri}")
      end

      it "maps href" do
        result = XRD_ENV % "<Link rel='self' href='urn:xyz'/>"
        links = HostMeta::Result.from_xml(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.href).should eq("urn:xyz")
      end
    end
  end

  describe ".from_json" do
    it "parses an application/jrd+json result" do
      HostMeta::Result.from_json("{}").should be_a(HostMeta::Result)
    end

    it "maps properties" do
      result = %[{"properties":{"one":"1","two":null}}]
      HostMeta::Result.from_json(result).properties.should eq({"one" => "1", "two" => nil})
    end

    context "links" do
      it "parses links" do
        result = %[{"links":[]}]
        HostMeta::Result.from_json(result).links.should be_a(Array(HostMeta::Result::Link))
      end

      it "maps rel" do
        result = %[{"links":[{"rel":"self"}]}]
        links = HostMeta::Result.from_json(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.rel).should eq("self")
      end

      it "maps type" do
        result = %[{"links":[{"rel":"self","type":"text"}]}]
        links = HostMeta::Result.from_json(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.type).should eq("text")
      end

      it "maps template" do
        result = %[{"links":[{"rel":"self","template":"https://example.com/?uri={uri}"}]}]
        links = HostMeta::Result.from_json(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.template).should eq("https://example.com/?uri={uri}")
      end

      it "maps href" do
        result = %[{"links":[{"rel":"self","href":"urn:xyz"}]}]
        links = HostMeta::Result.from_json(result).links
        links.try(&.size).should eq(1)
        links.try(&.first.href).should eq("urn:xyz")
      end
    end
  end

  describe "#property" do
    it "returns the value of the property" do
      result = XRD_ENV % "<Property type='one'>1</Property><Property type='two' xsi:nil='true'/>"
      HostMeta::Result.from_xml(result).property("one").should eq("1")
    end
  end

  describe "#property?" do
    it "returns true if the property has a value" do
      result = XRD_ENV % "<Property type='one'>1</Property><Property type='two' xsi:nil='true'/>"
      HostMeta::Result.from_xml(result).property?("one").should be_true
    end
  end

  describe "#links" do
    it "returns the links with the specified rel" do
      result = XRD_ENV % "<Link rel='next' href='next/1'/><Link rel='prev' href='prev/1'/>"
      HostMeta::Result.from_xml(result).links("next").map(&.href).should eq(["next/1"])
    end
  end

  describe "#links?" do
    it "returns true if the specified rel has any values" do
      result = XRD_ENV % "<Link rel='next' href='next/1'/><Link rel='prev' href='prev/1'/>"
      HostMeta::Result.from_xml(result).links?("next").should be_true
    end
  end
end
