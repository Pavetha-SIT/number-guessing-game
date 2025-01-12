#!/bin/bash

# Randomly generate the secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
DATABASE="user_data.db"

# Ensure database file exists
if [[ ! -f $DATABASE ]]; then
  echo "username,games_played,best_game" > $DATABASE
fi

# Prompt user for a username
echo "Enter your username:"
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Please try again."
  exit 1
fi

# Check if user exists in the database
USER_DATA=$(grep "^$USERNAME," $DATABASE)
if [[ $USER_DATA ]]; then
  IFS=',' read -r _ GAMES_PLAYED BEST_GAME <<< "$(echo "$USER_DATA")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=1000
fi

# Start the game
echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true; do
  read GUESS
  ((GUESS_COUNT++))
  
  # Validate input
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if ((GUESS == SECRET_NUMBER)); then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif ((GUESS > SECRET_NUMBER)); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update the database
if ((GUESS_COUNT < BEST_GAME)); then
  BEST_GAME=$GUESS_COUNT
fi
((GAMES_PLAYED++))

if [[ $USER_DATA ]]; then
  sed -i "/^$USERNAME,/c\\$USERNAME,$GAMES_PLAYED,$BEST_GAME" $DATABASE
else
  echo "$USERNAME,$GAMES_PLAYED,$BEST_GAME" >> $DATABASE
fi
