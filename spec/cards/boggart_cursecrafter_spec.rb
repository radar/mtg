require "spec_helper"

RSpec.describe Magic::Cards::BoggartCursecrafter do
  include_context "two player game"

  let!(:cursecrafter) { ResolvePermanent("Boggart Cursecrafter", owner: p1) }

  it "is a 2/3 deathtouch Goblin Warlock" do
    expect([cursecrafter.power, cursecrafter.toughness]).to eq([2, 3])
    expect(cursecrafter).to be_deathtouch
  end

  it "deals 1 damage to each opponent whenever another Goblin you control dies" do
    goblin = ResolvePermanent("Boggart Prankster", owner: p1)
    goblin.destroy!
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "ignores non-Goblins, an opponent's Goblin and itself" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    ResolvePermanent("Boggart Prankster", owner: p2).destroy!
    cursecrafter.destroy!
    game.settle!

    expect(p2.life).to eq(20)
  end
end
