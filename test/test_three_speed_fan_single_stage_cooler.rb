require_relative 'time_machine'

require 'thermostat/compressor'
require 'thermostat/three_speed_drying_fan'
require 'thermostat/three_speed_fan_single_stage_cooler'

class TestThreeSpeedFanSingleStageCooler < TimeMachine
	def setup
		super

		@ambient = Thermostat::TemperatureSensor.new #timers: @timers
		@compressor = Thermostat::Compressor.new timers: @timers
		@fan = Thermostat::ThreeSpeedDryingFan.new timers: @timers

		@uut = Thermostat::ThreeSpeedFanSingleStageCooler.new ambient_temperature_sensor: @ambient, compressor: @compressor, fan: @fan, timers: @timers
	end

	def test_bootstrap_with_single_cooling_cycle
		$logger.debug 'About to start the thermostat simulation'

		assert @fan.idle?, 'Fan did not begin idle'

		# Set the initial states
		fast_forward 180 # Skip time until the compressor is done cooling down
		assert @compressor.may_start?, 'Compressor is not ready to start'

		# Make sure the compressor doesn't kick in too early
		@ambient.new_value 19.0
		assert @compressor.idle?, 'Compressor started running too early'

		# Fan and compressor should go on when temperature exceeds setpoint
		@ambient.new_value 21.7
		assert @compressor.running?, 'Compressor is not running during cooling'
		assert @fan.running?, 'Fan is not running during cooling'
		assert_equal :high, @fan.speed, 'Fan is not at high speed during cooling'

		# Compressor should go off, fan goes to drying when temperature is below setpoint
		@ambient.new_value 19.24
		assert @compressor.cooling_down?, 'Compressor is not cooling down after running'
		assert @fan.running?, 'Fan is not running during drying'
		assert_equal :medium, @fan.speed, 'Fan is not at medium speed during drying'

		# Now the drying time has passed so fan should be off
		fast_forward 120
		assert @fan.idle?, 'Fan is not idle after drying'

		# For good measure, make sure compressor is still cooling down
		assert @compressor.cooling_down?, 'Compressor is not cooling_down after drying phase'
		assert @fan.idle?, 'Fan is not idle at the end of simulation'

		fast_forward 60
		assert @compressor.idle?, 'Compressor is not idle at the end of simulation'
	end

end
