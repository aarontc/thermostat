require 'aasm'
require 'timers'

class Fan
	include AASM

	aasm do
		state :idle, initial: true
		state :running
		state :running_timed

		event :start do
			transitions from: :idle, to: :running
		end

		event :stop do
			transitions from: :running, to: :idle, guard: :can_turn_off?
		end
	end

	def initialize
		@duration = nil
	end

	def can_turn_off?
		(@duration.nil?) ? true : false
	end

	def start_for_duration(duration)
		@duration = duration

	end

	#test code that will leave
	def wait_for_a_while(timer)
		@passed = false
		puts 'starting to wait'
		five_sec = timer.after(5) { some_proc true }
		timer.wait
		@passed
	end

	def some_proc result
		@passed = result
	end

end