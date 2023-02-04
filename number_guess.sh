#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

rnumber=$(( 1 + $RANDOM % 1000 ))
echo "Enter your username:"
read username
num_tries=1

#find user
  get_username=$($PSQL "SELECT username FROM users WHERE username = '$username'")

  if [[ -z $get_username ]]
  then
    echo "Welcome, $username! It looks like this is your first time here."
    insert_user=$($PSQL "INSERT INTO users(username, num_games) VALUES('$username', 0)")
  else
    get_num_games=$($PSQL "SELECT num_games FROM users WHERE username = '$username'")
    get_best=$($PSQL "SELECT MIN(best) FROM users WHERE username = '$get_username'")
    echo "Welcome back, $username! You have played $get_num_games games, and your best game took $get_best guesses."
  fi

echo "Guess the secret number between 1 and 1000:"
read guess
if [[ ! $guess =~ ^[+-]?[0-9]+$ ]]
  then
    echo "1 That is not an integer, guess again:"
fi

#guesser
while [ $guess != $rnumber ]
do
  if [[ $guess -lt $rnumber ]]
  then
    num_tries=$(($num_tries + 1))
    echo "It's higher than that, guess again:"
  fi

  if [[ $guess -gt $rnumber ]]
  then
    num_tries=$(($num_tries + 1))
    echo "It's lower than that, guess again:"
  fi

  if [[ ! $guess =~ ^[+-]?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  fi
  read guess
done

#update user
update_num_games=$($PSQL "UPDATE users SET num_games = num_games + 1 WHERE username = '$username'")
get_best_current=$($PSQL "SELECT MIN(best) FROM users WHERE username = '$get_username'")
if [[ -z $get_best_current ]]
then
  insert_best_initial=$($PSQL "UPDATE users SET best = $num_tries")
else
  if [[ $get_best_current -gt $num_tries ]]
  then
    insert_best_new=$($PSQL "UPDATE users SET best = $num_tries WHERE username = '$get_username'")
  fi
fi

echo -e "You guessed it in $num_tries tries. The secret number was $rnumber. Nice job!"
exit
