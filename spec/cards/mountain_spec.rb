require 'spec_helper'

RSpec.describe Magic::Cards::Mountain do
  include_context "two player game"
  subject { ResolvePermanent("Mountain", owner: p1) }

  it "taps for a single red mana" do
    expect(p1).to receive(:add_mana).with(red: 1)
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
    action.pay_tap
    game.take_action(action)
    expect(subject).to be_tapped
  end
end
