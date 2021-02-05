require "sitemap_updater/version"
require "errors"
require "sitemaps/creator"
require "sitemapindex/updater"

module SitemapUpdater
  class Cont
    # @params(Str, Str)
    # [Str]the absolute path of the directory where sitemaps locates
    # [Str]the name of the sitemap file
    def initialize(sitemaps_dir, sitemap_name)
      @start_time   = Time.now
      @sitemaps_dir = sitemaps_dir
      @sitemap_name = sitemap_name
    end

    # create the sitemap files & update the sitemapindex file
    # @params(Arr, Str, Str, Str, Str)
    # [Arr]URLs to be included in the sitemap file
    # [Str]the frequency the URLs changes,
    #      select from "always", "hourly", "daily", "weekly", "monthly", "yearly", "never"
    # [Str]the priority of the URLs, select from "0.0" ~ "1.0"
    def update(urls, sitemapindex_path, toppage_url, freq = nil, prio = nil)
      conds         = { "frequency" => freq, "priority" => prio }
      sitemap_paths = Sitemaps::Creator.create_sitemaps(@start_time, @sitemaps_dir, @sitemap_name, urls, conds)
      Sitemapindex::Updater.
        update_sitemapindex(@start_time, sitemapindex_path, sitemap_name, sitemap_paths, toppage_url)
    end

    # only create the sitemap files, not update the sitemapindex file
    # @params(Arr, Str, Str)
    # [Arr]URLs to be included in the sitemap file
    # [Str]the frequency the URLs changes,
    #      select from "always", "hourly", "daily", "weekly", "monthly", "yearly", "never"
    # [Str]the priority of the URLs, select from "0.0" ~ "1.0"
    def only_create_sitemaps(urls, freq = nil, prio = nil)
      conds = { "frequency" => freq, "priority" => prio }
      Sitemaps::Creator.create_sitemaps(@sitemaps_dir, @sitemap_name, urls, conds)
    end
  end

  class Error < StandardError; end
end
