# frozen_string_literal: true
require "pry"
require "magic"

module CardHelper
  def Card(name, owner: p1, **args)
    Magic::Cards.const_get(name.gsub("\sof\s", "Of").gsub(/[^a-z]/i, "").gsub(/\s(a-z)/) { $1.upcase }).new(game: game, owner:, **args)
  end

  def Permanent(name, **args)
    Magic::Permanent.new(game: game, card: Card(name), **args)
  end

  def ResolvePermanent(name, **args)
    card = Card(name)
    Magic::Permanent.resolve(game: game, card: card, **args)
  end

  def AddLand(name, **args)

  end

  def add_to_library(name, player:)
    card = Card(name, owner: player)
    player.library.add(card)
    card
  end

  def cast_action(card:, player: card.owner, targeting: nil, &block)
    action = Magic::Actions::Cast.new(card: card, player: player, game: game)
    action.targeting(targeting) if targeting
    yield action if block_given?
    action
  end

  def add_to_stack_and_resolve(action)
    game.stack.add(action)
    game.stack.resolve!
  end

  def cast_and_resolve(card:, player: card.owner, targeting: nil, &block)
    action = cast_action(card: card, player: player, targeting: targeting, &block)
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

  def go_to_main_phase!
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
  end

  def skip_to_combat!
    go_to_main_phase!
    current_turn.beginning_of_combat!
  end

  def go_to_combat_damage!
    current_turn.attackers_declared! if current_turn.step?(:declare_attackers)
    current_turn.combat_damage! if current_turn.step?(:declare_blockers)
  end

  def creatures
    game.battlefield.creatures
  end

  def add_to_battlefield(permanent)
    game.battlefield.add(permanent)
    game.tick!
  end

  before do
    p1_library.each_with_index { p1.library.add(_1, _2) }
    p2_library.each_with_index { p2.library.add(_1, _2) }
    game.add_players(p1, p2)

    game.start!
  end
end
