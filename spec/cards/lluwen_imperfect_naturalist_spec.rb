# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LluwenImperfectNaturalist do
  include_context "two player game"

  it "is a 1/3 Elf Druid" do
    lluwen = ResolvePermanent("Lluwen, Imperfect Naturalist", owner: p1)

    expect(lluwen.power).to eq(1)
    expect(lluwen.toughness).to eq(3)
    expect(lluwen.type?("Elf")).to eq(true)
    expect(lluwen.type?("Druid")).to eq(true)
  end

  it "costs {B/G}{B/G}, payable with any mix of black and green mana" do
    card = Card("Lluwen, Imperfect Naturalist")

    expect(card.mana_value).to eq(2)
    expect(card.colors).to contain_exactly(:black, :green)

    p1.add_mana(green: 2)
    expect(card.cost.can_pay?(p1)).to eq(true)

    p1.pay_mana(green: 2)
    p1.add_mana(black: 2)
    expect(card.cost.can_pay?(p1)).to eq(true)
  end

  describe "when it enters the battlefield" do
    it "mills four cards and may put a creature or land card among them on top of the library" do
      creature = Card("Elvish Mystic", owner: p1)
      p1.library.add(creature)

      ResolvePermanent("Lluwen, Imperfect Naturalist", owner: p1)

      expect(p1.graveyard.count).to eq(4)

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::LluwenImperfectNaturalist::ReturnChoice)
      expect(choice.choices).to include(creature)

      choice.resolve!(target: creature)

      expect(p1.library.first).to eq(creature)
      expect(p1.graveyard).to_not include(creature)
    end

    it "may decline to put a card on top of the library, leaving the milled cards in the graveyard" do
      ResolvePermanent("Lluwen, Imperfect Naturalist", owner: p1)

      choice = game.choices.first
      p1.skip_choice(choice)

      expect(game.choices).to be_empty
      expect(p1.graveyard.count).to eq(4)
    end

    it "doesn't offer a choice when none of the milled cards are a creature or land" do
      4.times { p1.library.add(Card("Lightning Bolt", owner: p1)) }

      ResolvePermanent("Lluwen, Imperfect Naturalist", owner: p1)

      expect(p1.graveyard.count).to eq(4)
      expect(game.choices).to be_empty
    end
  end

  describe "activated ability" do
    let!(:lluwen) { ResolvePermanent("Lluwen, Imperfect Naturalist", owner: p1) }

    before do
      p1.skip_choice(game.choices.first) if game.choices.any?
      p1.graveyard.items.clear
    end

    it "discards a land, taps, and creates a Worm token for each land card in the graveyard" do
      3.times { p1.graveyard.add(Card("Forest", owner: p1)) }

      discard_card = Card("Forest", owner: p1)
      p1.hand.add(discard_card)

      p1.add_mana(black: 4, green: 1)
      p1.activate_ability(ability: lluwen.activated_abilities.first) do |a|
        a.pay_mana(generic: { black: 2 }, black: 2, green: 1)
        a.pay_discard(discard_card)
      end

      game.stack.resolve!

      expect(discard_card.zone).to be_graveyard
      expect(lluwen.tapped?).to eq(true)

      worm_tokens = game.battlefield.creatures.by_name("Worm")
      expect(worm_tokens.count).to eq(4)
      expect(worm_tokens).to all(have_attributes(power: 1, toughness: 1))
    end

    it "lets the {B/G}{B/G}{B/G} portion of its cost be paid with any mix of black and green mana" do
      discard_card = Card("Forest", owner: p1)
      p1.hand.add(discard_card)

      p1.add_mana(green: 5)
      p1.activate_ability(ability: lluwen.activated_abilities.first) do |a|
        a.pay_mana(generic: { green: 2 }, green: 3)
        a.pay_discard(discard_card)
      end

      game.stack.resolve!

      expect(p1.mana_pool.values.sum).to eq(0)
      worm_tokens = game.battlefield.creatures.by_name("Worm")
      expect(worm_tokens.count).to eq(1)
    end

    it "counts the land just discarded to pay the cost when no other lands are in the graveyard" do
      discard_card = Card("Forest", owner: p1)
      p1.hand.add(discard_card)

      p1.add_mana(black: 4, green: 1)
      p1.activate_ability(ability: lluwen.activated_abilities.first) do |a|
        a.pay_mana(generic: { black: 2 }, black: 2, green: 1)
        a.pay_discard(discard_card)
      end

      game.stack.resolve!

      worm_tokens = game.battlefield.creatures.by_name("Worm")
      expect(worm_tokens.count).to eq(1)
    end
  end
end
