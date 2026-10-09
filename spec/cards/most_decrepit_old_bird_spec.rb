# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MostDecrepitOldBird do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Most Decrepit Old Bird", owner: p1) }

  it "is a 1/1 flier" do
    bird = ResolvePermanent("Most Decrepit Old Bird", owner: p1)
    expect(bird.power).to eq(1)
    expect(bird.keywords).to include(Magic::Cards::Keywords::FLYING)
  end

  it "gets +1/+1 with seven or more cards in your graveyard" do
    bird = ResolvePermanent("Most Decrepit Old Bird", owner: p1)
    6.times { p1.graveyard.add(Card("Forest", owner: p1)) }
    game.tick!
    expect(bird.power).to eq(1)
    p1.graveyard.add(Card("Forest", owner: p1))
    game.tick!
    expect(bird.power).to eq(2)
    expect(bird.toughness).to eq(2)
  end

  describe "adventure: Speak Secrets" do
    before do
      p1.hand.add(card)
      p1.add_mana(blue: 2)
    end

    it "mills four and lets you put an instant or sorcery from among them into your hand" do
      spell = Card("Moment Of Glory", owner: p1)
      p1.library.add(Card("Forest", owner: p1))
      p1.library.add(spell)
      p1.cast(card:, adventure: true) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
      game.stack.resolve!
      expect(game.choices.last.choices).to eq([spell])
      game.resolve_choice!(target: spell)
      expect(spell.zone).to be_hand
      expect(card.zone).to be_exile
    end

    it "may take nothing" do
      p1.cast(card:, adventure: true) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
      game.stack.resolve!
      expect(p1.graveyard.cards.count).to be >= 4
    end
  end
end
