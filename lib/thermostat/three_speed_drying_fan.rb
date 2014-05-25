require_relative 'fan'

module Thermostat
	class ThreeSpeedDryingFan < Fan
		COOL_SPEED = :high
		DRY_SPEED = :medium
		FAN_SPEED = :low

		def start_drying(duration)
			@dry_duration = duration
			if @dry_duration > 0
				start unless started?
			end
		end
	end
end
