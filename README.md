# music

A MySQL project surrounding a fictional music database. The project is split into two parts:

  1. Database creation and table population. Here, we repurpose and modify T-SQL code from Adrian Ng (which can be found at https://adrian.ng/SQL/musicDB/) for use in MySQL, and to better fit the project's goals. The code for this is found in table_creator.sql and table_populator.sql.
  
  2. Data exploration. The data exploration is split into 3 parts:
    a. queries_popular_artists.sql: Here, we see which artist is followed by the most users, and see if there is any connection between artist popularity and various other factors.
    b. queries_user_metrics. Here, we explore how users behave in general, and examine the amount of 'active' users
    c. queries_strings. Here, we examine if factors like song name length influences song duration or song popularity, among other things.
    
Note: As certain tables within the database are randomly populated, we are not looking to extract meaningful insight from the dataset - the project is just meant to demonstrate how one might analyse data stored by a music streaming app. Also, due to the random population, your results may different to the ones described in the data exploration files. 
   
