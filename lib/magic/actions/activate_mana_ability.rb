module Magic
  module Actions
    class ActivateManaAbility < ActivateAbility
      def choose(color)
        ability.choose(color)
      end
    end
  end
end
