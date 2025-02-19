#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/https"
require "base64"
require "json"
require "colorize"
require "open-uri"

puts "Grabbing latest version of Disenchanter...".light_blue

def run
  sep =
    "____________________________________________________________".light_black

  if File.exist?("LeagueClient.exe")
    # Doinb 400CS backwards compatibility hack
    updater_processes = `tasklist | find /I /C "disenchanter_up.exe"`
    if(updater_processes.to_i > 2)
      puts "Backwards compatibility: killing Disenchanter..."
      `taskkill /IM "disenchanter.exe" /F /T >nul 2>&1 && exit`
    end
    `tasklist|findstr "disenchanter.exe" >nul 2>&1 && echo Backwards compatibility: popping out into separate process... && start cmd.exe @cmd /k "disenchanter_up.exe" && exit`
    sleep(1)
    puts "Killing Disenchanter..."
    `taskkill /IM "disenchanter.exe" /F /T >nul 2>&1`

    uri =
      URI(
        "https://api.github.com/repos/marvinscham/disenchanter/releases/latest"
      )
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri, "Content-Type": "application/json")
    res = http.request req
    ans = JSON.parse(res.body)

    puts "Downloading Disenchanter #{ans["tag_name"]}".light_green

    `curl https://github.com/marvinscham/disenchanter/releases/download/#{ans["tag_name"]}/disenchanter.exe -L -o disenchanter.exe`
    puts sep
    puts "Done downloading!".green

    pid = spawn("start cmd.exe @cmd /k \"disenchanter.exe\"")
    Process.detach(pid)
    puts "Exiting...".light_black
    exit
  else
    puts "Not in League Client folder, skipping update...".yellow
  end
end

run
