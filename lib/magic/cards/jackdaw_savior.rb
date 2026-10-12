module Magic
  module Cards
    JackdawSavior = Creature("Jackdaw Savior") do
      cost generic: 2, white: 1
      creature_type("Bird Cleric")
      keywords :flying
      power 3
      toughness 1
    end

    class JackdawSavior < Creature
      # Whenever this creature or another creature you control with flying dies, return another target creature
      # card with lesser mana value from your graveyard to the battlefield.
      class FlyerDies < TriggeredAbility
        class ReturnChoice < Magic::Choice::Targeted
          def initialize(actor:, dead:)
            @dead = dead
            super(actor: actor)
          end

          def choices
            controller.graveyard.creatures.reject { _1 == @dead.card || _1.mana_value >= @dead.mana_value }
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
          end
        end

        def should_perform?
          event.controller == controller && event.permanent.keywords.include?(Keywords::FLYING)
        end

        def call
          choice = ReturnChoice.new(actor: actor, dead: event.permanent)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::CreatureDied => FlyerDies)

      # (Its own death needs the trigger too: a dying permanent no longer receives events.)
      def death_triggers = [OwnDeath]

      class OwnDeath < TriggeredAbility::Death
        def call
          choice = FlyerDies::ReturnChoice.new(actor: actor, dead: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end
    end
  end
end
