# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VodalianArcanist do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:arcanist) { ResolvePermanent("Vodalian Arcanist", owner: p1) }

  def tap_for_mana
    p1.activate_ability(ability: arcanist.activated_abilities.first)
  end

  it "is a 1/3 Merfolk Wizard" do
    expect([arcanist.power, arcanist.toughness]).to eq([1, 3])
  end

  it "adds {C} that can be spent on an instant" do
    tap_for_mana
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 0)

    expect(p1.restricted_mana.count).to eq(1)
    expect { p1.cast(card: bolt) { |a| a.pay_mana(red: 1) } }.to raise_error(StandardError) # still needs {R}
  end

  it "can pay the generic part of a sorcery" do
    tap_for_mana
    spell = Card("Mind Rot", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 3)

    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { colorless: 1, black: 1 }, black: 1).targeting(p2) }
    end.not_to raise_error
  end

  it "can't be spent on a creature spell" do
    tap_for_mana
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.add_mana(green: 1)

    expect { p1.cast(card: bears) { |a| a.pay_mana(generic: { colorless: 1 }, green: 1) } }.to raise_error(StandardError)
  end
end
