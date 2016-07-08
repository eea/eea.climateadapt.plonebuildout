# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import std;
import directors;


########backend default {
########    .host = "127.0.0.1";
########    .port = "8000";
########}

backend mil0101 {
    .host = "10.128.0.39";
    .port = "8001";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0102 {
    .host = "10.128.0.39";
    .port = "8002";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0103 {
    .host = "10.128.0.39";
    .port = "8003";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0104 {
    .host = "10.128.0.39";
    .port = "8004";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}


backend mil0201 {
    .host = "10.128.0.41";
    .port = "8001";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0202 {
    .host = "10.128.0.41";
    .port = "8002";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0203 {
    .host = "10.128.0.41";
    .port = "8003";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0204 {
    .host = "10.128.0.41";
    .port = "8004";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}


backend mil0301 {
    .host = "10.128.0.44";
    .port = "8001";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0302 {
    .host = "10.128.0.44";
    .port = "8002";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0303 {
    .host = "10.128.0.44";
    .port = "8003";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}
backend mil0304 {
    .host = "10.128.0.44";
    .port = "8004";
    .probe = {
         .url = "/varnish_probe";
         .interval = 5s;
         .timeout = 2s;
         .window = 5;
         .threshold = 3;
    }
}

sub vcl_init {
    new cluster1 = directors.round_robin();
    #new cluster1 = directors.hash();

    cluster1.add_backend(mil0101);
    cluster1.add_backend(mil0102);
    cluster1.add_backend(mil0103);
    cluster1.add_backend(mil0104);

    cluster1.add_backend(mil0201);
    cluster1.add_backend(mil0202);
    cluster1.add_backend(mil0203);
    cluster1.add_backend(mil0204);

    cluster1.add_backend(mil0301);
    cluster1.add_backend(mil0302);
    cluster1.add_backend(mil0303);
    cluster1.add_backend(mil0304);

}

sub vcl_recv {
    set req.backend_hint = cluster1.backend();
    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }
    if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }
    if (req.method != "GET" && req.method != "HEAD") {
        /* We only deal with GET and HEAD by default */
        return (pass);
    }
    if (req.http.Authorization || req.http.Cookie) {
        /* Not cacheable by default */
        return (pass);
    }

    if (req.method == "GET" && req.http.cookie) {
       return(hash);
    }

    # javascript + css
    if (req.method == "GET" && req.url ~ "\.(js|css)") {
        return(hash);
    }

    ## images
    if (req.method == "GET" && req.url ~ "\.(gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf)$") {
        return(hash);
    }

    ## multimedia
    if (req.method == "GET" && req.url ~ "\.(svg|swf|ico|mp3|mp4|m4a|ogg|mov|avi|wmv)$") {
        return(hash);
    }

    ## xml
    if (req.method == "GET" && req.url ~ "\.(xml)$") {
        return(hash);
    }

    ## for some urls or request we can do a pass here (no caching)
    if (req.method == "GET" && (req.url ~ "aq_parent" || req.url ~ "manage$" || req.url ~ "manage_workspace$" || req.url ~ "manage_main$")) {
        return(pass);
    }

    return (hash);
}
 
sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    # set bereq.http.connection = "close";
    # here.  It is not set by default as it might break some broken web
    # applications, like IIS with NTLM authentication.
    return (pipe);
}
 
sub vcl_pass {
    return (fetch);
}
 
#   sub vcl_hash {
#       hash_data(req.url);
#       if (req.http.host) {
#           hash_data(req.http.host);
#       } else {
#           hash_data(server.ip);
#       }
#       return (lookup);
#   }
 
sub vcl_hit {
    return (deliver);
}
 
sub vcl_miss {
    return (fetch);
}
 
sub vcl_backend_response {
    if (beresp.http.Set-Cookie) {
        return(deliver);
    }

    if (beresp.ttl < 120s) {
        std.log("Adjusting TTL");
        set beresp.ttl = 120s;
    }

    if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
        /*
         * Mark as "Hit-For-Pass" for the next 2 minutes
         */
        set beresp.ttl = 120 s;
        set beresp.uncacheable = true;
        # return (hit_for_pass);
        # varnish vcl 4 compat
    }
    return (deliver);
}
 
sub vcl_deliver {
    return (deliver);
}
 
sub vcl_backend_error {
#   set resp.http.Content-Type = "text/html; charset=utf-8";
#   set resp.http.Retry-After = "5";
#       synthetic( {"
#   <?xml version="1.0" encoding="utf-8"?>
#   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
#   <html>
#     <head>
#       <title>"} + obj.status + " " + obj.reason + {"</title>
#     </head>
#     <body>
#       <h1>Error "} + obj.status + " " + obj.reason + {"</h1>
#       <p>"} + obj.reason + {"</p>
#       <h3>Guru Meditation:</h3>
#       <p>XID: "} + req.xid + {"</p>
#       <hr>
#       <p>Varnish cache server</p>
#     </body>
#   </html>
#   "});
    synthetic( {"Error from backend"} );
    return (deliver);
}
 
sub vcl_init {
    return (ok);
}

sub vcl_fini {
    return (ok);
}
