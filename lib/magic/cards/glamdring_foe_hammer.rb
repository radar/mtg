module Magic
  module Cards
    GlamdringFoeHammer = Equipment("Glamdring, Foe-hammer") do
      legendary_artifact
      cost generic: 2
      equip [Costs::Mana.new(generic: 2)]
    end

    class GlamdringFoeHammer < Equipment
      # Gleam of Death {3}{U}, Sorcery -- Adventure
      adventure generic: 3, blue: 1

      # "Mill six cards, then put all instant and sorcery cards from among them into your hand."
      def adventure_resolve!(**)
        milled = controller.mill(6)
        milled.select { |card| card.instant? || card.sorcery? }.each { |card| card.move_to_hand!(controller) }
      end

      # "Instant and sorcery spells you cast cost {X} less to cast, where X is equipped creature's power."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: 0 })
        end

        # A method, not a stored lambda, so the game stays marshallable.
        def adjustment
          { generic: -[source.attached_to&.power.to_i, 0].max }
        end

        # Also asked about permanents (for their own characteristics); those are never spells.
        def applies_to?(card)
          card.is_a?(Magic::Card) && (card.instant? || card.sorcery?) && (card.controller || card.owner) == source.controller &&
            !source.attached_to.nil?
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
