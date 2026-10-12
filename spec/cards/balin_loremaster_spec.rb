# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BalinLoremaster do
  include_context "two player game"
  before { go_to_main_phase! }

  def enter(name, owner: p1)
    permanent = ResolvePermanent(name, owner: owner)
    game.settle!
    permanent
  end

  it "is a 4/4 legendary Dwarf Bard" do
    balin = enter("Balin, Loremaster")
    expect(balin.power).to eq(4)
    expect(balin.type?("Dwarf")).to eq(true)
  end

  context "when Balin enters" do
    it "may discard the hand and draw that many cards" do
      balin = enter("Balin, Loremaster")
      hand_size = p1.hand.count
      library_size = p1.library.count
      expect(hand_size).to be > 0
      expect(game.choices.first).to be_a(described_class::DiscardHandChoice)
      game.resolve_choice!
      expect(p1.hand.count).to eq([hand_size, library_size].min)
      expect(p1.graveyard.count).to eq(hand_size)
      expect(p2.life).to eq(20)
      expect(balin).to be_a(Magic::Permanent)
    end

    it "does nothing if declined" do
      enter("Balin, Loremaster")
      hand_size = p1.hand.count
      game.skip_choice!
      expect(p1.hand.count).to eq(hand_size)
      expect(p1.graveyard.count).to eq(0)
    end

    it "deals X damage to each opponent with an enduring story" do
      p1.enduring_story = true
      enter("Balin, Loremaster")
      hand_size = p1.hand.count
      game.resolve_choice!
      game.settle!
      expect(p2.life).to eq(20 - hand_size)
    end
  end

  it "triggers when another Dwarf you control enters, but not for an opponent's Dwarf" do
    enter("Balin, Loremaster")
    game.skip_choice!
    enter("Iron Hills Stalwart", owner: p2)
    expect(game.choices).to be_empty
    enter("Iron Hills Stalwart")
    expect(game.choices.first).to be_a(described_class::DiscardHandChoice)
  end
end
