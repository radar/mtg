require 'spec_helper'

RSpec.describe Magic::Cards::Swamp do
  include_context "two player game"
  subject { ResolvePermanent("Swamp", owner: p1) }

  it "taps for a single white mana" do
    expect(p1).to receive(:add_mana).with(black: 1)
    p1.activate_ability(ability: subject.activated_abilities.first)
    expect(subject).to be_tapped
  end
end
