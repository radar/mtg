# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DisruptorFlute do
  include_context "two player game"

  def resolve_flute(name: "Hedron Archive")
    flute = ResolvePermanent("Disruptor Flute", owner: p1)
    game.resolve_choice!(choice: name)
    game.tick!
    flute
  end

  def cost_of(card)
    Magic::Actions::Cast.new(card: card, player: card.owner, game: game).mana_cost.cost
  end

  it "is a colorless artifact with flash" do
    flute = ResolvePermanent("Disruptor Flute", owner: p1)

    expect(flute.type?("Artifact")).to be(true)
    expect(flute).to be_flash
    expect(flute.colors).to eq([])
  end

  it "can be cast at instant speed" do
    flute = Card("Disruptor Flute", owner: p1)
    p1.hand.add(flute)
    p1.add_mana(red: 2)
    p1.cast(card: flute) { |a| a.pay_mana(generic: { red: 2 }) }
    game.stack.resolve!
    game.settle!

    expect(game.choices.first).to be_a(Magic::Choice::CardName)
    game.resolve_choice!(choice: "Lightning Bolt")

    expect(p1.permanents.map(&:card)).to include(flute)
  end

  it "stores the chosen name as it enters" do
    flute = ResolvePermanent("Disruptor Flute", owner: p1)

    expect(game.choices.first).to be_a(Magic::Choice::CardName)
    game.resolve_choice!(choice: "Lightning Bolt")

    expect(flute.chosen_card_name).to eq("Lightning Bolt")
  end

  context "spells with the chosen name cost {3} more" do
    it "increases your spell with the chosen name" do
      resolve_flute(name: "Lightning Bolt")

      expect(cost_of(Card("Lightning Bolt", owner: p1))).to eq({ red: 1, generic: 3 })
    end

    it "increases an opponent's spell with the chosen name" do
      resolve_flute(name: "Lightning Bolt")

      expect(cost_of(Card("Lightning Bolt", owner: p2))).to eq({ red: 1, generic: 3 })
    end

    it "does not increase a spell with a different name" do
      resolve_flute(name: "Lightning Bolt")

      expect(cost_of(Card("Shock", owner: p1))).to eq({ red: 1 })
    end

    it "requires the extra mana to cast" do
      resolve_flute(name: "Lightning Bolt")
      bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(bolt)
      p1.add_mana(red: 1)

      expect { p1.cast(card: bolt) { |a| a.pay_mana(red: 1) } }.to raise_error(StandardError)
      expect(p1.hand.cards).to include(bolt)
    end
  end

  context "activated abilities of sources with the chosen name" do
    let!(:archive) { ResolvePermanent("Hedron Archive", owner: p1) }

    it "can't be activated" do
      resolve_flute
      p1.add_mana(red: 2)

      expect do
        p1.activate_ability(ability: archive.activated_abilities.last) { |a| a.pay_mana(generic: { red: 2 }) }
      end.to raise_error(Magic::IllegalAction, /can't be activated/)
      expect(archive).not_to be_tapped
      expect(p1.mana_pool.values.sum).to eq(2)
      expect(p1.graveyard.cards).not_to include(archive.card)
    end

    it "also stops the opponent's source with the chosen name" do
      resolve_flute
      theirs = ResolvePermanent("Hedron Archive", owner: p2)
      p2.add_mana(red: 2)

      expect do
        p2.activate_ability(ability: theirs.activated_abilities.last) { |a| a.pay_mana(generic: { red: 2 }) }
      end.to raise_error(Magic::IllegalAction, /can't be activated/)
      expect(theirs).not_to be_tapped
      expect(p2.mana_pool.values.sum).to eq(2)
    end

    it "still allows its mana abilities" do
      resolve_flute
      p1.activate_ability(ability: archive.activated_abilities.first)

      expect(archive).to be_tapped
      expect(p1.mana_pool.values.sum).to eq(2)
    end

    it "does not stop abilities of sources with another name" do
      resolve_flute(name: "Lightning Bolt")
      p1.add_mana(red: 2)
      p1.activate_ability(ability: archive.activated_abilities.last) { |a| a.pay_mana(generic: { red: 2 }) }
      game.stack.resolve!
      game.settle!

      expect(p1.graveyard.cards).to include(archive.card)
    end
  end
end
