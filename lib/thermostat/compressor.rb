require 'aasm'

module Thermostat
	class Compressor
		include AASM

		aasm do
			state :cooling_down, initial: true
			state :idle
			state :running

			event :run do
				transitions from: :idle, to: :running
			end

			event :stop do
				transitions from: :running, to: :cooling_down
			end

			event :idle do
				transitions from: :cooling_down, to: :idle
			end
		end
	end
end
