require "spec_helper"
require "pry-byebug"
require "nokogiri"
require "timecop"
require "tilt"
require "zlib"

RSpec.describe Sitemaps::Creator do
  describe "Sitemaps::Creator" do
    let!(:time_freeze) { Timecop.freeze("2020-01-01") }
    let(:creator) { Sitemaps::Creator }

    describe "#create_sitemaps(start_time, sitemaps_dir, sitemap_name, urls, conds = {})" do
      after(:each) { system("rm spec/test_sitemap*") }
      subject(:result)   { creator.create_sitemaps(start_time, sitemaps_dir, sitemap_name, urls, conds) }
      let(:start_time)   { Time.now }
      let(:sitemaps_dir) { "spec/" }
      let(:sitemap_name) { "test_sitemap" }
      let(:urls)         { ["url0", "url1", "url2"] }
      let(:conds)        { { "frequency" => "daily", "priority" => "0.5" } }
      # normally
      context "when given args correctly" do
        it "returns [Arr]the paths of the created sitemaps" do
          expect(result).to eq(["spec/test_sitemap.xml.gz"])
        end
      end
      context "when given args(urls).length is over MAX_NUM_URLS" do
        let(:change_max_num_urls) { stub_const("Sitemaps::Creator::MAX_NUM_URLS", 2) }
        let(:urls)                { ["url0", "url1", "url2", "url3", "url4"] }
        it "returns [Arr]the paths of the created sitemaps" do
          change_max_num_urls
          expect(result).to eq(["spec/test_sitemap.xml.gz", "spec/test_sitemap_1.xml.gz","spec/test_sitemap_2.xml.gz"])
        end
      end
      #exceptionally
      context "when the specified directory as args(sitemaps_dir) does not exist" do
        let(:sitemaps_dir) { "spec/unexistdir" }
        it "raise SitemapsCreateError" do
          expect{ result }.to raise_error(SitemapsCreateError)
          expect{ result }.to raise_error("The specified directory does not exist.")
        end
      end
      context "when the given args(urls) is empty" do
        let(:urls) { [] }
        it "raise SitemapsCreateError" do
          expect{ result }.to raise_error(SitemapsCreateError)
          expect{ result }.to raise_error("The given URL array is empty.")
        end
      end
    end

    describe "#create_gz_sitemap(start_time, sitemaps_dir, sitemap_name, urls, conds, idx)" do
      after(:each) { system("rm spec/test_sitemap.xml.gz") }
      subject(:result)   { execute }
      let(:execute)      { creator.create_gz_sitemap(start_time, sitemaps_dir, sitemap_name, urls, conds, idx) }
      let(:start_time)   { Time.now }
      let(:sitemap_name) { "test_sitemap" }
      let(:sitemaps_dir) { "spec/" }
      let(:urls)         { ["url0", "url1", "url2"] }
      let(:conds)        { { "frequency" => "daily", "priority" => "0.5" } }
      let(:idx)          { 0 }
      context "when given args correctly" do
        it "returns [Str]the path of the created sitemaps" do
          expect(result).to eq("spec/test_sitemap.xml.gz")
        end
        it "creates the xml files of the sitemap" do
          expect(File.exist?("spec/test_sitemap.xml.gz")).to be_falsy
          execute
          expect(File.exist?("spec/test_sitemap.xml.gz")).to be_truthy
        end
      end
    end

    describe "#sitemap_path(dir, name, idx)" do
      subject(:result) { creator.sitemap_path(dir, name, idx) }
      let(:dir)        { "/home/sitemaps/"}
      let(:name)       { "sitemaptest"}
      context "when args(idx) = 0" do
        let(:idx) { 0 }
        it "returns [Str]unnumbered file name" do
          expect(result).to eq("/home/sitemaps/sitemaptest.xml.gz")
        end
      end
      context "when args(idx) != 0" do
        let(:idx) { 20 }
        it "returns [Str]numbered file name" do
          expect(result).to eq("/home/sitemaps/sitemaptest_20.xml.gz")
        end
      end
    end

    describe "#render_xml(time, urls, conds)" do
      subject(:result) { Nokogiri::XML(creator.render_xml(time, urls, conds)) }
      let(:time)       { Time.now }
      let(:urls)       { ["url0", "url1", "url2"] }
      let(:conds)      { { "frequency" => frequency, "priority" => priority } }
      let(:frequency)  { "daily" }
      let(:priority)   { "0.5" }
      context "when given args correctly" do
        it "returns rendered xml" do
          expect(result.search("urlset/url").size).to eq(3)
          expect(result.search("urlset/url[1]/loc").text).to eq("url0")
          expect(result.search("urlset/url[1]/lastmod").inner_text).to eq("2020-01-01T00:00:00+09:00")
          expect(result.search("urlset/url[1]/changefreq").inner_text).to eq("daily")
          expect(result.search("urlset/url[1]/priority").inner_text).to eq("0.5")
          expect(result.search("urlset/url[2]/loc").text).to eq("url1")
          expect(result.search("urlset/url[3]/loc").text).to eq("url2")
        end
      end
    end
  end
end
