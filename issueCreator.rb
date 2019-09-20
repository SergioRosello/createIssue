#!/usr/bin/env ruby

require "json"
require 'dotenv/load'
require "net/http"

# The script will take [1..n] file absolute paths as parameters
# Example absolute path for a file:
# home/user/Documents/Wave/issues/Sister/iOS/1.0-20/issue.issuea
# We check for Sister, Schools, Wola to determine project
# We check for Android or iOS to determine platform
#

# returns Github Project repository the issue has to go to
def project(substring)
  if substring.include? "Sister" and substring.include? "iOS" 
    repo = "sister_ios"
  elsif substring.include? "Sister" and substring.include? "Android" 
    repo = "sister_android"
  elsif substring.include? "Schools" and substring.include? "iOS" 
    repo = "wola_schools_ios"
  elsif substring.include? "Schools" and substring.include? "Android" 
    repo = "school_android"
  elsif substring.include? "Wola" and substring.include? "iOS"
    repo = "wola_maps_ios"
  elsif substring.include? "Wola" and substring.include? "Android" 
    repo = "wola_maps_android"
  else abort_script
  end
  repo
end

# Print error message
def abort_script
  abort("Provide 1..N absolute filepaths in order to upload issues")  
end

# Returs the name in human readable form
def issue_title(issue)
  name = issue.split(/\//)
  # gets the last / separated part of the string
  # divides the previous string where the "." appears
  # replaces "_" with " "
  name.last.split(/\./).first.gsub!('_', ' ')
end

# Reads the issue file and converts it into a string
def issue_body(issue)
  File.read(issue)
end

# Add labels to issue.
# They will be proirity medium and type bug
def issue_labels
  ["Priority: Medium", "Type: Bug"]
end

# Generates the JSON object to send to Github
def generate_payload(issue)
  # Parse the issue name
  payload = {:title => issue_title(issue)}
  payload[:body] = issue_body(issue)
  payload[:labels] = issue_labels
  payload
end

def upload(payload, issue)
  # POST /repos/:owner/:repo/issues
  uri = URI.parse("https://api.github.com/repos/WolaApplication/#{project(issue)}/issues")
  headers = {'Content.type': 'application/json',
             'Accept': 'application/vnd.github.v3+json'}
  # Create the HTTP objects
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.basic_auth(ENV['GITHUB_USERNAME'], ENV['GITHUB_TOKEN'])
    request.body = payload
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/vnd.github.v3+json'

    http.request(request)
  end

  # Send the request
  p response.body
end

abort_script if ARGV.length == 0

ARGV.each do |issue|
  upload(JSON.generate(generate_payload(issue)), issue)
end
