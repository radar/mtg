module Magic
  module Cards
    class LeafkinAvenger < Creature
      card_name "Leafkin Avenger"
      cost "{2}{R}{G}"
      creature_type "Elemental Druid"
      power 4
      toughness 3

      class Ability < ManaAbility
        costs "{T}"

        def resolve!
          count = creatures_you_control.power_gte(4).count
          controller.add_mana(green: count)
        end
      end

      class Ability2 < ActivatedAbility
        costs "{7}{R}"

        def target_choices
          game.players + game.battlefield.planeswalkers
        end

        def resolve!(target:)
          deal_damage(source.power, to: target)
        end
      end

      def activated_abilities
        [Ability, Ability2]
      end
    end
  end
end
