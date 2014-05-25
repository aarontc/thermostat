require_relative 'helper'

require 'thermostat/compressor'
require 'thermostat/three_speed_drying_fan'
require 'thermostat/three_speed_fan_single_stage_cooler'

class TestThreeSpeedFanSingleStageCooler < Minitest::Test
	def setup
		@ambient = stub(Thermostat::TemperatureSensor.new)
		@fan = stub(Thermostat::ThreeSpeedDryingFan.new)
		@compressor = Thermostat::Compressor.new
		#@compressor = stub(Thermostat::Compressor.new).start
		stub(@compressor).start
		stub(@compressor).add_observer

		@uut = Thermostat::ThreeSpeedFanSingleStageCooler.new ambient_temperature_sensor: @ambient, compressor: @compressor, fan: @fan
	end


	def test_bootstrap_with_single_cooling_cycle
		# Set the initial states
		@uut.update @compressor, Time.now, {aasm_transition: {from: :cooling_down, to: :idle}}
		@uut.update @ambient, Time.now, {current_value: 19.0}
		@uut.update @ambient, Time.now, {current_value: 24.0}
		# Fan and compressor should go on
		assert_received(@compressor) {|o| o.start}

		@uut.update @ambient, Time.now, {current_value: 23.24}
		# Compressor should go off, fan goes to drying


	end

end
