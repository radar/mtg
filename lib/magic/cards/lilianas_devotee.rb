module Magic
  module Cards
    LilianasDevotee = Creature("Liliana's Devotee") do
      cost generic: 2, black: 1
      creature_type "Human Warlock"
      power 2
      toughness 3
    end

    class LilianasDevotee < Creature
      ZombieToken = Token.create "Zombie" do
        creature_type "Zombie"
        power 2
        toughness 2
        colors :black
      end

      # "Zombies you control get +1/+0."
      class ZombieBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applicable_targets { source.controller.creatures.by_type("Zombie") }
      end

      def static_abilities = [ZombieBuff]

      # "...you may pay {1}{B}. If you do, create a 2/2 black Zombie creature token."
      class PayChoice < Magic::Choice::PayMana
        def resolve!(**args)
          super(**args)
          trigger_effect(:create_token, token_class: ZombieToken)
        end
      end

      # "At the beginning of your end step, if a creature died this turn, ..."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && game.current_turn.events.any? { |e| e.is_a?(Events::CreatureDied) }
        end

        def call
          choice = PayChoice.new(actor:, mana: { generic: 1, black: 1 })
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
