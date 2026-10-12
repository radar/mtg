module Magic
  module Cards
    BoseijuWhoEndures = Card("Boseiju, Who Endures") do
      type T::Super::Legendary, T::Land
    end

    class BoseijuWhoEndures < Card
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]

      # "Channel -- {1}{G}, Discard this card: Destroy target artifact, enchantment, or nonbasic land an opponent controls.
      # That player may search their library for a basic land card, put it onto the battlefield, then shuffle. This ability
      # costs {1} less to activate for each legendary creature you control."
      class ChannelAbility < Magic::ActivatedAbility
        def description = "Channel: destroy target artifact, enchantment, or nonbasic land"

        def costs
          generic = [1 - controller.creatures.count(&:legendary?), 0].max
          mana = generic.zero? ? { green: 1 } : { generic: generic, green: 1 }
          [Costs::Mana.new(mana), Costs::SelfDiscard.new(source)]
        end

        def requirements_met?
          !!source.zone&.hand? && source.owner == controller
        end

        def target_choices
          battlefield.not_controlled_by(controller).select do |permanent|
            permanent.artifact? || permanent.enchantment? || (permanent.land? && !permanent.basic_land?)
          end
        end

        def resolve!(target:)
          opponent = target.controller
          trigger_effect(:destroy_target, target: target)
          # The permanent, not its card, is the actor: a token's card has no controller.
          game.search_library(target, find: :basic_lands, to: :battlefield) if opponent.library.basic_lands.any?
        end
      end

      def hand_abilities = [ChannelAbility.new(source: self)]
    end
  end
end
