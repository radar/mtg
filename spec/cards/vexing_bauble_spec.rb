# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VexingBauble do
  include_context "two player game"

  let!(:bauble) { ResolvePermanent("Vexing Bauble", owner: p1) }

  before { go_to_main_phase! }

  def resolve_stack
    game.settle!
    game.stack.resolve! until game.stack.empty?
    game.settle!
  end

  it "is a colorless artifact" do
    expect(bauble.type?("Artifact")).to be(true)
    expect(bauble.colors).to eq([])
  end

  context "whenever a player casts a spell, if no mana was spent to cast it, counter that spell" do
    it "counters your own spell cast for no mana" do
      crypt = Card("Tormod's Crypt", owner: p1)
      p1.hand.add(crypt)
      p1.cast(card: crypt)
      resolve_stack

      expect(p1.graveyard.cards).to include(crypt)
      expect(p1.permanents.map(&:card)).not_to include(crypt)
    end

    it "counters an opponent's spell cast for no mana" do
      go_to_main_phase_for!(p2)
      crypt = Card("Tormod's Crypt", owner: p2)
      p2.hand.add(crypt)
      p2.cast(card: crypt)
      resolve_stack

      expect(p2.graveyard.cards).to include(crypt)
      expect(p2.permanents.map(&:card)).not_to include(crypt)
    end

    it "does not counter a spell that mana was spent on" do
      greaves = Card("Lightning Greaves", owner: p1)
      p1.hand.add(greaves)
      p1.add_mana(red: 2)
      p1.cast(card: greaves) { |a| a.pay_mana(generic: { red: 2 }) }
      resolve_stack

      expect(p1.permanents.map(&:card)).to include(greaves)
      expect(p1.graveyard.cards).not_to include(greaves)
    end

    it "does not counter an opponent's spell that mana was spent on" do
      go_to_main_phase_for!(p2)
      greaves = Card("Lightning Greaves", owner: p2)
      p2.hand.add(greaves)
      p2.add_mana(red: 2)
      p2.cast(card: greaves) { |a| a.pay_mana(generic: { red: 2 }) }
      resolve_stack

      expect(p2.permanents.map(&:card)).to include(greaves)
    end
  end

  context "{1}, {T}, Sacrifice this artifact: Draw a card" do
    def activate(player: p1)
      player.add_mana(red: 1)
      player.activate_ability(ability: bauble.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }) }
    end

    it "draws a card and sacrifices the Bauble" do
      hand_size = p1.hand.cards.size
      activate
      resolve_stack

      expect(p1.hand.cards.size).to eq(hand_size + 1)
      expect(p1.graveyard.cards).to include(bauble.card)
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "can't be activated without the mana" do
      expect do
        p1.activate_ability(ability: bauble.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }) }
      end.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(bauble).not_to be_tapped
      expect(p1.graveyard.cards).not_to include(bauble.card)
    end

    it "can't be activated by the opponent" do
      p2.add_mana(red: 1)

      expect do
        p2.activate_ability(ability: bauble.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }) }
      end.to raise_error(Magic::IllegalAction, /does not control/)
      expect(bauble).not_to be_tapped
      expect(p2.mana_pool.values.sum).to eq(1)
    end
  end
end
