require "sitemap_updater/version"

class Error < StandardError
  attr_reader :cause

  def initialize(error)
    @cause = nil

    if error.respond_to?(:backtrace) && error.respond_to?(:message)
      super(error.message)
      @cause = error
    else
      super(error.to_s)
    end
  end

  def backtrace
    if @cause
      @cause.backtrace
    else
      super
    end
  end
end

# Error class for problems in generating sitemaps
class SitemapsCreateError < Error; end
# Error class for problems in updating sitemapindex
class SitemapindexUpdateError < Error; end
