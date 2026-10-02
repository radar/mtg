# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaraudingBlightPriest do
  include_context "two player game"

  let!(:priest) { ResolvePermanent("Marauding Blight-Priest", owner: p1) }

  it "is a 3/2 Vampire Cleric" do
    expect([priest.power, priest.toughness]).to eq([3, 2])
  end

  it "makes each opponent lose 1 life whenever you gain life" do
    p1.gain_life(3)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(23)
  end

  it "doesn't trigger when an opponent gains life" do
    p2.gain_life(3)
    game.settle!

    expect(p1.life).to eq(20)
  end
end
