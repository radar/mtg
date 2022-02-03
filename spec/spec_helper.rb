# frozen_string_literal: true
require "pry"
require "magic"

module CardHelper
  def Card(name, **args)
    Magic::Cards.const_get(name.gsub(/[^a-z]/i, "")).new(game: game, **args)
  end
end

module PlayerHelper
  def Player
    Magic::Player.new(library: [Card("Forest")])
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include CardHelper
  config.include PlayerHelper
end

RSpec.shared_context "two player game" do
  let(:game) { Magic::Game.start! }
  let(:p1) { Magic::Player.new }
  let(:p2) { Magic::Player.new }

  def p1_library
    [
      Card("Forest")
    ]
  end

  def current_turn
    game.current_turn
  end

  def skip_to_combat!
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
    current_turn.beginning_of_combat!
  end

  def go_to_combat_damage!
    current_turn.attackers_declared! if current_turn.step?(:declare_attackers)
    current_turn.combat_damage! if current_turn.step?(:declare_blockers)
  end

  before do
    game.add_player(p1)
    game.add_player(p2)
    game.next_turn

    p1_library.each { |card| p1.library.add(card) }
  end
end
