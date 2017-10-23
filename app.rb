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
	erb :index, :layout => :public_layout
end

get '/logout' do
	session.clear
	redirect '/login_screen' 
end

post '/login' do
	login = params['login']
	password = Digest::MD5.hexdigest(params['password'])
	wizard = Wizard.first(:login => login, :password => password)
	puts wizard
	puts '----------------------------------------------'
	if (wizard != nil)
		session[:logado] = true
		session[:admin] = false
		redirect '/user/'
	else 
		admin = Admin.first(:login => login, :password => password)
		if (admin != nil)
			session[:logado] = true
			session[:admin] = true
			redirect '/admin/'
		else
			@m = "Login Error</div>"
			erb :login_screen,:layout => :public_layout
		end
	end
end

get '/admin/' do
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
	length = params["length"].gsub!(',','.')

	if (/[0-9]*.[0-9]*/.match(length) != nil)
		wand.length = length
	else 
		if (/[0-9]*/.match(length) != nil)
			wand.length = length
		else
			puts "-------------------------\n"
			puts "fosdfjksdoifjsdiofjsdiofidjso\n"
			puts "-------------------------\n"
			puts "-------------------------\n"
		end
	end

	if (wand.wood != '' && wand.flexibility != '' && wand.core != '')
		if (wand.save)
			@s = "Wand successfuly added!"
		else
			@e = "An error occurred while trying to add the wand."
		end
		erb :create_wand, :layout => :admin_layout
	else 
		@e = "Please fill all the fields in the form (the field named length must be a number)."
		erb :create_wand, :layout => :admin_layout
	end	
end

get '/admin/retrieve_wands' do
	@wandArr = Wand.all
	erb :retrieve_wands, :layout => :admin_layout

end