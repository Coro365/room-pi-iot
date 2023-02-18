PIIR_DIR = '~/Documents/PiIR'
IRLED_PIN = 17

def send_ir(device, signal)
  signal = signal ? 'on' : 'off'
  signal_file = File.expand_path(File.join(PIIR_DIR, "#{device}.json"))
  cmd = ['piir', 'play', '-g', IRLED_PIN.to_s, '-f', signal_file, signal]
  system(*cmd)
  # TODO: move
  Influx.post(device: device, action: signal)
end
