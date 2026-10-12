# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WickerfolkThresher do
  include_context "two player game"

  let!(:thresher) { ResolvePermanent("Wickerfolk Thresher", owner: p1) }

  def fill_graveyard
    %w[Wood\ Elves Sol\ Ring Glorious\ Anthem Island].each do |name|
      card = Card(name, owner: p1)
      p1.graveyard.add(card)
    end
  end

  # Library cards are added after the draw step, which skip_to_combat! passes through.
  before { skip_to_combat! }

  def attack_with(creature)
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 5/4 artifact creature" do
    expect(thresher.power).to eq(5)
    expect(thresher.toughness).to eq(4)
    expect(thresher).to be_artifact
  end

  it "does nothing without delirium" do
    top = add_to_library("Island", player: p1)
    attack_with(thresher)
    expect(game.choices).to be_empty
    expect(top.zone).to eq(p1.library)
  end

  context "with delirium" do
    before { fill_graveyard }

    it "puts a nonland top card into your hand" do
      top = add_to_library("Wood Elves", player: p1)
      attack_with(thresher)
      expect(top.zone).to eq(p1.hand)
    end

    it "lets you put a land top card onto the battlefield" do
      top = add_to_library("Island", player: p1)
      attack_with(thresher)
      game.resolve_choice!
      expect(top.zone).to be_battlefield
    end

    it "puts a land into your hand if you decline" do
      top = add_to_library("Island", player: p1)
      attack_with(thresher)
      game.skip_choice!
      expect(top.zone).to eq(p1.hand)
    end
  end
end
