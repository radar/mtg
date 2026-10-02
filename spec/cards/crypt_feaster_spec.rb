# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CryptFeaster do
  include_context "two player game"

  let!(:feaster) { ResolvePermanent("Crypt Feaster", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(feaster, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 3/4 with menace" do
    expect([feaster.power, feaster.toughness]).to eq([3, 4])
    expect(feaster).to be_menace
  end

  it "gets +2/+0 when it attacks with seven or more cards in your graveyard" do
    7.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
    attack!

    expect(feaster.power).to eq(5)
  end

  it "doesn't get the bonus with fewer than seven cards" do
    6.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
    attack!

    expect(feaster.power).to eq(3)
  end
end
