# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated bounce, counter, tap, mill, search, blocking and conditions in play" do
  include CardParserHelpers
  include_context "two player game"

  def p1_library
    # The first seven are the opening hand.
    [*7.times.map { Card("Forest") }, Card("Forest"), Card("Wood Elves"), Card("Forest")]
  end

  # Casts a generated spell paying {N}{C} (or just {C}) with colour C only.
  def cast(name, color, generic = 0, player: p1, &block)
    card = Card(name, owner: player)
    player.hand.add(card)
    player.add_mana(color => generic + 1)
    payment = generic.zero? ? { color => 1 } : { generic: { color => generic }, color => 1 }
    player.cast(card:) do |action|
      action.pay_mana(payment)
      block&.call(action)
    end
  end

  it "returns target creature to its owner's hand" do
    load_card("Parsed Unsummon {U}\nInstant\nReturn target creature to its owner's hand.\n")
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast("Parsed Unsummon", :blue) { _1.targeting(bears) }
    game.stack.resolve!

    expect(bears.card.zone).to be_hand
    expect(p2.hand.map(&:name)).to include("Grizzly Bears")
  end

  it "counters a creature spell, and can't target a noncreature one" do
    load_card("Parsed Scatter {1}{U}\nInstant\nCounter target creature spell.\n")
    go_to_main_phase_for!(p2)
    elves = Card("Llanowar Elves", owner: p2)
    p2.hand.add(elves)
    p2.add_mana(green: 1)
    elves_spell = p2.cast(card: elves) { _1.pay_mana(green: 1) }

    scatter = Card("Parsed Scatter", owner: p1)
    expect(scatter.target_choices).to eq([elves_spell])
    p1.hand.add(scatter)
    p1.add_mana(blue: 2)
    p1.cast(card: scatter) { _1.pay_mana(generic: { blue: 1 }, blue: 1).targeting(elves_spell) }
    game.stack.resolve!
    game.stack.resolve!

    expect(elves.zone).to be_graveyard
    expect(p2.creatures).to be_empty
  end

  it "taps target creature" do
    load_card("Parsed Frost {U}\nInstant\nTap target creature an opponent controls.\n")
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast("Parsed Frost", :blue) { _1.targeting(bears) }
    game.stack.resolve!

    expect(bears).to be_tapped
  end

  it "makes target player mill" do
    load_card("Parsed Sculpt {U}\nInstant\nTarget player mills three cards.\n")
    library_size = p2.library.count
    milled = p2.library.first(3)
    cast("Parsed Sculpt", :blue) { _1.targeting(p2) }
    game.stack.resolve!

    expect(p2.library.count).to eq(library_size - 3)
    expect(milled.map(&:zone)).to all(be_graveyard)
  end

  it "searches the library for a creature card and puts it into your hand" do
    load_card("Parsed Tutor {1}{G}\nSorcery\nSearch your library for a creature card, reveal it, put it into your hand, then shuffle.\n")
    go_to_main_phase!
    elves = p1.library.find { _1.name == "Wood Elves" }
    cast("Parsed Tutor", :green, 1)
    game.stack.resolve!
    choice = game.choices.last
    expect(choice.choices).to contain_exactly(elves)
    game.resolve_choice!(targets: [elves])

    expect(elves.zone).to be_hand
  end

  context "with a generated creature that can't be blocked and can't block" do
    let!(:rat) do
      load_card("Parsed Rat {1}{B}\nCreature — Rat\nParsed Rat can't be blocked.\nParsed Rat can't block.\n1/1\n")
      ResolvePermanent("Parsed Rat", owner: p1)
    end

    it "can't be blocked" do
      blocker = ResolvePermanent("Wood Elves", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(rat, target: p2)
      current_turn.attackers_declared!

      expect { current_turn.declare_blocker(blocker, attacker: rat) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    end

    it "can't block" do
      attacker = ResolvePermanent("Grizzly Bears", owner: p2)
      go_to_main_phase_for!(p2)
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p1)
      current_turn.attackers_declared!

      expect { current_turn.declare_blocker(rat, attacker: attacker) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    end
  end

  it "has flying only as long as you control another artifact" do
    load_card("Parsed Gearsmith {2}\nArtifact Creature — Construct\nParsed Gearsmith has flying as long as you control another artifact.\n1/1\n")
    gearsmith = ResolvePermanent("Parsed Gearsmith", owner: p1)
    game.tick!
    expect(gearsmith).not_to be_flying

    stone = ResolvePermanent("Mind Stone", owner: p1)
    game.tick!
    expect(gearsmith).to be_flying

    stone.destroy!
    game.tick!
    expect(gearsmith).not_to be_flying
  end
end
