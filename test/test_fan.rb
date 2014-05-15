require 'minitest/autorun'

require 'thermostat/fan'

class TestFan < Minitest::Test
	def setup
		@f = Fan.new
	end

	def test_create_a_fan
		assert !@f.nil?
	end

	def test_default_fan_stat_is_idle
		assert @f.idle?
	end

	def test_fan_can_transition_idle_to_on
		@f.start
		assert @f.running?
	end

	def test_a_fan_turned_on_can_return_to_idle
		@f.start
		assert @f.running?

		@f.stop
		assert @f.idle?
	end

end