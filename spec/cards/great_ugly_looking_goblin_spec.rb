# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GreatUglyLookingGoblin do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Great Ugly Looking Goblin", owner: p1) }

  it "is a 4/4 Goblin Soldier" do
    goblin = ResolvePermanent("Great Ugly Looking Goblin", owner: p1)
    expect(goblin.power).to eq(4)
    expect(goblin.type?("Goblin")).to eq(true)
  end

  it "gives menace to creatures you control with a +1/+1 counter" do
    ResolvePermanent("Great Ugly Looking Goblin", owner: p1)
    with_counter = ResolvePermanent("Large Bear", owner: p1)
    without = ResolvePermanent("Guardian Of The Halls", owner: p1)
    opp = ResolvePermanent("Large Bear", owner: p2)
    with_counter.add_counter("+1/+1")
    opp.add_counter("+1/+1")
    game.tick!
    expect(with_counter.keywords).to include(Magic::Cards::Keywords::MENACE)
    expect(without.keywords).not_to include(Magic::Cards::Keywords::MENACE)
    expect(opp.keywords).not_to include(Magic::Cards::Keywords::MENACE)
  end

  describe "adventure: Clap! Snap!" do
    it "amasses Goblins 2 and exiles the card" do
      p1.hand.add(card)
      p1.add_mana(black: 2)
      p1.cast(card:, adventure: true) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
      game.stack.resolve!
      army = p1.creatures.find { _1.types.include?("Army") }
      expect(army.power).to eq(2)
      expect(card.zone).to be_exile
    end
  end
end
