module Magic
  module Cards
    class OkoShadowmoorScion < Planeswalker
      card_name "Oko, Shadowmoor Scion"
      type T::Super::Legendary, T::Planeswalker, "Oko"
      color_indicator :green
      loyalty 3

      # "You get an emblem with 'Creatures you control of the chosen type get +3/+3 and have
      # vigilance and hexproof.'"
      class Emblem < Magic::Emblem
        attr_reader :creature_type

        def initialize(game:, owner:, creature_type:)
          super(game:, owner:)
          @creature_type = creature_type
        end

        class Buff < Abilities::Static::PowerAndToughnessModification
          modify power: 3, toughness: 3

          def applicable_targets = source.controller.creatures.select { _1.type?(source.creature_type) }
        end

        class Keywords < Abilities::Static::KeywordGrant
          keyword_grants Magic::Cards::Keywords::VIGILANCE, Magic::Cards::Keywords::HEXPROOF

          def applicable_targets = source.controller.creatures.select { _1.type?(source.creature_type) }
        end

        def static_abilities = [Buff, Keywords]
      end

      class ChooseTypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          game.add_emblem(Emblem.new(game:, owner: controller, creature_type:))
        end
      end

      ElkToken = Token.create "Elk" do
        creature_type "Elk"
        power 3
        toughness 3
        colors :green
      end

      # "-1: Mill three cards. You may put a permanent card from among them into your hand."
      class MillAbility < Magic::LoyaltyAbility
        def loyalty_change = -1

        def resolve!
          milled = controller.mill(3)
          game.add_choice(Magic::Choice::ReturnFromAmong.new(actor: source, cards: milled, filter: ->(card) { card.permanent? }))
        end
      end

      # "-3: Create two 3/3 green Elk creature tokens."
      class ElkAbility < Magic::LoyaltyAbility
        def loyalty_change = -3

        def resolve!
          trigger_effect(:create_token, token_class: ElkToken, amount: 2)
        end
      end

      # "-6: Choose a creature type. You get an emblem with ..."
      class EmblemAbility < Magic::LoyaltyAbility
        def loyalty_change = -6

        def resolve!
          game.add_choice(ChooseTypeChoice.new(actor: source))
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay blue: 1
      end

      def loyalty_abilities = [MillAbility, ElkAbility, EmblemAbility]

      def event_handlers
        { Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class OkoLorwynLiege < Planeswalker
      card_name "Oko, Lorwyn Liege"
      cost generic: 2, blue: 1
      type T::Super::Legendary, T::Planeswalker, "Oko"
      loyalty 3
      back_face OkoShadowmoorScion

      # "+2: Up to one target creature gains all creature types. (This effect doesn't end.)"
      class TypesAbility < Magic::LoyaltyAbility
        def loyalty_change = 2

        def single_target? = true

        def target_choices = battlefield.creatures

        def resolve!(target: nil)
          target&.gain_all_creature_types!
        end
      end

      # "+1: Target creature gets -2/-0 until your next turn."
      class ShrinkAbility < Magic::LoyaltyAbility
        def loyalty_change = 1

        def single_target? = true

        def target_choices = battlefield.creatures

        def resolve!(target:)
          target.modify_power_until_turn_of!(controller, -2)
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay green: 1
      end

      def loyalty_abilities = [TypesAbility, ShrinkAbility]

      def event_handlers
        { Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
