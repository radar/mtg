# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FurorOfTheBitten do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def enchant(creature)
    card = Card("Furor Of The Bitten", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { |a| a.pay_mana(red: 1).targeting(creature) }
    game.stack.resolve!
    game.tick!
  end

  it "gives the enchanted creature +2/+2" do
    enchant(bears)

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "makes the enchanted creature attack each combat if able" do
    expect(bears.must_attack?).to eq(false)
    enchant(bears)

    expect(bears.must_attack?).to eq(true)
  end

  it "can enchant an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    enchant(theirs)

    expect([theirs.power, theirs.toughness]).to eq([4, 4])
  end
end
