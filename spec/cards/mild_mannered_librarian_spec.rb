# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MildManneredLibrarian do
  include_context "two player game"

  let!(:librarian) { ResolvePermanent("Mild Mannered Librarian", owner: p1) }

  def transform
    p1.add_mana(green: 4)
    p1.activate_ability(ability: librarian.activated_abilities.first) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 1/1 Human for {G}" do
    expect([librarian.power, librarian.toughness]).to eq([1, 1])
    expect(librarian.type?("Human")).to be(true)
    expect(Card("Mild Mannered Librarian", owner: p1).cost.cost).to eq(green: 1)
  end

  it "becomes a Werewolf (no longer a Human) with two +1/+1 counters and draws a card for {3}{G}" do
    hand = p1.hand.count
    transform

    expect(librarian.type?("Werewolf")).to be(true)
    expect(librarian.type?("Human")).to be(false)
    expect(librarian.type?("Creature")).to be(true)
    expect([librarian.power, librarian.toughness]).to eq([3, 3])
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "can be activated only once" do
    transform
    p1.add_mana(green: 4)

    expect { p1.activate_ability(ability: librarian.activated_abilities.first) { |a| a.pay_mana(generic: { green: 3 }, green: 1) } }
      .to raise_error(Magic::IllegalAction)
    expect([librarian.power, librarian.toughness]).to eq([3, 3])
  end

  it "stays a Werewolf past the end of the turn" do
    transform
    current_turn.end!
    current_turn.cleanup!

    expect(librarian.type?("Werewolf")).to be(true)
    expect(librarian.type?("Human")).to be(false)
  end

  it "stops being a Human for things that care: Stromkirk Noble can't be blocked by Humans" do
    noble = ResolvePermanent("Stromkirk Noble", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(noble, target: p1)
    current_turn.attackers_declared!

    expect { current_turn.declare_blocker(librarian, attacker: noble) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    transform
    expect { current_turn.declare_blocker(librarian, attacker: noble) }.not_to raise_error
  end
end
