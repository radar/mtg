module Magic
  module Cards
    ReflectionOfKikiJiki = Creature("Reflection of Kiki-Jiki") do
      enchantment_creature_type "Goblin Shaman"
      power 2
      toughness 2
    end

    class ReflectionOfKikiJiki < Creature
      class EndStepSacrifice < TriggeredAbility
        def call
          actor.sacrifice!
        end
      end

      class CopyAbility < Magic::ActivatedAbility
        costs "{1}, {T}"

        def target_choices
          controller.creatures.reject(&:legendary?)
        end

        def resolve!(target:)
          copy = Permanent.resolve(
            game: game,
            owner: controller,
            card: target.card,
            token: true,
            copy: true,
          )
          copy.grant_haste!
          copy.register_turn_trigger(Events::BeginningOfEndStep, EndStepSacrifice)
        end
      end

      def activated_abilities = [CopyAbility]
    end
  end
end