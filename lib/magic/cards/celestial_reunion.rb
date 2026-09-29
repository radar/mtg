module Magic
  module Cards
    class CelestialReunion < Sorcery
      card_name "Celestial Reunion"
      cost green: 1, x: 1

      # As an additional cost to cast this spell, you may choose a creature type and behold two
      # creatures of that type.
      def kicker_cost
        @behold_kicker_cost ||= Costs::BeholdKicker.new(self)
      end

      # Search your library for a creature card with mana value X or less, reveal it, put it into
      # your hand, then shuffle. If this spell's additional cost was paid and the revealed card is
      # the chosen type, put that card onto the battlefield instead of putting it into your hand.
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:, x:, chosen_type:)
          @chosen_type = chosen_type
          super(actor: actor, filter: ->(card) { card.creature? && card.cmc <= x }, reveal: true, to_zone: :hand)
        end

        def resolve!(targets:)
          targets = Array(targets)
          raise ArgumentError, "can search for at most 1 card, got #{targets.size}" if targets.size > 1

          trigger_effect(:reveal_cards, target: targets)
          targets.each do |target|
            @chosen_type && target.type?(@chosen_type) ? target.resolve!(enters_tapped: false) : target.move_to_hand!
          end
          controller.shuffle!
        end
      end

      def resolve!(value_for_x:)
        chosen_type = kicker_cost.creature_type if kicker_cost.paid?
        kicker_cost.reset!
        game.add_choice(SearchChoice.new(actor: self, x: value_for_x.to_i, chosen_type: chosen_type))
      end
    end
  end
end
