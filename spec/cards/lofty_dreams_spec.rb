# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LoftyDreams do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "has convoke and can enchant any creature" do
    expect(Card("Lofty Dreams").convoke?).to be(true)

    opponents_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 5)
    aura = Card("Lofty Dreams", owner: p1)
    p1.hand.add(aura)

    p1.cast(card: aura) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2).targeting(opponents_bears) }

    expect(game.stack.spells.map(&:card)).to eq([aura])
  end

  it "draws a card when it enters" do
    library_count = p1.library.count
    p1.add_mana(blue: 5)

    aura = Card("Lofty Dreams", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2).targeting(bears) }
    game.stack.resolve!

    expect(p1.library.count).to eq(library_count - 1)
  end

  it "gives the enchanted creature +2/+2 and flying" do
    p1.add_mana(blue: 5)
    aura = Card("Lofty Dreams", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2).targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(4)
    expect(bears.flying?).to be(true)
  end
end
