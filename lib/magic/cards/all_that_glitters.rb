module Magic
  module Cards
    AllThatGlitters = Aura("All That Glitters") do
      cost generic: 1, white: 1
    end

    class AllThatGlitters < Aura
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification
          controller.permanents.count do |permanent|
            permanent.artifact? || permanent.enchantment? || permanent.card.is_a?(Cards::Aura)
          end
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end