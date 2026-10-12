module Magic
  module Cards
    VowToErebor = Instant("Vow to Erebor") do
      cost generic: 1, white: 1
    end

    class VowToErebor < Instant
      def single_target? = true

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      # "If it's a Dwarf, you may attach an Equipment you control to it."
      class AttachChoice < Magic::Choice::Targeted
        def initialize(actor:, creature:)
          super(actor: actor)
          @creature = creature
        end

        def choice_amount = 0..1

        def choices
          game.battlefield.controlled_by(controller).by_any_type("Equipment")
        end

        def resolve!(target:)
          target.attach_to!(@creature)
        end
      end

      def resolve!(target:)
        target.untap!
        trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 2)
        return unless target.type?("Dwarf")

        choice = AttachChoice.new(actor: self, creature: target)
        game.add_choice(choice) if choice.choices.any?
      end
    end
  end
end
