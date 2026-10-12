module Magic
  module Cards
    KineticAugur = Creature("Kinetic Augur") do
      cost generic: 3, red: 1
      creature_type "Human Shaman"
      keywords :trample
      power 0
      toughness 4
    end

    class KineticAugur < Creature
      # "Kinetic Augur's power is equal to the number of instant and sorcery cards in your graveyard."
      class DynamicPower < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.graveyard.cards.count { |card| card.instant? || card.sorcery? }
        end
      end

      def static_abilities = [DynamicPower]

      class DiscardDrawChoice < Magic::Choice
        def choices = controller.hand

        # "Discard up to two cards, then draw that many cards."
        def resolve!(discarded: [])
          raise ArgumentError, "Choose up to two cards to discard." if discarded.size > 2

          discarded.each(&:discard!)
          trigger_effect(:draw_cards, number_to_draw: discarded.size) if discarded.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(DiscardDrawChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
