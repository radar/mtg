# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Stab do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:elemental) { ResolvePermanent("Fire Elemental", owner: p2) } # 5/4

  def stab(target)
    p1.add_mana(black: 1)
    p1.cast(card: Card("Stab", owner: p1)) { |a| a.pay_mana(black: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "gives target creature -2/-2 until end of turn" do
    stab(elemental)

    expect([elemental.power, elemental.toughness]).to eq([3, 2])
  end

  it "kills a 2/2" do
    stab(bears)

    expect(bears.card.zone).to be_graveyard
  end

  it "wears off at end of turn" do
    stab(elemental)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([elemental.power, elemental.toughness]).to eq([5, 4])
  end
end
