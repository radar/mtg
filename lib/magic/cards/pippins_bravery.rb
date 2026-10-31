module Magic
  module Cards
    PippinsBravery = Instant("Pippin's Bravery") do
      cost green: 1
    end

    class PippinsBravery < Instant
      # "You may sacrifice a Food. If you do, target creature gets +4/+4 until end of turn. Otherwise, that creature
      # gets +2/+2 until end of turn." Choosing a Food (`resolve!(sacrifice:)`) gives +4/+4; declining
      # (`game.skip_choice!`) gives +2/+2.
      class SacrificeFoodChoice < Magic::Choice
        def initialize(actor:, creature:)
          super(actor:)
          @creature = creature
        end

        def prompt = "Sacrifice a Food to give the creature +4/+4 instead of +2/+2?"

        def choices = controller.permanents.select { _1.type?("Food") }

        def resolve!(sacrifice:)
          raise ArgumentError, "choose one of your Foods" unless choices.include?(sacrifice)

          sacrifice.sacrifice!
          pump(@creature, 4, 4)
        end

        def decline!
          pump(@creature, 2, 2)
        end
      end

      def target_choices = battlefield.creatures

      def resolve!(target:)
        choice = SacrificeFoodChoice.new(actor: self, creature: target)
        if choice.choices.any?
          game.add_choice(choice)
        else
          pump(target, 2, 2)
        end
      end
    end
  end
end
