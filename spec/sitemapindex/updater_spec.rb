require "spec_helper"
require "pry-byebug"
require "nokogiri"
require "timecop"
require "tilt"
require "zlib"

RSpec.describe Sitemapindex::Updater do
  describe "Sitemapindex::Updater" do
    let!(:time_freeze) { Timecop.freeze("2020-01-01") }
    let(:updater) { Sitemapindex::Updater }

    describe "#update_sitemapindex(start_time, sitemapindex_path, sitemap_name, sitemap_paths, toppage_url)" do
      before(:each) { system("cp spec/fixtures/sitemap.xml.gz spec/sitemap.xml.gz") }
      after(:each)  { system("rm spec/sitemap.xml.gz") }
      subject(:result) do
        updater.update_sitemapindex(time, index_path, name, paths, url)
        Nokogiri::XML(Zlib::GzipReader.open(index_path))
      end
      let(:time)       { Time.now }
      let(:index_path) { "spec/sitemap.xml.gz" }
      let(:name)       { "sitemap_test" }
      let(:paths)      { ["/home/sitemaps/sitemap_test.xml.gz", "/home/sitemaps/sitemap_test_1.xml.gz", "/home/sitemaps/sitemap_test_2.xml.gz"] }
      let(:url)        { "http://www.example.com/" }
      context "when given args correctly" do
        it "keeps other sitemaps nodes" do
          expect(result.search("sitemapindex/sitemap").size).to eq(8)
          expect(result.search("sitemapindex/sitemap[1]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_example.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[1]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
          expect(result.search("sitemapindex/sitemap[5]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_item_2.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[5]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
        end
        it "adds the new sitemaps nodes" do
          expect(result.search("sitemapindex/sitemap[6]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[6]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
          expect(result.search("sitemapindex/sitemap[7]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test_1.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[7]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
          expect(result.search("sitemapindex/sitemap[8]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test_2.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[8]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
        end
      end
    end

    describe "#delete_old_nodes(xml_doc, sitemap_name)" do
      before(:each) { system("cp spec/fixtures/sitemap_delete.xml spec/sitemap_delete.xml")}
      after(:each)  { system("rm spec/sitemap_delete.xml") }
      subject(:result) { updater.delete_old_nodes(doc, name) }
      let(:doc)        { Nokogiri::XML(File.open("spec/sitemap_delete.xml")) }
      let(:name)       { "sitemap_delete" }
      context "when given args correctly" do
        it "deletes the args(sitemap_name) nodes" do
          expect(doc.search("sitemapindex/sitemap").size).to eq(6)
          expect(result.search("sitemapindex/sitemap").size).to eq(1)
        end
        it "keeps other sitemaps nodes" do
          expect(doc.search("sitemapindex/sitemap[6]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test.xml.gz"
          )
          expect(doc.search("sitemapindex/sitemap[6]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
          expect(result.search("sitemapindex/sitemap[1]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[1]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
        end
      end
    end

    describe "#add_new_nodes(start_time, xml_doc, toppage_url, sitemap_paths)" do
      before(:each) { system("cp spec/fixtures/sitemap_add.xml spec/sitemap_add.xml")}
      after(:each)  { system("rm spec/sitemap_add.xml") }
      subject(:result) { updater.add_new_nodes(time, doc, url, paths) }
      let(:time)       { Time.now }
      let(:doc)        { Nokogiri::XML(File.open("spec/sitemap_add.xml")) }
      let(:url)        { "http://www.example.com/" }
      let(:paths)      { ["/home/sitemaps/sitemap_test.xml.gz", "/home/sitemaps/sitemap_test_1.xml.gz"] }
      context "when given args correctly" do
        it "keeps other sitemaps nodes" do
          expect(result.search("sitemapindex/sitemap[1]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_example.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[1]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
        end
        it "adds the new sitemaps nodes" do
          expect(result.search("sitemapindex/sitemap").size).to eq(3)
          expect(result.search("sitemapindex/sitemap[2]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[2]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
          expect(result.search("sitemapindex/sitemap[3]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test_1.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[3]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
        end
      end
    end

    describe "#add_sitemap_node(start_time, xml_doc, toppage_url, sitemap_path)" do
      subject(:result) { updater.add_sitemap_node(time, doc, url, path) }
      let(:time)       { Time.now }
      let(:doc)        { Nokogiri::XML(File.open("spec/fixtures/sitemap_add.xml")) }
      let(:url)        { "http://www.example.com/" }
      let(:path)       { "/home/sitemaps/sitemap_test.xml.gz" }
      context "when given args correctly" do
        it "keeps the old sitemaps node" do
          expect(result.search("sitemapindex/sitemap[1]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_example.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[1]/lastmod").inner_text).to eq("2019-01-01T00:00:00+09:00")
        end
        it "adds the new sitemaps node" do
          expect(result.search("sitemapindex/sitemap").size).to eq(2)
          expect(result.search("sitemapindex/sitemap[2]/loc").inner_text).to eq(
            "http://www.example.com/sitemap_test.xml.gz"
          )
          expect(result.search("sitemapindex/sitemap[2]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
        end
      end
    end

    describe "#sitemap_url(toppage_url, sitemap_path)" do
      subject(:result) { updater.sitemap_url(url, path) }
      let(:path)       { "/home/sitemaps/sitemap_test.xml.gz" }
      context "when given args correctly" do
        let(:url) { "http://www.example.com/" }
        it "returns [Str]the url of the sitemap" do
          expect(result).to eq("http://www.example.com/sitemap_test.xml.gz")
        end
      end
      context "when given args(toppage_url)'s last character isn't '/'" do
        let(:url) { "http://www.example.com" }
        it "returns [Str]the url of the sitemap" do
          expect(result).to eq("http://www.example.com/sitemap_test.xml.gz")
        end
      end
    end
  end
end
