require 'aasm'

class Fan
	include AASM

	aasm do
		state :idle, :initial => true
		state :running
		state :running_timed

		event :start do
			transitions :from => :idle, :to => :running
		end

		event :stop do
			transitions :from => :running, :to => :idle
		end
	end
end