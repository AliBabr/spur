class History < ApplicationRecord
    belongs_to :user
    validates :place_type, :name, :place_id, presence: true
end
