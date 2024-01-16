module Magic
  module Cards
    SpeakerOfTheHeavens = Creature("Speaker of the Heavens") do
      power 1
      toughness 1
      cost white: 1
      creature_type("Human Cleric")
      keywords :vigilance, :lifelink


      class ActivatedAbility < Magic::ActivatedAbility
        def initialize(source:)
          super(source: source, requirements: [
            -> {
              source.controller.life >= source.controller.starting_life + 7
            },
            -> {
              game.can_cast_sorcery?(source.controller)
            }
          ])
        end

        def costs = [Costs::Tap.new(source)]

        def resolve!
          source.controller.create_token(token: Tokens::Angel)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
