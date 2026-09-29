module Magic
  module Cards
    class GravelgillScoundrel < Creature
      card_name "Gravelgill Scoundrel"
      cost generic: 1, blue: 1
      creature_type "Merfolk Rogue"
      power 1
      toughness 3
      keywords :vigilance

      class TapChoice < Magic::Choice::Targeted
        def choices = controller.creatures.untapped.except(actor)

        def choice_amount = 1

        def resolve!(target:)
          target.tap!
          trigger_effect(:grant_keyword, target: actor, keyword: :cant_be_blocked)
        end
      end

      class MayTapChoice < Magic::Choice::May
        def resolve!
          choice = TapChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Whenever this creature attacks, you may tap another untapped creature you control. If you do,
      # this creature can't be blocked this turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.choices.add(MayTapChoice.new(actor:)) if controller.creatures.untapped.except(actor).any?
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
