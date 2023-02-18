require 'sinatra'
require 'sinatra/reloader'
require 'json'
require File.join(__dir__, 'influxdb.rb')

helpers do
  def v1(device, data)
    if data && data['status'] && device
      puts("#{device} #{data['status']}")

      Influx.post(device: device, action: data['status'])
      status 202
    else
      json_status(400, 'Not support payload format')
    end
  end

  def device_state_v1(device)
    if device
      { status: 'off' }.to_json
    else
      status 400
    end
  end

  def version(accept)
    accept && accept.first.to_s.slice(/vnd\.piir\.v(\d+)/, 1).to_i
  end

  def file_type(accept)
    accept && accept.first.to_s.slice(/vnd\.piir\.v\d+\+(.*)/, 1)
  end

  def json_status(code, reason)
    status code
    {
      status: code,
      reason: reason
    }.to_json
  end

  def accept_params(params, *fields)
    h = {  }
    fields.each do |name|
      h[name] = params[name] if params[name]
    end
    h
  end
end

get('/api') do
  'PiIR API https://github.com/Coro365/RoomPi'
end

get('/api/devices/:device') do |device|
  # set(:content_type, 'text/json;charset=utf-8')
  case ['v', version(request.accept), '+', file_type(request.accept)].join
  when 'v1+json'
    device_state_v1(device)
  else
    json_status(406, 'Not support version or mimetype')
  end
end

put('/api/devices/:device') do |device|
  # set(:content_type, 'text/json;charset=utf-8')
  request.body.rewind
  data = JSON.parse(request.body.read) rescue nil

  case version(request.accept)
  when 1
    v1(device, data)
  else
    json_status(406, 'Not support version')
  end
end

get('*') do
  status 404
end

post('*') do
  status 404
end

put('*') do
  status 404
end

delete('*') do
  status 404
end

not_found do
  json_status(404, 'Not found')
end

error do
  json_status(500, env['sinatra.error'].message)
end
