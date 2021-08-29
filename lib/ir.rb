require 'open3'
PIIR_DIR = '~/Documents/PiIR'
IRLED_PIN = 17

INFLUXDB_ADRR = 'http://awayuki.local:8086/write?db=home-sensor'
LOCATION = 3

def send_ir(device, signal)
  signal = signal ? 'on' : 'off'
  signal_file = File.expand_path(File.join(PIIR_DIR, "#{device}.json"))
  cmd = ['piir', 'play', '-g', IRLED_PIN.to_s, '-f', signal_file, signal]
  p cmd.join(' ')
  system(*cmd)
  post_influxdb(signal)
end

def post_influxdb(action)
  # TODO: change fulentd
  payload = "swaction,location=#{LOCATION},device='light1' value=\"#{action}\""
  cmd = ['curl', '-i', '-XPOST', INFLUXDB_ADRR, '--data-binary', payload]
  system(*cmd)
end

def fetch_last_state_influxdb(device)
  # TODO: workarounds when influxdb server down
  # TODO: Use influx gems
  false
end
