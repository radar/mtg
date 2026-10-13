module Magic
  module Cards
    KioraTheRisingTide = Creature("Kiora, the Rising Tide") do
      cost generic: 2, blue: 1
      legendary_creature_type("Merfolk Noble")
      power 3
      toughness 2
    end

    class KioraTheRisingTide < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          draw_cards(2)
          2.times { game.add_choice(Magic::Choice::Discard.new(player: controller)) }
        end
      end

      def etb_triggers = [EntersTrigger]

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && (controller.graveyard.cards.count >= 7)
        end

        ScionOfTheDeepToken = Token.create "Scion of the Deep" do
          legendary_creature_type "Octopus"
          power 8
          toughness 8
          colors :blue
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            create_token(token:ScionOfTheDeepToken)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
