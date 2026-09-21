# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LindblumIndustrialRegency do
  include_context "two player game"
  before { go_to_main_phase! }

  describe "land side" do
    let(:card) { Card("Lindblum, Industrial Regency") }

    let!(:permanent) do
      p1.play_land(land: card)
      p1.permanents.by_name("Lindblum, Industrial Regency").first
    end

    it "enters the battlefield tapped" do
      expect(permanent).to be_tapped
    end

    it "taps for red mana" do
      permanent.untap!
      expect(p1).to receive(:add_mana).with(red: 1)

      p1.activate_ability(ability: permanent.activated_abilities.first)
    end

    it "is a Town" do
      expect(card.type?("Town")).to eq(true)
    end
  end

  describe "adventure: Mage Siege" do
    it "creates a 0/1 black Wizard creature token and exiles Lindblum" do
      card = Card("Lindblum, Industrial Regency")
      p1.hand.add(card)
      p1.add_mana(red: 3)

      p1.cast(card: card, adventure: true) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!

      token = p1.permanents.by_name("Wizard").first
      expect(token.power).to eq(0)
      expect(token.toughness).to eq(1)
      expect(token.colors).to eq([:black])
      expect(card.zone).to be_exile
    end

    it "can later be played as a land from exile" do
      card = Card("Lindblum, Industrial Regency")
      p1.hand.add(card)
      p1.add_mana(red: 3)

      p1.cast(card: card, adventure: true) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!

      p1.play_land(land: card)
      permanent = p1.permanents.by_name("Lindblum, Industrial Regency").first

      expect(permanent).to be_tapped
    end

    it "the token deals 1 damage to each opponent when its controller casts a noncreature spell" do
      card = Card("Lindblum, Industrial Regency")
      p1.hand.add(card)
      p1.add_mana(red: 3)
      p1.cast(card: card, adventure: true) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!

      p1.add_mana(red: 1)
      lava_dart = Card("Lava Dart")
      p1.hand.add(lava_dart)
      p1.cast(card: lava_dart) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.stack.resolve!

      # 1 damage from Lava Dart resolving, 1 damage from the Wizard token's trigger
      expect(p2.life).to eq(18)
    end

    it "does not trigger when its controller casts a creature spell" do
      card = Card("Lindblum, Industrial Regency")
      p1.hand.add(card)
      p1.add_mana(red: 3)
      p1.cast(card: card, adventure: true) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!

      p1.add_mana(red: 1)
      mogg_fanatic = Card("Mogg Fanatic")
      p1.hand.add(mogg_fanatic)
      p1.cast(card: mogg_fanatic) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!

      expect(p2.life).to eq(20)
    end
  end
end
