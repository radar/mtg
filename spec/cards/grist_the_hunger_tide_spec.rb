# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GristTheHungerTide do
  include_context "two player game"

  let(:card) { Card("Grist, The Hunger Tide") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with three loyalty" do
    expect(planeswalker.loyalty).to eq(3)
  end

  it "is a Legendary Planeswalker" do
    expect(planeswalker.legendary?).to eq(true)
    expect(planeswalker.planeswalker?).to eq(true)
  end

  it "is not a creature while on the battlefield" do
    expect(planeswalker.creature?).to eq(false)
  end

  it "is a 1/1 Insect creature in addition to its other types while not on the battlefield" do
    hand_card = Card("Grist, The Hunger Tide", owner: p1)

    expect(hand_card.creature?).to eq(true)
    expect(hand_card.type?("Insect")).to eq(true)
    expect(hand_card.planeswalker?).to eq(true)
  end

  context "+1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    def insect_tokens
      game.battlefield.controlled_by(p1).creatures.select(&:token?)
    end

    context "when no Insect card is milled" do
      it "creates one Insect token, mills one card, and gains one loyalty" do
        top_card = p1.library.first

        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(4)
        expect(insect_tokens.count).to eq(1)
        expect(insect_tokens.first.power).to eq(1)
        expect(insect_tokens.first.toughness).to eq(1)
        expect(p1.graveyard.cards).to include(top_card)
      end
    end

    context "when an Insect card is milled" do
      let!(:insect_card) { add_to_library("Grist, The Hunger Tide", player: p1) }

      it "repeats the process, creating another token and another loyalty counter" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(5)
        expect(insect_tokens.count).to eq(2)
        expect(p1.graveyard.cards).to include(insect_card)
      end
    end
  end

  context "-2 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }

    context "when the controller has no creatures" do
      it "does not present a choice" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!

        expect(game.choices).to be_empty
      end
    end

    context "when the controller declines to sacrifice a creature" do
      let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

      it "destroys nothing" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.skip_choice!

        expect(bear.zone).to eq(game.battlefield)
      end
    end

    context "when the controller sacrifices a creature" do
      let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
      let!(:opposing_bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

      it "sacrifices the chosen creature and destroys the target" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.resolve_choice!
        game.resolve_choice!(target: bear)
        game.resolve_choice!(target: opposing_bear)

        expect(bear.card.zone).to eq(p1.graveyard)
        expect(opposing_bear.card.zone).to eq(p2.graveyard)
      end
    end
  end

  context "-5 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }

    before do
      # Leave loyalty above 5 so Grist itself doesn't die from paying the
      # cost and inflate the graveyard creature count it's about to read
      # (Grist is a creature card while off the battlefield).
      planeswalker.change_loyalty!(3)
      2.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
    end

    it "each opponent loses life equal to the number of creature cards in your graveyard" do
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!

      expect(p2.life).to eq(18)
    end
  end
end
