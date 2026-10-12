module Magic
  module Cards
    HelgaSkittishSeer = Creature("Helga, Skittish Seer") do
      legendary_creature_type "Frog Druid"
      cost green: 1, white: 1, blue: 1
      power 1
      toughness 3
    end

    class HelgaSkittishSeer < Creature
      # Whenever you cast a creature spell with mana value 4 or greater, you draw a card, gain 1 life, and put a
      # +1/+1 counter on Helga.
      class BigCreatureCast < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && spell.creature? && spell.mana_value >= 4

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
          trigger_effect(:gain_life, life: 1)
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(Events::SpellCast => BigCreatureCast)

      # {T}: Add X mana of any one color, where X is Helga's power. Spend this mana only to cast creature spells
      # with mana value 4 or greater or creature spells with {X} in their mana costs.
      class ManaAbility < Magic::TapManaAbility
        choices :all

        def resolve!
          raise "Invalid choice made for mana ability. Choice: #{choice}, Choices: #{choices}" unless choices.include?(choice)

          source.controller.add_mana({ choice => source.power }, restriction: mana_restriction)
        end

        def mana_restriction = ManaRestriction::BigOrXCreatureSpells.new
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
