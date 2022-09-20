#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "drop table if exists teams, games;")"
echo "$($PSQL "create table teams(
                                  team_id serial primary key,
                                  name varchar(50) unique not null
);")"
echo "$($PSQL "create table games(
                                game_id serial primary key,
                                year int not null,
                                round varchar(50) not null,
                                winner_id int not null references teams(team_id),
                                opponent_id int not null references teams(team_id),
                                winner_goals int not null,
                                opponent_goals int not null
);")"
#echo "$($PSQL "Alter table teams add column team_id serial primary key;")"
#echo "$($PSQL "Alter table teams add column name varchar(50) unique;")"

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do 
  if [[ $year != 'year' ]]
  then
    # get winner_id
    winner_id=$($PSQL "Select team_id from teams where name='$winner'")
    opponent_id=$($PSQL "Select team_id from teams where name='$opponent'")

    # if not found
    if [[ -z $winner_id ]]
    then
      # insert teams
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $winner
        winner_id=$($PSQL "Select team_id from teams where name='$winner'")
      fi
    fi
    if [[ -z $opponent_id ]]
    then
      # insert teams
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $opponent
        opponent_id=$($PSQL "Select team_id from teams where name='$opponent'")
      fi
    fi
   
    # insert student
    INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values('$year', '$round', '$winner_id', '$opponent_id', '$winner_goals', '$opponent_goals')")
    if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
    then
        echo "Inserted into students, $year $round"
    fi
  fi
  done
