module Magic
  module Cards
    VolcanicSalvo = Sorcery("Volcanic Salvo") do
      cost "{10}{R}{R}"
    end

    class VolcanicSalvo < Sorcery
      # "This spell costs {X} less to cast, where X is the total power of creatures you control."
      def self_mana_cost_adjustment
        { generic: -> { -(controller || owner).creatures.sum(&:power) } }
      end

      def target_choices = battlefield.by_any_type(T::Creature, T::Planeswalker)

      def distinct_targets? = true

      # "Volcanic Salvo deals 6 damage to each of up to two target creatures and/or planeswalkers."
      def resolve!(targets:)
        targets.first(2).each { |target| trigger_effect(:deal_damage, target:, damage: 6) }
      end
    end
  end
end
