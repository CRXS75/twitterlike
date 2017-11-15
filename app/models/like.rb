class Like < ApplicationRecord
  belongs_to :user
  belongs_to :micropost, optional: true
  belongs_to :comment, optional: true
end
