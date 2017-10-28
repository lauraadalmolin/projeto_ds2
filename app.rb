#encoding: utf-8

require 'sinatra'
require 'erb'
require './models.rb'

enable :sessions

before '/admin' do
  	if ((session[:logado].nil?) || session[:logado] == false || session[:admin] == false)
  		redirect '/'
  	end
end

before '/admin/*' do
  	if ((session[:logado].nil?) || session[:logado] == false || session[:admin] == false)
  		redirect '/'
  	end
end

before '/user' do
	if (session[:logado].nil? || session[:logado == false] || session[:admin] == true)
		redirect '/'
	end
end

before '/user/*' do
	if (session[:logado].nil? || session[:logado == false] || session[:admin] == true)
		redirect '/'
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

get '/register' do
	erb :register, :layout => :public_layout
end

post '/register' do
	wizard = Wizard.new
	if (params["name"] != nil && params["login"] != nil && params["dateOfBirth"] != nil && params["password"] != nil)
		if(/^(?:(?:31(\/)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/.match(params["dateOfBirth"]) != nil)
			arr = params["dateOfBirth"].split("/")
			if (/[0-9]+/.match(arr[2]) != nil)
				if (arr[2].to_i <= 2017)
					wizard.name = params["name"]
					wizard.login = params["login"]
					password = Digest::MD5.hexdigest(params['password'])
					wizard.password = password
					wizard.dateOfBirth = params["dateOfBirth"]
					wizard.house = House.get(5)
					wizard.animal = Animal.get(1)
					wizard.wand = Wand.get(1)
					if (wizard.save)
						session[:logado] = true
						session[:admin] = false
						redirect '/user'
					else
						@e = "Erro no cadastro"
					end
				else
					@w = "O ano da data de nascimento não pode ser maior que o atual"
				end
			else
				@w = "O ano deve ser um número" 
			end
		else
			@w = "A data deve respeitar o seguinte formato: DD/MM/AAAA"
		end
	else 
		@w = "Todos os campos devem ser preenchidos"
	end
	erb :register, :layout => :public_layout
end

get '/admin/retrieve_wizards' do
	@wizardArr = Wizard.all
	erb :retrieve_wizards, :layout => :admin_layout
end

get '/admin/delete_wizard/:id' do
	wizard = Wizard.get(params["id"].to_i)
	if (wizard != nil) 
		wizard.destroy
	else
		@p = "Impossível excluir um usuário inexistente"
	end
	@wizardArr = Wizard.all
	erb :retrieve_wizards, :layout => :admin_layout
end

get '/admin/update_wizard/:id' do
	@wizard = Wizard.get(params["id"].to_i)
	arr = @wizard.dateOfBirth.to_s.split('-')
	@dateOfBirth = arr[2] + "/" + arr[1] + "/" + arr[0]
	erb :update_wizard_screen, :layout => :admin_layout
end

post '/admin/update_wizard/:id' do
	@wizard = Wizard.get(params["id"].to_i)
	if (@wizard != nil)
		if (params["name"] != nil && params["login"] != nil && params["dateOfBirth"] != nil)
			if(/^(?:(?:31(\/)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/.match(params["dateOfBirth"]) != nil)
				arr = params["dateOfBirth"].split("/")
				if (/[0-9]+/.match(arr[2]) != nil)
					if (arr[2].to_i <= 2017)
						if (@wizard.update(:name => params["name"], :login => params["login"], :dateOfBirth => params["dateOfBirth"]))
							redirect '/admin/retrieve_wizards'
						else
							@e = "Erro no cadastro"
						end
					else
						@w = "O ano da data de nascimento não pode ser maior que o atual"
					end
				else
					@w = "O ano deve ser um número" 
				end
			else
				@w = "A data deve respeitar o seguinte formato: DD/MM/AAAA"
			end
		else 
			@w = "Todos os campos devem ser preenchidos"
		end
		arr = @wizard.dateOfBirth.to_s.split('-')
		@dateOfBirth = arr[2] + "/" + arr[1] + "/" + arr[0]
		erb :update_wizard_screen, :layout => :admin_layout
	end
	redirect '/admin/retrieve_wizards'
end

get '/admin/features' do
	erb :features, :layout => :admin_layout
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
			file = params['file'][:tempfile]
			accepted_formats = [".jpg"]
			if accepted_formats.include? File.extname(file)
				File.open('./public/images/wands/' + wand.id.to_s + File.extname(file), "w") do |f|
					f.write(params['file'][:tempfile].read)
				end
			end
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
	if (wand != nil)
		File.delete("./public/images/wands/" + wand.id.to_s + ".jpg")
		wand.destroy
		redirect '/admin/retrieve_wands'
	end 
	redirect '/'
end

get '/admin/update_wand/:id' do
	@wand = Wand.get(params["id"].to_i)
	if (@wand != nil && @wand.id != 1)
		erb :update_wand_screen, :layout => :admin_layout
	end
	redirect '/'
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
				if (params["file"] != nil)
					file = params['file'][:tempfile]
					accepted_formats = [".jpg"]
					if accepted_formats.include? File.extname(file)
						File.open('./public/images/wands/' + @wand.id.to_s + File.extname(file), "w") do |f|
							f.write(params['file'][:tempfile].read)
						end
					end
				end
				redirect '/admin/retrieve_wands'

			end
		else 
			if (/[0-9]+/.match(len) != nil)
				@wand.update(:flexibility => params["flexibility"], :wood => params["wood"], :length => len.to_f, :core => params["core"])
				if (params["file"] != nil)
					file = params['file'][:tempfile]
					accepted_formats = [".jpg"]
					if accepted_formats.include? File.extname(file)
						File.open('./public/images/wands/' + @wand.id.to_s + File.extname(file), "w") do |f|
							f.write(params['file'][:tempfile].read)
						end
					end
				end
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
			file = params['file'][:tempfile]
			accepted_formats = [".jpg"]
			if accepted_formats.include? File.extname(file)
				File.open('./public/images/animals/' + animal.id.to_s + File.extname(file), "w") do |f|
					f.write(params['file'][:tempfile].read)
				end
			end
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
	if (animal != nil)
		File.delete("./public/images/animals/" + animal.id.to_s + ".jpg")
		animal.destroy
		redirect '/admin/retrieve_animals'
	end 
	redirect '/'
end

get '/admin/update_animal/:id' do
	@animal = Animal.get(params["id"].to_i)
	if (@animal != nil && @animal.id != 1)
		erb :update_animal_screen, :layout => :admin_layout 
	end 
	redirect '/'
end

post '/admin/update_animal/:id' do
	@animal = Animal.get(params["id"].to_i)
	if (params["species"] != "" && params["name"] != "")
		if (@animal.update(:species => params["species"], :name => params["name"]))
			@s = "Animal editado com sucesso!"
			if (params['file'] != nil)
				file = params['file'][:tempfile]
				accepted_formats = [".jpg"]
				if accepted_formats.include? File.extname(file)
					File.open('./public/images/animals/' + @animal.id.to_s + File.extname(file), "w") do |f|
						f.write(params['file'][:tempfile].read)
					end
				end
			end
		else
			@e = "Ocorreu um erro ao tentar editar o animal."
		end
	else 
		@w = "Você deve preencher todos os campos do formulário."
	end
	erb :update_animal_screen, :layout => :admin_layout
end

get '/admin/create_question' do
	erb :create_question, :layout => :admin_layout
end

post '/admin/create_question' do
	question = Question.new
	if (params["description"] != "") 
		question.description = params["description"]
		if (question.save)
			@s = "Pergunta salva com sucesso!"
		else 
			@e = "Ocorreu um erro ao salvar sua pergunta."
		end
	else
		@w = "Você deve preencher todos os campos."
	end
	erb :create_question, :layout => :admin_layout
end

get '/admin/retrieve_questions' do
	@questionArr = Question.all
	erb :retrieve_questions, :layout => :admin_layout
end

get '/admin/delete_question/:id' do
	question = Question.get(params["id"].to_i)
	if (question != nil)
		question.destroy
	else
		@p = "Impossível excluir uma pergunta inexistente"
	end
	@questionArr = Question.all
	erb :retrieve_questions, :layout => :admin_layout
end

get '/admin/update_question/:id' do
	@question = Question.get(params["id"].to_i)
	if (@question != nil)
		erb :update_question_screen, :layout => :admin_layout
	end
	redirect "/"
end

post '/admin/update_question/:id' do
	@question = Question.get(params["id"].to_i)
	if (params["description"] != "") 
		if (@question.update(:description => params["description"]))
			@s = "Pergunta editada com sucesso!"
		else 
			@e = "Ocorreu um erro ao editar sua pergunta."
		end
	else
		@w = "Você deve preencher todos os campos."
	end
	erb :update_question_screen, :layout => :admin_layout
end

get '/admin/create_answer' do
	@questionArr = Question.all
	if (@questionArr.length == 0)
		@m = "Antes de cadastrar as respostas, você deve cadastrar ao menos uma pergunta."
	end
	erb :create_answer, :layout => :admin_layout
end

post '/admin/create_answer' do
	answer = Answer.new
	question = Question.get(params["question_id"].to_i)
	if (params["description"] != "" && params["question_id"] != nil && params['color'] != nil)
		if (/^[1-4]$/.match(params["gryffindorValue"]) != nil && /^[1-4]$/.match(params["slytherinValue"]) != nil && /^[1-4]$/.match(params["ravenclawValue"]) != nil && /^[1-4]$/.match(params["hufflepuffValue"]) != nil)
			answer.question = question
			answer.color = params["color"]
			answer.description = params["description"]
			answer.gryffindorValue = params["gryffindorValue"]
			answer.slytherinValue = params["slytherinValue"]
			answer.ravenclawValue = params["ravenclawValue"]
			answer.hufflepuffValue = params["hufflepuffValue"]
			if (answer.save) 
				@s = "Resposta salva com sucesso!"
			else 
				@e = "Ocorreu um erro ao tentar salvar a resposta."
			end
		else 
			@w = "Os campos relativos a pontos devem ser preenchidos com apenas um dos números inteiros: 1, 2, 3 ou 4."
		end
	else
		@w = "Você deve preencher todos os campos."
	end
	@questionArr = Question.all
	erb :create_answer, :layout => :admin_layout
end

get '/admin/delete_answer/:id' do
	answer = Answer.get(params["id"].to_i)
	if (answer != nil)
		answer.destroy
	else
		@m = "Impossível excluir uma resposta inexistente"
	end
	@questionArr = Question.all
	erb :retrieve_questions, :layout => :admin_layout
end

get '/admin/update_answer/:id' do
	@questionArr = Question.all
	@answer = Answer.get(params["id"].to_i)
	if (@answer != nil)
		erb :update_answer_screen, :layout => :admin_layout	
	end
	redirect "/"
end

post '/admin/update_answer/:id' do
	@answer = Answer.get(params["id"].to_i)
	@question = Question.get(params["question_id"].to_i)
	if (params["description"] != "" && params["question_id"] != nil && params["color"] != nil)
		if (/^[1-4]$/.match(params["gryffindorValue"]) != nil && /^[1-4]$/.match(params["slytherinValue"]) != nil && /^[1-4]$/.match(params["ravenclawValue"]) != nil && /^[1-4]$/.match(params["hufflepuffValue"]) != nil)
			if (@answer.update(:color => params["color"], :question => @question, :description => params["description"], :gryffindorValue => params["gryffindorValue"], :slytherinValue => params["slytherinValue"], :ravenclawValue => params["ravenclawValue"], :hufflepuffValue => params["hufflepuffValue"])) 
				@s = "Resposta editada com sucesso!"
			else 
				@e = "Ocorreu um erro ao tentar editar a resposta."
			end
		else 
			@w = "Os campos relativos a pontos devem ser preenchidos com apenas um dos números inteiros: 1, 2, 3 ou 4."
		end
	else
		@w = "Você deve preencher todos os campos."
	end
	@questionArr = Question.all
	erb :create_answer, :layout => :admin_layout
end