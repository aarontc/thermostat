require 'timers'

require_relative 'observable_state_machine'

module Thermostat
	class Fan < ObservableStateMachine
		def initialize(timers: nil)
			@timers = timers || Timers.new

			super()
		end

		aasm do
			state :idle, :initial => true
			state :running

			event :start do
				transitions from: :idle, to: :running, on_transition: :on_transition
			end

			event :stop do
				transitions from: :running, to: :idle, on_transition: :on_transition
			end
		end
	end
end
