require 'spec_helper'

RSpec.describe Magic::Game::CombatPhase do

  let(:p1) { Magic::Player.new }
  let(:p2) { Magic::Player.new }

  subject(:phase) do
    Magic::Game::CombatPhase.new(active_player: p1, opponents: [p2])
  end

  context "combat phase" do
    context "with a loxodon wayfarer" do
      let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new }
      it "with p1 loxodon attacking p2, no blockers" do
        p1_starting_life = p1.life
        p2_starting_life = p2.life

        phase.next_step
        expect(phase).to be_declare_attackers

        phase.declare_attacker(
          loxodon_wayfarer,
          target: p2,
        )

        phase.next_step
        expect(phase).to be_declare_blockers

        phase.next_step
        expect(phase).to be_first_strike

        phase.next_step
        expect(phase).to be_combat_damage

        expect(p2.life).to eq(p2_starting_life - 1)
      end
    end

    context "with a loxodon wayfarer and vastwood gorger" do
      let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new }
      let(:vastwood_gorger) { Magic::Cards::VastwoodGorger.new }
      it "with p1 loxodon attacking p2, blocked by vastwood gorger" do
        p1_starting_life = p1.life
        p2_starting_life = p2.life

        phase.next_step
        expect(phase).to be_declare_attackers

        phase.declare_attacker(
          loxodon_wayfarer,
          target: p2,
        )

        phase.next_step
        expect(phase).to be_declare_blockers

        phase.declare_blocker(
          vastwood_gorger,
          target: loxodon_wayfarer,
        )

        phase.next_step
        expect(phase).to be_first_strike

        phase.next_step
        expect(phase).to be_combat_damage

        expect(p2.life).to eq(p2_starting_life)
        expect(phase.fatalities).to eq([loxodon_wayfarer])
      end

      it "with p1 vastwood gorger attacking p2, blocked by loxodon wayfarer" do
        p1_starting_life = p1.life
        p2_starting_life = p2.life

        phase.next_step
        expect(phase).to be_declare_attackers

        phase.declare_attacker(
          vastwood_gorger,
          target: p2,
        )

        phase.next_step
        expect(phase).to be_declare_blockers

        phase.declare_blocker(
          loxodon_wayfarer,
          target: vastwood_gorger,
        )

        phase.next_step
        expect(phase).to be_first_strike

        phase.next_step
        expect(phase).to be_combat_damage

        expect(p2.life).to eq(p2_starting_life)
        expect(phase.fatalities).to eq([loxodon_wayfarer])
      end
    end
  end
end
