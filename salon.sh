#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

QUESTION_SERVICE="Welcome to My Salon, how can i help you?"
QUESTION_SERVICE_ALTERNATIVE="I could not find that service. What would you like today?"
QUESTION_PHONE="What's your phone number?"
QUESTION_PHONE_ALTERNATIVE="I don't have a record for thath phone number, what's your name?"
QUESTION_WHAT_TIME="What time would you like your"
QUESTION_APPOINTMENT="I have put you down for a cut at"

#QUERY

function MY_SALON(){
  # display service list
  echo $QUESTION_SERVICE
  echo -e "\n1) cut \n2) color \n3) perm \n4) style \n5) trim"
  read SERVICE_SELECTION

  # get service id 
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_SELECTION")
  # get service name
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_SELECTION")

  # if user doesnt pick service
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$  || -z $SERVICE_ID_SELECTED ]]
  then
    # display service list
    echo -e "\n$QUESTION_SERVICE_ALTERNATIVE"
    echo -e "\n1) cut \n2) color \n3) perm \n4) style \n5) trim"
    read SERVICE_ID_SELECTED
  else
    #get customer info
    echo -e "\n$QUESTION_PHONE"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesnt exist
    if [[ -z $CUSTOMER_NAME ]]
    then 
      # get new customer name
      echo -e "\n$QUESTION_PHONE_ALTERNATIVE"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # get service time
    echo -e "\n$QUESTION_WHAT_TIME $SERVICE_NAME_SELECTED, $CUSTOMER_NAME"
    read SERVICE_TIME

    # insert appointment 
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

    # give last message
    echo -e "\n$QUESTION_APPOINTMENT $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MY_SALON
