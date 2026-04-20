require 'spec_helper'

RSpec.describe Magic::Game, 'damage events -- canonical only' do
  include_context 'two player game'

  let!(:attacker) { ResolvePermanent('Loxodon Wayfarer', owner: p1) }

  it 'tracks combat damage through DamageDealt without CombatDamageDealt events' do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    go_to_combat_damage!

    damage_events = current_turn.events.select { |event| event.is_a?(Magic::Events::DamageDealt) }

    aggregate_failures do
      expect(damage_events.any?(&:combat?)).to eq(true)
      expect(current_turn.events.map(&:class).map(&:name)).not_to include('Magic::Events::CombatDamageDealt')
    end
  end
end
