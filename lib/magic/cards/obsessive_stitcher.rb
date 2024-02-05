module Magic
  module Cards
    class ObsessiveStitcher < Creature
      card_name "Obsessive Stitcher"
      cost "{1}{U}{B}"
      creature_type "Human Wizard"
      power 0
      toughness 3

      class Ability < ActivatedAbility
        costs "{T}"

        def resolve!
          trigger_effect(:draw_cards)
          add_choice(:discard)
        end
      end

      class Ability2 < ActivatedAbility
        costs "{2}{U}{B}, {T}, Sacrifice {this}"

        def target_choices
          controller.graveyard
        end

        def resolve!(target:)
          trigger_effect(:move_zone, target: target, destination: battlefield)
        end
      end

      def activated_abilities
        [Ability, Ability2]
      end
    end
  end
end
