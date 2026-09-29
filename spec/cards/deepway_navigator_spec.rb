# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeepwayNavigator do
  include_context "two player game"

  let!(:shorethief_1) { ResolvePermanent("Triton Shorethief", owner: p1) }
  let!(:shorethief_2) { ResolvePermanent("Triton Shorethief", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/2 Merfolk Wizard with flash" do
    navigator = ResolvePermanent("Deepway Navigator", owner: p1)
    expect([navigator.power, navigator.toughness]).to eq([2, 2])
    expect(navigator.has_keyword?(:flash)).to eq(true)
    expect(navigator.type?("Merfolk")).to eq(true)
  end

  it "untaps each other Merfolk you control when it enters, not other creatures or itself" do
    [shorethief_1, bears].each(&:tap!)
    rival = ResolvePermanent("Triton Shorethief", owner: p2)
    rival.tap!
    navigator = ResolvePermanent("Deepway Navigator", owner: p1)

    expect(shorethief_1).to be_untapped
    expect(bears).to be_tapped
    expect(rival).to be_tapped
    expect(navigator).to be_untapped
  end

  context "once it's on the battlefield" do
    let!(:navigator) { ResolvePermanent("Deepway Navigator", owner: p1) }

    def attack_with(*attackers)
      skip_to_combat!
      current_turn.declare_attackers!
      attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
      current_turn.attackers_declared!
      game.tick!
    end

    it "gives Merfolk you control +1/+0 after you attack with three or more Merfolk" do
      attack_with(navigator, shorethief_1, shorethief_2)

      expect(shorethief_1.power).to eq(2)
      expect(navigator.power).to eq(3)
      expect(bears.power).to eq(2)
    end

    it "doesn't with only two Merfolk attacking" do
      attack_with(navigator, shorethief_1, bears)

      expect(shorethief_1.power).to eq(1)
      expect(navigator.power).to eq(2)
    end

    it "doesn't before attackers are declared" do
      game.tick!
      expect(shorethief_1.power).to eq(1)
    end
  end
end
