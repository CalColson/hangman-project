require 'yaml'

class Hangman

	def initialize(full_health)
		@full_health = full_health
		@lives = full_health

		dictionary = File.readlines 'assets/dictionary.txt'
		dictionary.select! do |word|
			word.length.between?(7, 14)
		end

		@secret_word = dictionary.sample.downcase.strip
		@right_guesses = '' 
		@wrong_guesses = ''
	end

	def draw_screen
		print "LIVES: #{'X ' * (@full_health - @lives)}" 
		puts 'O ' * @lives
		puts '-----------------------------'; puts
		print "Incorrect Letters: "
		@wrong_guesses.each_char do |char|
			print char + ' '
		end; puts
		puts '-----------------------------'; puts
		@secret_word.each_char do |chr|
			if @right_guesses.include? chr
				print "#{chr} "
			else
				print "__ "
			end
		end
		puts; puts; puts
	end

	def game_over?
		@lives == 0
	end

	def game_win?
		@secret_word.split('').all? do |char|
			@right_guesses.include? char
		end
	end

	def start
		until game_over? || game_win?
			draw_screen
			guess = '123'
			until ((guess =~ /[a-z]/) == 0 && guess.length == 1) || guess == '!'
				print 'Please guess a letter (or type [!] to save): '
				guess = gets.chomp
				puts; puts
			end
			return 'save' if guess == '!'
			if @secret_word.include? guess
				@right_guesses << guess
			else
				@wrong_guesses << guess
				@lives -= 1
			end
		end
		puts "The word was #{@secret_word}"
		puts game_win? ? 'YOU WIN!!! :)' : 'YOU LOSE!!! :('; puts
		puts 'Play again? y/n'
		return gets.chomp
	end

end

lives = 26
puts 'Would you like to continue an old game? If so, type [load]:'
load_answer = gets.chomp
if load_answer == 'load'
	yaml = ''
	File.open('saves/saved_file.yml') do |f|
		yaml = f.read
	end
	hangman = YAML.load(yaml)
else
	hangman = Hangman.new lives
end

answer = hangman.start
while answer == 'y'
	hangman = Hangman.new lives
	answer = hangman.start 	
end

if answer == 'save'
	Dir.mkdir('saves') unless Dir.exists? 'saves'
	yaml = YAML.dump(hangman)
	save = File.new('saves/saved_file.yml', 'w')
	save.write(yaml)
	save.close
end
