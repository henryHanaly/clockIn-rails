class User < ApplicationRecord

    has_secure_password

    has_many :sleep_records, dependent: :destroy
    has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
    has_many :following, through: :followed_users, source: :followed

    validates :name, presence: true
    validates :email, presence: true
    validates :password, presence: true

end
