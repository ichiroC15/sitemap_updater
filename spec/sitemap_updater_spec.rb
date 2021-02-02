require "spec_helper"
require "pry-byebug"
require "timecop"

RSpec.describe SitemapUpdater do
  describe "SitemapUpdater::Cont" do
    let!(:time_freeze) { Timecop.freeze("2020-01-01") }
    let(:cont) { SitemapUpdater::Cont.new(dir, name) }
    let(:dir)        { "/home/sitemaps/"}
    let(:name)       { "sitemap_test" }

    describe "#initialize(sitemaps_dir, sitemap_name)" do
      subject(:result) { cont }
      it "has @start_time & @sitemaps_dir & @sitemap_name" do
        expect(result.instance_variable_get(:@start_time)).to eq(Time.now)
        expect(result.instance_variable_get(:@sitemaps_dir)).to eq("/home/sitemaps/")
        expect(result.instance_variable_get(:@sitemap_name)).to eq("sitemap_test")
      end
    end

    describe "#update(urls, sitemapindex_path, toppage_url, freq, prio)" do
      let!(:set_mock) do
        allow(Sitemaps::Creator).to receive(:create_sitemaps).with(time, dir, name, urls, conds)
        allow(Sitemapindex::Updater).to receive(:update_sitemapindex).with(time, path, name, paths, url)
      end
      subject(:result) { cont.update(urls, path, url, freq, prio) }
      let(:time)  { Time.now }
      let(:urls)  { ["url0", "url1", "url2"] }
      let(:path)  { "spec/sitemap.xml.gz" }
      let(:url)   { "http://www.example.com/" }
      let(:freq)  { "daily" }
      let(:prio)  { "0.5" }
      let(:conds) { { "frequency" => freq, "priority" => prio } }
      let(:paths) { ["/home/sitemaps/sitemap_test.xml.gz"] }
      it "calls #create_sitemaps" do
        allow(Sitemaps::Creator).to receive(:create_sitemaps).with(time, dir, name, urls, conds).once
      end
      it "calls #update_sitemapindex" do
        allow(Sitemapindex::Updater).to receive(:update_sitemapindex).with(time, path, name, paths, url).once
      end
    end

    describe "#only_create_sitemaps(urls, freq, prio)" do
      let!(:set_mock) do
        allow(Sitemaps::Creator).to receive(:create_sitemaps).with(time, dir, name, urls, conds)
      end
      subject(:result) { cont.only_create_sitemaps(urls, freq, prio) }
      let(:time)  { Time.now }
      let(:urls)  { ["url0", "url1", "url2"] }
      let(:conds) { { "frequency" => freq, "priority" => prio } }
      let(:freq)  { "daily" }
      let(:prio)  { "0.5" }
      it "calls #create_sitemaps" do
        allow(Sitemaps::Creator).to receive(:create_sitemaps).with(time, dir, name, urls, conds).once
      end
    end
  end

  it "has a version number" do
    expect(SitemapUpdater::VERSION).not_to be nil
  end
end
