# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WitchKingBringerOfRuin do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:king) { ResolvePermanent("Witch King Bringer Of Ruin", owner: p1) }

  def attack(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a legendary 5/3 flying Wraith Noble" do
    expect([king.power, king.toughness]).to eq([5, 3])
    expect(king).to have_keyword(:flying)
    expect(king.card).to be_legendary
    expect(king.type?("Wraith")).to be(true)
    expect(king.type?("Noble")).to be(true)
  end

  it "makes the defending player sacrifice their only least-power creature without a choice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    goblin = ResolvePermanent("Raging Goblin", owner: p2)
    attack(king)

    expect(game.choices).to be_empty
    expect(p2.creatures).to eq([bears])
    expect(p2.graveyard.cards).to include(goblin.card)
  end

  it "lets the defending player choose among creatures tied for least power" do
    goblin1 = ResolvePermanent("Raging Goblin", owner: p2)
    goblin2 = ResolvePermanent("Raging Goblin", owner: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    attack(king)

    choice = game.choices.first
    expect(choice.chooser).to eq(p2)
    expect(choice.choices.to_a).to contain_exactly(goblin1, goblin2)
    expect { game.resolve_choice!(target: bears) }.to raise_error(ArgumentError)

    game.resolve_choice!(target: goblin2)
    game.settle!

    expect(p2.creatures).to contain_exactly(goblin1, bears)
  end

  it "makes the sacrifice mandatory" do
    ResolvePermanent("Raging Goblin", owner: p2)
    ResolvePermanent("Raging Goblin", owner: p2)
    attack(king)
    game.skip_choice!
    game.settle!

    expect(p2.creatures.size).to eq(1)
  end

  it "does not touch the attacker's other creatures" do
    mine = ResolvePermanent("Raging Goblin", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    attack(king)

    expect(p1.creatures).to include(mine)
    expect(p2.creatures).not_to include(theirs)
  end

  it "does nothing when the defending player has no creatures" do
    attack(king)

    expect(game.choices).to be_empty
    expect(p1.creatures).to eq([king])
  end

  it "does not trigger when another creature attacks" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    attack(other)

    expect(game.choices).to be_empty
    expect(p2.creatures).to eq([bears])
  end
end
