require 'spec_helper'

RSpec.describe Magic::Permanent do
  include_context "two player game"

  context "Equipment and Auras" do
    it "have each of their types, so type checks work on them" do
      sword = ResolvePermanent("Short Sword", owner: p1)
      armor = Card("Ethereal Armor", owner: p1)

      expect([sword.type?("Artifact"), sword.type?("Equipment"), sword.artifact?]).to eq([true, true, true])
      expect([armor.type?("Enchantment"), armor.type?("Aura"), armor.enchantment?]).to eq([true, true, true])
    end
  end

  context "resolving a card that is in another zone" do
    it "moves the card to the battlefield too, out of exile" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.exile.add(bears)

      permanent = described_class.resolve(game: game, card: bears, cast: false)

      expect(permanent.zone).to be_battlefield
      expect(bears.zone).to be_battlefield
      expect(p1.exile).to be_empty
    end

    it "leaves the card alone when a token copy of it is made" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(bears)

      described_class.resolve(game: game, card: bears, token: true, cast: false)

      expect(bears.zone).to be_graveyard
      expect(p1.graveyard.map(&:name)).to include("Grizzly Bears")
    end
  end

  context "moving to graveyard" do
    context "when permanent is not a token" do
      let!(:permanent) { ResolvePermanent("Scute Swarm", owner: p1) }

      it "moves the related card to the graveyard" do
        permanent.destroy!
        expect(p1.graveyard.by_name("Scute Swarm").count).to eq(1)
      end
    end

    context "when permanent is a token" do
      let!(:permanent) { ResolvePermanent("Scute Swarm", owner: p1, token: true, copy: true) }

      it "does not move the card to the graveyard" do
        permanent.destroy!
        expect(p1.graveyard.by_name("Scute Swarm").count).to eq(0)
      end
    end
  end

  context "a token that leaves the battlefield" do
    let(:soldier_class) do
      Magic::Token.create("Soldier") do
        creature_type "Soldier"
        power 1
        toughness 1
      end
    end

    it "can be sacrificed, destroyed or exiled" do
      3.times.map { soldier_class.new(game: game, owner: p1).resolve! }.zip(%i[sacrifice! destroy! exile!]).each do |token, action|
        expect { token.public_send(action) }.not_to raise_error
        expect(token.zone).to be_nil
      end
    end

    it "leaves the card it copies alone" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      copy = described_class.resolve(game: game, card: bears.card, token: true, cast: false)
      copy.sacrifice!

      expect(p1.graveyard.cards).not_to include(bears.card)
    end
  end

  context "becomes" do
    let(:permanent) { ResolvePermanent("Riddleform", owner: p1) }

    it "becomes a 3/3 Sphinx creature with flying", aggregate_failures: true do
      permanent.add_types(Magic::Types::Creature, Magic::Types::Creatures["Sphinx"])
      permanent.modify_base_power(3)
      permanent.modify_base_toughness(3)
      permanent.grant_keyword(Magic::Keywords::FLYING)

      game.tick!

      expect(permanent).to be_a_creature
      expect(permanent.type?("Sphinx")).to eq(true)
      expect(permanent.power).to eq(3)
      expect(permanent.toughness).to eq(3)
      expect(permanent.flying?).to eq(true)
    end
  end
end
