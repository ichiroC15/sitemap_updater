require_relative 'lib/sitemap_updater/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemap_updater"
  spec.version       = SitemapUpdater::VERSION
  spec.authors       = ["ichiroC15"]
  spec.email         = ["ichiro.n.c15@gmail.com"]

  spec.summary       = "This Gem allows to create sitemaps for a given URL."
  spec.description   = "This Gem allows to create sitemaps for a given URL. Each sitemap consists of up tp 5000 URLs and the file name is 'the specified sitemap name + _file number'. You can also add the information from the sitemap you have created to the index file."
  spec.homepage      = "https://github.com/ichiroC15/sitemap_updater"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ichiroC15/sitemap_updater"
  spec.metadata["changelog_uri"] = "https://github.com/ichiroC15/sitemap_updater"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
