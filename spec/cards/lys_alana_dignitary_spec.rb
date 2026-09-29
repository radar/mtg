# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LysAlanaDignitary do
  include_context "two player game"

  let(:card) { Card("Lys Alana Dignitary", owner: p1) }

  def cast_with(payment, mana:)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(mana)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_behold(payment) }
    game.stack.resolve!
  end

  it "is a 2/3 Elf Advisor" do
    dignitary = ResolvePermanent("Lys Alana Dignitary", owner: p1)
    expect([dignitary.power, dignitary.toughness]).to eq([2, 3])
    expect(dignitary.type?("Elf")).to eq(true)
  end

  it "can behold an Elf you control or pay {2} instead" do
    elf = ResolvePermanent("Wood Elves", owner: p1)
    cast_with(elf, mana: { green: 2 })
    expect(card.zone).to be_battlefield
    expect(elf.zone).to be_battlefield
  end

  it "can be cast by paying {2}" do
    cast_with({ generic: { green: 2 } }, mana: { green: 4 })
    expect(card.zone).to be_battlefield
    expect(p1.mana_pool[:green]).to eq(0)
  end

  describe "the mana ability" do
    let!(:dignitary) { ResolvePermanent("Lys Alana Dignitary", owner: p1) }
    let(:ability) { dignitary.activated_abilities.first }

    it "adds {G}{G} when there is an Elf card in your graveyard" do
      p1.graveyard.add(Card("Wood Elves", owner: p1))
      p1.activate_ability(ability: ability)
      expect(p1.mana_pool[:green]).to eq(2)
    end

    it "can't be activated without an Elf card in your graveyard" do
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      p2.graveyard.add(Card("Wood Elves", owner: p2))
      expect { p1.activate_ability(ability: ability) }.to raise_error(Magic::IllegalAction)
    end
  end
end
