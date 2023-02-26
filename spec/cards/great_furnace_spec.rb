require 'spec_helper'

RSpec.describe Magic::Cards::GreatFurnace do
  include_context "two player game"

  subject { ResolvePermanent("Great Furnace", owner: p1) }

  it "taps for red mana" do
    expect(p1).to receive(:add_mana).with(red: 1)
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
    action.pay_tap
    game.take_action(action)
    expect(subject).to be_tapped
  end

  it "is an artifact" do
    expect(subject).to be_an_artifact
  end
end
