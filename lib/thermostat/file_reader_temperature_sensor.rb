require 'rb-inotify'

require_relative 'temperature_sensor'

module Thermostat
	class FileReaderTemperatureSensor < TemperatureSensor

		def initialize(path: nil)
			@path = path
			raise ArgumentError, 'tpath must be defined' if @path.nil?

			super()
			setup_notifier
		end


		def start
			new_value read_file
			@worker = Thread.new { @notifier.run }
		end


		def stop
			@notifier.stop
		end


		private
		def read_file
			File.read(@path).to_f
		end


		def setup_notifier
			@notifier = INotify::Notifier.new
			@notifier.watch(@path, :modify) do |event|
				new_value read_file
			end
		end
	end
end
