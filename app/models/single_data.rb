class SingleData < ApplicationRecord
  def self.method_missing(key)
    self.find_or_create_by(k: key)
  end
end