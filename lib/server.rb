require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def v1(device, data)
    if data['status'] && device
      puts("#{device} #{data['status']}")
      status 202
    else
      status 400
    end
  end

  def version(request)
    accept = request.accept
    accept && accept.first.to_s.slice(/vnd\.piir\.v(\d+)/, 1).to_i
  end
end

get '/api' do
  'PiIR API https://github.com/Coro365/'
end

put('/api/devices/:device') do |device|
  request.body.rewind
  data = JSON.parse(request.body.read)

  case version(request)
  when 1
    v1(device, data)
  else
    status 406
  end
end

get '*' do
  status 404
end

post '*' do
  status 404
end

put '*' do
  status 404
end

delete '*' do
  status 404
end

# not_found do
#   json_status 404, 'Not found'
# end
#
# error do
#   json_status 500, env['sinatra.error'].message
# end
