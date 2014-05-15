require 'minitest/autorun'
require 'rr'

require 'thermostat/compressor'

class TestCompressor < Minitest::Test
	def test_constructor
		@uut = Thermostat::Compressor.new
	end

	def test_starts_idle
		@uut = Thermostat::Compressor.new

		assert @uut.cooling_down?
	end

	def test_must_cool_down
		@uut = Thermostat::Compressor.new

		assert @uut.cooling_down?

		assert_raises(AASM::InvalidTransition) {
			@uut.idle
		}
	end

	def test_can_cool_down
		@uut = Thermostat::Compressor.new
		mock(@uut).cooled_down? { true }

		assert @uut.cooling_down?
		assert @uut.idle
	end

end
