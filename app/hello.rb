require 'sinatra'
require 'sinatra/cookies'

require_relative 'lib/db'
require_relative 'lib/auth'

set(:auth) do |role|
  condition do
    return false unless logged_in?(cookies)
    @username = logged_in?(cookies)
    if role == :admin
      admin?(cookies)
    else
      true
    end
  end
end

get '/hello/:name' do |name|
  "Hello, #{name}"
end

post '/user' do
  unless User.where(email: params[:email]).empty?
    [409, "User with email #{params[:email]} already exists"]
  else
    hashed_password = password_hash(params[:password])
    is_admin = params[:admin] == 'on'
    User.create(name: params[:name], email: params[:email],
                password: hashed_password[:hash], salt: hashed_password[:salt],
                admin: is_admin)
    [201, "Created a user: #{params}"]
  end
end

get '/users', auth: :admin do
  erb :users, locals: { users: DB[:users], username: @username }
end

get '/users', auth: :user do
  erb :users, locals: { users: DB[:users].select(:id, :name, :email),
                        username: @username }
end

post '/login' do
  users = User.where(name: params[:name])
  if users.empty?
    [401, 'Invalid username and/or password.']
  else
    hashed_password = password_hash(params[:password], users.first[:salt])
    if hashed_password[:hash] == users.first[:password]
      cookies[:auth_token] = jwt_token(username: users.first[:name], admin: users.first[:admin])
      'Login successful'
    else
      [401, 'Invalid username and/or password.']
    end
  end
end

get '/logout' do
  if cookies[:auth_token]
    token_data = jwt_payload(cookies[:auth_token])
    unless token_data && token_data.first['username']
      [401, 'Unauthorized']
    else
      cookies[:auth_token] = nil
    end
  else
    [401, 'Unauthorized']
  end
end
