!function(t,n,i){t(i).on("click","a",function(){var i=t(this).attr("href"),e=t(this).text();new RegExp("/"+n.location.host+"/").test(i)||0!=i.indexOf("http")||_gaq.push(["_trackEvent","Outgoing Links",i,e]),i.indexOf("mailto:")>=0&&_gaq.push(["_trackEvent","Mailto",i,e])})}(jQuery,window,document);