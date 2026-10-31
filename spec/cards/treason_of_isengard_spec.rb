# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TreasonOfIsengard do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Treason Of Isengard", owner: p1) }
  let(:shock) { Card("Shock", owner: p1) }
  let(:duress) { Card("Duress", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:opp_shock) { Card("Shock", owner: p2) }

  def army = p1.creatures.by_type("Army").first

  def cast_spell(*targets)
    p1.hand.add(spell)
    p1.add_mana(blue: 3)
    p1.cast(card: spell) do |a|
      a.pay_mana(generic: { blue: 2 }, blue: 1)
      a.targeting(*targets) if targets.any?
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {2}{U} sorcery" do
    expect(spell.cost.cost).to eq(generic: 2, blue: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "puts a targeted instant from your graveyard on top of your library" do
    p1.graveyard.add(shock)
    cast_spell(shock)

    expect(p1.library.cards.first).to eq(shock)
    expect(shock.zone).to eq(p1.library)
    expect(p1.graveyard.cards).not_to include(shock)
  end

  it "also takes a sorcery" do
    p1.graveyard.add(duress)
    cast_spell(duress)

    expect(p1.library.cards.first).to eq(duress)
  end

  it "does not offer a creature card or an opponent's graveyard card" do
    p1.graveyard.add(bears)
    p2.graveyard.add(opp_shock)
    p1.graveyard.add(shock)

    p1.hand.add(spell)

    expect(spell.target_choices.flatten).to eq([shock])
  end

  it "rejects a creature card as a target" do
    p1.graveyard.add(bears)
    p1.hand.add(spell)
    p1.add_mana(blue: 3)

    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(bears) }
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "rejects a second target" do
    p1.graveyard.add(shock)
    p1.graveyard.add(duress)
    p1.hand.add(spell)
    p1.add_mana(blue: 3)

    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(shock, duress) }
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can be cast with no target and still amasses Orcs 2" do
    p1.graveyard.add(shock)
    cast_spell

    expect(p1.graveyard.cards).to include(shock)
    expect(army.type?("Orc")).to be(true)
    expect(army.colors).to eq([:black])
    expect([army.power, army.toughness]).to eq([2, 2])
  end

  it "amasses after returning the card" do
    p1.graveyard.add(shock)
    cast_spell(shock)

    expect([army.power, army.toughness]).to eq([2, 2])
  end
end
