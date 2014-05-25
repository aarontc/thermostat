require_relative 'helper'

require 'thermostat/fan'

class TestFan < Minitest::Test
	def setup
		@f = Thermostat::Fan.new
	end

	def test_create_a_fan
		refute @f.nil?
	end

	def test_default_fan_state_is_idle
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

	def test_fan_whines_on_double_start
		@f.start

		assert @f.running?
		assert_raises(AASM::InvalidTransition) {
			@f.start
		}
	end

	def test_fan_whines_on_double_stop
		assert @f.idle?

		assert_raises(AASM::InvalidTransition) {
			@f.stop
		}
	end
end
