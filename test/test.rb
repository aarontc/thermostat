require 'minitest/autorun'

require_relative '../lib/thermostat'

class TestThermostat < Minitest::Test
	
	def test_constructor
		@uut = Thermostat.new
	end
	
end
