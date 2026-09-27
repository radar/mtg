# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AquitectsDefenses do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attach!
    p1.add_mana(blue: 2)
    aura = Card("Aquitect's Defenses", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(bears) }
    game.stack.resolve!
  end

  it "has flash" do
    expect(Card("Aquitect's Defenses").flash?).to be(true)
  end

  it "can only enchant a creature you control" do
    opponents_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 2)
    aura = Card("Aquitect's Defenses", owner: p1)
    p1.hand.add(aura)

    expect { p1.cast(card: aura) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(opponents_bears) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "gives the enchanted creature hexproof until end of turn when it enters" do
    attach!

    expect(bears.hexproof?).to be(true)
  end

  it "gives the enchanted creature +1/+2" do
    attach!

    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(4)
  end
end
