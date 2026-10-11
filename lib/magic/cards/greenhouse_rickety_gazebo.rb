module Magic
  module Cards
    class GreenhouseRicketyGazebo < Room
      class Greenhouse < Room::Door
        card_name "Greenhouse"
        cost generic: 2, green: 1

        # "{T}: Add one mana of any color."
        class AnyColorManaAbility < Magic::TapManaAbility
          choices :all
        end

        # "Lands you control have '{T}: Add one mana of any color.'"
        class GrantManaAbility < Abilities::Static::GrantActivatedAbilities
          def applies_to?(permanent)
            permanent.land? && permanent.controller == controller
          end

          def granted_abilities = [AnyColorManaAbility]
        end

        def static_abilities = [GrantManaAbility]
      end

      class RicketyGazebo < Room::Door
        card_name "Rickety Gazebo"
        cost generic: 3, green: 1

        # "When you unlock this door, mill four cards, then return up to two permanent cards from among them to your
        # hand."
        when_unlocked do
          milled = controller.mill(4)
          choice = Magic::Choice::ReturnFromAmong.new(actor: actor, cards: milled, filter: ->(card) { card.permanent? }, count: 2)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      doors Greenhouse, RicketyGazebo
    end
  end
end
