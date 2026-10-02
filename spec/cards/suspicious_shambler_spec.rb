# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SuspiciousShambler do
  include_context "two player game"

  it "is a 4/2 Zombie" do
    shambler = ResolvePermanent("Suspicious Shambler", owner: p1)

    expect([shambler.power, shambler.toughness]).to eq([4, 2])
  end

  describe "from the graveyard" do
    before { go_to_main_phase! }

    let(:card) { Card("Suspicious Shambler", owner: p1) }

    before { p1.graveyard.add(card) }

    it "exiles itself for {4}{B}{B} to create two 2/2 black Zombie tokens" do
      p1.add_mana(black: 6)
      p1.activate_ability(ability: card.graveyard_abilities.first) { _1.pay_mana(generic: { black: 4 }, black: 2) }
      game.stack.resolve!
      game.settle!
      zombies = p1.creatures.select { _1.name == "Zombie" }

      expect(zombies.count).to eq(2)
      expect(zombies.map { [_1.power, _1.toughness] }).to all(eq([2, 2]))
      expect(game.exile.cards).to include(card)
    end

    it "can only be activated as a sorcery" do
      go_to_main_phase_for!(p2)
      p1.add_mana(black: 6)

      expect { p1.activate_ability(ability: card.graveyard_abilities.first) { _1.pay_mana(generic: { black: 4 }, black: 2) } }
        .to raise_error(Magic::IllegalAction)
    end
  end
end
