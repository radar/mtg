module Magic
  module Cards
    PrismaticUndercurrents = Enchantment("Prismatic Undercurrents") do
      cost generic: 3, green: 1
    end

    class PrismaticUndercurrents < Enchantment
      additional_lands_per_turn 1

      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, upto: actor.controller.colors_among_permanents, to_zone: :hand, reveal: true, filter: Filter[:basic_lands])
        end
      end

      # Vivid -- When this enchantment enters, search your library for up to X basic land cards.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(SearchChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
