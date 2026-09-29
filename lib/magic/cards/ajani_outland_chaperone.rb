module Magic
  module Cards
    class AjaniOutlandChaperone < Planeswalker
      card_name "Ajani, Outland Chaperone"
      cost generic: 1, white: 2
      type T::Super::Legendary, T::Planeswalker, "Ajani"
      loyalty 3

      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      # "+1: Create a 1/1 green and white Kithkin creature token."
      class KithkinAbility < Magic::LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          trigger_effect(:create_token, token_class: KithkinToken)
        end
      end

      # "−2: Ajani deals 4 damage to target tapped creature."
      class DamageAbility < Magic::LoyaltyAbility
        def loyalty_change = -2

        def single_target? = true

        def target_choices = battlefield.creatures.select(&:tapped?)

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 4)
        end
      end

      class PutChoice < Magic::Choice
        attr_reader :cards

        def initialize(actor:, cards:)
          super(actor:)
          @cards = cards
        end

        def choices = cards.select { _1.permanent? && !_1.land? && _1.mana_value <= 3 }

        # `targets`: any number of the offered cards.
        def resolve!(targets: [])
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be put onto the battlefield" if invalid.any?

          targets.each { _1.resolve!(controller:) }
          controller.shuffle!
        end
      end

      # "−8: Look at the top X cards of your library, where X is your life total. You may put any
      # number of nonland permanent cards with mana value 3 or less from among them onto the
      # battlefield. Then shuffle."
      class TopCardsAbility < Magic::LoyaltyAbility
        def loyalty_change = -8

        def resolve!
          cards = controller.library.first([controller.life, 0].max)
          game.add_choice(PutChoice.new(actor: source, cards:))
        end
      end

      def loyalty_abilities = [KithkinAbility, DamageAbility, TopCardsAbility]
    end
  end
end
