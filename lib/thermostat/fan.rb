require 'aasm'

class Fan
	include AASM

	aasm do
		state :idle, initial: true
		state :on
		state :on_timed

	end
end