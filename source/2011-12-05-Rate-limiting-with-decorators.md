---
title: Rate Limiting Function Calls in Python with a Decorator
---

source: [Stack Overflow "What's a good rate limiting algorithm?"](http://stackoverflow.com/a/667706/586172)

I making this into a post because I have found it so handy. Some web
APIs have rate limits on requests per minute or you may want to play nice
and not overwhelm the service. In Python, you can use this decorator to
rate limit a function that may handle the API access: 

```python
import time

def RateLimited(maxPerSecond):
    minInterval = 1.0 / float(maxPerSecond)
    def decorate(func):
        lastTimeCalled = [0.0]
        def rateLimitedFunction(*args,**kargs):
            elapsed = time.clock() - lastTimeCalled[0]
            leftToWait = minInterval - elapsed
            if leftToWait>0:
                time.sleep(leftToWait)
            ret = func(*args,**kargs)
            lastTimeCalled[0] = time.clock()
            return ret
        return rateLimitedFunction
    return decorate

@RateLimited(2)  # 2 per second at most
def PrintNumber(num):
    print num

if __name__ == "__main__":
    print "This should print 1,2,3... at about 2 per second."
    for i in range(1,100):
        PrintNumber(i)
```

This answer is simpler than setting up a queue system and is blocking,
which can be good for sequential jobs. 
