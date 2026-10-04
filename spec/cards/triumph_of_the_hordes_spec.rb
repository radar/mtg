# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TriumphOfTheHordes do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.add_mana(green: 4)
    p1.cast(card: Card("Triumph Of The Hordes", owner: p1)) { |a| a.pay_mana(generic: { green: 2 }, green: 2) }
    game.stack.resolve!
    game.tick!
  end

  it "gives creatures you control +1/+1, trample and infect until end of turn" do
    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to have_keyword(:trample)
    expect(bears).to have_keyword(:infect)
  end

  it "doesn't affect opponents' creatures" do
    expect([rival.power, rival.toughness]).to eq([2, 2])
    expect(rival).not_to have_keyword(:infect)
  end

  it "gives poison counters instead of damage when an infect creature hits a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    go_to_combat_damage!

    expect(p2.life).to eq(20)
    expect(p2.counters.of_type(Magic::Counters::Poison).count).to eq(3)
  end
end
