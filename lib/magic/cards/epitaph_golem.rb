module Magic
  module Cards
    class EpitaphGolem < Creature
      name "Epitaph Golem"
      artifact_creature_type "Golem"
      cost generic: 4

      class Ability < ActivatedAbility
        costs "{2}"

        def target_choices
          controller.graveyard
        end

        def resolve!(target:)
          trigger_effect(:move_zone, source: source, target: target, destination: controller.library)
        end
      end

      def activated_abilities
        [Ability]
      end
    end
  end
end
