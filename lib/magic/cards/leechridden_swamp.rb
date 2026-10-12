module Magic
  module Cards
    LeechriddenSwamp = Card("Leechridden Swamp") do
      type T::Land, T::Lands::Swamp
      enters_tapped
    end

    class LeechriddenSwamp < Card
      # "{B}, {T}: Each opponent loses 1 life. Activate only if you control two or more black permanents."
      class DrainAbility < Magic::ActivatedAbility
        costs "{B}, {T}"

        def requirements_met?
          controller.permanents.count { _1.colors.include?(:black) } >= 2
        end

        def resolve!
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 1) }
        end
      end

      def activated_abilities = [DrainAbility]
    end
  end
end
