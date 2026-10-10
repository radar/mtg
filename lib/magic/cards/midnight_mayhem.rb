module Magic
  module Cards
    MidnightMayhem = Sorcery("Midnight Mayhem") do
      cost "{2}{R}{W}"
    end

    class MidnightMayhem < Sorcery
      GremlinToken = Token.create "Gremlin" do
        creature_type "Gremlin"
        power 1
        toughness 1
        colors :red
      end

      # "Create three 1/1 red Gremlin creature tokens. Gremlins you control gain menace, lifelink, and haste until end
      # of turn."
      def resolve!
        3.times { trigger_effect(:create_token, token_class: GremlinToken) }
        controller.creatures.select { _1.type?("Gremlin") }.each do |gremlin|
          %i[menace lifelink haste].each { |keyword| trigger_effect(:grant_keyword, target: gremlin, keyword: keyword) }
        end

        super
      end
    end
  end
end
