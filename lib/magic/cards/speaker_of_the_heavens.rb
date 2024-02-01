module Magic
  module Cards
    SpeakerOfTheHeavens = Creature("Speaker of the Heavens") do
      power 1
      toughness 1
      cost white: 1
      creature_type("Human Cleric")
      keywords :vigilance, :lifelink

      AngelToken = Token.create("Angel") do
        type "Creature -- Angel"
        power 4
        toughness 4
        keywords :flying
        colors :white
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def requirements_met?
          source.controller.life >= source.controller.starting_life + 7 &&
          game.can_cast_sorcery?(source.controller)
        end

        def costs = [Costs::Tap.new(source)]

        def resolve!
          source.controller.create_token(token_class: AngelToken)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
