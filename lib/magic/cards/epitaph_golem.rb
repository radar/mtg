module Magic
  module Cards
    class EpitaphGolem < Creature
      card_name "Epitaph Golem"
      artifact_creature_type "Golem"
      cost generic: 4

      class Ability < ActivatedAbility
        costs "{2}"

        def target_choices
          controller.graveyard
        end

        def resolve!(target:)
          trigger_effect(
            :move_card_zone,
            source: source,
            target: target,
            from: source.zone,
            to: controller.library,
            placement: -1
          )
        end
      end

      def activated_abilities
        [Ability]
      end
    end
  end
end
