# README

Assignment 

Prequisite : 

1. Ruby 3.4.3
2. Rails 8.0.2
3. PostgreSQL 
4. Redis 



All endpoint need Authorization through endpoint /auth/login --> using JWT token 

example : 
    email : donald@gmail.com 
    password : test12345


Header : 
    Authorization : Jwt Token from login 
    Idempotency-Key : clockin-timestamp (for clockin endpoint)


Example Response : 

{
    "data": {[]},
    "message": "",
    "meta": {
        "current_page": 1,
        "next_page": 2,
        "prev_page": null,
        "total_pages": 2,
        "total_count": 4,
        "per_page": 2
    }
}




1. Clock in operation will divided into 3 API 
    1.1 Clock-in --> POST method (doesn't have body param, will record based on current time)
        If user not yet/forgot to checkout last event , system will reject it.
        (To avoid idempotency - double click or etc , implement redis with TTL back off  ) - explanation :  https://medium.com/@ayeshgk/rest-idempotency-f637e868df39
    1.2 Clock-out --> PATCH method (doesn't have body param, will record based on current time)
        Must be check in first before user can check-out 
    1.3 Get All records from current user --> GET method (Front end can hit this API after clock-in or clock-out return success)


2. Follow and unfollow 
    2.1 Follow --> POST method with params body user_id following 
    2.2 Unfollow --> DELETE method params body user_id following 
    2.3 get all user --> GET all user 



3. See all records from all users who have been followed 
-> will  returning response 
{
record 1 from user A,
record 2 from user B,
record 3 from user A,
...
}

if the number of records becomes very large sending all of them in a single response is inefficient and can consume significant memory and bandwidth. 

    1. Suggestion response with object of array like 
    "data": [
        {
            "id": 8,
            "user_id": 10,
            "clock_in": "2025-05-08T09:17:47.929Z",
            "clock_out": "2025-05-08T09:17:51.569Z",
            "created_at": "2025-05-08T09:17:47.935Z",
            "updated_at": "2025-05-08T09:17:51.574Z",
            "duration": 3
        },
        {
            "id": 7,
            "user_id": 10,
            "clock_in": "2025-05-08T09:16:14.626Z",
            "clock_out": "2025-05-08T09:16:18.450Z",
            "created_at": "2025-05-08T09:16:14.633Z",
            "updated_at": "2025-05-08T09:16:18.464Z",
            "duration": 3
        }
    ],

        we can use pagination for smaller chunks (50 records at max)

    2. Database read replicate
        Inserting and updating data to master while reading from replica 

    3. Redis caching --> only help few case (e.g cache user for 1 day) 

    4. Using background proccess or queing (Kafka or sidekiq) 
        Pro : Can be handling big data and heavy traffic using queue 
         our server need to notify after queing done (need to specify which endpoint to be hit by our server)
         



