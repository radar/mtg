# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PossessedGoat do
  include_context "two player game"

  let!(:goat) { ResolvePermanent("Possessed Goat", owner: p1) }

  def transform
    discard = p1.hand.cards.first
    p1.add_mana(white: 3)
    p1.activate_ability(ability: goat.activated_abilities.first) do |a|
      a.pay_mana(generic: { white: 3 })
      a.pay_discard(discard)
    end
    game.stack.resolve!
    game.tick!
    discard
  end

  it "is a white 1/1 Goat for {W}" do
    expect([goat.power, goat.toughness]).to eq([1, 1])
    expect(goat.type?("Goat")).to be(true)
    expect(goat.colors).to eq([:white])
  end

  it "gets three +1/+1 counters and becomes a black Demon in addition, discarding a card" do
    discard = transform

    expect([goat.power, goat.toughness]).to eq([4, 4])
    expect(goat.type?("Demon")).to be(true)
    expect(goat.type?("Goat")).to be(true)
    expect(goat.colors).to contain_exactly(:white, :black)
    expect(discard.zone).to be_graveyard
  end

  it "can be activated only once" do
    transform
    p1.add_mana(white: 3)

    expect do
      p1.activate_ability(ability: goat.activated_abilities.first) do |a|
        a.pay_mana(generic: { white: 3 })
        a.pay_discard(p1.hand.cards.first)
      end
    end.to raise_error(Magic::IllegalAction)
  end
end
