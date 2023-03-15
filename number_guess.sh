#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for username
echo "Enter your username:"
read USERNAME

# Check if username exists in database
USER_INFO=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z "$USER_INFO" ]]
then
  # Add new user to database
  INSER_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 0)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Get user's games played and best game from database
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))

# Prompt user to guess secret number
echo -e "\nGuess the secret number between 1 and 1000:"

# Initialize guess count to 0
guess_count=0

while read GUESS
do
  # Check if guess is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # Increment guess count
    guess_count=$((guess_count + 1))

    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      # Update user's games played and best game in database
      UPDATE_PLAYED=$($PSQL "UPDATE users SET games_played = $(( GAMES_PLAYED + 1 )) WHERE username='$USERNAME'")
      if ((guess_count < BEST_GAME || BEST_GAME == 0))
      then
        UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $guess_count WHERE username='$USERNAME'")
      fi

      echo "You guessed it in $guess_count tries. The secret number was $SECRET_NUMBER. Nice job!"
      break;
    else
      if [[ $GUESS -gt $SECRET_NUMBER ]]
      then 
        echo "It's lower than that, guess again:"
        elif [[ $GUESS -lt $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
      fi
    fi
  fi
done

