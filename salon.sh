#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Jaiidedme Salon ~~~\n"

SERVICE_MENU() {
  # check for and execute args
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # greeting
  echo  "Thanks for choosing Jaiidedme Salon!"
  echo -e "How can we help you today?\n"

  # display services
  echo -e "\n1) cut\n2) style\n3) color\n4) highlight\n5) facial\n6) Exit"
  read SERVICE_ID_SELECTED

  # if input is not a number 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send back to main
    SERVICE_MENU "Please select a valid service."
  else
    # check if selection exists 
    SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    # if not exist
    if [[ -z $SERVICE_TYPE ]]
    then
      SERVICE_MENU "That service is currently being offered try another"
    else
      # get customer info
      echo -e "\nLet's get you taken care of, what's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new name from customer
        echo -e "\nLooks like this is your first time with us, what's your name?"
        read CUSTOMER_NAME

        # insert and create new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # get appointment time
      echo -e "\nWhat time would you like your $SERVICE_TYPE, $CUSTOMER_NAME?(use HH:MM format)"
      read SERVICE_TIME

      APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_TYPE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

}

SERVICE_MENU

