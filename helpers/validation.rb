# Provide various functions for validating data
module Validation
  def self.str_is_integer?(str)
    return true if str.is_a?(Integer)

    return false if str.nil? || !str.is_a?(String)

    str.match?(/^(\d)+$/)
  end

  def self.str_has_special_chars?(str)
    return nil if str.nil?

    str = str.to_s unless str.is_a?(String)
    return false if str.eql?("")

    !str.match?(/\A[a-zA-Z0-9 ]+\z/)
  end
end
