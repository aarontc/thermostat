require_relative 'three_speed_fan'

module Thermostat
	class ThreeSpeedDryingFan < ThreeSpeedFan
		COOL_SPEED = :high
		DRY_SPEED = :medium
		FAN_SPEED = :low


		def cancel_dry_timer
			@dry_timer.cancel unless @dry_timer.nil?
		end


		def on_transition(*args)
			cancel_dry_timer
			super
		end


		def start_drying(duration)
			cancel_dry_timer

			set_speed :medium
			start unless running?
			@dry_timer = @timers.after(duration) { finish_drying }
		end


		def finish_drying
			stop
		end
	end
end
