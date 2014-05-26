require 'observer'

module Thermostat
	class TemperatureSensor
		include Observable

		attr_reader :current_value

		def initialize
			@current_value = 0.0

			super
		end

		def new_value(value)
			if (value - @current_value).abs > 0.01
				@current_value = value
				changed
				notify_observers self, Time.now, {current_value: @current_value}
			end
		end
	end
end
