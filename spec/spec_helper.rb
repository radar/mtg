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

  def AddLand(name, **args)

  end

  def add_to_library(name, player:)
    card = Card(name)
    player.library.add(card)
    card
  end

  def cast_action(card:, player:, targeting: nil)
    action = Magic::Actions::Cast.new(card: card, player: player)
    action.targeting(targeting) if targeting
    action
  end

  def add_to_stack_and_resolve(action)
    game.stack.add(action)
    game.stack.resolve!
  end

  def cast_and_resolve(card:, player:, targeting: nil)
    action = cast_action(card: card, player: player, targeting: targeting)
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
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(name: "P1") }
  let(:p2) { Magic::Player.new(name: "P2") }

  def p1_library
    7.times.map { Card("Forest") }
  end

  def p2_library
    7.times.map { Card("Mountain") }
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
    p1_library.each { p1.library.add(_1) }
    p2_library.each { p2.library.add(_1) }
    game.add_players(p1, p2)

    game.start!
  end
end
