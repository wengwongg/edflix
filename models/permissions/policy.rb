class Policy < Sequel::Model(:policies)
  dataset_module do
    def get_policies_from_ids_array(policies)
      raise("Provided policies array is actually not an array!") unless policies.is_a?(Array)

      where(id: policies).all
    end
  end
end
