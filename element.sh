#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align"
element=$($PSQL -v element="$1" <<'SQL'
SELECT e.atomic_number || '|' || e.name || '|' || e.symbol || '|' || t.type || '|' || p.atomic_mass || '|' || p.melting_point_celsius || '|' || p.boiling_point_celsius
FROM elements e
JOIN properties p USING (atomic_number)
JOIN types t USING (type_id)
WHERE e.atomic_number::text = :'element' OR e.symbol = :'element' OR e.name = :'element';
SQL
)

if [[ -z "$element" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$element"
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."