# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TavernSwindler do
  include_context "two player game"

  let!(:swindler) { ResolvePermanent("Tavern Swindler", owner: p1) }

  def activate
    p1.activate_ability(ability: swindler.activated_abilities.first)
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 Human Rogue" do
    expect([swindler.power, swindler.toughness]).to eq([2, 2])
  end

  it "pays 3 life and gains 6 when you win the flip" do
    allow(p1).to receive(:flip_coin!).and_return(true)
    activate

    expect(p1.life).to eq(23)
    expect(swindler).to be_tapped
  end

  it "pays 3 life and gains nothing when you lose the flip" do
    allow(p1).to receive(:flip_coin!).and_return(false)
    activate

    expect(p1.life).to eq(17)
  end

  it "flips a real coin when not stubbed" do
    expect([true, false]).to include(p1.flip_coin!)
  end
end
