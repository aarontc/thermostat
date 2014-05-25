require_relative 'helper'

require 'thermostat/temperature_sensor'

class TestTemperatureSensor < Minitest::Test
	def setup
		@uut = Thermostat::TemperatureSensor.new
	end

	def test_returns_value
		mock(@uut).current_value { 24.0 }

		assert_in_delta 24.0, @uut.current_value
	end
end
