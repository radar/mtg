module Magic
  module Cards
    class LizardBlades < Equipment
      card_name "Lizard Blades"
      cost generic: 1, red: 1
      type T::Artifact, T::Creature, "Equipment", T::Creatures["Lizard"]
      keywords :double_strike
      power 1
      toughness 1

      # Reconfigure (702.151): attach it to a creature you control, or unattach it, only as a sorcery. While it is
      # attached it isn't a creature (see Permanents::ContinuousEffects#calculate_types).
      def reconfigure? = true

      # Equipment is not a Creature card, which is where the base power and toughness normally come from.
      def base_power = self.class::POWER
      def base_toughness = self.class::TOUGHNESS

      # "Equipped creature has double strike."
      def keyword_grants = [Keywords::DOUBLE_STRIKE]

      class AttachAbility < Magic::ActivatedAbility
        costs "{2}"

        def requirements_met? = game.can_cast_sorcery?(controller) && source.attached_to.nil?

        def target_choices = controller.creatures.reject { _1 == source }

        def resolve!(target:)
          source.attach_to!(target)
          source.apply_continuous_effects!
        end
      end

      class UnattachAbility < Magic::ActivatedAbility
        costs "{2}"

        def requirements_met? = game.can_cast_sorcery?(controller) && !source.attached_to.nil?

        def resolve!
          source.detach!
          source.apply_continuous_effects!
        end
      end

      def activated_abilities = [AttachAbility, UnattachAbility]
    end
  end
end
