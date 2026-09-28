module Magic
  module Cards
    GlisterBairn = Creature("Glister Bairn") do
      creature_type "Ouphe"
      cost "{2}{G/U}{G/U}{G/U}"
      power 1
      toughness 4
    end

    class GlisterBairn < Creature
      class TargetChoice < Magic::Choice::Targeted
        def choices
          battlefield.creatures.controlled_by(controller) - [actor]
        end

        def choice_amount = 1

        def resolve!(target:)
          x = controller.colors_among_permanents
          trigger_effect(:modify_power_toughness, power: x, toughness: x, target: target, until_eot: true)
        end
      end

      # Vivid -- At the beginning of combat on your turn, another target creature you control gets +X/+X until end of turn.
      class CombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
