module Magic
  module Cards
    VoiceOfTheWoods = Creature("Voice of the Woods") do
      creature_type "Elf"
      cost "{3}{G}{G}"
      power 2
      toughness 2
    end

    class VoiceOfTheWoods < Creature
      ElementalToken = Token.create "Elemental" do
        creature_type "Elemental"
        power 7
        toughness 7
        colors :green
        keywords :trample
      end

      class TapFiveElvesAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(-> (c) { c.type?("Elf") && c.controller == controller && c.untapped? }, 5)]

        def resolve!
          trigger_effect(:create_token, token_class: ElementalToken)
        end
      end

      def activated_abilities = [TapFiveElvesAbility]
    end
  end
end
