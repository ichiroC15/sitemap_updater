require "sitemap_updater/version"

module Sitemaps
  class Creator
    MAX_NUM_URLS = 5000
    ISO_8601     = "%Y-%m-%dT%H:%M:%S%:z"
    class << self
      # @params(Str, Str, Time, Arr, Str, Str)
      # [Str]the name of the sitemap file
      # [Str]the absolute path of the directory where sitemaps locates
      # [Arr]URLs to be included in the sitemap file
      # [Hash]the conditions of urls, keys = ["frequency", "priority"]
      # @return Arr
      # the paths of the created sitemaps
      def create_sitemaps(start_time, sitemaps_dir, sitemap_name, urls, conds)
        raise SitemapsCreateError, "The specified directory does not exist." unless Dir.exist?(sitemaps_dir)
        raise SitemapsCreateError, "The given URL array is empty." if urls.empty?

        sitemap_paths = []
        grouped_urls = urls.each_slice(MAX_NUM_URLS).to_a
        grouped_urls.each_with_index do |sliced_urls, idx|
          sitemap_paths << create_gz_sitemap(start_time, sitemaps_dir, sitemap_name, sliced_urls, conds, idx)
        end
        sitemap_paths
      end

      # @params(Time, Str, Str, Arr, Hash)
      # [Time]the time when the process started
      # [Str]the name of the sitemap file
      # [Str]the absolute path of the directory where sitemaps locates
      # [Arr]URLs to be included in the sitemap file, the max num is 5000
      # [Hash]the conditions of urls, keys = ["frequency", "priority"]
      # @return Str
      # the path of the created sitemap
      def create_gz_sitemap(start_time, sitemaps_dir, sitemap_name, urls, conds, idx)
        xml  = render_xml(start_time, urls, conds)
        path = sitemap_path(sitemaps_dir, sitemap_name, idx)
        Zlib::GzipWriter.open(path) do |gz|
          gz.puts(xml)
        end
        path
      end

      # @patams(Str, Str, Int)
      # [Str]the name of the sitemap file
      # [Str]the absolute path of the directory where sitemaps locates
      # @return Str
      # the numbered name of the sitemap file
      def sitemap_path(dir, name, idx)
        if idx == 0
          "#{dir}#{name}.xml.gz"
        else
          "#{dir}#{name}_#{idx}.xml.gz"
        end
      end

      # @params(Arr, Time, Str, Str)
      # [Arr]URLs to be included in the sitemap file
      # [Time]the current time
      # [Hash]the conditions of urls, keys = ["frequency", "priority"]
      #   ["frequency"]choose from "always", "hourly", "daily", "weekly", "monthly", "yearly" and "never"
      #   ["priority"]choose from "0.1" to "1.0"
      # @return [Str]the xml document of the sitemap
      # "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset ...</urlset>"
      def render_xml(time, urls, conds)
        erubi_template = Tilt.new(template)
        erubi_template.render(self,
                              urls:     urls,
                              time:     time.strftime(ISO_8601),
                              freq:     conds["frequency"] || "daily",
                              priority: conds["priority"]  || "0.5")
      end

      def template
        "lib/sitemaps/template.erb"
      end
    end
  end
end
