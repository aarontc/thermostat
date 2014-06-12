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

	def notification_receiver(sender, time, data)
		@received_notifications << [sender, time, data]
	end

	def test_notifies_observers
		@received_notifications = []
		@uut.add_observer self, :notification_receiver

		@uut.send :new_value, 55.27

		assert_equal 1, @received_notifications.length, 'Notification not received'

		assert_equal @uut, @received_notifications[0][0]
		assert_instance_of Time, @received_notifications[0][1]
		assert_instance_of Hash, @received_notifications[0][2]
		assert_in_delta 55.28, @received_notifications[0][2][:current_value], 0.01
	end
end
