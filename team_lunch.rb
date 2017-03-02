#!/usr/bin/env ruby

require 'yaml'
require 'active_support/inflector'
require './lib/team'
require './lib/restaurant'
require './lib/meal'

file_path = ARGV[0] || 'config/input.yml.example'
team_config = YAML.load_file(file_path)

# Run the app with config data
team=Team.new(team_config)
team.generate_lunch_orders

# Output to console
puts ""
puts "****************************************************"
puts "Expected meal orders: #{team.print_lunch_orders}"
puts
