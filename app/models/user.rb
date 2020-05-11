class User < ApplicationRecord
  has_secure_password
  enum admin: { general: false, admin: true }
  scope :engineer, -> { where(admin_flag: false) }
end