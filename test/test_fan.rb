require 'minitest/autorun'
require 'timers'

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

	def test_running_fan_cannot_be_turned_off_if_duration_not_expired
		@f.start_for_duration(5)
		mock(@f.can_turn_off?) { false }

		assert_raises(AASM::InvalidTransition) {
			@f.stop
		}
	end

	#test code that will leave
	def test_blah
		timer = Timers.new
		mock(timer).after(5) {@f.some_proc true}
		result = @f.wait_for_a_while(timer)

		assert result
	end

end