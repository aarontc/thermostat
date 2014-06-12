require 'thermostat'

class WindowAirConditionerThermostat

	def initialize
		Thread.abort_on_exception = true
		@timers = Timers.new

		@compressor = Thermostat::Compressor.new timers: timers
		@fan = ThreeSpeedDryingFan.new timers: timers
		@temperature_input = Thermostat::Tmp36.new timers: timers

		@controller = Thermostat::ThreeSpeedFanSingleStageCooler.new ambient_temperature_sensor: @temperature_input, compressor: @compressor, fan: @fan, timers: @timers
	end

	def run
		# Wait for thread pool to finish
		@state_thread.join
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

	def thread_function

	end
end

WindowAirConditionerThermostat.new.run if $0 === __FILE__
