;(function ($, window, document, undefined) {
  $(document).on('click', 'a', function() {
    var href = $(this).attr('href');
    var label = $(this).text()
    var internalHost = new RegExp('/' + window.location.host + '/');

    // Track outgoing links
    if (!internalHost.test(href) && href.indexOf('http') == 0) {
      _gaq.push(['_trackEvent', 'Outgoing Links', href, label]);
    }

    if (href.indexOf('mailto:') >= 0) {
      _gaq.push(['_trackEvent', 'Mailto', href, label]);
    }
  });
})( jQuery, window, document);
