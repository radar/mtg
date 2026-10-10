module Magic
  module Cards
    FearOfFalling = Creature("Fear of Falling") do
      cost generic: 3, blue: 2
      enchantment_creature_type "Nightmare"
      keywords :flying
      power 4
      toughness 4
    end

    class FearOfFalling < Creature
      class WeakenChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.reject { _1.controller == controller }

        def choice_amount = 1

        def resolve!(target:)
          target.modify_power_until_turn_of!(controller, -2)
          target.lose_keyword_until_turn_of!(Keywords::FLYING, controller)
        end
      end

      # "Whenever this creature attacks, target creature defending player controls gets -2/-0 and loses flying
      # until your next turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          choice = WeakenChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::CreatureAttacked => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
