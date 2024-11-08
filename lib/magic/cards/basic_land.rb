module Magic
  module Cards
    class BasicLand < Land
      def self.inherited(klass)
        klass.const_set(:NAME, klass.name.split("::").last)
      end

      def self.type(type)
        const_set(:TYPE_LINE, [Types::Super::Basic, Types::Land, type])
      end
    end
  end
end
