require 'minitest/autorun'

require 'thermostat/compressor'

class TestCompressor < Minitest::Test
	def test_constructor
		@uut = Thermostat::Compressor.new
	end

	def test_starts_idle
		@uut = Thermostat::Compressor.new

		assert @uut.cooling_down?
	end

end
