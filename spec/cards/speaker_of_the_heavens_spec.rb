require 'spec_helper'

RSpec.describe Magic::Cards::SpeakerOfTheHeavens do
  include_context "two player game"

  subject(:speaker_of_the_heavens) { ResolvePermanent("Speaker Of The Heavens", owner: p1) }

  it "has vigilance and lifelink" do
    expect(subject).to be_lifelink
    expect(subject).to be_vigilant

  end

  it "activated ability" do
    p1.gain_life(7)
    ability = speaker_of_the_heavens.activated_abilities.first
    action = p1.prepare_activate_ability(ability: ability)
    expect(action.can_be_activated?(p1)).to eq(true)
    action.pay_tap
    action.finalize_costs!(p1)
    game.take_action(action)
    game.tick!

    angels = game.battlefield.creatures.by_name("Angel")
    expect(angels.count).to eq(1)
    angel = angels.first
    expect(angel.colors).to eq([:white])
    expect(angel).to be_flying
    expect(angel.power).to eq(4)
    expect(angel.toughness).to eq(4)
  end
end
