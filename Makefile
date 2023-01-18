index.html: *.rb
	bundle exec ruby algorithm.rb

clean:
	-rm -rf index.html imgs/*.png *~

install:
	bundle install
