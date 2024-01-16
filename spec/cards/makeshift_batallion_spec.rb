require 'spec_helper'

RSpec.describe Magic::Cards::MakeshiftBatallion do
  include_context "two player game"

  subject(:makeshift_batallion) { ResolvePermanent("Makeshift Batallion", owner: p1) }
  let(:wood_elves_1) { ResolvePermanent("Wood Elves", owner: p1) }
  let(:wood_elves_2) { ResolvePermanent("Wood Elves", owner: p1) }
  let(:falconer_adept) { ResolvePermanent("Falconer Adept", owner: p1) }

  context "when attacking" do
    before do
      skip_to_combat!
    end

    it "gets a +1/+1 counter when both elves attack" do
      current_turn.declare_attackers!

      p1.declare_attacker(
        attacker: makeshift_batallion,
        target: p2,
      )

      p1.declare_attacker(
        attacker: wood_elves_1,
        target: p2,
      )

      p1.declare_attacker(
        attacker: wood_elves_2,
        target: p2,
      )

      current_turn.attackers_declared!

      expect(makeshift_batallion.counters.count).to eq(1)
      expect(makeshift_batallion.counters.first).to be_a(Magic::Counters::Plus1Plus1)
    end

    it "gets no counters when only one elf attacks" do
      current_turn.declare_attackers!

      p1.declare_attacker(
        attacker: makeshift_batallion,
        target: p2,
      )

      p1.declare_attacker(
        attacker: wood_elves_1,
        target: p2,
      )

      current_turn.attackers_declared!

      expect(makeshift_batallion.counters.count).to eq(0)
    end

    # Rule 508.3
    # Even though there are three attackers, only two were declared during the declare step.
    it "gets no counters when falconer adept attacks" do
      current_turn.declare_attackers!

      p1.declare_attacker(
        attacker: makeshift_batallion,
        target: p2,
      )

      p1.declare_attacker(
        attacker: falconer_adept,
        target: p2,
      )

      current_turn.attackers_declared!

      expect(makeshift_batallion.counters.count).to eq(0)
    end
  end
end
