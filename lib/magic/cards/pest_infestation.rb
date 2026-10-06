module Magic
  module Cards
    class PestInfestation < Sorcery
      card_name "Pest Infestation"
      cost x: 1, green: 1

      PestToken = Token.create("Pest") do
        creature_type "Pest"
        power 1
        toughness 1
        colors :black, :green

        # "When this creature dies, you gain 1 life."
        def death_triggers = [PestInfestation::PestDiesTrigger]
      end

      class PestDiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:gain_life, life: 1)
        end
      end

      def resolve!(value_for_x:)
        trigger_effect(:create_token, token_class: PestToken, amount: 2 * value_for_x)
      end
    end
  end
end
