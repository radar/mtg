module Magic
  module Cards
    LilypadVillage = Card("Lilypad Village") do
      type T::Land
    end

    class LilypadVillage < Card
      TRIBES = %w[Bird Frog Otter Rat].freeze

      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add {U}. Spend this mana only to cast a creature spell.
      class CreatureMana < Magic::TapManaAbility
        choices :blue

        def mana_restriction = ManaRestriction::CreatureSpells.new
      end

      # {U}, {T}: Surveil 2. Activate only if a Bird, Frog, Otter, or Rat entered the battlefield under your
      # control this turn.
      class VillageAbility < Magic::ActivatedAbility
        costs "{U}, {T}"

        def requirements_met?
          event_this_turn?(Events::EnteredTheBattlefield) do |event|
            event.permanent.controller == controller && LilypadVillage::TRIBES.any? { event.permanent.type?(_1) }
          end
        end

        def resolve!
          game.choices.add(Magic::Choice::Surveil.new(actor: source, amount: 2))
        end
      end

      def activated_abilities = [ColorlessMana, CreatureMana, VillageAbility]
    end
  end
end
