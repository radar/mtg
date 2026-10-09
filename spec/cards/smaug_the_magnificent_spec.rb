# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmaugTheMagnificent do
  include_context "two player game"

  let!(:smaug) { ResolvePermanent("Smaug The Magnificent", owner: p1) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  # Goes through your upkeep (which makes a Treasure), replaces the Treasures with `count`, then attacks.
  def attack_with_treasures(count)
    skip_to_combat!
    treasures.each(&:sacrifice!)
    count.times { Magic::Tokens::Treasure.new(game: game, owner: p1).resolve! }
    current_turn.declare_attackers!
    current_turn.declare_attacker(smaug, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 4/3 flying, haste Dragon" do
    expect([smaug.power, smaug.toughness]).to eq([4, 3])
    expect(smaug).to have_keyword(:flying)
    expect(smaug).to have_keyword(:haste)
  end

  it "creates a Treasure at the beginning of your upkeep" do
    skip_to_combat!

    expect(treasures.count).to eq(1)
  end

  it "doesn't create a Treasure on an opponent's upkeep" do
    go_to_main_phase_for!(p2)

    expect(treasures).to be_empty
  end

  it "deals damage equal to the number of Treasures you control to any target when it attacks" do
    attack_with_treasures(3)
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(17)
  end

  it "can target a creature" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    attack_with_treasures(2)
    game.resolve_choice!(target: victim)

    expect(victim.card.zone).to be_graveyard
  end

  it "deals no damage with no Treasures" do
    attack_with_treasures(0)
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(20)
  end
end
