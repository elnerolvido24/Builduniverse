#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -qAt"

show_services() {
  $PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"
echo
show_services
read SERVICE_ID_SELECTED

while true; do
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_EXISTS=$($PSQL -c "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  else
    SERVICE_EXISTS=""
  fi

  if [[ -n "$SERVICE_EXISTS" ]]; then
    break
  fi

  echo
  echo "I could not find that service. What would you like today?"
  show_services
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

ESCAPED_CUSTOMER_PHONE=$(sql_escape "$CUSTOMER_PHONE")
CUSTOMER_RECORD=$($PSQL -c "SELECT customer_id || '|' || name FROM customers WHERE phone = '$ESCAPED_CUSTOMER_PHONE';")

if [[ -z "$CUSTOMER_RECORD" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  ESCAPED_CUSTOMER_NAME=$(sql_escape "$CUSTOMER_NAME")
  CUSTOMER_ID=$($PSQL -c "INSERT INTO customers (name, phone) VALUES ('$ESCAPED_CUSTOMER_NAME', '$ESCAPED_CUSTOMER_PHONE') RETURNING customer_id;")
else
  IFS='|' read -r CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_RECORD"
fi

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

ESCAPED_SERVICE_TIME=$(sql_escape "$SERVICE_TIME")
$PSQL -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$ESCAPED_SERVICE_TIME');"

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."