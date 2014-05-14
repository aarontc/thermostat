require 'aasm'

class Thermostat
	include AASM
	
	aasm do
		state :idle, initial: true
		state :cooling
		state :compressor_cooldown
		state :drying
		
end