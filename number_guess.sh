#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -q -t --no-align -c"

printf "Enter your username: "
IFS= read -r USERNAME
USERNAME_ESCAPED=${USERNAME//\'/\'\'}
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_ESCAPED'")

if [[ -z $USER_ID ]]; then
	USER_ID=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_ESCAPED') RETURNING user_id")
	printf "Welcome, %s! It looks like this is your first time here.\n" "$USERNAME"
else
	USER_STATS=$($PSQL "SELECT COUNT(*) || '|' || COALESCE(MIN(number_of_guesses)::text, '') FROM games WHERE user_id=$USER_ID")
	IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$USER_STATS"
	printf "Welcome back, %s! You have played %s games, and your best game took %s guesses.\n" "$USERNAME" "$GAMES_PLAYED" "$BEST_GAME"
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0
printf "Guess the secret number between 1 and 1000: "
IFS= read -r GUESS

while [[ $GUESS != "$SECRET_NUMBER" ]]; do
	NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
	if ! [[ $GUESS =~ ^-?[0-9]+$ ]]; then
		printf "That is not an integer, guess again: "
	elif (( GUESS > SECRET_NUMBER )); then
		printf "It's lower than that, guess again: "
	else
		printf "It's higher than that, guess again: "
	fi
	IFS= read -r GUESS
done

NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
printf "You guessed it in %s tries. The secret number was %s. Nice job!\n" "$NUMBER_OF_GUESSES" "$SECRET_NUMBER"
$PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)" > /dev/null
