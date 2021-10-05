require 'spec_helper'

RSpec.describe Magic::Game, "attackers declared" do
  subject(:game) { Magic::Game.new }

  let!(:p1) { game.add_player(library: [Card("Forest")]) }
  let!(:p2) { game.add_player }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  before do
    game.battlefield.add(wood_elves)
  end

  context "with basri ket's delayed trigger" do
    before do
      game.after_step(:declare_attackers, Magic::Cards::BasriKet::AfterAttackersDeclaredTrigger.new)
    end

    it "creates a 1/1 white soldier creature token" do
      until subject.at_step?(:declare_attackers)
        subject.next_step
      end

      combat = game.begin_combat!
      combat.declare_attacker(
        wood_elves,
        target: p2
      )

      subject.next_step
      creatures = game.battlefield.creatures
      expect(creatures.count).to eq(2)

      soldier = creatures.find { |c| c.name == "Soldier" }
      expect(soldier).to be_tapped
      soldier_attack = combat.attacks.find { |attack| attack.attacker == soldier }
      expect(soldier_attack.target).to eq(p2)

      until subject.at_step?(:cleanup)
        subject.next_step
      end

      empty_triggers = subject.after_step_triggers.all? { |_key, triggers| triggers.empty? }
      expect(empty_triggers).to eq(true)
    end
  end
end
