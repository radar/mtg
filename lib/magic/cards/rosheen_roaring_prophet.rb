module Magic
  module Cards
    RosheenRoaringProphet = Creature("Rosheen, Roaring Prophet") do
      cost "{2}{R}{G}"
      legendary_creature_type "Giant Shaman"
      power 4
      toughness 4
    end

    class RosheenRoaringProphet < Creature
      def self.x_card?(card) = !!card.cost&.cost&.key?(:x)

      # "When Rosheen enters, mill six cards. You may put a card with {X} in its mana cost from among them into your hand."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          milled = controller.mill(6)
          game.choices.add(
            Magic::Choice::ReturnFromAmong.new(actor: actor, cards: milled, filter: ->(card) { RosheenRoaringProphet.x_card?(card) })
          )
        end
      end

      # "Reveal any number of cards with {X} in their mana cost in your hand. Add {C}{C} for each card revealed this way."
      class RevealChoice < Magic::Choice
        def choices = hand.cards.select { RosheenRoaringProphet.x_card?(_1) }

        def resolve!(targets: [])
          revealed = targets.to_a
          invalid = revealed.reject { choices.include?(_1) }
          raise ArgumentError, "#{invalid.first.name} is not a valid choice" if invalid.any?
          raise ArgumentError, "cards must be distinct" if revealed.uniq.size != revealed.size
          return if revealed.empty?

          controller.add_mana({ colorless: revealed.size * 2 }, restriction: ManaRestriction::CostsWithX.new)
        end

        def decline!
        end
      end

      # "{T}: Reveal any number of cards with {X} in their mana cost in your hand. Add {C}{C} for each card revealed this
      # way. Spend this mana only on costs that contain {X}."
      class RevealForMana < Magic::TapManaAbility
        def resolve!
          game.choices.add(RevealChoice.new(actor: source))
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [RevealForMana]
    end
  end
end
