# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnstableAmulet do
  include_context "two player game"

  let!(:amulet) { ResolvePermanent("Unstable Amulet", owner: p1) }

  def exile_ability = amulet.activated_abilities.first

  def activate
    p1.activate_ability(ability: exile_ability)
    game.stack.resolve!
    game.settle!
  end

  def put_on_top(name)
    card = Card(name)
    p1.library.add(card)
    card
  end

  def cast_bolt(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) do |action|
      action.pay_mana(red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {1}{R} artifact" do
    expect(amulet.type?("Artifact")).to be(true)
    expect(amulet.mana_value).to eq(2)
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  context "whenever you cast a spell from anywhere other than your hand" do
    it "deals 1 damage to each opponent when cast from exile" do
      bolt = put_on_top("Lightning Bolt")
      activate
      cast_bolt(bolt)

      # 1 from the Amulet's trigger, 3 from the Bolt
      expect(p2.life).to eq(16)
    end

    it "doesn't trigger for a spell cast from your hand" do
      bolt = Card("Lightning Bolt")
      p1.hand.add(bolt)
      cast_bolt(bolt)

      expect(p2.life).to eq(17)
    end

    it "doesn't trigger for an opponent's spell cast from exile" do
      bolt = Card("Lightning Bolt")
      p2.hand.add(bolt)
      game.exile.add(bolt)
      game.play_permissions.grant_until_end_of_turn(card: bolt, player: p2)
      p2.add_mana(red: 1)
      p2.cast(card: bolt) do |action|
        action.pay_mana(red: 1)
        action.targeting(p1)
      end
      game.stack.resolve!
      game.settle!

      expect(p2.life).to eq(20)
      expect(p1.life).to eq(17)
    end
  end

  context "{T}, Pay {E}{E}: exile the top card of your library" do
    it "taps, pays energy and exiles the top card" do
      top = put_on_top("Lightning Bolt")
      activate

      expect(amulet).to be_tapped
      expect(p1.energy).to eq(0)
      expect(top.zone).to be_exile
    end

    it "lets you play the exiled card" do
      top = put_on_top("Lightning Bolt")
      activate

      expect(game.play_permissions.permits?(top, p1)).to be(true)
    end

    it "doesn't let the opponent play it" do
      top = put_on_top("Lightning Bolt")
      activate

      expect(game.play_permissions.permits?(top, p2)).to be(false)
    end

    it "keeps the permission across turns" do
      top = put_on_top("Lightning Bolt")
      activate
      game.next_turn
      game.next_turn
      go_to_main_phase!

      expect(game.play_permissions.permits?(top, p1)).to be(true)
    end

    it "ends the permission for the first card when you exile another one" do
      first = put_on_top("Lightning Bolt")
      activate
      amulet.untap!
      p1.add_counter("energy", amount: 2)
      second = put_on_top("Grizzly Bears")
      activate

      expect(second.zone).to be_exile
      expect(game.play_permissions.permits?(first, p1)).to be(false)
      expect(game.play_permissions.permits?(second, p1)).to be(true)
    end

    it "can't be activated while tapped" do
      amulet.tap!
      expect { p1.activate_ability(ability: exile_ability) }.to raise_error(Magic::IllegalAction)
      expect(p1.energy).to eq(2)
    end

    it "can't be activated without two energy" do
      p1.pay_energy!(1)
      expect { p1.activate_ability(ability: exile_ability) }.to raise_error(StandardError)
    end

    it "does nothing with an empty library" do
      p1.library.cards.clear
      activate

      expect(game.exile.cards).to be_empty
    end
  end
end
