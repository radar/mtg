# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WalkingCorpse do
  include_context "two player game"

  it "is a 2/2 Zombie" do
    corpse = ResolvePermanent("Walking Corpse", owner: p1)

    expect([corpse.power, corpse.toughness]).to eq([2, 2])
    expect(corpse.type?("Zombie")).to eq(true)
  end
end
