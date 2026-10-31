module Magic
  module Cards
    class EntishRestoration < Instant
      card_name "Entish Restoration"
      cost generic: 2, green: 1

      class LandSearch < Magic::Choice::SearchLibrary
        def initialize(actor:, amount:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: amount, filter: Filter[:basic_lands],
                prompt: "Search your library for up to #{amount} basic land cards. They enter the battlefield tapped.")
        end
      end

      # "Sacrifice a land." Mandatory, so declining sacrifices the first land. The search follows either way.
      class SacrificeLand < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice a land."

        def initialize(actor:)
          super(actor: actor, type: "Land", other: false)
        end

        def resolve!(sacrifice: nil)
          super
          search
        end

        def decline!
          resolve!(sacrifice: candidates.first)
        end

        # "If you control a creature with power 4 or greater, instead ... up to three."
        def search
          big_creature = chooser.creatures.any? { _1.power >= 4 }
          game.add_choice(LandSearch.new(actor: actor, amount: big_creature ? 3 : 2))
        end
      end

      def resolve!
        choice = SacrificeLand.new(actor: self)
        if choice.candidates.any?
          game.add_choice(choice)
        else
          choice.search
        end
      end
    end
  end
end
