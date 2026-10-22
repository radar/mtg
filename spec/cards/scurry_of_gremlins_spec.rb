# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScurryOfGremlins do
  include_context "two player game"

  def gremlins = p1.creatures.select { _1.type?("Gremlin") }

  context "when it enters" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:scurry) { ResolvePermanent("Scurry Of Gremlins", owner: p1) }

    it "creates two 1/1 red Gremlin tokens" do
      expect(gremlins.size).to eq(2)
      expect(gremlins.map { [_1.power, _1.toughness] }).to all(eq([1, 1]))
      expect(gremlins.map(&:colors)).to all(eq([:red]))
    end

    it "gives you energy equal to the number of creatures you control, counting the tokens" do
      expect(p1.energy).to eq(3)
      expect(p2.energy).to eq(0)
    end
  end

  context "with an opposing creature on the battlefield" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:scurry) { ResolvePermanent("Scurry Of Gremlins", owner: p1) }

    it "doesn't count the opponent's creature for energy" do
      expect(p1.energy).to eq(3)
    end
  end

  context "Pay {E}{E}{E}{E}" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:scurry) { ResolvePermanent("Scurry Of Gremlins", owner: p1) }

    def activate
      p1.activate_ability(ability: scurry.activated_abilities.first)
      game.stack.resolve!
      game.settle!
    end

    before do
      scurry.trigger_effect(:add_counter, counter_type: "energy", target: p1, amount: 2)
      game.settle!
    end

    it "pumps and hastes your creatures until end of turn" do
      expect(p1.energy).to eq(5)
      activate

      expect(p1.energy).to eq(1)
      expect(bears.power).to eq(3)
      expect(bears.has_keyword?(:haste)).to be(true)
      expect(gremlins.map(&:power)).to all(eq(2))
      expect(gremlins).to all(satisfy { _1.has_keyword?(:haste) })
    end

    it "wears off at end of turn" do
      activate
      expect(bears.power).to eq(3)

      current_turn.end!
      current_turn.cleanup!
      game.settle!

      expect(bears.power).to eq(2)
      expect(bears.has_keyword?(:haste)).to be(false)
      expect(gremlins.map(&:power)).to all(eq(1))
    end

    it "doesn't affect opposing creatures" do
      activate

      expect(enemy.power).to eq(2)
      expect(enemy.has_keyword?(:haste)).to be(false)
    end

    it "can't be activated without four energy" do
      p1.pay_energy!(2)

      expect { p1.activate_ability(ability: scurry.activated_abilities.first) }
        .to raise_error(RuntimeError, /can't pay 4 \{E\}/)
      expect(bears.power).to eq(2)
    end
  end
end
