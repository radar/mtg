# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MischievousMystic do
  include_context "two player game"

  let!(:mystic) { ResolvePermanent("Mischievous Mystic", owner: p1) }

  def faeries(player) = player.creatures.select { _1.name == "Faerie" }

  it "is a 2/1 flying Human Wizard" do
    expect([mystic.power, mystic.toughness]).to eq([2, 1])
    expect(mystic).to be_flying
  end

  it "creates a 1/1 blue Faerie with flying when you draw your second card each turn" do
    2.times { p1.draw! }
    game.settle!

    expect(faeries(p1).count).to eq(1)
    expect(faeries(p1).first).to be_flying
    expect([faeries(p1).first.power, faeries(p1).first.toughness]).to eq([1, 1])
  end

  it "doesn't trigger on the first card" do
    p1.draw!
    game.settle!

    expect(faeries(p1)).to be_empty
  end

  it "only triggers once a turn" do
    3.times { p1.draw! }
    game.settle!

    expect(faeries(p1).count).to eq(1)
  end

  it "ignores the opponent's draws" do
    2.times { p2.draw! }
    game.settle!

    expect(faeries(p1)).to be_empty
  end
end
