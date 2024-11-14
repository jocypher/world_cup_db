#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    # Get WINNER 
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    # If not found
    if [[ -z "$WINNER_ID" ]]
    then
      # Insert team
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")

      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi


        # Get OPPONENT
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # If not found
    if [[ -z "$OPPONENT_ID" ]]
    then
      # Insert team
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")

      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi
done

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # Get the winner team_id from the team table
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  
  # Get the opponent team_id from the team table
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # Check if both winner and opponent exist
  if [[ -n "$WINNER_ID" && -n "$OPPONENT_ID" ]]
  then
    # Insert the game into the games table
    INSERT_GAME=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                          VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, '$WINNER_GOALS', '$OPPONENT_GOALS');")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted game for year $YEAR, round $ROUND between $WINNER and $OPPONENT"
    fi
  else
    echo "Error: Team(s) not found for $WINNER or $OPPONENT"
  fi
done