require 'sqlite3'
require 'net/http'
require 'json'

# Open a database
db = SQLite3::Database.new "stopandsearch.db"

rows = db.execute('SELECT rowid, latitude, longitude FROM stop_and_search')
errors = []

rows.each do |row|
  json = Net::HTTP.get("api.postcodes.io", "/postcodes?lon=#{row[2]}&lat=#{row[1]}")
  response = JSON.parse(json)
  if response['result']
    print '.'
    data = response['result'][0]
    query = <<-SQL
      UPDATE stop_and_search
      SET admin_ward = "#{data['admin_ward']}",
          postcode = "#{data['postcode']}",
          lsoa = "#{data['lsoa']}"
      WHERE rowid = #{row[0]}
    SQL
    db.execute query
  else
    print "E"
    errors.push row[0]
  end
end

puts ""
puts "Errors on rows #{errors.join(', ')}"
