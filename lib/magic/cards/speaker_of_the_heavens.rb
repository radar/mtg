module Magic
  module Cards
    SpeakerOfTheHeavens = Creature("Speaker of the Heavens") do
      power 1
      toughness 1
      cost white: 1
      type "Creature -- Human Cleric"
      keywords :vigilance, :lifelink


      class ActivatedAbility < Magic::ActivatedAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super(source: source, requirements: [
            -> {
              source.controller.life >= source.controller.starting_life + 7
            },
            -> {
              game.can_cast_sorcery?(source.controller)
            }
          ])
        end

        def resolve!
          Permanent.resolve(game: game, controller: source.controller, card: Tokens::Angel.new)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
