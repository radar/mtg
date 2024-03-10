module Magic
  module Cards
    class TeferisProtoge < Creature
      card_name "Teferi's Protoge"
      creature_type "Human Wizard"
      cost "{2}{U}"
      power 2
      toughness 3

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{U}, {T}"

        def resolve!
          trigger_effect(:draw_cards, player: controller)
          add_choice(:discard)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
