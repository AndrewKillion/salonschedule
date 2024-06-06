#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Salon Appointment App ~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # Display services
  echo "Please choose a service:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || $SERVICE_ID_SELECTED -lt 1 || $SERVICE_ID_SELECTED -gt $(echo "$SERVICES" | wc -l) ]]
  then
    MAIN_MENU "Sorry, that's not a valid service."
  else
    # Get phone number
    echo "What is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "First time? Please enter your name:"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Get service time
    echo "What time would you like for your appointment?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
