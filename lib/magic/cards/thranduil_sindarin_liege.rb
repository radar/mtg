module Magic
  module Cards
    ThranduilSindarinLiege = Creature("Thranduil, Sindarin Liege") do
      cost "{2}{G/U}{G/U}"
      legendary_creature_type "Elf Noble"
      power 2
      toughness 3
    end

    class ThranduilSindarinLiege < Creature
      ElfToken = Token.create "Elf" do
        creature_type "Elf"
        power 1
        toughness 1
        colors :green
      end

      # Silvan Rally {1}{G/U}{G/U}, Sorcery -- Adventure
      adventure "{1}{G/U}{G/U}"

      # "Mill four cards, then put up to two land cards from among them into your hand."
      class LandsChoice < Magic::Choice
        def initialize(actor:, milled:)
          super(actor: actor)
          @lands = milled.select(&:land?)
        end

        def choices = @lands

        def resolve!(targets:)
          raise ArgumentError, "at most two cards may be chosen" if targets.size > 2

          targets.each { |land| land.move_to_hand! }
        end
      end

      def adventure_resolve!(**)
        milled = controller.mill(4)
        choice = LandsChoice.new(actor: self, milled: milled)
        game.choices.add(choice) if choice.choices.any?
      end

      # "Other Elves you control get +1/+1."
      class ElfLord < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      def static_abilities = [ElfLord]

      # "Landfall -- Whenever a land you control enters, create a 1/1 green Elf creature token."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          trigger_effect(:create_token, token_class: ElfToken, controller: controller)
        end
      end

      def event_handlers = super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
