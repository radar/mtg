require 'spec_helper'

RSpec.describe Magic::Cards::BirdsOfParadise do
  include_context "two player game"

  subject { ResolvePermanent("Birds of Paradise", owner: p1) }

  it "has flying" do
    expect(subject).to be_flying
  end

  it "can be tapped for one mana of any color" do
    ability = subject.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(subject).to be_tapped
  end
end
