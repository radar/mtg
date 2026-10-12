# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrnithopterOfParadise do
  include_context "two player game"

  let!(:thopter) { ResolvePermanent("Ornithopter Of Paradise", owner: p1) }

  it "is a 0/2 flying artifact creature" do
    expect([thopter.power, thopter.toughness]).to eq([0, 2])
    expect(thopter).to be_flying
    expect(thopter.type?("Artifact")).to be true
  end

  it "taps for one mana of any colour" do
    p1.activate_ability(ability: thopter.activated_abilities.first) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
