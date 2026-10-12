module Magic
  module Cards
    OakhollowVillage = Card("Oakhollow Village") do
      type T::Land
    end

    class OakhollowVillage < Card
      TRIBES = %w[Frog Rabbit Raccoon Squirrel].freeze

      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add {G}. Spend this mana only to cast a creature spell.
      class CreatureMana < Magic::TapManaAbility
        choices :green

        def mana_restriction = ManaRestriction::CreatureSpells.new
      end

      # {G}, {T}: Put a +1/+1 counter on each Frog, Rabbit, Raccoon, or Squirrel you control that entered the
      # battlefield this turn.
      class VillageAbility < Magic::ActivatedAbility
        costs "{G}, {T}"

        def resolve!
          entered = game.current_turn.events.select { _1.is_a?(Events::EnteredTheBattlefield) }.map(&:permanent)
          battlefield.controlled_by(controller).creatures.each do |creature|
            next unless entered.include?(creature) && OakhollowVillage::TRIBES.any? { creature.type?(_1) }

            add_counter("+1/+1", to: creature)
          end
        end
      end

      def activated_abilities = [ColorlessMana, CreatureMana, VillageAbility]
    end
  end
end
