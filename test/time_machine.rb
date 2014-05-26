require_relative 'helper'

class TimeMachine < Minitest::Test
	def setup
		@current_offset = 0.0
		@timers = Timers.new

		stub(@timers).current_offset { @current_offset }
	end


	def fast_forward(seconds) @current_offset += seconds
		@timers.fire
	end
end
