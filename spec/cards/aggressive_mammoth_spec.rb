# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AggressiveMammoth do
  include_context "two player game"

  let!(:mammoth) { ResolvePermanent("Aggressive Mammoth", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { game.tick! }

  it "is an 8/8 trampler" do
    expect([mammoth.power, mammoth.toughness]).to eq([8, 8])
    expect(mammoth).to be_trample
  end

  it "gives other creatures you control trample" do
    expect(bears).to be_trample
  end

  it "doesn't give opponents' creatures trample" do
    expect(rival).not_to be_trample
  end
end
