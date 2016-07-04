---
title: Stream a remote file to S3
date: 2015-06-20 17:07 PDT
tags: ruby, aws, s3, upload, open-uri
---

While attempting to work with my gif collection, I was experimenting with how
to capture gifs from the internet and place them into a S3 bucket for later
use. I found that it was possible to stream a remote file directly to S3.

Using the `aws-sdk` [gem version 2](https://github.com/aws/aws-sdk-ruby), and
the `open-uri` module of the [ruby standard
library](http://ruby-doc.org/stdlib-2.2.2/libdoc/open-uri/rdoc/OpenURI.html),
one can link the two IO streams together fairly easily:

READMORE

```ruby
require 'aws-sdk'
require 'open-uri'
require 'sequel'
require 'digest/md5'

class RemoteFile
  def initialize(url)
    @url = url
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  end

  def md5_hash
    Digest::MD5.hexdigest(@url)
  end

  def obj(bucket_name)
    s3.bucket(bucket_name).object(md5_hash)
  end

  def url
    URI.parse(URI.escape(@url))
  end

  def upload_to_s3(bucket_name:)
    open(url) do |file|
      obj(bucket_name).put(body: file)
    end
  end
end

RemoteFile.new('https://i.imgur.com/DO3Hr4A.gif')
  .upload_to_s3(bucket_name: 'mah_gifs')

```

This code snippet assumes you have `ENV['AWS_ACCESS_KEY_ID']` and
`ENV['AWS_SECRET_ACCESS_KEY']` set.

