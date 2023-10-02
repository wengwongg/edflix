# Team 11 - EdFlix
## Installing and setup
1. To get started we need to first git clone the project. To do so, open a terminal or command prompt and navigate to a suitable directory.
```git clone https://git.shefcompsci.org.uk/com1001-2022-23/team11/project.git```
2. After cloning the directory with the command above, we will then enter the project directory.
```cd project```
3. We are expecting users to already have ruby installed on their system. We need to install the ruby gems.
``bundle install``
## Running the application
1. After installation of the gems we can now setup the project.
2. Run in the terminal
```shell
    export APP_ENV=production #This is used for selecting which database to use
    export SESSION_SECRET_ENV='bQeThWmZq4t7w!z%C*F)J@NcRfUjXn2r5u8x/A?D(G+KaPdSgVkYp3s6v9y$B&E)' # This is an example password, you need to replace it with your own that you keep safe
```
3. Run sinatra
``sinatra app.rb`` or if sinatra is pre-installed ``sinatra``.
4. If this does not work, you will need to run ``ruby app.rb``.
5. In the command line, it will give you a link to click on to navigate to the webpage. Either click on it to open your default web browser or copy it into one.
6. After copy pasting it, edit the end of the path to navigate to the login page by adding `/login` or the register page `/register`.
## Testing the application
1. After installation you will be able to test the application with rspec.
2. ``rspec spec``