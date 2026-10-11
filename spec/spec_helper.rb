# frozen_string_literal: true
require "pry"
require "magic"

module CardHelper
  def Card(name, owner: p1, **args)
    Magic::Cards.const_get(name.gsub("\sof\s", "Of").gsub(/[^a-z]/i, "").gsub(/\s(a-z)/) { $1.upcase }).new(game: game, owner:, **args)
  end

  # Permanents built by the spec helpers count as having been on the battlefield since before the
  # game's first turn, so they are not summoning sick. Pass summoning_sick: true to opt out.
  def Permanent(name, summoning_sick: false, **args)
    permanent = Magic::Permanent.new(game: game, card: Card(name), **args)
    permanent.controlled_since_turn = 0 unless summoning_sick
    permanent
  end

  # settle: false opts out of the auto-settle below -- needed when a spec is mid-way
  # through building up other pending stack items/choices it wants to stay pending
  # (settling would resolve them out from under it).
  # A spell resolving by default; `cast: false` puts the card onto the battlefield as an effect would, and
  # `token: true` or `copy: true` makes a token copy of it. `doors: [:left]` puts a Room onto the battlefield with those
  # doors unlocked.
  def ResolvePermanent(name, summoning_sick: false, settle: true, cast: true, token: false, copy: false, doors: nil, **args)
    card = Card(name, owner: args.fetch(:owner, p1))
    card.preunlock!(*doors) if doors
    permanent =
      if token || copy
        Magic::Permanent.token_copy(game: game, card: card, **args)
      elsif cast
        Magic::Permanent.resolve_spell(game: game, card: card, **args)
      else
        Magic::Permanent.put_onto_battlefield(game: game, card: card, **args)
      end
    permanent.controlled_since_turn = 0 unless summoning_sick
    # Skip auto-settling for Auras: fixtures often build one unattached and call
    # #attach_to! as a separate step, and settling in between would kill it to SBA
    # 704.5m before it's actually attached.
    if settle && !(permanent.card.is_a?(Magic::Cards::Aura) || permanent.type?("Aura"))
      game.settle!
    end
    permanent
  end

  def AddLand(name, **args)

  end

  def add_to_library(name, player:)
    card = Card(name, owner: player)
    player.library.add(card)
    card
  end

  def cast_action(card:, player: card.owner, targeting: nil, &block)
    cast_action_as(:normal, card:, player:, targeting:, &block)
  end

  def cast_action_as(mode, card:, player: card.owner, targeting: nil, &block)
    action = Magic::Actions::Cast.for_mode(mode).new(card: card, player: player, game: game)
    action.targeting(targeting) if targeting
    yield action if block_given?
    action
  end

  def add_to_stack_and_resolve(action)
    game.stack.add(action)
    game.settle!
  end

  def cast_and_resolve(card:, player: card.owner, targeting: nil, &block)
    action = cast_action(card: card, player: player, targeting: targeting, &block)
    game.stack.add(action)
    game.settle!
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
    14.times.map { Card("Forest") }
  end

  def p2_library
    14.times.map { Card("Mountain", owner: p2) }
  end

  def current_turn
    game.current_turn
  end

  def go_to_main_phase!
    return if current_turn.main_phase?

    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
  end

  # Advance to the given player's next turn and go to their first main phase.
  def go_to_main_phase_for!(player)
    game.next_turn until current_turn.active_player == player
    go_to_main_phase!
  end

  # The cleanup step makes a player holding more than seven cards discard (rule 514.1); a spec that
  # ends a turn with a big hand answers those pending discards (first cards in hand) to carry on.
  def resolve_cleanup_discards!
    while (choice = game.choices.last).is_a?(Magic::Choice::Discard)
      game.resolve_choice!(card: choice.player.hand.first)
    end
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

  # The two things that set off Eerie for p1: an enchantment entering, and fully unlocking a Room.
  # Sanctum of Calm Waters is legendary: a second one makes the legend rule ask a question, so pass another enchantment
  # ("Elderfang Venom") to enter two in one spec.
  def eerie_enchantment_enters!(name = "Sanctum Of Calm Waters")
    ResolvePermanent(name, owner: p1)
    game.settle!
  end

  # A Room that is a permanent already, so that entering is not what sets Eerie off while a spec measures the unlock.
  def eerie_room
    go_to_main_phase!
    ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:right])
  end

  def eerie_fully_unlock_room!(room = eerie_room)
    go_to_main_phase!
    p1.add_mana(black: 3)
    p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.settle!
  end

  before do
    p1_library.each_with_index { p1.library.add(_1, _2) }
    p2_library.each_with_index { p2.library.add(_1, _2) }
    game.add_players(p1, p2)

    game.start!
  end
end
