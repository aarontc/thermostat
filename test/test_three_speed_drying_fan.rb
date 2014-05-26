require_relative 'time_machine'

require 'thermostat/three_speed_drying_fan'

class TestThreeSpeedDryingFan < TimeMachine
	def setup
		super

		@uut = Thermostat::ThreeSpeedDryingFan.new timers: @timers
	end


	def test_timed_drying_to_idle_transition
		assert @uut.idle?, 'Fan did not start idle'

		@uut.start_drying 120
		assert @uut.running?, 'Fan did not start running for drying phase'

		fast_forward 120
		assert @uut.idle?, 'Fan did not return to idle state automatically'
	end
end
