module DocMyRoutes
  # Define hash helpers for deep hash merge and transforming hash into array of keys
  module HashHelpers
    def self.deep_merge(first_hash, second_hash)
      merger = proc do |key, first, second|
        first.is_a?(Hash) && second.is_a?(Hash) ? first.merge(second, &merger) : second
      end

      first_hash.merge(second_hash, &merger)
    end

    def self.array_to_hash_keys(arr, default_value = {})
      {}.tap { |hash| arr.each { |key| hash[key] = default_value } }
    end
  end
end
