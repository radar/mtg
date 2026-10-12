module Magic
  module Cards
    YgraEaterOfAll = Creature("Ygra, Eater of All") do
      legendary_creature_type "Elemental Cat"
      cost generic: 3, black: 1, green: 1
      power 6
      toughness 6
      ward sacrifice: "Food"
    end

    class YgraEaterOfAll < Creature
      # Other creatures are Food artifacts in addition to their other types.
      class FoodTypes < Abilities::Static::TypeGrant
        type_grants T::Artifact, "Food"

        def applicable_targets = battlefield.creatures.to_a - [source]
      end

      # ...and have "{2}, {T}, Sacrifice this permanent: You gain 3 life."
      class FoodAbility < Abilities::Static::GrantActivatedAbilities
        attr_reader :source

        def applies_to?(permanent) = permanent != source && permanent.creature?

        def granted_abilities = [Tokens::Food::GainLife]
      end

      def static_abilities = [FoodTypes, FoodAbility]

      # Whenever a Food is put into a graveyard from the battlefield, put two +1/+1 counters on Ygra.
      class FoodDies < TriggeredAbility
        def should_perform? = event.permanent.type?("Food") && event.to.graveyard?

        def call
          add_counter("+1/+1", amount: 2)
        end
      end

      def event_handlers = super.merge(Events::LeftTheBattlefield => FoodDies)
    end
  end
end
