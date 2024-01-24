module Magic
  module Cards
    RousingRead = Aura("Rousing Read") do
      cost generic: 2, blue: 1


      enters_the_battlefield do
        permanent.trigger_effect(:draw_cards, number_to_draw: 2)
        permanent.add_choice(:discard)
      end

      def target_choices
        battlefield.creatures
      end

      def keyword_grants
        [Keywords::FLYING]
      end

      def power_modification
        1
      end

      def toughness_modification
        1
      end
    end
  end
end
