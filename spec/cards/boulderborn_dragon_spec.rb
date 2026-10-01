# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoulderbornDragon do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Boulderborn Dragon", owner: p1) }

  it "is a 3/3 artifact Dragon with flying and vigilance" do
    expect(dragon).to be_artifact
    expect(dragon.type?("Dragon")).to eq(true)
    expect([dragon.power, dragon.toughness]).to eq([3, 3])
    expect(dragon.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
    expect(dragon.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
  end

  it "surveils 1 when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(dragon, target: p2)
    current_turn.attackers_declared!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(1)

    top = p1.library.first
    game.resolve_choice!(graveyard: [top])
    expect(p1.graveyard.cards).to include(top)
  end

  it "does not surveil when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices.last).not_to be_a(Magic::Choice::Surveil)
  end
end
