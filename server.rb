require 'rubygems'
require "sinatra"
require "mongo"
require 'json/ext'
require 'json'

# mathieu.laporte@gmail.com

enable :sessions

get '/' do


  # connexion au serveur de base de donnée distante
  #mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)

  # connexion à la base de donnée
  #database = mongo_client.db("chat")

  # authentification
  #auth = database.authenticate("user", "ingesup")

  # récupération de la collection des messages
  #collection = database["messages"]

  #collection.find.each{ |row| messages << row.inspect }

  # récupération de tous les messages en base
  #@messages = collection.find.to_a

  # ouverture de la page "index.*"
  erb :index
end


get '/messages' do
  mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)
  database = mongo_client.db("chat")
  auth = database.authenticate("user", "ingesup")
  collection = database.collection('messages')

  affichage = []
  collection.find.each {
      |message|
      affichage << message
  }

  affichage.to_json
end

post '/messages' do

  mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)
  database = mongo_client.db("chat")
  auth = database.authenticate("user", "ingesup")
  collection = database.collection('messages')

  username = (session['username']) ? session['username'] : "anonymous"

  new_message = { "content" =>  params[:content], "username" => username }
  collection.insert(new_message)
end

post '/' do

  # connexion au serveur de base de donnée distante
  mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)

  # connexion à la base de donnée
  database = mongo_client.db("chat")

  # authentification
  auth = database.authenticate("user", "ingesup")

  # récupération de la collection des messages
  collection = database.collection('messages')


  username = (session['username']) ? session['username'] : "anonymous"

  new_message = { "content" =>  params[:content], "username" => username }

  # ajout du message envoyé dans la base de donnée
  collection.insert(new_message)

  redirect to('/')
end

post '/users/login' do


  # connexion au serveur de base de donnée distante
  mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)

  # connexion à la base de donnée
  database = mongo_client.db("chat")

  # authentification
  auth = database.authenticate("user", "ingesup")

  # récupération de la collection des messages
  collection = database.collection('user')

  current_user = collection.find_one("username" => params['username'], "password" => params['password'])

  if current_user
    session['username'] = current_user['username']
  end

  redirect to('/')

end

get '/users/logout' do

  session['username'] = nil

  redirect to('/')

end



get '/users/new' do



  erb :user_form
end

post '/users/new' do


  # connexion au serveur de base de donnée distante
  mongo_client = Mongo::MongoClient.new("ds059907.mongolab.com", 59907)

  # connexion à la base de donnée
  database = mongo_client.db("chat")

  # authentification
  auth = database.authenticate("user", "ingesup")

  # récupération de la collection des messages
  collection = database.collection('user')

  if params[:password].empty? || params[:password2].empty? || params[:username].empty?
    session['error_message'] = "Tous les champs sont obligatoires"
    redirect to('/users/new')
  end

  if params[:password] != params[:password2]
    session['error_message'] = "Les deux mots de passe ne correspondent pas."
    redirect to('/users/new')
  end

  current_user = collection.find_one("username" => params['username'])

  if current_user
    session['error_message'] = "Ce nom d'utilisateur est déjà utilisé."
    redirect to('/users/new')
  else

    new_user = { "username" =>  params[:username], "password" => params[:password] }

    collection.insert(new_user)

    session['username'] = params[:username]

    redirect to('/')
  end


end