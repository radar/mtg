require 'spec_helper'

RSpec.describe Magic::Cards::LathrilBladeOfTheElves do
  include_context "two player game"

  subject! { ResolvePermanent("Lathril, Blade Of The Elves", owner: p1) }

  it "has menace" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::MENACE)
  end

  it "activated ability" do
    elves = 10.times.map do
      token = Magic::Tokens::ElfWarrior.new(game: game)
      token.resolve!(p1)
    end

    action = Magic::Actions::ActivateAbility.new(permanent: subject, ability: subject.activated_abilities.first, player: p1)
    action.pay_multi_tap(elves)
    game.take_action(action)
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

      expect(game.battlefield.creatures.controlled_by(p1).count).to eq(3)
    end
  end
end