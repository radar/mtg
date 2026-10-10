# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HandThatFeeds do
  include_context "two player game"

  let!(:hand) { ResolvePermanent("Hand That Feeds", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hand, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a 2/2 Mutant without menace" do
    expect([hand.power, hand.toughness]).to eq([2, 2])
    expect(hand.type?("Mutant")).to be true
    expect(hand).not_to be_menace
  end

  it "gets +2/+0 and menace when it attacks with delirium" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
    attack!

    expect(hand.power).to eq(4)
    expect(hand).to be_menace
  end

  it "gets nothing when it attacks without delirium" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")
    attack!

    expect(hand.power).to eq(2)
    expect(hand).not_to be_menace
  end
end
