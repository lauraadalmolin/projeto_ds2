#encoding: utf-8

require 'sinatra'
require 'erb'
require './models.rb'

enable :sessions

before '/admin/*' do
  if ((session[:logado].nil?) || session[:logado] == false || session[:admin] == false)
  	halt 404, 'Você não pode acessar essa página sem logar'
  end
end

get '/login_screen' do
	erb :login_screen,:layout => :public_layout
end

get '/' do
	if (session[:admin] == true)
		redirect '/admin'
	end
	if (session[:logado] == true)
		redirect '/user'
	end
	erb :login_screen, :layout => :public_layout
end

get '/user' do
	erb :home_user, :layout => :user_layout
end

get '/logout' do
	session.clear
	redirect '/login_screen' 
end

post '/login' do
	login = params['login']
	password = Digest::MD5.hexdigest(params['password'])
	wizard = Wizard.first(:login => login, :password => password)
	if (wizard != nil)
		session[:logado] = true
		session[:admin] = false
		redirect '/user'
	else 
		admin = Admin.first(:login => login, :password => password)
		if (admin != nil)
			session[:logado] = true
			session[:admin] = true
			redirect '/admin'
		else
			@m = "Senha ou login errado"
			erb :login_screen,:layout => :public_layout
		end
	end
end

get '/admin' do
	erb :home_admin, :layout => :admin_layout	
end

get '/admin/create_wand' do
	erb :create_wand, :layout => :admin_layout
end

post '/admin/create_wand' do
	wand = Wand.new
	wand.wood = params["wood"]
	wand.flexibility = params["flexibility"]
	wand.core = params["core"]
	len = params["length"]
	if len.include?(",")
		len = len.gsub!(',','.')
	end
	if (len.include?('.'))
		if(/[0-9]+.[0-9]+/.match(len) != nil)
			wand.length = len.to_f
		end
	else 
		if (/[0-9]+/.match(len) != nil)
			wand.length = len.to_f
		else
			@w = "Você informou um valor inválido para o comprimento da varinha.";	
		end
	end
	if (wand.wood != '' && wand.flexibility != '' && wand.core != '')
		if (wand.save)
			@s = "Varinha adicionada com sucesso!"
		else
			@e = "Um erro ocorreu ao tentar salvar a varinha."
		end
		erb :create_wand, :layout => :admin_layout
	else 
		@e = "Por favor, preencha todos os campos no formulário. Observe que o valor informado no campo comprimento deve ser um número."
		erb :create_wand, :layout => :admin_layout
	end	
end

get '/admin/retrieve_wands' do
	@wandArr = Wand.all
	erb :retrieve_wands, :layout => :admin_layout
end

get '/admin/delete_wand/:id' do
	wand = Wand.get(params["id"].to_i)
	wand.destroy
	redirect '/admin/retrieve_wands'
end

get '/admin/update_wand/:id' do
	@wand = Wand.get(params["id"].to_i)
	erb :update_wand_screen, :layout => :admin_layout
end

post '/admin/update_wand/:id' do
	@wand = Wand.get(params["id"])
	if (params["flexibility"] != '' && params["wood"] != '' && params["core"] != '')
		len = params["length"]
		if len.include? ","
			len = len.gsub!(',','.')
		end
		if (len.include? '.')
			if(/[0-9]+.[0-9]+/.match(len) != nil)
				@wand.update(:flexibility => params["flexibility"], :wood => params["wood"], :length => len.to_f, :core => params["core"])
				redirect '/admin/retrieve_wands'
			end
		else 
			if (/[0-9]+/.match(len) != nil)
				@wand.update(:flexibility => params["flexibility"], :wood => params["wood"], :length => len.to_f, :core => params["core"])
				redirect '/admin/retrieve_wands'
			else
				@w = "Você informou um valor inválido para o comprimento da varinha.";	
				erb :update_wand_screen, :layout => :admin_layout
			end
		end
	end
	@w = "Você deve preencher todos os campos."
	erb :update_wand_screen, :layout => :admin_layout
end

get '/admin/create_animal' do
	erb :create_animal, :layout => :admin_layout
end

post '/admin/create_animal' do
	animal = Animal.new
	if (params["species"] != "" && params["name"] != "")
		animal.species = params["species"]
		animal.name = params["name"]
		if (animal.save)
			@s = "Animal cadastrado com sucesso!"
		else
			@e = "Ocorreu um erro ao tentar salvar o animal."
		end
	else 
		@w = "Você deve preencher todos os campos do formulário."
	end
	erb :create_animal, :layout => :admin_layout
end

get '/admin/retrieve_animals' do
	@animalArr = Animal.all
	erb :retrieve_animals, :layout => :admin_layout
end

get '/admin/delete_animal/:id' do
	animal = Animal.get(params["id"].to_i)
	animal.destroy
	redirect '/admin/retrieve_animals'
end

get '/admin/update_animal/:id' do
	@animal = Animal.get(params["id"].to_i)
	erb :update_animal_screen, :layout => :admin_layout 
end

post '/admin/update_animal/:id' do
	@animal = Animal.get(params["id"].to_i)
	if (params["species"] != "" && params["name"] != "")
		if (@animal.update(:species => params["species"], :name => params["name"]))
			@s = "Animal editado com sucesso!"
		else
			@e = "Ocorreu um erro ao tentar editar o animal."
		end
	else 
		@w = "Você deve preencher todos os campos do formulário."
	end
	erb :update_animal_screen, :layout => :admin_layout
end