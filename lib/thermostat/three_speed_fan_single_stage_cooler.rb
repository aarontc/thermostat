require_relative 'compressor'
require_relative 'three_speed_drying_fan'
require_relative 'tmp36_temperature_sensor'

module Thermostat
	class ThreeSpeedFanSingleStageCooler
		def initialize(ambient_temperature_sensor: nil, compressor: nil, fan: nil, timers: nil)
			@timers = timers || Timers.new

			# AC has one compressor and one fan with three speeds
			@ambient_temperature_sensor = ambient_temperature_sensor || Tmp36TemperatureSensor.new(timers: @timers)
			@compressor = compressor || Compressor.new(timers: @timers)
			@fan = fan || ThreeSpeedDryingFan.new(timers: @timers)
			#@evaporator_temperature_sensor = TemperatureSensor.new
			#@condenser_temperature_sensor = TemperatureSensor.new


			@compressor.add_observer self, :on_compressor_state_change
			@fan.add_observer self, :on_fan_state_change
			@ambient_temperature_sensor.add_observer self, :on_temperature_change
		end


		def on_compressor_state_change(source, time, data)
			case data[:aasm_transition][:to]
				when :running
					$logger.debug 'Compressor is now running'
					@fan.set_speed :high
					@fan.start unless @fan.running?
				when :cooling_down
					$logger.debug 'Compressor is now cooling down'
					@fan.start_drying 120 if data[:aasm_transition][:from] === :running
				when :idle
					$logger.debug 'Compressor is now idle'
				else
					raise ArgumentError, "on_compressor_state_change: Invalid :to state"
			end
		end


		def on_fan_state_change(source, time, data)
			to = data[:aasm_transition] ? data[:aasm_transition][:to] : source.aasm.current_state
			$logger.debug "Fan is now #{to}, speed #{source.speed}"
		end


		def on_temperature_change(source, time, data)
			new_temperature = data[:current_value]
			$logger.debug "Temperature is now #{new_temperature}"
			if new_temperature >= 20.5
				self.want_cooling = true
			elsif new_temperature <= 19.5
				self.want_cooling = false
			end
		end


		def want_cooling=(value)
			if value
				$logger.debug "Trying to start compressor (may_start == #{@compressor.may_start?})"
				@compressor.start if @compressor.may_start?
			else
				@compressor.stop if @compressor.running?
			end
		end
	end
end
