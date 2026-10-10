module Magic
  module Cards
    class DemonicCounsel < Sorcery
      card_name "Demonic Counsel"
      cost generic: 1, black: 1

      class DemonSearch < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, filter: ->(card) { card.any_type?("Demon") },
                prompt: "Search your library for a Demon card, reveal it, and put it into your hand.")
        end
      end

      class AnySearch < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, filter: ->(_card) { true },
                prompt: "Search your library for a card and put it into your hand.")
        end
      end

      # "Search your library for a Demon card, reveal it, put it into your hand, then shuffle. Delirium — If there are
      # four or more card types among cards in your graveyard, instead search your library for any card, put it into
      # your hand, then shuffle."
      def resolve!
        choice_class = controller.graveyard.delirium? ? AnySearch : DemonSearch
        game.add_choice(choice_class.new(actor: self))

        super
      end
    end
  end
end
