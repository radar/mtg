module Magic
  module Cards
    AnUnexpectedParty = Enchantment("An Unexpected Party") do
      cost generic: 2, white: 2
    end

    class AnUnexpectedParty < Enchantment
      DwarfToken = Token.create "Dwarf" do
        creature_type "Dwarf"
        power 2
        toughness 2
        colors :red
      end

      # At the Door {X}{2}{W}, Sorcery -- Adventure: "Create X 2/2 red Dwarf creature tokens."
      adventure x: 1, generic: 2, white: 1

      def adventure_resolve!(value_for_x: 0, **)
        trigger_effect(:create_token, token_class: DwarfToken, amount: value_for_x) if value_for_x.positive?
      end

      # "As this enchantment enters, choose a creature type."
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      # "Creatures you control of the chosen type get +2/+2."
      class ChosenTypeBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2

        def applicable_targets
          return [] unless source.chosen_creature_type

          source.controller.creatures.by_type(source.chosen_creature_type)
        end
      end

      def static_abilities = [ChosenTypeBuff]
    end
  end
end
