# Wall toggle button
class Toggle
  include Pigpio::Constant
  @pi = Pigpio.new

  def initialize(button)
    Toggle.pi.connect || raise('pigpio connect error')
    
    @btn = Toggle.pi.gpio(button[:button_pin])
    @btn.mode = PI_INPUT
    @btn.pud = PI_PUD_UP
    @btn.glitch_filter(1000) # 1000ms == 1s

    
    @led = Toggle.pi.gpio(button[:led_pin])
    @led.mode = PI_OUTPUT

    @dev = button[:device]
    
    fetch_btn_state
    button_monitoring
    init_debug_print
    stay 
  end

  def init_debug_print
    puts('[DEBUG] initialezed')
    puts("[DEBUG] .pi:\t#{Toggle.pi}")
    puts("[DEBUG] @dev:\t#{@dev}")
    puts("[DEBUG] @led:\t#{@led}")
    puts("[DEBUG] @btn:\t#{@btn}")
    puts("[DEBUG] @btn_cb:\t#{@btn_cb}")
    puts("[DEBUG] @btn_st:\t#{@btn_state}")
    puts('')
  end

  def debug_print
    puts("[DEBUG] @btn_st:\t#{@btn_state}")
    puts("[DEBUG] @btn_cb:\t#{@btn_cb}")
  end

  def self.pi
    @pi
  end

  def fetch_btn_state
    @btn_state = fetch_last_state_influxdb(@dev)
    @btn_state || led_write(true)
  end

  def button_monitoring
    puts "start btn monitor"
    @btn_cb = @btn.callback(RISING_EDGE) { toggle }
  end

  def toggle
    @btn_state = !@btn_state
    led_write(!@btn_state)
    send_ir(@dev, @btn_state)

    puts('[DEBUG] push')
    debug_print
  end

  def led_write(level)
    level = level ? 1 : 0
    @led.write(level)
  end

  def stay
    puts('Quit is press q-key')
    gets.strip == 'q' && stop
  end

  def stop
    @btn_cb.cancel
    Toggle.pi.stop
    puts('Quited')
  end
end
