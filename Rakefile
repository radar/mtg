# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "magic"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :find_card, :name do |task, args|
  card = Magic::Oracle.new.find_card(args[:name])
  puts card.inspect
end
