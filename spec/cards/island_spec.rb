require 'spec_helper'

RSpec.describe Magic::Cards::Island do
  include_context "two player game"

  subject { ResolvePermanent("Island", owner: p1) }

  it "taps for a single blue mana" do
    expect(p1).to receive(:add_mana).with(blue: 1)
    p1.activate_ability(ability: subject.activated_abilities.first)
    expect(subject).to be_tapped
  end
end
