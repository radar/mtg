module Magic
  module Cards
    StrixLookout = Creature("Strix Lookout") do
      cost generic: 1, blue: 1
      creature_type("Bird")
      keywords :flying, :vigilance
      power 1
      toughness 2
    end

    class StrixLookout < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{U}, {T}"

        def resolve!
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: source, player: controller))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
