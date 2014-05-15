require 'minitest/autorun'

require 'thermostat'

class TestThermostat < Minitest::Test

	def test_constructor
		@uut = Thermostat::Thermostat.new
	end

end
