# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BespokeBattlewagon do
  include_context "two player game"

  let!(:wagon) { ResolvePermanent("Bespoke Battlewagon", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def ability(klass) = wagon.activated_abilities.find { _1.is_a?(klass) }

  def activate(klass, &block)
    p1.activate_ability(ability: ability(klass), &block)
    game.stack.resolve!
    game.tick!
  end

  def give_energy(n) = p1.add_counter("energy", amount: n)

  it "is a 5/6 Vehicle that is not a creature until animated or crewed" do
    expect(wagon.types).to include("Vehicle")
    expect(wagon).to be_artifact
    expect(wagon).not_to be_creature
  end

  describe "{T}: you get {E}{E}" do
    it "taps and gives two energy" do
      activate(Magic::Cards::BespokeBattlewagon::EnergyAbility)

      expect(p1.energy).to eq(2)
      expect(wagon).to be_tapped
    end

    it "can't be activated while tapped" do
      wagon.tap!

      expect { activate(Magic::Cards::BespokeBattlewagon::EnergyAbility) }.to raise_error(StandardError)
      expect(p1.energy).to eq(0)
    end
  end

  describe "{T}, pay {E}{E}: tap target creature" do
    before { give_energy(2) }

    it "taps an opponent's creature, paying two energy and tapping the Vehicle" do
      activate(Magic::Cards::BespokeBattlewagon::TapAbility) { _1.targeting(opp_bears) }

      expect(opp_bears).to be_tapped
      expect(wagon).to be_tapped
      expect(p1.energy).to eq(0)
    end

    it "can target your own creature" do
      activate(Magic::Cards::BespokeBattlewagon::TapAbility) { _1.targeting(bears) }

      expect(bears).to be_tapped
    end

    it "can't be activated with one energy" do
      p1.pay_energy!(1)

      expect { activate(Magic::Cards::BespokeBattlewagon::TapAbility) { _1.targeting(opp_bears) } }
        .to raise_error(RuntimeError, /can't pay 2 \{E\}/)
      expect(opp_bears).not_to be_tapped
    end
  end

  describe "{T}, pay {E}{E}{E}: draw a card" do
    before { give_energy(3) }

    it "draws a card for three energy" do
      expect { activate(Magic::Cards::BespokeBattlewagon::DrawAbility) }.to change { p1.hand.count }.by(1)

      expect(p1.energy).to eq(0)
      expect(wagon).to be_tapped
    end

    it "can't be activated with two energy" do
      p1.pay_energy!(1)

      expect { activate(Magic::Cards::BespokeBattlewagon::DrawAbility) }.to raise_error(RuntimeError, /can't pay 3 \{E\}/)
    end
  end

  describe "pay {E}{E}{E}{E}: becomes an artifact creature until end of turn" do
    before { give_energy(4) }

    it "becomes a 5/6 artifact creature without tapping" do
      activate(Magic::Cards::BespokeBattlewagon::AnimateAbility)

      expect(wagon).to be_creature
      expect(wagon).to be_artifact
      expect([wagon.power, wagon.toughness]).to eq([5, 6])
      expect(wagon).not_to be_tapped
      expect(p1.energy).to eq(0)
    end

    it "stops being a creature at end of turn" do
      activate(Magic::Cards::BespokeBattlewagon::AnimateAbility)
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!

      expect(wagon).not_to be_creature
    end

    it "can't be activated with three energy" do
      p1.pay_energy!(1)

      expect { activate(Magic::Cards::BespokeBattlewagon::AnimateAbility) }.to raise_error(RuntimeError, /can't pay 4 \{E\}/)
      expect(wagon).not_to be_creature
    end
  end

  describe "Crew 4" do
    def crew(*creatures)
      p1.activate_ability(ability: wagon.activated_abilities.first) { |a| a.pay_multi_tap(creatures) }
      game.stack.resolve!
      game.tick!
    end

    it "becomes a creature when creatures with total power 4 are tapped" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      crew(bears, other)

      expect(wagon).to be_creature
      expect([bears, other]).to all(be_tapped)
    end

    it "can't be crewed with too little power" do
      expect { crew(bears) }.to raise_error(StandardError)
      expect(wagon).not_to be_creature
    end
  end
end
