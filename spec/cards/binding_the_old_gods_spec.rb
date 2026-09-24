require "spec_helper"

RSpec.describe Magic::Cards::BindingTheOldGods do
  include_context "two player game"

  def p1_library
    20.times.map { Card("Forest") }
  end

  let!(:opponents_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:opponents_enchantment) { ResolvePermanent("Doubling Season", owner: p2) }
  let!(:opponents_forest) { ResolvePermanent("Forest", owner: p2) }
  let!(:my_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let(:card) { Card("Binding The Old Gods", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 1, green: 3)
    p1.cast(card: card) { _1.pay_mana(black: 1, green: 1, generic: { green: 2 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  let(:saga) { game.battlefield.by_name("Binding the Old Gods").first }

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

  it "I — destroys a target nonland permanent an opponent controls" do
    choice = game.choices.last
    expect(choice.choices).to contain_exactly(opponents_bears, opponents_enchantment)

    game.resolve_choice!(target: opponents_bears)
    expect(p2.graveyard.by_name("Grizzly Bears").count).to eq(1)
    expect(opponents_forest.zone).to be_battlefield
    expect(my_elves.zone).to be_battlefield
  end

  context "after chapter I" do
    before { game.resolve_choice!(target: opponents_bears) }

    it "II — searches for a Forest and puts it onto the battlefield tapped" do
      next_chapter

      choice = game.choices.last
      expect(choice.choices).to all(be_any_type("Forest"))
      game.resolve_choice!(targets: [choice.choices.first])

      forests = game.battlefield.controlled_by(p1).by_name("Forest")
      expect(forests.count).to eq(1)
      expect(forests.first).to be_tapped
    end

    it "III — gives creatures you control deathtouch, not the opponent's" do
      next_chapter
      game.resolve_choice!(targets: [game.choices.last.choices.first])
      opponent_elves = ResolvePermanent("Wood Elves", owner: p2)
      next_chapter

      expect(my_elves.has_keyword?(:deathtouch)).to be(true)
      expect(opponent_elves.has_keyword?(:deathtouch)).to be(false)
    end

    it "is sacrificed after chapter III" do
      next_chapter
      game.resolve_choice!(targets: [game.choices.last.choices.first])
      next_chapter

      expect(p1.graveyard.by_name("Binding the Old Gods").count).to eq(1)
    end
  end
end
