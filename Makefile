index.html: *.rb
	ruby algorithm.rb

clean:
	-rm -rf index.html imgs/*.png
