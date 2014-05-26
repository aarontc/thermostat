require 'logger'

STDOUT.sync = true
$logger = Logger.new STDOUT
$logger.level = Logger::DEBUG


require 'minitest/autorun'
require 'rr'
