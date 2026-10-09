# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThorinOakenshield do
  include_context "two player game"

  let!(:thorin) { ResolvePermanent("Thorin Oakenshield", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 3/2 with trample" do
    expect([thorin.power, thorin.toughness]).to eq([3, 2])
    expect(thorin).to have_keyword(:trample)
  end

  def opponent_bolts(target)
    go_to_main_phase_for!(p2)
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "has no ward without an enduring story" do
    opponent_bolts(bears)

    expect(game.choices).to be_empty
  end

  context "with an enduring story" do
    before do
      2.times { ResolvePermanent("Well-Worn Spatula", owner: p1) }
      game.tick!
    end

    it "gives your creatures ward {1}: unpaid ward counters the spell" do
      opponent_bolts(bears)
      expect(game.choices.last).to be_a(Magic::Choice::Ward)
      game.resolve_choice!(payment: {})
      game.stack.resolve!

      expect(game.battlefield.permanents).to include(bears)
    end

    it "lets the opponent pay {1}" do
      opponent_bolts(bears)
      p2.add_mana(red: 1)
      game.resolve_choice!(payment: { red: 1 })
      game.stack.resolve!

      expect(game.battlefield.permanents).not_to include(bears)
    end

    it "also covers your artifacts" do
      spatula = p1.permanents.find { _1.name == "Well-Worn Spatula" }
      go_to_main_phase_for!(p2)
      shatter = Card("Shatter", owner: p2)
      p2.hand.add(shatter)
      p2.add_mana(red: 2)
      p2.cast(card: shatter) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(spatula) }
      game.settle!

      expect(game.choices.last).to be_a(Magic::Choice::Ward)
    end
  end
end
