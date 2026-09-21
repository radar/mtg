# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeastWhisperer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:beast_whisperer) { ResolvePermanent("Beast Whisperer", owner: p1) }

  def card_draws_for(player)
    game.current_turn.events.select { |event| event.is_a?(Magic::Events::CardDraw) && event.player == player }
  end

  it "is a 2/3 Elf Druid" do
    expect(beast_whisperer.power).to eq(2)
    expect(beast_whisperer.toughness).to eq(3)
    expect(beast_whisperer.card.types).to include("Elf")
    expect(beast_whisperer.card.types).to include("Druid")
  end

  context "when you cast a creature spell" do
    it "draws a card" do
      spell = Card("Elvish Mystic", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 1)

      expect {
        p1.cast(card: spell) { |a| a.pay_mana(green: 1) }
      }.to change { card_draws_for(p1).count }.by(1)
    end
  end

  context "when you cast a noncreature spell" do
    it "does not draw a card" do
      spell = Card("Rampant Growth", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 2)

      expect {
        p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      }.not_to change { card_draws_for(p1).count }
    end
  end

  context "when an opponent casts a creature spell" do
    it "does not draw a card" do
      go_to_main_phase_for!(p2)
      spell = Card("Elvish Mystic", owner: p2)
      p2.hand.add(spell)
      p2.add_mana(green: 1)

      expect {
        p2.cast(card: spell) { |a| a.pay_mana(green: 1) }
      }.not_to change { card_draws_for(p1).count }
    end
  end
end
