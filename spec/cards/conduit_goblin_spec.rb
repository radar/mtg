require "spec_helper"

RSpec.describe Magic::Cards::ConduitGoblin do
  include_context "two player game"

  let!(:goblin) { ResolvePermanent("Conduit Goblin", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true) }

  it "is a 2/2" do
    expect([goblin.power, goblin.toughness]).to eq([2, 2])
  end

  it "gives you two energy counters when it enters" do
    expect(p1.energy).to eq(2)
  end

  it "pays {E} at the beginning of combat to give another creature +1/+0 and haste" do
    skip_to_combat!
    game.resolve_choice!
    game.tick!

    expect(p1.energy).to eq(1)
    expect(bears.power).to eq(3)
    expect(bears).to be_haste
    expect(goblin.power).to eq(2)
  end

  it "does nothing when you decline" do
    skip_to_combat!
    game.skip_choice!
    game.tick!

    expect(p1.energy).to eq(2)
    expect(bears.power).to eq(2)
  end

  it "offers nothing without energy" do
    p1.pay_energy!(2)
    skip_to_combat!

    expect(game.choices).to be_empty
  end

  it "doesn't trigger at the beginning of the opponent's combat" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!

    expect(game.choices).to be_empty
  end
end
