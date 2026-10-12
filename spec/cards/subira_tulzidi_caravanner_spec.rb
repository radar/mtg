# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SubiraTulzidiCaravanner do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:subira) { ResolvePermanent("Subira, Tulzidi Caravanner", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/3 Human Shaman with haste" do
    expect([subira.power, subira.toughness]).to eq([2, 3])
    expect(subira).to be_haste
  end

  describe "{1}: can't be blocked" do
    let(:ability) { subira.activated_abilities.first }

    it "makes another creature with power 2 or less unblockable this turn" do
      p1.add_mana(red: 1)
      p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }).targeting(bears) }
      game.stack.resolve!
      game.tick!

      expect(bears.has_keyword?(Magic::Cards::Keywords::CANT_BE_BLOCKED)).to eq(true)
    end

    it "can't target Subira herself or a creature with power greater than 2" do
      big = ResolvePermanent("Serra Angel", owner: p1)
      p1.add_mana(red: 2)

      expect { p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }).targeting(subira) } }.to raise_error(StandardError)
      expect { p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }).targeting(big) } }.to raise_error(StandardError)
    end
  end

  describe "{1}{R}, {T}, Discard your hand" do
    let(:ability) { subira.activated_abilities.last }

    before do
      subira.untap!
      p1.add_mana(red: 2)
      p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "discards your hand" do
      expect(p1.hand.count).to eq(0)
    end

    it "draws a card when a creature with power 2 or less deals combat damage to a player" do
      bears.untap!
      library_count = p1.library.count
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bears, target: p2)
      go_to_combat_damage!

      expect(p1.library.count).to eq(library_count - 1)
    end
  end
end
