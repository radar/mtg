module Magic
  module Cards
    class PucasEye < Artifact
      card_name "Puca's Eye"
      cost generic: 2

      class ColorChoice < Magic::Choice::Color
        # "... choose a color. This artifact becomes the chosen color."
        def resolve!(color:)
          actor.change_colors!([color], until_eot: false)
        end
      end

      # "When this artifact enters, draw a card, then choose a color. This artifact becomes the chosen
      # color."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
          game.choices.add(ColorChoice.new(actor:))
        end
      end

      # "{3}, {T}: Draw a card. Activate only if there are five colors among permanents you control."
      class DrawAbility < Magic::ActivatedAbility
        costs "{3}, {T}"

        def requirements_met? = controller.colors_among_permanents == 5

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [DrawAbility]
    end
  end
end
