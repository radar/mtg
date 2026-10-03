module Magic
  module Cards
    FieryAnnihilation = Instant("Fiery Annihilation") do
      cost generic: 2, red: 1
    end

    class FieryAnnihilation < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 5)
        choice = Magic::Choice::ExileAttachedEquipment.new(actor: self, creature: target)
        game.add_choice(choice) if choice.choices.any?
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
