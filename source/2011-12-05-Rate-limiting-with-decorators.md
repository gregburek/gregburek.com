---
title: Rate Limiting Function Calls in Python with a Decorator
---

source: [Stack Overflow "What's a good rate limiting algorithm?"](http://stackoverflow.com/a/667706/586172)

I making this into a post because I have found it so handy. Some web
APIs have rate limits on requests per minute or you may want to play nice
and not overwhelm the service. In Python, you can use this decorator to
rate limit a function that may handle the API access: 

<script
src="https://gist.github.com/1441055.js?file=rateLimitDecorator.py"></script>

This answer is simpler than setting up a queue system and is blocking,
which can be good for sequential jobs. 
