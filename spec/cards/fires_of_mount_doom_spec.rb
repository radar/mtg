# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FiresOfMountDoom do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def choice = game.choices.first

  def equip(sword, creature, player)
    player.add_mana(white: 1)
    player.activate_ability(ability: sword.activated_abilities.first) do
      _1.targeting(creature)
      _1.pay_mana(generic: { white: 1 })
    end
    game.stack.resolve!
    game.tick!
  end

  def enter_fires
    @fires = ResolvePermanent("Fires of Mount Doom", owner: p1)
    game.settle!
    @fires
  end

  it "is a legendary enchantment" do
    fires = ResolvePermanent("Fires of Mount Doom", owner: p1)
    expect(fires).to be_legendary
    expect(fires.type?("Enchantment")).to eq(true)
  end

  context "when it enters" do
    it "asks for a creature an opponent controls only" do
      enter_fires
      expect(choice).to be_a(described_class::DamageChoice)
      expect(choice.choices).to contain_exactly(angel, other)
    end

    it "deals 2 damage to the target" do
      enter_fires
      game.resolve_choice!(target: angel)
      expect(angel.damage).to eq(2)
      expect(mine.damage).to eq(0)
    end

    it "cannot target a hexproof creature an opponent controls" do
      big = ResolvePermanent("Gigantic Big Bear", owner: p2)
      enter_fires
      expect(choice.choices).not_to include(big)
      expect(choice.choices).to include(angel)
    end

    it "does nothing when the opponent has no creatures" do
      angel.destroy!
      other.destroy!
      game.settle!
      enter_fires
      expect(game.choices).to be_empty
    end

    it "destroys Equipment attached to the target but not to other creatures" do
      sword =ResolvePermanent("Short Sword", owner: p2)
      sword2 = ResolvePermanent("Short Sword", owner: p2)
      equip(sword, angel, p2)
      equip(sword2, other, p2)
      expect(angel.attachments.map(&:name)).to eq(["Short Sword"])

      enter_fires
      game.resolve_choice!(target: angel)
      game.tick!

      expect(angel.attachments).to be_empty
      expect(p2.graveyard.cards.map(&:name)).to include("Short Sword")
      expect(other.attachments.map(&:name)).to eq(["Short Sword"])
    end
  end

  context "the exile ability" do
    let!(:fires) do
      f = enter_fires
      game.resolve_choice!(target: angel)
      f
    end
    let(:top) { Card("Forest", owner: p1) }

    before { p1.library.add(top) }

    def activate
      p1.add_mana(red: 1, green: 2)
      p1.activate_ability(ability: fires.activated_abilities.first) do
        _1.pay_mana(generic: { green: 2 }, red: 1)
      end
      game.stack.resolve!
      game.tick!
    end

    it "exiles the top card of the library" do
      activate
      expect(game.exile.cards).to include(top)
    end

    it "lets you play that card this turn and not after" do
      activate
      current_turn.end!
      current_turn.cleanup!
      game.tick!
      expect { p1.play_land(land: top) }.to raise_error(Magic::IllegalAction)
      expect([p1.life, p2.life]).to eq([20, 20])
    end

    it "deals 2 damage to each player when you play a land that way" do
      activate
      p1.play_land(land: top)
      game.settle!
      expect([p1.life, p2.life]).to eq([18, 18])
    end

    it "deals 2 damage to each player when you cast a spell that way" do
      bolt = Card("Lightning Bolt", owner: p1)
      p1.library.add(bolt)
      activate
      p1.add_mana(red: 1)
      action = cast_action(card: bolt, player: p1)
      action.pay_mana(red: 1)
      action.targeting(p2)
      game.take_action(action)
      game.settle!
      game.stack.resolve!
      game.tick!
      expect([p1.life, p2.life]).to eq([18, 15])
    end

    it "deals no damage when the card is not played" do
      activate
      expect([p1.life, p2.life]).to eq([20, 20])
    end

    it "deals no damage for a land played from hand" do
      activate
      land = Card("Forest", owner: p1)
      p1.hand.add(land)
      p1.play_land(land: land)
      game.settle!
      expect([p1.life, p2.life]).to eq([20, 20])
    end

    it "does nothing with an empty library" do
      p1.library.cards.clear
      activate
      expect(game.exile.cards).to be_empty
    end
  end
end
