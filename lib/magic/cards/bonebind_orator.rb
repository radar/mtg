module Magic
  module Cards
    BonebindOrator = Creature("Bonebind Orator") do
      cost generic: 1, black: 1
      creature_type("Squirrel Warlock Bard")
      power 2
      toughness 2
    end

    class BonebindOrator < Creature
      # {3}{B}, Exile this card from your graveyard: Return another target creature card from your graveyard to
      # your hand.
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{3}{B}, Exile {this}"

        def requirements_met?
          (source.zone&.graveyard? || source.zone&.exile?) && source.owner == controller
        end

        def target_choices = controller.graveyard.creatures.reject { _1 == source }

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
