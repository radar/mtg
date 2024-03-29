require 'spec_helper'

RSpec.describe Magic::Cards::LathrilBladeOfTheElves do
  include_context "two player game"

  subject! { ResolvePermanent("Lathril, Blade Of The Elves", owner: p1) }

  it "has menace" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::MENACE)
  end

  it "activated ability" do
    elves = 10.times.map do
      described_class::ElfWarriorToken.new(game: game, owner: p1, base_power: 1, base_toughness: 1).resolve!(enters_tapped: false)
    end

    p1.activate_ability(ability: subject.activated_abilities.first) do
      _1.pay_multi_tap(elves)
    end
    game.stack.resolve!

    expect(p1.life).to eq(p1.starting_life + 10)
    expect(p2.life).to eq(p2.starting_life - 10)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "create elves based on combat damage dealt" do
      current_turn.declare_attackers!

      current_turn.declare_attacker(
        subject,
        target: p2,
      )

      go_to_combat_damage!

      expect(creatures.controlled_by(p1).count).to eq(3)
    end
  end
end
