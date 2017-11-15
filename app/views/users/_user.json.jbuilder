json.extract! user, :id, :username, :email, :password, :salt, :phone, :firstname, :lastname, :sex, :age, :created_at, :updated_at
json.url user_url(user, format: :json)
