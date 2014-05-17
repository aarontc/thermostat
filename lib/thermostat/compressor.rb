require 'aasm'
require 'timers'

module Thermostat
	class Compressor
		include AASM

		COOLDOWN_SECONDS = 1

		def initialize
			@cooled_down = false
			@timers = Timers.new
		end

		aasm do
			state :cooling_down, initial: true, before_enter: :begin_cooling_down
			state :idle
			state :running

			event :run do
				transitions from: :idle, to: :running
			end

			event :stop do
				transitions from: :running, to: :cooling_down
			end

			event :idle do
				transitions from: :cooling_down, to: :idle, guard: :cooled_down?
			end
		end


		private
		def begin_cooling_down
			@cooldown_timer = @timers.after(COOLDOWN_SECONDS) { finish_cooling_down }
		end

		def finish_cooling_down
			@cooled_down = true
			if may_idle?
				idle
			end
		end

		def cooled_down?
			@cooled_down
		end
	end
end
