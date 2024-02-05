module Magic
  module Cards
    class LeafkinAvenger < Creature
      card_name "Leafkin Avenger"
      cost "{2}{R}{G}"
      creature_type "Elemental Druid"
      power 4
      toughness 3

      class Ability < ActivatedAbility
        costs "{T}"

        def resolve!
          count = creatures_you_control.with_power { |power| power >= 4 }.count
          controller.add_mana(green: count)
        end
      end

      class Ability2 < ActivatedAbility
        costs "{7}{R}"

        def target_choices
          game.players + game.battlefield.planeswalkers
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: source.power, target: target)
        end
      end

      def activated_abilities
        [Ability, Ability2]
      end
    end
  end
end
