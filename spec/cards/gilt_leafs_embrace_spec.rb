# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GiltLeafsEmbrace do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attach!
    p1.add_mana(green: 3)
    aura = Card("Gilt-Leaf's Embrace", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(bears) }
    game.stack.resolve!
  end

  it "has flash and can enchant any creature" do
    expect(Card("Gilt-Leaf's Embrace").flash?).to be(true)
  end

  it "gives the enchanted creature trample and indestructible until end of turn when it enters" do
    attach!

    expect(bears.trample?).to be(true)
    expect(bears.indestructible?).to be(true)
  end

  it "gives the enchanted creature +2/+0" do
    attach!

    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(2)
  end
end
