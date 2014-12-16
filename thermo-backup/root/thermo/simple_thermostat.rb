#!/usr/bin/env ruby

#DRIFT_DEGREES = 0.25
LOOP_DELAY_SECONDS = 0.5
#MAX_COMPRESSOR_RUNTIME = 300

require 'pathname'
require_relative 'beaglebone'

class String
	def to_boolean
		return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
		return false if self == false || self.empty? || self =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
	end
end

class Settings
	SETTINGS_PATH = Pathname.new(File.dirname(__FILE__)).join('settings').freeze

	attr_accessor :cooldown_seconds, :target_temperature, :dry_time, :fan_speed_cooling, :fan_speed_drying, :fan_speed_fan, :desire_fan, :max_compressor_runtime, :drift_degrees

	def initialize
		reload true
	end

	def reload(initial = false)
		%w[target_temperature dry_time cooldown_seconds max_compressor_runtime drift_degrees].each do |var|
			try_load var, :float, initial
		end

		%w[fan_speed_cooling fan_speed_drying fan_speed_fan].each do |var|
			try_load var, :symbol, initial
		end

		%w[desire_fan].each do |var|
			try_load var, :boolean, initial
		end
	end

	def try_load(name, type, load_first = false)
		instance_variable_set "@#{name}", default_for(name) if load_first

		attempt = read_file SETTINGS_PATH.join(name)
		if attempt.nil?
			result = default_for name
		else
			case type
				when :boolean
					result = attempt.to_boolean
				when :float
					result = Float attempt
				when :symbol
					result = attempt.to_sym
					raise ArgumentError, "value '#{attempt}' invalid for setting '#{name}'" unless [:high, :medium, :low].include? result
				else
					raise ArgumentError, 'type must be :boolean, :float, or :symbol'
			end
		end

		previous = instance_variable_get "@#{name}"
		if result != previous
			$logger.info "Setting '#{name}' to new value '#{result}'"
			instance_variable_set "@#{name}", result
		end

	rescue Exception => e
		$logger.info "Settings.try_load: #{e}"
	end

	def read_file(path)
		value = nil
		begin
			value = File.read(path).strip
		rescue StandardError
		end
		value
	end

	def default_for(name)
		case name
			when 'cooldown_seconds'; 180.0
			when 'target_temperature'; 21.0
			when 'dry_time'; 120
			when 'fan_speed_cooling'; :high
			when 'fan_speed_drying'; :medium
			when 'fan_speed_fan'; :low
			when 'desire_fan'; false
			when 'max_compressor_runtime'; 300.0
			when 'drift_degrees'; 0.25
			else; raise ArgumentError, 'name is not in allowed list'
		end
	end
end
		

class OldThermostatEmulator
	def initialize
		@temp_moving_average = []
		(5 / LOOP_DELAY_SECONDS).to_i.times do
			@temp_moving_average << 0.0
		end

		@gpios = {
			compressor: Beagle::Gpio.new(49, active_low: true, default: :low, direction: :out),
			fan: {
				high: Beagle::Gpio.new(48, active_low: true, default: :low,direction: :out),
				low: Beagle::Gpio.new(30, active_low: true, default: :low,direction: :out),
				medium: Beagle::Gpio.new(31, active_low: true, default: :low,direction: :out),
			}
		}

		@_timer_counter = 0
		@old_temperature = 0.0
		@current_temperature = 0.0

		@counter_message, @counter_drying = -1, -1

		@old_status = 0
		puts 'Welcome to Thermo!'

		@settings = Settings.new

		@counter_compressor = 0
		@compressor_start_time = nil
		@_compressor = :off
		set_compressor :off

		$logger.info "Initialization complete"
	end

	def read_temperature
		new_value = File.read('/tmp/temp').to_f

		@old_temperature = @current_temperature
		#@current_temperature = rand 15.0..25.0
		@temp_moving_average.shift
		@temp_moving_average << new_value

		@current_temperature = @temp_moving_average.reduce(:+) / @temp_moving_average.length

		$logger.debug "Temperature is now #{@current_temperature}" if @old_temperature != @current_temperature
	end


	def run
		while true
			@settings.reload

			@old_status = @status
			read_temperature

			@counter_compressor = -1 if @counter_compressor >= @settings.cooldown_seconds
			@counter_drying = -1 if @counter_drying >= @settings.dry_time

			set_fan :off
			@status = :idle

			if @settings.desire_fan
				set_fan @settings.fan_speed_fan
				@status = :fan
			end

			if @old_status == :cooling
				if @current_temperature < (@settings.target_temperature - @settings.drift_degrees)
					$logger.info "Temperature below target, entering drying state"
					set_compressor :off
					@counter_drying = 0
				else
					set_fan @settings.fan_speed_cooling
					@status = :cooling
					@counter_drying = -1
				end
			end


			@status = :compressor_cooldown if @counter_compressor > -1


			if @current_temperature > @settings.target_temperature + @settings.drift_degrees
				if @counter_compressor < 0 and @old_status != :cooling
					$logger.info "Temperature above target and compressor cooldown finished, entering cooling state"
					set_fan @settings.fan_speed_cooling
					set_compressor :on
					@status = :cooling
					@counter_drying = -1
				end
			end


			# Check max compressor runtime
			unless @compressor_start_time.nil?
				if Time.now - @compressor_start_time >= @settings.max_compressor_runtime
					$logger.warn "Compressor max runtime exceeded, forcing state to drying"
					set_compressor :off
					@counter_drying = 0
				end
			end


			if @counter_drying > -1
				set_fan @settings.fan_speed_drying
				@status = :drying
			end


			update_control
			update_display

			sleep LOOP_DELAY_SECONDS
			update_timers
		end
	end

	def update_timers
		@_timer_counter += 1

		if @_timer_counter >= 1 / LOOP_DELAY_SECONDS
			@counter_compressor += 1 if @counter_compressor > -1
			@counter_message += 1 if @counter_message > -1
			@counter_drying += 1 if @counter_drying > -1
			@_timer_counter = 0
		end
	end

	def set_compressor(state)
		$logger.debug "Setting compressor to #{state}"

		unless state == @_compressor
			if state == :on
				@compressor_start_time = Time.now
			else
				@compressor_start_time = nil
			end
		end

		@counter_compressor = 0 if state == :off
		@_compressor = state
	end

	def set_fan(state)
		$logger.debug "Setting fan to #{state}"

		@_fan = state
	end

	def update_control
		case @_compressor
		when :off
			write_compressor :low
		when :on
			write_compressor :high
		else
			write_compressor :low
			$logger.error "INVALID COMPRESSOR STATE '#{@_compressor}'"
		end

		case @_fan
		when :high
			write_fan_medium :low; write_fan_low :low; write_fan_high :high
		when :medium
			write_fan_high :low; write_fan_low :low; write_fan_medium :high
		when :low
			write_fan_high :low; write_fan_medium :low; write_fan_low :high
		when :off
			write_fan_high :low; write_fan_medium :low; write_fan_low :low
		else
			write_fan_high :true; write_fan_medium :low; write_fan_low :low
			$logger.error "INVALID FAN STATE '#{@_fan}'"
		end
	end


	def write_compressor(state)
		#File.open(GPIO_COMPRESSOR, 'w') { |file| file.write(state) }
		@gpios[:compressor].value = state
	end

	def write_fan_high(state)
		#File.open(GPIO_FAN_HIGH, 'w') { |file| file.write(state) }
		@gpios[:fan][:high].value = state
	end

	def write_fan_low(state)
		#File.open(GPIO_FAN_LOW, 'w') { |file| file.write(state) }
		@gpios[:fan][:low].value = state
	end

	def write_fan_medium(state)
		#File.open(GPIO_FAN_MEDIUM, 'w') { |file| file.write(state) }
		@gpios[:fan][:medium].value = state
	end

	def update_display
		File.open('/tmp/thermostat.display', 'w') do |file|
			file.write "Now %.2f Set %.2f " % [@current_temperature, @settings.target_temperature]
			file.write "#{@settings.fan_speed_cooling[0]}#{@settings.fan_speed_drying[0]}#{@settings.fan_speed_fan[0]}\n".upcase
			case @status
				when :compressor_cooldown
					file.write "Cooldown [%d]" % (@settings.cooldown_seconds - @counter_compressor)
				when :cooling
					file.write "Cooling"
				when :drying
					file.write "Drying [%d]" % (@settings.dry_time - @counter_drying)
				when :fan
					file.write "Idle - Fan On"
				when :idle
					file.write "Idle"
				else
					file.write "Unknown status"
			end

			file.write "\n\nCompressor: #{@_compressor}, Fan: #{@_fan}"

			file.write "\n\n\n\n====DEBUG DUMP====\n#{self.inspect}"
		end
	end
end

if __FILE__ == $0
	require 'logger'
	$logger = Logger.new(STDOUT)
	$logger.level = Logger::INFO

	while true
		begin
			OldThermostatEmulator.new.run
		rescue SystemExit, Interrupt
			raise
		rescue Exception => e
			$logger.fatal "Exception in main object: #{e}\n#{e.backtrace}"
			sleep 10
		end
	end
end
