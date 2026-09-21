# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LysAlanaHuntmaster do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:huntmaster) { ResolvePermanent("Lys Alana Huntmaster", owner: p1) }

  context "when you cast an Elf spell" do
    it "presents a choice to create a token" do
      card = Card("Elvish Warmaster", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.choices.last).to be_a(Magic::Cards::LysAlanaHuntmaster::CreateTokenChoice)
    end

    it "creates a 1/1 green Elf Warrior token when the choice is accepted" do
      card = Card("Elvish Warmaster", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      game.resolve_choice!

      tokens = p1.creatures.by_name("Elf Warrior")
      expect(tokens.count).to eq(1)
      expect(tokens.first.power).to eq(1)
      expect(tokens.first.toughness).to eq(1)
    end

    it "creates no token when the choice is declined" do
      card = Card("Elvish Warmaster", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      game.skip_choice!

      expect(p1.creatures.by_name("Elf Warrior").count).to eq(0)
    end
  end

  context "when you cast a non-Elf spell" do
    it "does not present a choice" do
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.choices.last).to be_nil
    end
  end

  context "when an opponent casts an Elf spell" do
    it "does not present a choice" do
      go_to_main_phase_for!(p2)
      card = Card("Elvish Warmaster", owner: p2)
      p2.hand.add(card)
      p2.add_mana(green: 2)
      p2.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.choices.last).to be_nil
    end
  end
end
