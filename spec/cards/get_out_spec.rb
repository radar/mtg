# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GetOut do
  include_context "two player game"

  let(:get_out) { Card("Get Out", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(get_out)
  end

  it "counters a creature spell" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.add_mana(green: 2)
    p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    spell = game.stack.spells.first

    p1.add_mana(blue: 2)
    p1.cast(card: get_out) do |action|
      action.pay_mana(blue: 2)
      action.choose_mode(described_class::CounterCreatureOrEnchantment) { |m| m.targeting(spell) }
    end
    game.stack.resolve!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")
  end

  it "cannot target a noncreature, nonenchantment spell with the counter mode" do
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p1) }
    spell = game.stack.spells.first

    mode = described_class::CounterCreatureOrEnchantment.new(game: game, card: get_out)
    expect(mode.target_choices).not_to include(spell)
  end

  it "returns up to two creatures you own to your hand" do
    a = ResolvePermanent("Grizzly Bears", owner: p1)
    b = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    p1.add_mana(blue: 2)
    p1.cast(card: get_out) do |action|
      action.pay_mana(blue: 2)
      action.choose_mode(described_class::ReturnToHand) { |m| m.targeting(a, b) }
    end
    game.stack.resolve!
    game.settle!

    expect(p1.creatures).to be_empty
    expect(p1.hand.map(&:name).count("Grizzly Bears")).to eq(2)
    expect(p2.creatures).to include(theirs)
  end

  it "cannot return a creature you do not own" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    mode = described_class::ReturnToHand.new(game: game, card: get_out)
    expect(mode.target_choices).not_to include(theirs)
  end
end
