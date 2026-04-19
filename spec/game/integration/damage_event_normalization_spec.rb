require 'spec_helper'

RSpec.describe Magic::Game, 'damage events -- normalized pipeline' do
  include_context 'two player game'

  let!(:attacker) { ResolvePermanent('Loxodon Wayfarer', owner: p1) }

  def damage_events
    current_turn.events.select { |event| event.is_a?(Magic::Events::DamageDealt) }
  end

  it 'emits canonical noncombat damage event and applies damage once' do
    p2_starting_life = p2.life

    p1.add_mana(red: 1)
    shock = Card('Shock', owner: p1)
    p1.hand.add(shock)

    p1.cast(card: shock) do
      _1.pay_mana(red: 1)
      _1.targeting(p2)
    end

    game.stack.resolve!

    event = damage_events.last
    aggregate_failures do
      expect(event).not_to be_nil
      expect(event.combat?).to eq(false)
      expect(event.damage).to eq(2)
      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end

  it 'emits canonical combat damage event with combat metadata' do
    p2_starting_life = p2.life

    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    go_to_combat_damage!

    combat_damage_events = damage_events.select(&:combat?)
    event = combat_damage_events.last

    aggregate_failures do
      expect(event).not_to be_nil
      expect(event.combat?).to eq(true)
      expect(event.damage).to eq(attacker.power)
      expect(p2.life).to eq(p2_starting_life - attacker.power)
    end
  end
end
