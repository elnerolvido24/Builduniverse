#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

sql=""
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  sql+="INSERT INTO teams (name) VALUES ('$winner'), ('$opponent') ON CONFLICT (name) DO NOTHING;"
  sql+="INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT $year, '$round', winner_team.team_id, opponent_team.team_id, $winner_goals, $opponent_goals FROM teams AS winner_team CROSS JOIN teams AS opponent_team WHERE winner_team.name = '$winner' AND opponent_team.name = '$opponent';"
done < <(tail -n +2 games.csv)

$PSQL "$sql" > /dev/null
