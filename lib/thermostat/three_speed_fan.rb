require_relative 'fan'

module Thermostat
	class ThreeSpeedFan < Fan
		def speed
			@speed
		end

		def set_speed(speed)
			unless @speed === speed
				old_speed = @speed
				@speed = speed
				changed
				notify_observers self, Time.now, {fan_speed_set: {current: @speed, previous: old_speed}}
			end
		end
	end
end

