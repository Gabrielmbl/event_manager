require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number_string = phone_number.to_s

  if phone_number_string.length < 10
    puts "#{phone_number_string} -> Phone number is less than 10 digits. Bad number."

  elsif phone_number_string.length == 10
    puts "#{phone_number_string} -> Phone number has 10 digits. Good number."
    phone_number_string

  elsif phone_number_string.length == 11 and phone_number_string[0] == 1
    puts "#{phone_number_string} -> Phone number has 11 digits, first digit is 1"
    phone_number_string[1..]

  elsif phone_number_string.length == 11 and phone_number_string[0] != 1
    puts "#{phone_number_string} -> Phone number has 11 digits and first number is not 1. Bad number."

  elsif phone_number_string.length > 11
    puts "#{phone_number_string} -> Phone number is greater than 11 digits. Bad number."

  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])

  puts phone_number

  form_letter = erb_template.result(binding)

  #   save_thank_you_letter(id,form_letter)
end