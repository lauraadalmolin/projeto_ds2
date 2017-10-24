require "data_mapper"
require "dm-migrations"

#para o código funcionar é necessário fazer o seguinte insert : "INSERT INTO usuarios VALUES (DEFAULT, 'administrador', 'admin', '1234')"

DataMapper.setup(:default, 'postgres://postgres:postgres@localhost/hogwarts')

class Wand 
	include DataMapper::Resource
	property :id, Serial
	property :wood, String, :required => true
	property :flexibility, String, :required => true
	property :length, Float, :required => true
	property :core, String, :required => true
	has 1, :wizard

	#has n, :anotacaos, :constraint => :destroy
end

class House
	include DataMapper::Resource
	property :id, Serial
	property :nome, String, :required => true
	property :headOfHouse, String, :required => true
	has n, :wizards, :constraint => :destroy
end

class Wizard
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :password, String, :required => true
	property :login, String, :required => true
	property :dateOfBirth, Date #date_validation
	belongs_to :wand
	belongs_to :animal
	belongs_to :house
end

class Animal
	include DataMapper::Resource
	property :id, Serial
	property :species, String, :required => true
	property :name, String, :required => true
	has 1, :wizard
end

class Question
	include DataMapper::Resource
	property :id, Serial
	property :description, String, :required => true
	has n, :answers, :constraint => :destroy
end

class Answer 
	include DataMapper::Resource
	property :id, Serial
	property :colour, String, :required => true
	property :description, String, :required => true
	property :gryffindorValue, Integer, :required => true
	property :slytherinValue, Integer, :required => true
	property :ravenclawValue, Integer, :required => true
	property :hufflepuffValue, Integer, :required => true
	belongs_to :question
end

class Admin
	include DataMapper::Resource
	property :id, Serial
	property :login, String
	property :password, String
end

DataMapper.finalize
#DataMapper.auto_migrate!
# => DataMapper.auto_upgrade!

#INSERT INTO houses VALUES (DEFAULT, 'Gryffindor', 'Minerva McGonagall');
#INSERT INTO houses VALUES (DEFAULT, 'Slytherin', 'Horace Slughorn');
#INSERT INTO houses VALUES (DEFAULT, 'Ravenclaw', 'Filius Flitwick');
#INSERT INTO houses VALUES (DEFAULT, 'Hufflepuff', 'Pomona Sprout');

#INSERT INTO admins (login, password) VALUES ('admin', '21232f297a57a5a743894a0e4a801fc3');


