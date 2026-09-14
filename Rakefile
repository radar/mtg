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

task :find_cards do
  oracle = Magic::Oracle.new
  $stdin.each_line do |line|
    name = line.strip
    next if name.empty?

    puts "=== #{name} ==="
    begin
      puts oracle.find_card(name).inspect
    rescue Magic::Oracle::CardNotFound
      puts "NOT FOUND"
    end
    puts
  end
end

task :search_cards, :fragment do |task, args|
  names = Magic::Oracle.new.search_cards(args[:fragment])
  puts names.inspect
end
