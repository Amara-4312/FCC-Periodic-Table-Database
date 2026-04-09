#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# no argument
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # check if input is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    QUERY="WHERE atomic_number=$1"
  else
    QUERY="WHERE LOWER(symbol)=LOWER('$1') OR LOWER(name)=LOWER('$1')"
  fi

  # query database
  RESULT=$($PSQL "SELECT 
  atomic_number, 
  TRIM(name), 
  TRIM(symbol), 
  TRIM(type), 
  RTRIM(TRIM(TRAILING '0' FROM atomic_mass::text), '.'), 
  melting_point_celsius, 
  boiling_point_celsius 
  FROM elements 
  JOIN properties USING(atomic_number)
  JOIN types USING(type_id)
  $QUERY")

  # if no result
  if [[ -z $RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    # format output
    echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  fi
fi