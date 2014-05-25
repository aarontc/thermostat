require 'aasm'
require 'observer'

module Thermostat
	class ObservableStateMachine
		include AASM
		include Observable

		protected
		def on_transition(*args)
			changed
			$logger.debug "#{self}: Changing state from #{aasm.from_state} to #{aasm.to_state} with args #{args.inspect}" unless $logger.nil?
			notify_observers self, Time.now, {aasm_transition: {from: aasm.from_state, to: aasm.to_state}}
		end
	end
end
