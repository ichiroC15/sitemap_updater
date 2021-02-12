# SitemapUpdater
This Gem allows to create sitemaps for a given URL.
Each sitemap consists of up tp 5000 URLs and the file name is "the specified sitemap name + _file number".
You can also add the information from the sitemap you have created to the index file.
The latest version is 0.1.0.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sitemap_updater'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sitemap_updater

## Usage
If you have an existing sitemaps in the directory `/home/sitemaps/` and
you want to create sitemaps file called `item.xml.gz`, you can specify the arguments as fellows.

```ruby
  updatercont = SitemapUpdater::Cont.new("/home/sitemaps/", "item")
```

Prepare an array of URLs that you want to include in the sitemaps.
For example, if you want to register the URLs of all "items" as "https://www.example.com/item/[item_id]",
set the argument `urls` as follows.
```ruby
  item_ids = Item.all.pluck(:item_id)
  urls     = item_ids.map{ |id| "https://www.example.com/item/#{id}"}
```

If you'd like create sitemaps to add those information to the sitemap index file (sitemap.xml.gz), you can do the following.
When the path of the sitemap index file (sitemap.xml.gz) is `/home/sitemap.xml.gz` and
the URL of the web toppage is "http://www.example.com/",
you can specify the arguments as follows.
```ruby
  updatercont.update(urls, "/home/sitemap.xml.gz", "http://www.example.com/")
```

You can also set the frequency and priority of URL updates.
The default value for the frequency is "daily" and for the priority is "0.5".
For more information on the frequency and priority of updates, please see the [official page](https://www.sitemaps.org/ja/protocol.html).
```ruby
  updatercont.update(urls, sitemapindex_path, toppage_url, "daily", "0.5")
```

If you only want to create a sitemap and not register it in the sitemap index file (sitemap.xml.gz), you can do the following.
```ruby
  updatercont.only_create_sitemaps(urls)
```

You can also set the frequency and priority of URL updates.
The default value for the frequency is "daily" and for the priority is "0.5".
For more information on the frequency and priority of updates, please see the [official page](https://www.sitemaps.org/ja/protocol.html).
```ruby
  updatercont.only_create_sitemaps(urls, "daily", "0.5")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ichiroC15/sitemap_updater. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ichiroC15/sitemap_updater/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SitemapUpdater project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sitemap_updater/blob/master/CODE_OF_CONDUCT.md).
