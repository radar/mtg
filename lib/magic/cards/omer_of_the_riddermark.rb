module Magic
  module Cards
    OmerOfTheRiddermark = Creature("Éomer of the Riddermark") do
      cost generic: 4, red: 1
      legendary_creature_type "Human Knight"
      power 5
      toughness 4
      keywords :haste
    end

    class OmerOfTheRiddermark < Creature
      # "Whenever Éomer attacks, if you control a creature with the greatest power among creatures on the battlefield,
      # create a 1/1 white Human Soldier creature token." The "if" is checked when it triggers and when it resolves.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacker == actor && greatest_power?
        end

        def call
          create_token(token: Tokens::HumanSoldier) if greatest_power?
        end

        private

        # A tie for the greatest power still counts, so long as one of the tied creatures is yours.
        def greatest_power?
          creatures = game.battlefield.creatures.to_a
          greatest = creatures.map(&:power).max
          controller.creatures.any? { _1.power == greatest }
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttackTrigger }
    end
  end
end
