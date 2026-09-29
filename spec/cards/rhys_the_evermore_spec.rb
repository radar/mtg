# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RhysTheEvermore do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:rhys) { ResolvePermanent("Rhys, The Evermore", owner: p1) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 2/2 flash legendary Elf Warrior" do
    expect([rhys.power, rhys.toughness]).to eq([2, 2])
    expect(rhys).to be_legendary
    expect(rhys.card.flash?).to be(true)
  end

  describe "when it enters" do
    it "gives another target creature you control persist until end of turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      rhys
      game.tick!

      expect(bears).to be_persist
    end

    it "makes that creature come back with a -1/-1 counter when it dies" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      rhys
      game.tick!
      bears.destroy!
      game.settle!
      returned = p1.creatures.find { _1.name == "Courser of Kruphix" }

      expect(returned).not_to be_nil
      expect(minus_counters(returned)).to eq(1)
    end

    it "persist ends at end of turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      rhys
      game.tick!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(bears).not_to be_persist
    end

    it "can't give persist to itself or an opponent's creature" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      rhys

      expect(game.choices).to be_empty
    end
  end

  describe "{W}, {T}: remove any number of counters from target creature you control" do
    let!(:creature) { ResolvePermanent("Courser Of Kruphix", owner: p1) }

    before do
      rhys
      3.times { creature.add_counter(Magic::Counters::Minus1Minus1) }
    end

    def activate
      p1.add_mana(white: 1)
      p1.activate_ability(ability: rhys.activated_abilities.first) { _1.pay_mana(white: 1).targeting(creature) }
      game.stack.resolve!
    end

    it "removes as many counters as you choose" do
      activate
      game.resolve_choice!(remove: { Magic::Counters::Minus1Minus1 => 2 })

      expect(minus_counters(creature)).to eq(1)
    end

    it "may remove none" do
      activate
      game.resolve_choice!(remove: {})

      expect(minus_counters(creature)).to eq(3)
    end

    it "can't remove more counters than it has" do
      activate

      expect { game.resolve_choice!(remove: { Magic::Counters::Minus1Minus1 => 4 }) }.to raise_error(ArgumentError)
    end

    it "does nothing when the creature has no counters" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(white: 1)
      p1.activate_ability(ability: rhys.activated_abilities.first) { _1.pay_mana(white: 1).targeting(bears) }
      game.stack.resolve!

      expect(game.choices).to be_empty
    end

    it "taps Rhys and can only be activated at sorcery speed" do
      activate
      game.resolve_choice!(remove: {})
      expect(rhys).to be_tapped

      current_turn.beginning_of_combat!
      rhys.untap!
      p1.add_mana(white: 1)

      expect { p1.activate_ability(ability: rhys.activated_abilities.first) { _1.pay_mana(white: 1).targeting(creature) } }
        .to raise_error(Magic::IllegalAction)
    end
  end
end
