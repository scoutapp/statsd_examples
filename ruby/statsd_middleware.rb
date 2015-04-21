# Rack Middleware to instrument applications via StatsD and the statsd-ruby Ruby gem.
#
# To use: 
# * add 'statsd-ruby' to your Gemfile
# * include this file in your app
# * in your app initialization, add: "use StatsdInstrument::Middleware"

require 'statsd-ruby'
STATSD = Statsd.new 'localhost', 8125
module StatsdInstrument
	class Middleware
		attr_accessor :app, :max_size, :except

		def initialize(app)
			@app = app
		end

		def call(env)
			(status, headers, body), response_time = call_with_timing(env)
			STATSD.timing("response",response_time)
			STATSD.increment("response_codes.#{status.to_s.gsub(/\d{2}$/,'xx')}")
			# Rack response
			[status, headers, body]
		end

		def call_with_timing(env)
			start = Time.now
			result = @app.call(env)
			[result, ((Time.now - start) * 1000).round]
		end
	end
end