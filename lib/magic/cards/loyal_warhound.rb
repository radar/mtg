module Magic
  module Cards
    LoyalWarhound = Creature("Loyal Warhound") do
      cost generic: 1, white: 1
      creature_type "Dog"
      keywords :vigilance
      power 3
      toughness 1
    end

    class LoyalWarhound < Creature
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :battlefield,
            enters_tapped: true,
            filter: ->(card) { card.basic_land? && card.any_type?("Plains") },
          )
        end
      end

      # "When this creature enters, if an opponent controls more lands than you, search your library for a basic
      # Plains card, put it onto the battlefield tapped, then shuffle."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          opponents.any? { |opponent| opponent.lands.count > controller.lands.count }
        end

        def call
          game.choices.add(SearchChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
