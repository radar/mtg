module Magic
  module Cards
    JaxisTheTroublemaker = Creature("Jaxis, the Troublemaker") do
      cost generic: 3, red: 1
      legendary_creature_type "Human Warrior"
      power 2
      toughness 3
      blitz generic: 1, red: 1
    end

    class JaxisTheTroublemaker < Creature
      class CopyAbility < Magic::ActivatedAbility
        costs "{R}, {T}, Discard a card"

        def requirements_met?
          game.can_cast_sorcery?(source.controller)
        end

        def single_target?
          true
        end

        def target_choices
          controller.creatures.reject { |creature| creature == source }
        end

        def resolve!(target:)
          token = Permanent.resolve(
            game: game,
            owner: controller,
            card: target.card,
            token: true,
            copy: true,
          )
          token.grant_haste!
          token.register_turn_trigger(Events::CreatureDied, Blitz::DeathDrawTrigger)
          token.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
        end
      end

      def activated_abilities = [CopyAbility]
    end
  end
end
