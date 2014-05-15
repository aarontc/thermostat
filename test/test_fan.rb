require 'minitest/autorun'

require 'thermostat/fan'

class TestFan < Minitest::Test
	def setup
		@f = Fan.new
	end

	def test_create_a_fan
		assert !@f.nil?
	end

end