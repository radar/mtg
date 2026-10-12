module Magic
  module Cards
    ElvishRejuvenator = Creature("Elvish Rejuvenator") do
      cost generic: 2, green: 1
      creature_type "Elf Druid"
      power 1
      toughness 1
    end

    class ElvishRejuvenator < Creature
      # "Look at the top five cards of your library. You may put a land card from among them onto the
      # battlefield tapped. Put the rest on the bottom of your library in a random order."
      class LookChoice < Magic::Choice
        attr_reader :looked_at

        def prompt = "Put a land card from the top five cards of your library onto the battlefield tapped. The rest go on the bottom."

        def initialize(actor:)
          super
          @looked_at = controller.library.first(5)
        end

        def choices = looked_at.select(&:land?)

        # target: the land to put onto the battlefield tapped, or nil to take none.
        def resolve!(target: nil)
          raise ArgumentError, "#{target.name} is not a valid choice" if target && !choices.include?(target)

          target&.resolve!(enters_tapped: true)

          (looked_at - [target]).shuffle.each do |card|
            controller.library.remove(card)
            controller.library.push(card)
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(LookChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
