---
title: Moving site to Middleman
date: "2014-07-06"
tags:  [ meta, design, writing ]
---

This is me attempting to resurrect my blog after several years of silence. This
has also given me a chance to redesign things and adopt another static site
generator.

Octopress served me well, but I felt like it was difficult to grasp the
fundamentals and hard to pick up after a while away. I went looking for new site
framework and found [Middleman](http://middlemanapp.com/). I liked that it was
written in Ruby and I really liked the tutorials I found for it.

In particular, Julie Pagano's fantastic
[tutorial](http://juliepagano.com/blog/2013/11/10/site-redesign-using-middleman/)
was invaluable in getting me past a bunch of unexpected things.

The plugins I am using are:

- [middleman-blog](https://github.com/middleman/middleman-blog) for support of
  the article format
- [middleman-gh-pages](https://github.com/neo/middleman-gh-pages) for an easy
  GitHub pages integrated workflow
- [middleman-syntax](https://github.com/middleman/middleman-blog) for syntax
  highlighting of code snippets

Starting from a blank Gemfile, unfortunately, seemed to not give properly
rendered code syntax blocks.

An unmerged [PR](https://github.com/middleman/middleman-syntax/pull/42) appears
to address the problem, but I found that using Julie Pagano's
[Gemfile.lock](https://github.com/juliepagano/juliepagano.com/blob/master/Gemfile.lock)
also worked very well. I am very grateful that it was available.

The rest of the work was about adapting my strange icon color scheme into
something that doesn't repulse and offend. Mixed results, I would say.

Now that this is set up, I have high hopes to use this new system to write more
about technology and my experiences with it.

The code for this site now resides on [GitHub](https://github.com/gregburek/gregburek.com)
