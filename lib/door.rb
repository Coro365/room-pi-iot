def door_open?
  %x(gpio mode #{READ_SW_1_PIN} in)
  state = %x(gpio read #{READ_SW_1_PIN}).chr.to_i

  if state == 0 or state == 1
    return state
  else
    puts("ERROR:can not read pin.")
    return nil
  end
end

def door_monitoring(past)
  loop do
    now = door_open?
    unless past == now
      door_state_print(now)
      door_state_post(now)
      past = now
    end
    sleep RS_MONITORING_SLEEPTIME
  end
end

def door_state_print(state)
  state == 0 ? puts("=>OPEN") : puts("=>CLOSE") 
end

def door_state_post(state)
  payload = "ocaction,location=#{LOCATION} value=#{state}"
  system("curl -i -XPOST '#{INFLUXDB_ADRR}' --data-binary '#{payload}'")
end
