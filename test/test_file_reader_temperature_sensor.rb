require_relative 'helper'

require 'fakefs/safe'
require 'thermostat/file_reader_temperature_sensor'

class TestFileReaderTemperatureSensor < Minitest::Test
	def notification_receiver(sender, time, data)
		@received_notifications << [sender, time, data]
	end

	def test_watch_creates_notification
		@received_notifications = []
		#mock(Listen).do

		FakeFS do
			Dir.mkdir '/tmp' unless Dir.exists? '/tmp'
			File.open('/tmp/temperature_in', 'w') { |f| f.write('44.08') }
			uut = Thermostat::FileReaderTemperatureSensor.new path: '/tmp/temperature_in'
			uut.add_observer self, :notification_receiver
			File.open('/tmp/temperature_in', 'w').write('44.09')
		end

		assert_equal 1, @received_notifications.length, 'Notification not received'

		assert_equal @uut, @received_notifications[0][0]
		assert_instance_of Time, @received_notifications[0][1]
		assert_instance_of Hash, @received_notifications[0][2]
		assert_in_delta 44.09, @received_notifications[0][2][:current_value], 0.01
	end
end
