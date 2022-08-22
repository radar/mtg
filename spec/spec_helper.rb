# frozen_string_literal: true
require "pry"
require "magic"

module CardHelper
  def Card(name, **args)
    Magic::Cards.const_get(name.gsub(/[^a-z]/i, "").gsub(/\s(a-z)/) { $1.upcase }).new(game: game, **args)
  end

  def Permanent(name, **args)
    Magic::Permanent.new(game: game, card: Card(name), **args)
  end

  def ResolvePermanent(name, **args)
    Magic::Permanent.resolve(game: game, card: Card(name), **args)
  end

  def cast_action(card:, player:)
    Magic::Actions::Cast.new(card: card, player: player)
  end

  def add_to_stack_and_resolve(action)
    game.stack.add(action)
    game.stack.resolve!
  end

  def cast_and_resolve(card:, player:, targeting: nil)
    action = cast_action(card: card, player: player)
    action = action.targeting(targeting) if targeting
    game.stack.add(action)
    game.stack.resolve!
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
  let(:p1) { Magic::Player.new(name: "P1", library: p1_library) }
  let(:p2) { Magic::Player.new(name: "P2", library: p2_library) }

  def p1_library
    [
      Card("Forest")
    ]
  end

  def p2_library
    [
      Card("Mountain")
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
  end
end
