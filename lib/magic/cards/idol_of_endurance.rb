module Magic
  module Cards
    IdolOfEndurance = Artifact("Idol of Endurance") do
      cost generic: 2, white: 1
    end

    class IdolOfEndurance < Artifact
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          cards_to_exile = controller.graveyard.cmc_lte(3)
          cards_to_exile.each do |card|
            exile_effect = Effects::Exile.new(source: permanent).resolve(card)
            permanent.exiled_cards << card
          end
        end
      end

      def etb_triggers = [ETB]

      class LTB < TriggeredAbility::EnterTheBattlefield
        def perform
          # TODO: Should this take into account the graveyard the cards came _from_?
          # If this Idol changes controllers before the LTB is triggered, those cards would go to that new controller's graveyard.
          permanent.exiled_cards.each { _1.move_to_graveyard!(permanent.controller) }
        end
      end

      def ltb_triggers = [LTB]

      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 1, white: 1), Costs::Tap.new(source)]

        def single_target?
          true
        end

        def target_choices
          source.exiled_cards
        end

        def resolve!(target:)
          source.remove_from_exile(target)
          cast_action = Magic::Actions::Cast.new(card: target, player: source.controller)
          cast_action.mana_cost = 0
          game.take_action(cast_action)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
