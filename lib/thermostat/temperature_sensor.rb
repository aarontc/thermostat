require 'observer'

module Thermostat
	class TemperatureSensor
		include Observable
		attr_reader :current_value

		# Number of seconds to allow changes below the smoothing threshold to go unannounced
		SQUELCH_TIME = 2

		# Readings which differ from the previous value by this amount or less will be ignored, unless no change greater than this threshold has occurred for +SQUELCH_TIME+
		SMOOTHING_THRESHOLD = 0.001


		def initialize
			@current_value = 0.0
			@current_value_at = Time.at 0
		end


		protected
		def new_value(value)
			if (value - @current_value).abs >= SMOOTHING_THRESHOLD or Time.now - @current_value_at >= SQUELCH_TIME
				@current_value = value
				@current_value_at = Time.now
				changed
				notify_observers self, @current_value_at, { current_value: @current_value }
			end
		end
	end
end
