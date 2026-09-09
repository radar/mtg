module Magic
  module Cards
    SoulOfWindgrace = Creature("Soul of Windgrace") do
      legendary_creature_type "Cat Avatar"
      cost generic: 1, black: 1, red: 1, green: 1
      power 5
      toughness 4
    end

    class SoulOfWindgrace < Creature
      class LandChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.game.graveyard_cards.lands
          super
        end

        def resolve!(target:)
          target.resolve!(enters_tapped: true)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = LandChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          choice = LandChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class GainLifeAbility < Magic::ActivatedAbility
        costs "{G}"

        def resolve!
          controller.gain_life(3)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger,
          Events::FinalAttackersDeclared => AttackTrigger,
        }
      end

      def activated_abilities = [GainLifeAbility]
    end
  end
end