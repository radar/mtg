# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnflinchingCourage do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.add_mana(green: 1, white: 2)
    p1.cast(card: Card("Unflinching Courage", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, green: 1, white: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "gives the enchanted creature +2/+2, trample and lifelink" do
    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to be_trample
    expect(bears).to be_lifelink
  end

  it "doesn't affect other creatures" do
    expect([other.power, other.toughness]).to eq([2, 2])
    expect(other).not_to be_trample
  end
end
