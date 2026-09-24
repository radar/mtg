require "spec_helper"

RSpec.describe Magic::Cards::KhalniHeartExpedition do
  include_context "two player game"

  subject!(:expedition) { ResolvePermanent("Khalni Heart Expedition", owner: p1) }

  def p1_library
    9.times.map { Card("Forest") }
  end

  def quest_counters = expedition.counters.of_type(Magic::Counters::Quest).count

  it "may put a quest counter on itself when a land enters under your control" do
    ResolvePermanent("Forest", owner: p1)
    game.resolve_choice!
    expect(quest_counters).to eq(1)
  end

  it "doesn't have to put a counter on" do
    ResolvePermanent("Forest", owner: p1)
    game.skip_choice!
    expect(quest_counters).to eq(0)
  end

  it "ignores lands entering under an opponent's control" do
    ResolvePermanent("Forest", owner: p2)
    expect(game.choices).to be_empty
  end

  context "with three quest counters" do
    before { expedition.add_counter(Magic::Counters::Quest, amount: 3) }

    it "removes them and sacrifices itself to fetch two basic lands tapped" do
      p1.activate_ability(ability: expedition.activated_abilities.first)
      expect(p1.graveyard.by_name("Khalni Heart Expedition").count).to eq(1)
      game.stack.resolve!

      choice = game.choices.last
      game.resolve_choice!(targets: choice.choices.first(2))

      forests = game.battlefield.permanents.by_name("Forest")
      expect(forests.count).to eq(2)
      expect(forests).to all(be_tapped)
    end
  end

  it "can't be activated with fewer than three quest counters" do
    expedition.add_counter(Magic::Counters::Quest, amount: 2)
    expect { p1.activate_ability(ability: expedition.activated_abilities.first) }.to raise_error(/Not enough .*Quest counters to remove/)  end
end
