require 'pigpio'

Dir[File.join(__dir__, 'lib', '*.rb')].each { |f| require_relative f }

# device: PiIR signal json file name
tb = Toggle.new(device: 'light', button_pin: 10, led_pin: 22)

