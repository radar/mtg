module Magic
  module Cards
    DevourerOfDestiny = Creature("Devourer of Destiny") do
      cost generic: 5, colorless: 2
      creature_type "Eldrazi"
      power 6
      toughness 6
      keywords :devoid
      reveals_from_opening_hand
    end

    class DevourerOfDestiny < Creature
      # "...look at the top four cards of your library. You may put one of those cards back on top of your library.
      # Exile the rest."
      class TopFourChoice < Magic::Choice
        attr_reader :looked_at

        def initialize(actor:)
          super
          @looked_at = chooser.library.first(4)
        end

        def choices = looked_at

        # target: the card to put back on top, or nil to exile all four.
        def resolve!(target: nil)
          raise ArgumentError, "#{target.name} is not one of the top four cards" if target && !looked_at.include?(target)

          (looked_at - [target]).each { |card| card.exile! }
        end
      end

      # "When you cast this spell, exile target permanent that's one or more colors."
      class ExileChoice < Magic::Choice::Targeted
        def choices = battlefield.permanents.reject(&:colorless?)

        def choice_amount = 1

        def resolve!(target:)
          exile_target(target)
        end
      end

      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [CastTrigger]

      def opening_hand_reveal_effect(game:, player:)
        game.add_choice(TopFourChoice.new(actor: self))
      end
    end
  end
end
