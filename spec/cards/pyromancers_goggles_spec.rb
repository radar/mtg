# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PyromancersGoggles do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:goggles) { ResolvePermanent("Pyromancer's Goggles", owner: p1) }
  let(:bolt) { Card("Lightning Bolt", owner: p1) }

  before { p1.hand.add(bolt) }

  def tap_goggles_for_red!
    p1.activate_ability(ability: goggles.activated_abilities.first)
  end

  it "taps for red" do
    tap_goggles_for_red!

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "copies a red instant or sorcery spell cast with that mana, offering new targets for the copy" do
    tap_goggles_for_red!
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    game.skip_choice!
    game.stack.resolve!

    expect(p2.life).to eq(20 - 3 - 3)
  end

  it "may choose new targets for the copy" do
    tap_goggles_for_red!
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    game.resolve_choice!
    game.resolve_choice!(target: p1)
    game.stack.resolve!

    expect(p1.life).to eq(17)
    expect(p2.life).to eq(17)
  end

  it "does not copy a spell cast without tapping the goggles first" do
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(17)
  end

  it "does not copy a nonred spell" do
    tap_goggles_for_red!
    p1.add_mana(green: 2)
    bear = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bear)

    p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    expect(game.choices).to be_empty
    expect(p1.creatures.count).to eq(1)
  end

  it "only copies once per activation" do
    tap_goggles_for_red!
    other_bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(other_bolt)
    p1.add_mana(red: 1)

    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.skip_choice!
    game.stack.resolve!

    p1.cast(card: other_bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(20 - 3 - 3 - 3)
  end
end
