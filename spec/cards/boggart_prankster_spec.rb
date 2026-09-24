require "spec_helper"

RSpec.describe Magic::Cards::BoggartPrankster do
  include_context "two player game"

  let!(:prankster) { ResolvePermanent("Boggart Prankster", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:idle_goblin) { ResolvePermanent("Boggart Cursecrafter", owner: p1) }

  def attack_with(*creatures)
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
  end

  it "is a 1/3" do
    expect([prankster.power, prankster.toughness]).to eq([1, 3])
  end

  it "gives an attacking Goblin you control +1/+0 whenever you attack" do
    attack_with(prankster, bears)

    expect(game.choices).to be_empty
    expect(prankster.power).to eq(2)
    expect(bears.power).to eq(2)
    expect(idle_goblin.power).to eq(2)
  end

  it "lets you choose among several attacking Goblins" do
    attack_with(prankster, idle_goblin)
    expect(game.choices.last.choices).to contain_exactly(prankster, idle_goblin)

    game.resolve_choice!(target: idle_goblin)
    expect(idle_goblin.power).to eq(3)
    expect(prankster.power).to eq(1)
  end
end
