# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DiregrafGhoul do
  include_context "two player game"

  let!(:ghoul) { ResolvePermanent("Diregraf Ghoul", owner: p1) }

  it "is a 2/2 Zombie" do
    expect([ghoul.power, ghoul.toughness]).to eq([2, 2])
  end

  it "enters tapped" do
    expect(ghoul).to be_tapped
  end
end
