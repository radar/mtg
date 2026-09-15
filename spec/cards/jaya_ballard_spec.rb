# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JayaBallard do
  include_context "two player game"

  let(:card) { Card("Jaya Ballard") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with 5 loyalty" do
    expect(planeswalker.loyalty).to eq(5)
  end

  context "first +1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    it "adds {R}{R}{R}" do
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(6)
      expect(p1.mana_pool[:red]).to eq(3)
    end
  end

  context "second +1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }
    let!(:discarded_card) { Card("Grizzly Bears", owner: p1) }
    let!(:kept_card) { Card("Grizzly Bears", owner: p1) }

    before do
      p1.hand.add(discarded_card)
      p1.hand.add(kept_card)
    end

    it "discards the chosen cards, then draws that many" do
      starting_hand_size = p1.hand.count
      starting_library_size = p1.library.count

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!
      game.resolve_choice!(discarded: [discarded_card])

      expect(planeswalker.loyalty).to eq(6)
      expect(discarded_card.zone).to be_graveyard
      expect(p1.hand.count).to eq(starting_hand_size)
      expect(p1.library.count).to eq(starting_library_size - 1)
    end

    it "draws no cards when nothing is discarded" do
      starting_hand_size = p1.hand.count

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!
      game.resolve_choice!(discarded: [])

      expect(p1.hand.count).to eq(starting_hand_size)
    end
  end

  context "-8 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }

    it "gives you an emblem letting you cast instant and sorcery spells from your graveyard, exiling them after" do
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(game.emblems.count).to eq(1)

      lightning_bolt = Card("Lightning Bolt", owner: p1)
      p1.graveyard.add(lightning_bolt)

      p2_starting_life = p2.life
      p1.add_mana(red: 1)
      action = cast_action(player: p1, card: lightning_bolt)
      action.pay_mana(red: 1)
      action.targeting(p2)
      game.take_action(action)
      game.stack.resolve!

      expect(p2.life).to eq(p2_starting_life - 3)
      expect(lightning_bolt.zone).to be_exile
      expect(lightning_bolt.zone).not_to be_graveyard
    end
  end
end
