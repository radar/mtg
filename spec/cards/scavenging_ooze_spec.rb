require 'spec_helper'

RSpec.describe Magic::Cards::ScavengingOoze do
  include_context "two player game"

  let(:scavenging_ooze) { ResolvePermanent("Scavenging Ooze", owner: p1) }

  context "activated ability" do
    def ability
      scavenging_ooze.activated_abilities.first
    end

    context "when p2 has wood elves in their graveyard" do
      let(:wood_elves) { Card("Wood Elves") }

      before do
        p2.graveyard << wood_elves
      end

      it "exiles a card from a graveyard, adds +1/1 counter and p1 gains life" do
        p1.add_mana(green: 1)
        starting_life = p1.life
        p1.activate_ability(ability: ability) do
          _1
            .pay_mana(green: 1)
            .targeting(wood_elves)
        end
        game.stack.resolve!

        aggregate_failures do
          expect(wood_elves.zone).to be_exile

          expect(scavenging_ooze.counters.count).to eq(1)
          expect(scavenging_ooze.counters.first).to be_a(Magic::Counters::Plus1Plus1)

          expect(p1.life).to eq(starting_life + 1)
        end
      end
    end

    context "when p2 has sol ring in their graveyard" do
      let(:sol_ring) { Card("Sol Ring") }

      before do
        p2.graveyard << sol_ring
      end

      it "exiles sol ring, does not add counter and p1 does not gain life" do
        p1.add_mana(green: 1)
        starting_life = p1.life
        p1.activate_ability(ability: ability) do
          _1
            .pay_mana(green: 1)
            .targeting(sol_ring)
        end
        game.stack.resolve!

        aggregate_failures do
          expect(sol_ring.zone).to be_exile

          expect(scavenging_ooze.counters.count).to eq(0)

          expect(p1.life).to eq(starting_life)
        end
      end
    end
  end
end
