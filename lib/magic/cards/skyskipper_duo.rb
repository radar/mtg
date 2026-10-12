module Magic
  module Cards
    SkyskipperDuo = Creature("Skyskipper Duo") do
      cost generic: 4, blue: 1
      creature_type("Bird Frog")
      keywords :flying
      power 3
      toughness 3
    end

    class SkyskipperDuo < Creature
      # When this creature enters, exile up to one other target creature you control. Return it to the battlefield
      # under its owner's control at the beginning of the next end step.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ExileChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures - [actor]

          def choice_amount = 0..1

          def resolve!(target:)
            card = target.card
            trigger_effect(:exile, target: target)
            game.subscribe(DelayedReturn.new(game: game, cards: [card]))
          end
        end

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
