#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?"
  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  if [[ -z AVAILABLE_SERVICES ]]
  then
    MAIN_MENU "Sorry, we do not have any services available right now."
  else
    echo -e "\nHere are the services we have right now.\nSelect '-1' to exit."
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == '-1' ]]
  then
    EXIT
  elif [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number."
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      MAIN_MENU "That service is not available."
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")


      fi

      echo -e "\nWhat time would you like to schedule?"
      read SERVICE_TIME


      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")


      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}

EXIT() {
  echo -e "\nThank you for using my salon."
}

MAIN_MENU