require 'listen'

require_relative 'temperature_sensor'

module Thermostat
	class FileReaderTemperatureSensor < TemperatureSensor

		def initialize(path: nil)
			@current_value = 0.0
			@path = path
			raise ArgumentError, 'path must be defined' if @path.nil?

			super()
			@listener = Listen.to @path, &method(:listener_callback)
			@listener.start
		end

		def new_value(value)
			if (value - @current_value).abs > 0.01
				@current_value = value
				changed
				notify_observers self, Time.now, {current_value: @current_value}
			end
		end


		private
		def listener_callback(modified, added, removed)
			value = File.read(@path)
			new_value value
		end
	end
end
