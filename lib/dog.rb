require 'pry'

class Dog

	attr_accessor :name, :breed, :id


	@@all = []
	def self.all
		@@all 
	end


	def self.db
		DB[:conn]
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
			)
			SQL

		db.execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
		drop table dogs;
		SQL

		db.execute(sql)
	end

	def self.create(attributes)
		dog = Dog.new(attributes)
		dog.save

	end

	def self.new_from_db(row)
		attributes = {id: row[0], name: row[1], breed: row[2]}
		Dog.create(attributes)
	end

	def self.find_by_id(id)
		sql = <<-SQL
		select * from dogs where id = ?
		SQL
		#binding.pry
		doggo = self.new_from_db(db.execute(sql, id).first)
		#binding.pry
	end

	def self.find_by_name(name)
		sql = <<-SQL
		select * from dogs where name = ?
		limit 1
		SQL

		dog = new_from_db(db.execute(sql, name).first)
	end


	def self.find_or_create_by(name:, breed:)
		sql = <<-SQL
		select * from dogs where name = ? and breed = ?
		SQL

		dogs = db.execute(sql, name, breed)
		doglist = dogs.each_with_object([]) {|dog, list| list << new_from_db(dog)}
		
		dogs.empty? ? dog = new_from_db([nil, name, breed]) : dog = doglist.select {|dog| dog.name == name && dog.breed == breed}.first

	end

	def initialize(id: nil, name:, breed:)
		@name = name 
		@breed = breed
		@id = id
	end

	def save
  	if persisted?
  	#	binding.pry
  		self.update
  	#	binding.pry
  	else
  	#	binding.pry
  		self.store
  	#	binding.pry
  	end
  	self
  end


  def store
  	sql = <<-SQL 
  	INSERT INTO dogs (name, breed) VALUES (?, ?);
  	SQL

  	self.class.db.execute(sql, self.name, self.breed)
  #	binding.pry
  	@id = self.class.db.last_insert_row_id
  end

  def persisted? 
  	!!self.id
  end

  def update
  	sql = <<-SQL 
  	UPDATE dogs SET name = ?, breed = ? where id = ?;
  	SQL

  	self.class.db.execute(sql, self.name, self.breed, self.id)
  end



end