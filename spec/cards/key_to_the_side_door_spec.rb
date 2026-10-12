# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KeyToTheSideDoor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:key) { ResolvePermanent("Key To The Side-Door", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  before { key.untap! }

  describe "{2}, {T}: target creature can't be blocked this turn" do
    it "grants can't be blocked" do
      p1.add_mana(green: 2)
      p1.activate_ability(ability: key.activated_abilities.first) do |a|
        a.targeting(bears)
        a.pay_mana(generic: { green: 2 })
      end
      game.stack.resolve!
      game.tick!

      expect(bears.has_keyword?(Magic::Cards::Keywords::CANT_BE_BLOCKED)).to eq(true)
      expect(key).to be_tapped
    end
  end

  describe "{1}, {T}, discard a legendary card with the same name as a legendary permanent you control: draw two" do
    let!(:bilbo) { ResolvePermanent("Bilbo, Luckwearer", owner: p1) }
    let(:ability) { key.activated_abilities.last }

    it "draws two cards" do
      twin = Card("Bilbo, Luckwearer", owner: p1)
      p1.hand.add(twin)
      p1.add_mana(green: 1)

      expect do
        p1.activate_ability(ability:) do |a|
          a.pay_mana(generic: { green: 1 })
          a.pay_discard(twin)
        end
        game.stack.resolve!
      end.to change { p1.hand.count }.by(1)
      expect(p1.graveyard.cards).to include(twin)
    end

    it "can't discard a legendary card with no matching permanent" do
      other = Card("Bilbo, Baggins Burglar", owner: p1)
      p1.hand.add(other)
      p1.add_mana(green: 1)

      expect do
        p1.activate_ability(ability:) do |a|
          a.pay_mana(generic: { green: 1 })
          a.pay_discard(other)
        end
      end.to raise_error(/Invalid target chosen for discard/)
    end
  end
end
