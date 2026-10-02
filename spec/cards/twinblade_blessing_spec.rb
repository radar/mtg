# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwinbladeBlessing do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.add_mana(white: 3)
    p1.cast(card: Card("Twinblade Blessing", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 2).targeting(bears) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "has flash" do
    expect(Card("Twinblade Blessing", owner: p1).has_keyword?(:flash)).to eq(true)
  end

  it "gives the enchanted creature double strike" do
    expect(bears).to be_double_strike
  end

  it "doesn't affect other creatures" do
    expect(other).not_to be_double_strike
  end

  it "stops when the Aura leaves the battlefield" do
    p1.permanents.by_name("Twinblade Blessing").first.destroy!
    game.settle!
    game.tick!

    expect(bears).not_to be_double_strike
  end
end
