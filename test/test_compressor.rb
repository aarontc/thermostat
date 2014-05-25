require_relative 'helper'

require 'thermostat/compressor'

class TestCompressor < Minitest::Test
	def setup
		@uut = Thermostat::Compressor.new
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
		timers = Timers.new
		uut = Thermostat::Compressor.new cooldown_seconds: 1, timers: timers

		assert uut.cooling_down?, 'Compressor did not start in cooling_down state'
		timers.wait
		assert uut.idle?, 'Compressor did not return to idle state automatically'
	end
end
