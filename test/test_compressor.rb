require 'minitest/autorun'
require 'rr'

require 'thermostat/compressor'

class TestCompressor < Minitest::Test
	def setup
		@uut = Thermostat::Compressor.new
	end

	def test_starts_idle
		assert @uut.cooling_down?
	end

	def test_must_cool_down
		assert @uut.cooling_down?
		assert_raises(AASM::InvalidTransition) {
			@uut.idle
		}
	end

	def test_can_cool_down
		assert @uut.cooling_down?
		mock(@uut).cooled_down?.returns { true }
		assert @uut.idle
	end

	def test_cooling_down_to_idle_transition
		#@uut = mock!(Thermostat::Compressor).COOLDOWN_SECONDS { 1 }
		assert @uut.cooling_down?
		sleep 2
		assert @uut.idle?
	end

end
