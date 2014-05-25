require_relative 'compressor'
require_relative 'three_speed_drying_fan'
require_relative 'tmp36_temperature_sensor'

module Thermostat
	class ThreeSpeedFanSingleStageCooler
		def initialize(ambient_temperature_sensor: nil, compressor: nil, fan: nil)
			# AC has one compressor and one fan with three speeds
			@ambient_temperature_sensor = ambient_temperature_sensor || Tmp36TemperatureSensor.new
			@compressor = compressor || Compressor.new
			@fan = fan || ThreeSpeedDryingFan.new
			#@evaporator_temperature_input = TemperatureSensor.new
			#@condenser_temperature_input = TemperatureSensor.new

			# Start a thread to handle state changes
			#@state_thread = Thread.new thread_function
			#@state_thread.abort_on_exception = true

			@compressor.add_observer self
			@fan.add_observer self
			@ambient_temperature_sensor.add_observer self
		end

		def run
			# Wait for thread pool to finish
			#@state_thread.join
		end

		def on_compressor_event(from: nil, to: nil)
			case to
				when :started
					@fan.start(:high)
				when :stopped
					@fan.start_drying
			end
		end

		def on_temperature_change(new_temperature: 0.0, old_temperature: 0.0)
			if new_temperature >= 20.5
				want_cooling = true
			elsif new_temperature <= 19.5
				want_cooling = false
			end
		end


		def want_cooling=(value)
			if value
				@compressor.start
			else
				@compressor.stop
			end
		end


		def update(*args)
			$logger.debug "#{self}: update(#{args.inspect})"
		end
	end
end
