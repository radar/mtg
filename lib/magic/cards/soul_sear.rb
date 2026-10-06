module Magic
  module Cards
    SoulSear = Instant("Soul Sear") do
      cost generic: 2, red: 1
    end

    class SoulSear < Instant
      def target_choices = battlefield.by_any_type(T::Creature, T::Planeswalker)

      # "Soul Sear deals 5 damage to target creature or planeswalker. That permanent loses indestructible
      # until end of turn."
      def resolve!(target:)
        trigger_effect(:deal_damage, target:, damage: 5)
        target.lose_keyword!(Keywords::INDESTRUCTIBLE)
      end
    end
  end
end
