#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Welcome to My Salon, how can I help you?\n"
  SERVICES_LIST=$($PSQL "select * from services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done
  echo -e "Select the service you want"
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE ]]
  then
    SERVICES "Enter a valid service id"
  else
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    fi
    SERVICE=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
    FORMATTED_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')
    FORMATTED_SERVICE=$(echo "$SERVICE" | sed -r 's/^ *| *$//g')
    echo "What time would you like your $FORMATTED_SERVICE, $FORMATTED_CUSTOMER_NAME?"
    read SERVICE_TIME
    $($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    echo "I have put you down for a $FORMATTED_SERVICE at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
  fi
}
SERVICES
