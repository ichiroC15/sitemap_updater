require "sitemap_updater/version"

module Sitemapindex
  class Updater
    ISO_8601     = "%Y-%m-%dT%H:%M:%S%:z"
    class << self
      # @params(Time, Str, Str, Arr, Str)
      # [Time]the time when the process started
      # [Str]the absolute path of the sitemapindex
      # [Str]the name of the sitemap file
      # [Arr]paths of the sitemaps created newly
      # @return File
      # the updated sitemapindex file
      def update_sitemapindex(start_time, sitemapindex_path, sitemap_name, sitemap_paths, toppage_url)
        raise SitemapindexUpdateError, "The sitemap index file does not exist at the specified path." unless File.exist?(sitemapindex_path)

        xml_doc         = Zlib::GzipReader.open(sitemapindex_path) { |gz| Nokogiri::XML(gz) }
        deleted_xml_doc = delete_old_nodes(xml_doc, sitemap_name)
        added_xml_doc   = add_new_nodes(start_time, deleted_xml_doc, toppage_url, sitemap_paths)
        Zlib::GzipWriter.open(sitemapindex_path) { |gz| gz.puts(added_xml_doc.to_xml) }
      end

      # @params(object, Str)
      # object Nokogiri::XML
      # [Str]the name of the sitemap file
      # @return object
      # object Nokogiri::XML, deleted
      def delete_old_nodes(xml_doc, sitemap_name)
        xml_doc.search("sitemapindex/sitemap").each do |sitemap_node|
          if sitemap_node.at("loc").content.include?(sitemap_name)
            sitemap_node.remove
          end
        end
        xml_doc
      end

      def add_new_nodes(start_time, xml_doc, toppage_url, sitemap_paths)
        sitemap_paths.each do |sitemap_path|
          add_sitemap_node(start_time, xml_doc, toppage_url, sitemap_path)
        end
        xml_doc
      end

      def add_sitemap_node(start_time, xml_doc, toppage_url, sitemap_path)
        node            = Nokogiri::XML::Node.new("sitemap", xml_doc)
        loc             = Nokogiri::XML::Node.new("loc", xml_doc)
        lastmod         = Nokogiri::XML::Node.new("lastmod", xml_doc)
        loc.content     = sitemap_url(toppage_url, sitemap_path)
        lastmod.content = start_time.strftime(ISO_8601)
        node << loc << lastmod
        xml_doc.at("sitemapindex") << node
        xml_doc
      end

      def sitemap_url(toppage_url, sitemap_path)
        toppage_url = "#{toppage_url}/" unless toppage_url =~ /\/$/

        "#{toppage_url}#{sitemap_path.split('/').last}"
      end
    end
  end
end
