module Magic
  module Cards
    class HorrificAssault < Sorcery
      card_name "Horrific Assault"
      cost green: 1

      def multi_target? = true

      def target_choices
        [
          battlefield.controlled_by(controller).creatures,
          battlefield.not_controlled_by(controller).by_any_type(T::Creature, T::Planeswalker)
        ]
      end

      # Target creature you control deals damage equal to its power to target creature or planeswalker you don't
      # control. If you control an Eldrazi, you gain 3 life.
      def resolve!(targets:)
        mine, theirs = targets
        mine.bite!(theirs)
        gain_life 3 if battlefield.controlled_by(controller).any? { _1.type?("Eldrazi") }
      end
    end
  end
end
