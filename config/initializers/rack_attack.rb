class Rack::Attack
  # Set cache store for throttling - local Redis without authentication
  redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } + '/cache'
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url, expires_in: 480.minutes)

  # Set custom error when throttled
  Rack::Attack.throttled_response = lambda do |env|
    # Using 503 because it may make attacker think that they have successfully DOSed the site
    [503, {}, ['You are doing that too many times. Try again later.']]
  end

  # Set custom error when blocked
  Rack::Attack.blocklisted_response = lambda do |env|
    # Using 503 because it may make attacker think that they have successfully DOSed the site
    [503, {}, ['Service unavailable.']]
  end

  # Disable throttling criteria if running in test env
  unless Rails.env.test? || Rails.env.development?
    # Block suspicious requests for operating system files, WordPress specific paths - general automatic pentest stuff
    # After 1 blocked request, block all requests from that IP for 24 hours.
    Rack::Attack.blocklist("Malicious query") do |req|
      # `filter` returns truthy value if request fails, or if it's from a previously banned IP
      Rack::Attack::Fail2Ban.filter("malicious-#{req.ip}", maxretry: 1, findtime: 10.minutes, bantime: 24.hours) do
        # The count for the IP is incremented if the return value is truthy
        CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
        CGI.unescape(req.query_string) =~ %r{/bin/sh} ||
        CGI.unescape(req.query_string) =~ %r{boot.ini} ||
        req.path.include?('/etc/passwd') ||
        req.path.include?('/bin/sh') ||
        req.path.include?('boot.ini') ||
        req.path.include?('wp-admin') ||
        req.path.include?('wp-login')
      end
    end

    # Throttle IPs to a certain number of requests in a time period
    throttle("General request limit", limit: 100, period: 5.minutes) do |req|
      req.ip
    end
  end
end
