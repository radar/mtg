require 'spec_helper'

RSpec.describe Magic::Cards::Island do
  include_context "two player game"

  subject { ResolvePermanent("Island", controller: p1) }

  it "taps for a single blue mana" do
    expect(p1).to receive(:add_mana).with(blue: 1)
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
    action.pay_tap
    game.take_action(action)
  end
end
