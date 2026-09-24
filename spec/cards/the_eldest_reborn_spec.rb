require "spec_helper"

RSpec.describe Magic::Cards::TheEldestReborn do
  include_context "two player game"

  let!(:opponents_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:opponents_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:opponents_forest) { ResolvePermanent("Forest", owner: p2) }
  let(:card) { Card("The Eldest Reborn", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 5)
    p1.cast(card: card) { _1.pay_mana(black: 1, generic: { black: 4 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  let(:saga) { game.battlefield.by_name("The Eldest Reborn").first }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "enters with a lore counter" do
    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end

  it "I — each opponent sacrifices a creature or planeswalker of their choice" do
    choice = game.choices.last
    expect(choice.choices).to contain_exactly(opponents_bears, opponents_elves)

    game.resolve_choice!(target: opponents_elves)
    expect(p2.graveyard.by_name("Wood Elves").count).to eq(1)
    expect(opponents_bears.zone).to be_battlefield
    expect(opponents_forest.zone).to be_battlefield
  end

  context "after chapter I" do
    before { game.resolve_choice!(target: opponents_bears) }

    it "II — each opponent discards a card" do
      next_chapter

      expect(game.choices.last).to be_a(Magic::Choice::Discard)
      expect(game.choices.last.player).to eq(p2)
      expect { game.resolve_choice!(card: p2.hand.first) }.to change { p2.hand.count }.by(-1)
    end

    it "III — puts a creature card from any graveyard onto the battlefield under your control" do
      next_chapter
      game.resolve_choice!(card: p2.hand.first)
      p1.graveyard.add(Card("Wood Elves", owner: p1))
      p2.graveyard.add(Card("Acidic Slime", owner: p2))
      next_chapter

      choice = game.choices.last
      expect(choice.choices.map(&:name)).to include("Acidic Slime", "Wood Elves")
      game.resolve_choice!(target: choice.choices.find { _1.name == "Acidic Slime" })

      slime = game.battlefield.creatures.by_name("Acidic Slime").first
      expect(slime.controller).to eq(p1)
      expect(slime.owner).to eq(p2)
      expect(p2.graveyard.by_name("Acidic Slime").count).to eq(0)
    end
  end
end
