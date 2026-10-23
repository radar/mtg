module Magic
  module Cards
    TheNecrobloom = Creature("The Necrobloom") do
      legendary_creature_type "Plant"
      cost "{1}{W}{B}{G}"
      power 2
      toughness 7
    end

    class TheNecrobloom < Creature
      # "Landfall -- Whenever a land you control enters, create a 0/1 green Plant creature token. If you control seven or
      # more lands with different names, create a 2/2 black Zombie creature token instead."
      class LandfallTrigger < TriggeredAbility::Landfall
        PlantToken = Token.create "Plant" do
          creature_type "Plant"
          power 0
          toughness 1
          colors :green
        end

        ZombieToken = Token.create "Zombie" do
          creature_type "Zombie"
          power 2
          toughness 2
          colors :black
        end

        def should_perform? = event.player == controller

        def call
          if controller.lands.map(&:name).uniq.count >= 7
            create_token(token: ZombieToken)
          else
            create_token(token: PlantToken)
          end
        end
      end

      # "Land cards in your graveyard have dredge 2."
      class LandDredge < StaticAbility
        def dredge_amount(card, player)
          2 if player == controller && card.land?
        end
      end

      # Whenever you would draw, offer each dredgeable graveyard card (or the draw itself) as the answer.
      class DredgeChoice < Magic::Choice
        attr_reader :player, :remaining

        def initialize(actor:, player:, remaining:)
          super(actor: actor)
          @player = player
          @remaining = remaining
        end

        def chooser = player

        def prompt = "Dredge a card from your graveyard instead of drawing, or draw normally."

        def modes
          player.dredgeable_cards.to_h { [_1, "Dredge #{_1.name} (mill #{player.dredge_amount(_1)})"] }.merge(draw: "Draw a card normally")
        end

        def resolve!(mode:)
          mode == :draw ? player.draw! : player.dredge!(mode)
          # The rest of the draws each get the same offer.
          game.add_effect(Effects::DrawCards.new(source: actor, player:, number_to_draw: remaining - 1)) if remaining > 1
        end
      end

      class DredgeInstead < Effect
        def initialize(source:, player:, remaining:)
          super(source:)
          @player = player
          @remaining = remaining
        end

        def inspect = "#<TheNecrobloom::DredgeInstead player:#{@player.name}>"

        def resolve!
          game.add_choice(DredgeChoice.new(actor: source, player: @player, remaining: @remaining))
        end
      end

      class DredgeReplacement < ReplacementEffect
        def applies?(effect)
          effect.is_a?(Effects::DrawCards) && effect.player == receiver.controller && effect.number_to_draw > 0 && effect.player.dredgeable_cards.any?
        end

        def call(effect)
          DredgeInstead.new(source: receiver, player: effect.player, remaining: effect.number_to_draw)
        end
      end

      def static_abilities = [LandDredge]

      def replacement_effects = { Effects::DrawCards => DredgeReplacement }

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
