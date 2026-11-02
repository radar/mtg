# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GaladhrimBow do
  include_context "two player game"

  let(:bow_card) { Card("Galadhrim Bow", owner: p1) }

  def equip(bow, creature)
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: bow.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a {2}{G} Equipment with flash" do
    expect(bow_card).to be_a(Magic::Cards::Equipment)
    expect(bow_card.mana_value).to eq(3)
    expect(bow_card.keywords).to include(Magic::Cards::Keywords::FLASH)
  end

  it "can be cast at instant speed" do
    p1.hand.add(bow_card)
    p1.add_mana(green: 1, colorless: 2)
    expect(current_turn.main_phase?).to be false
    expect { p1.cast(card: bow_card) { _1.pay_mana(generic: { colorless: 2 }, green: 1) } }.not_to raise_error
  end

  describe "enters trigger" do
    it "attaches to the only creature you control and untaps it" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.tap!
      bow = ResolvePermanent("Galadhrim Bow", owner: p1)
      game.settle!
      game.tick!

      expect(bow.attached_to).to eq(bears)
      expect(bears.tapped?).to be false
      expect([bears.power, bears.toughness]).to eq([3, 4])
    end

    it "lets you choose among your creatures, never offering the opponent's, and untaps only that one" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      giant = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.tap!
      giant.tap!
      bow = ResolvePermanent("Galadhrim Bow", owner: p1)
      game.settle!

      expect(game.choices.first.choices).to contain_exactly(bears, giant)
      expect(game.choices.first.choices).not_to include(theirs)
      game.resolve_choice!(target: giant)

      expect(bow.attached_to).to eq(giant)
      expect(giant.tapped?).to be false
      expect(bears.tapped?).to be true
    end

    it "does nothing with no creature you control" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      bow = ResolvePermanent("Galadhrim Bow", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
      expect(bow.attached_to).to be_nil
    end

    it "attaches to a legal creature when skipped, as the target is mandatory" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
      bow = ResolvePermanent("Galadhrim Bow", owner: p1)
      game.settle!
      game.skip_choice!

      expect(bow.attached_to).not_to be_nil
      expect(bow.attached_to.controller).to eq(p1)
    end
  end

  describe "equipped creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:bow) { ResolvePermanent("Galadhrim Bow", owner: p1) }
    before do
      game.settle!
      go_to_main_phase!
    end

    it "has equip {2}" do
      ability = bow.activated_abilities.first
      expect(ability.costs.size).to eq(1)
      expect(ability.costs.first.cost[:generic]).to eq(2)
    end

    it "gets +1/+2 and reach" do
      expect([bears.power, bears.toughness]).to eq([3, 4])
      expect(bears).to have_keyword(:reach)
    end

    it "only sorcery-speed: cannot equip on the opponent's turn" do
      go_to_main_phase_for!(p2)
      p1.add_mana(colorless: 2)

      expect do
        p1.activate_ability(ability: bow.activated_abilities.first) do |a|
          a.pay_mana(generic: { colorless: 2 })
          a.targeting(bears)
        end
      end.to raise_error(Magic::IllegalAction, /requirements to activate/)
    end

    it "moves to another creature, which then gets the bonus while the first loses it" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      equip(bow, other)

      expect([other.power, other.toughness]).to eq([3, 4])
      expect(other).to have_keyword(:reach)
      expect([bears.power, bears.toughness]).to eq([2, 2])
      expect(bears).not_to have_keyword(:reach)
    end

    it "loses the bonus when the Bow leaves the battlefield" do
      bow.destroy!
      game.settle!
      game.tick!

      expect(game.battlefield.permanents).not_to include(bow)
      expect([bears.power, bears.toughness]).to eq([2, 2])
      expect(bears).not_to have_keyword(:reach)
    end
  end
end
