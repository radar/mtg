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
        def costs = [Costs::MultiTap.new(5) { controller.creatures.by_type("Elf").untapped }]

        def resolve!
          create_token(token:ElementalToken)
        end
      end

      def activated_abilities = [TapFiveElvesAbility]
    end
  end
end
