vcl 4.1;
import std;

backend backend_a {
    .host = "backend-a";
    .port = "80";
}

backend backend_b {
    .host = "backend-b";
    .port = "80";
}

sub vcl_recv {
    # Default values
    set req.http.X-Experiment = "NONE";

    # Check for cookie
    if (req.http.Cookie ~ "experiment=B") {
        set req.http.X-Experiment = "B";
        set req.backend_hint = backend_b;
    } else {
        set req.http.X-Experiment = "A";
        set req.backend_hint = backend_a;
    }

    # Assign if missing
    if (req.http.X-Experiment == "NONE") {
        # 40% chance of going to B
        if (std.random(0, 100) < 40) {
            set req.http.X-Experiment = "B";
            set req.backend_hint = backend_b;
        } else {
            set req.http.X-Experiment = "A";
            set req.backend_hint = backend_a;
        }
    }
}

sub vcl_deliver {
    # Set cookie if not already set
    if (req.http.X-Experiment && !req.http.Cookie ~ "experiment=") {
        set resp.http.Set-Cookie = "experiment=" + req.http.X-Experiment + "; Path=/;";
    }

    # Debug headers
    set resp.http.X-Experiment = req.http.X-Experiment;
    set resp.http.X-Backend = req.backend_hint;
}