require 'timers'

require_relative 'observable_state_machine'

module Thermostat
	class Compressor < ObservableStateMachine
		def initialize(cooldown_seconds: nil, timers: nil)
			@cooldown_seconds = cooldown_seconds || 3 * 60
			@cooled_down = false
			@timers = timers || Timers.new

			super()
		end

		aasm do
			state :cooling_down, initial: true, before_enter: :begin_cooling_down
			state :idle
			state :running

			event :start do
				transitions from: :idle, to: :running, on_transition: :on_transition
			end

			event :stop do
				transitions from: :running, to: :cooling_down, on_transition: :on_transition
			end

			event :idle do
				transitions from: :cooling_down, to: :idle, guard: :cooled_down?, on_transition: :on_transition
			end
		end


		private
		def begin_cooling_down
			@cooled_down = false
			@cooldown_timer = @timers.after(@cooldown_seconds) { finish_cooling_down }
		end

		def finish_cooling_down
			@cooled_down = true
			idle
		end

		def cooled_down?
			@cooled_down
		end
	end
end
