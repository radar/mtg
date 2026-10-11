module Magic
  module Cards
    LeylineOfTransformation = Enchantment("Leyline of Transformation") do
      cost generic: 2, blue: 2
      begins_on_battlefield
    end

    class LeylineOfTransformation < Enchantment
      # "As this enchantment enters, choose a creature type."
      class TypeChoice < Magic::Choice::ChooseCreatureTypeForPermanent
        def prompt = "Choose a creature type."
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          game.add_choice(TypeChoice.new(actor: actor))
        end
      end

      # "Creatures you control are the chosen type in addition to their other types. The same is true for creature spells you
      # control and creature cards you own that aren't on the battlefield."
      class ChosenTypeGrant < Abilities::Static::TypeGrant
        def applicable_targets = source.controller.creatures

        def type_grants = [source.chosen_creature_type].compact

        # Cards in hand, library, graveyard and exile, and spells on the stack (which are still the card).
        def outside_battlefield_type_grants(card)
          card.owner == controller ? type_grants : []
        end
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [ChosenTypeGrant]
    end
  end
end
