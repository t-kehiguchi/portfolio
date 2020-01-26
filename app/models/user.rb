class User < ApplicationRecord
  has_secure_password
  enum admin_flag: { general: FALSE, admin: TRUE }
end