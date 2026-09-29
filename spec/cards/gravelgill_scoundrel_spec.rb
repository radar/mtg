# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GravelgillScoundrel do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:scoundrel) { ResolvePermanent("Gravelgill Scoundrel", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(scoundrel, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 1/3 vigilance Merfolk Rogue" do
    expect([scoundrel.power, scoundrel.toughness]).to eq([1, 3])
    expect(scoundrel).to be_vigilant
  end

  it "may tap another untapped creature you control; if you do, it can't be blocked this turn" do
    helper = ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack!
    game.resolve_choice! # yes
    game.tick!

    expect(helper).to be_tapped
    expect { current_turn.declare_blocker(blocker, attacker: scoundrel) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "stays blockable when you decline" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack!
    game.skip_choice!
    game.tick!

    expect { current_turn.declare_blocker(blocker, attacker: scoundrel) }.not_to raise_error
  end

  it "offers nothing without another untapped creature" do
    attack!

    expect(game.choices).to be_empty
  end

  it "ignores tapped creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1).tap!
    attack!

    expect(game.choices).to be_empty
  end
end
