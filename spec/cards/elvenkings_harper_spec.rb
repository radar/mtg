# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenkingsHarper do
  include_context "two player game"

  let!(:harper) { ResolvePermanent("Elvenking's Harper", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 2/2 Elf Bard" do
    expect([harper.power, harper.toughness]).to eq([2, 2])
    expect(harper.type?("Elf")).to eq(true)
  end

  it "makes target creature unblockable this turn for {4}{U}" do
    p1.add_mana(blue: 5)
    p1.activate_ability(ability: harper.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { blue: 4 }, blue: 1)
    end
    game.stack.resolve!
    game.tick!

    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    expect { current_turn.declare_blocker(blocker, attacker: bears) }.to raise_error(StandardError)
  end
end
