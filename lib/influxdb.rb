require 'influxdb'

# post and fetch from influxdb
class << Influx
  def client_new
    database = 'home-sensor'
    influx_options = { host: 'awayuki.local', port: '8086',
                       open_timeout: 10, retry: 5, async: true }
    @influxdb = InfluxDB::Client.new(database, influx_options)
  end

  def post(field: 'swaction', location: '1', device: nil, action: nil)
    @influxdb || client_new

    data = {
      values: { value: action },
      tags: { location: location, device: device }
    }

    @influxdb.write_point(field, data)
  end

  def fetch_latest(field: 'swaction', location: '1', device: nil)
    @influxdb || client_new

    select = "select value from #{field}"
    where = "where location = '#{location}'"
    device && where = [where, "and device = '#{device}'"].join(' ')
    order = 'order by desc limit 1'

    query = [select, where, order].join(' ')
    @influxdb.query(query).dig(0, 'values', 0, 'value')
  end
end

# p Influx.fetch_latest(device: 'light1')
# p Influx.post(device: 'light1', action: 'off')
# p Influx.fetch_latest(device: 'light1')
# p Influx.fetch_latest(field: 'temperature', location: '2')
