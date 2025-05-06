class User < ApplicationRecord
    has_many :sleep_records, dependent: :destroy
    has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
    has_many :following, through: :followed_users, source: :followed

end
