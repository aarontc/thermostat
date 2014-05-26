require_relative 'time_machine'

require 'timers'
require 'thermostat/compressor'

class TestCompressor < TimeMachine
	def setup
		super

		@uut = Thermostat::Compressor.new timers: @timers
	end


	def test_starts_cooling_down
		assert @uut.cooling_down?, 'Compressor did not start in cooling_down state'
	end


	def test_must_cool_down
		assert @uut.cooling_down?, 'Compressor did not start in cooling_down state'
		assert_raises(AASM::InvalidTransition) {
			@uut.idle
		}
	end


	def test_can_cool_down
		assert @uut.cooling_down?, 'Compressor did not start in cooling_down state'
		mock(@uut).cooled_down?.returns { true }
		assert @uut.idle, 'Compressor did not return to idle state'
	end


	def test_cooling_down_to_idle_transition
		assert @uut.cooling_down?, 'Compressor did not start in cooling_down state'

		fast_forward 180

		assert @uut.idle?, 'Compressor did not return to idle state automatically'
	end
end
