module Magic
  module Cards
    class HeirloomEpic < Card
      card_name "Heirloom Epic"
      type T::Artifact, "Book"
      cost generic: 1

      # {4}, {T}: Draw a card. For each mana in this ability's activation cost, you may tap an untapped creature
      # you control rather than pay that mana. Activate only as a sorcery.
      #
      # Tapped creatures are named with `action.convoke(creature)` before the mana is paid: each reduces the
      # generic cost by one.
      class DrawAbility < Magic::ActivatedAbility
        activate_only_as_sorcery

        def convoke? = true

        def costs
          @costs ||= [Costs::Mana.new(generic: 4), Costs::SelfTap.new(source)]
        end

        def resolve!
          draw_card
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
