require 'spec_helper'

RSpec.describe Magic::Cards::Mountain do
  include_context "two player game"
  subject { ResolvePermanent("Mountain", owner: p1) }

  it "taps for a single red mana" do
    expect(p1).to receive(:add_mana).with(red: 1)
    p1.activate_ability(ability: subject.activated_abilities.first)
    expect(subject).to be_tapped
  end
end
