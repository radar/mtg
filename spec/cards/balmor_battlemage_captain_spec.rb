# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BalmorBattlemageCaptain do
  include_context "two player game"

  let!(:balmor) { ResolvePermanent("Balmor Battlemage Captain", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_strike
    p1.add_mana(red: 2)
    p1.cast(card: Card("Sure Strike", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
    game.settle!
    game.tick!
  end

  it "is a 1/3 flyer" do
    expect([balmor.power, balmor.toughness]).to eq([1, 3])
    expect(balmor).to be_flying
  end

  it "gives creatures you control +1/+0 and trample when you cast an instant" do
    cast_strike

    expect(bears.power).to eq(6) # 2 + 3 from Sure Strike + 1 from Balmor
    expect(bears).to be_trample
    expect(balmor.power).to eq(2)
  end

  it "doesn't affect opponents' creatures" do
    cast_strike

    expect(rival.power).to eq(2)
    expect(rival).not_to be_trample
  end

  it "doesn't trigger on a creature spell" do
    p1.add_mana(green: 2)
    go_to_main_phase!
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
