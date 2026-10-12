module Magic
  module Cards
    ClammyProwler = Creature("Clammy Prowler") do
      cost generic: 3, blue: 1
      enchantment_creature_type "Horror"
      power 2
      toughness 5
    end

    class ClammyProwler < Creature
      class UnblockableChoice < Magic::Choice::Targeted
        def choices = controller.creatures.attacking.except(actor)

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:grant_keyword, target:, keyword: :cant_be_blocked)
        end
      end

      # "Whenever this creature attacks, another target attacking creature can't be blocked this turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          choice = UnblockableChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
