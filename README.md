# README

Assignment 

1. Clock in operation will divided into 3 API 
    1.1 Clock-in --> POST method (doesn't have body param, will record based on current time)
        If user not yet/forgot to checkout last event , system will reject it.
    1.2 Clock-out --> PATCH method (doesn't have body param, will record based on current time)
        Must be check in first before user can check-out 
    1.3 Get All records from current user --> GET method (Front end can hit this API after clock-in or clock-out return success)