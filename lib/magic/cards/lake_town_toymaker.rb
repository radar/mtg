module Magic
  module Cards
    LakeTownToymaker = Creature("Lake-town Toymaker") do
      cost generic: 3, white: 1
      creature_type "Human Artificer"
      power 3
      toughness 4
    end

    class LakeTownToymaker < Creature
      # "At the beginning of combat on your turn, if you've drawn two or more cards this turn, another target
      # creature you control gets +3/+0 and gains first strike until end of turn."
      class CombatTrigger < TriggeredAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures - [actor]

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)
            trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
          end
        end

        def should_perform?
          event.active_player == controller &&
            game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == controller } >= 2
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge({ Events::BeginningOfCombat => CombatTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
