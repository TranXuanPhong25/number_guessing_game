#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo -n "Enter your username: "
read USERNAME

# if [ ${#username} -eq 22 ]; then
#     echo "Username is valid and stored in the database."
#     # Add your database storing logic here
# else
#     echo "Error: Username must be exactly 22 characters long."
# fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  $PSQL "INSERT INTO users (name, games_played, best_game) VALUES ('$USERNAME', 0, NULL)" > /dev/null
  echo "Welcome, $USERNAME! It looks like this is your first time here." 
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
  echo "$GAMES_PLAYED $BEST_GAME"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER=$((RANDOM % 1000 + 1))

echo "Guess the secret number between 1 and 1000: "
read guess

number_of_guesses=1

while true; do
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again: "
    read guess
    continue
  fi

  if (( guess < NUMBER )); then
    echo "It's higher than that, guess again: "
    read guess
    (( number_of_guesses++ ))
  elif (( guess > NUMBER )); then
    echo "It's lower than that, guess again: "
    read guess
    (( number_of_guesses++ ))
  else
    echo "You guessed it in $number_of_guesses tries. The secret number was $NUMBER. Nice job!"
    break
  fi
done 
$PSQL "UPDATE users SET games_played = games_played + 1 WHERE name = '$USERNAME'"  > /dev/null
$PSQL "UPDATE users SET best_game = LEAST(best_game, $number_of_guesses) WHERE name ='$USERNAME'"  > /dev/null