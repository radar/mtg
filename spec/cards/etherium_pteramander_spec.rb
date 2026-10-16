# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EtheriumPteramander do
  include_context "two player game"

  let!(:pteramander) { ResolvePermanent("Etherium Pteramander", owner: p1) }

  def adapt(mana)
    p1.add_mana(**mana)
    p1.activate_ability(ability: pteramander.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: mana.fetch(:red) }, black: 1)
    end
    game.stack.resolve!
    game.settle!
  end

  def attack_with(attacker)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    current_turn.attackers_declared!
  end

  it "is a 1/1 flying Salamander Drake artifact creature" do
    expect([pteramander.power, pteramander.toughness]).to eq([1, 1])
    expect(pteramander).to be_flying
    expect(pteramander.type?("Artifact")).to be(true)
    expect(pteramander.type?("Creature")).to be(true)
    expect(pteramander.type?("Salamander")).to be(true)
    expect(pteramander.type?("Drake")).to be(true)
  end

  context "can block only creatures with flying" do
    it "can block a creature with flying" do
      attacker = ResolvePermanent("Healer's Hawk", owner: p2)
      attack_with(attacker)

      expect { current_turn.declare_blocker(pteramander, attacker:) }.not_to raise_error
    end

    it "can't block a creature without flying" do
      attacker = ResolvePermanent("Grizzly Bears", owner: p2)
      attack_with(attacker)

      expect { current_turn.declare_blocker(pteramander, attacker:) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    end
  end

  context "{6}{B}: Adapt 4" do
    it "puts four +1/+1 counters on it when it has none, paying the full {6}{B} with no other artifacts" do
      adapt(red: 6, black: 1)

      expect([pteramander.power, pteramander.toughness]).to eq([5, 5])
    end

    it "does nothing when it already has a +1/+1 counter" do
      pteramander.add_counter("+1/+1")
      game.settle!
      adapt(red: 6, black: 1)

      expect([pteramander.power, pteramander.toughness]).to eq([2, 2])
    end

    it "costs {1} less for each other artifact you control" do
      ResolvePermanent("Lightning Greaves", owner: p1)
      ResolvePermanent("Lightning Greaves", owner: p1)
      adapt(red: 4, black: 1)

      expect([pteramander.power, pteramander.toughness]).to eq([5, 5])
    end

    it "is not discounted by the opponent's artifacts, or by itself" do
      ResolvePermanent("Lightning Greaves", owner: p2)
      p1.add_mana(red: 5, black: 1)

      expect do
        p1.activate_ability(ability: pteramander.activated_abilities.first) do |a|
          a.pay_mana(generic: { red: 5 }, black: 1)
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(pteramander.counters).to be_empty
    end
  end
end
