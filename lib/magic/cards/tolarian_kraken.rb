module Magic
  module Cards
    TolarianKraken = Creature("Tolarian Kraken") do
      cost generic: 4, blue: 2
      creature_type "Kraken"
      power 4
      toughness 6
    end

    class TolarianKraken < Creature
      # "When you do, you may tap or untap target creature." Declining is `game.skip_choice!`; answer with
      # `resolve_choice!(target:, untap: true)` to untap (the default taps).
      class TapOrUntapChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:, untap: false)
          untap ? target.untap! : target.tap!
        end
      end

      # "Whenever you draw a card, you may pay {1}."
      class PayChoice < Magic::Choice::PayMana
        def resolve!(**args)
          super(**args)
          choice = TapOrUntapChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class DrawTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          choice = PayChoice.new(actor:, mana: { generic: 1 })
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def event_handlers = { Events::CardDraw => DrawTrigger }
    end
  end
end
