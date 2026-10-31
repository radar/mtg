# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BaradDr do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Barad Dr", owner: p1) }

  def ability(name) = land.activated_abilities.find { _1.is_a?(described_class.const_get(name)) }

  def army = p1.creatures.find { _1.type?("Army") }

  def kill_a_creature
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
  end

  def amass(x, mana: 1 + 2 * x)
    land.untap!
    p1.add_mana(black: mana)
    p1.activate_ability(ability: ability(:AmassAbility), value_for_x: x) do |a|
      a.pay_mana(x: { black: 2 * x }, black: 1)
    end
    game.stack.resolve!
    game.settle!
  end

  describe "enters tapped unless you control a legendary creature" do
    it "enters tapped with no legendary creature" do
      expect(land).to be_tapped
    end

    it "enters tapped with only a nonlegendary creature" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(ResolvePermanent("Barad Dr", owner: p1)).to be_tapped
    end

    it "enters tapped when only an opponent controls a legendary creature" do
      ResolvePermanent("Lotho Corrupt Shirriff", owner: p2)

      expect(ResolvePermanent("Barad Dr", owner: p1)).to be_tapped
    end

    it "enters untapped with a legendary creature" do
      ResolvePermanent("Lotho Corrupt Shirriff", owner: p1)

      expect(ResolvePermanent("Barad Dr", owner: p1)).not_to be_tapped
    end
  end

  it "taps for {B}" do
    land.untap!
    p1.activate_ability(ability: ability(:ManaAbility))

    expect(p1.mana_pool[:black]).to eq(1)
    expect(land).to be_tapped
  end

  describe "{X}{X}{B}, {T}: amass Orcs X" do
    it "amasses Orcs X after a creature died, paying twice X plus {B}" do
      kill_a_creature
      amass(2)

      expect(army.type?("Orc")).to eq(true)
      expect(army.power).to eq(2)
      expect(land).to be_tapped
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "adds counters to an existing Army" do
      kill_a_creature
      amass(1)
      amass(2)

      expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
      expect(army.power).to eq(3)
    end

    it "can't be activated when no creature died this turn" do
      land.untap!
      p1.add_mana(black: 3)

      expect do
        p1.activate_ability(ability: ability(:AmassAbility), value_for_x: 1) { |a| a.pay_mana(x: { black: 2 }, black: 1) }
      end.to raise_error(Magic::IllegalAction)
      expect(army).to be_nil
    end

    it "can't be activated when X is only paid once" do
      kill_a_creature
      land.untap!
      p1.add_mana(black: 2)

      expect do
        p1.activate_ability(ability: ability(:AmassAbility), value_for_x: 1) { |a| a.pay_mana(x: { black: 1 }, black: 1) }
      end.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(army).to be_nil
    end
  end
end
