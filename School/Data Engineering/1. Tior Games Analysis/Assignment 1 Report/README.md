To access the data warehouse: 
Connect to the university’s VPN. 
Go to Azure data studio or VSCode, connect with your login details as we did in the workshop and are detailed on Moodle.
Select the TiorGames database. You are NOT allowed to use any other data warehouse.

The data dictionary is also provided in a separate file link: 
https://docs.google.com/spreadsheets/d/1-ifRuypTcBd_NZAR_fBydqIvi7IiVEbp/edit?usp=sharing&ouid=100867728873298265982&rtpof=true&sd=true


Question 1
Write and run 5 SQL queries. In the report include the code of the queries and a screenshot of them running as well as the short description of the business rationale in no more than 200 words per query.
Notes:
Your queries must use OLAP functions. OLTP queries will get marked as zero.
Your queries must be meaningful and demonstrate the strength of DW in supporting decision makers.
Your queries must use a broad range of fact tables and dimensions of the provided DW. 
You should provide a short description of each query, to explain the business rationale for creating it.
All 5 queries must be different from each other, using different fact tables and dimensions. 
All 5 queries should include at least one data warehouse concept. Queries such as “select * from tablename where condition is true” and repetitive queries, will get marked as zero. 

{Total marks: 20}
Question 2
Modify the given schema and suggest at least 2 more dimensions that would provide you with insights that you wish there were there. You must submit the 2 dimensions, the data dictionary for them and the rationale report. 

Notes:
Provide reasoning and business rationale for your choice (also known as: why these dimensions and how can the business use them?) in no more than 400 words. 
You need to submit these two dimensions, following the same naming convention that exists in the data warehouse.
These two dimensions should seamlessly blend together with at least one fact table or dimension of the current data marts.
You also have to include a data dictionary following the same format of the given data dictionary.
Make sure that the dimensions you suggest are NOT the same as the one mentioned in Question 4 or you will get zero marks for that suggestion.

{Total marks 10}
Question 3
A junior member of your team complained fiercely to the data warehouse administrators that the access that you have is too restricted, and they would like to be able to view the spectators of each game of each event. In other words, the people that purchase tickets and attend the event. They argued that they would like to know when these people purchased the tickets, how many they bought and why they returned them if they did so. 

Your response is that a dimension such as this, would require a new fact table. The junior member seemed confused and asked you why, since there are already the eventFact, Tickets, TimeDim, DateDim and Refund tables. 

To answer this you need to simply state 1 sentence. What would you say? 
Use no more than 100 words.

{Total marks 5}
Question 4
When joining two tables in any type of DBMS system, including a data warehouse, you have multiple join options. Typically, when two tables are joined together with inner, left or right join they may or may not have the same number of rows. 
A junior member of your team came to you saying that we have incomplete data and that our audience will be very upset if we present them with null data values. You are very confused and ask the member of your team to show you the query they are running: 

select * from PlayerInGameDim left join ChampionInGameSpecDim on PlayerInGameDim.PlayerInGameID = ChampionInGameSpecDim.PlayerInGameID
After a bit of investigation you identify that there are indeed null values and some of the values do not adhere to foreign key constraints. Your tasks are:

Explain why there are null values
Suggest a way to solve it. You must present a code solution. Remember that you will not be able to execute code that alters the structure of the database. 

Use no more than 300 words.
{Total marks 10}
Question 5
As you have seen so far, the database has major data structure issues. Identify two of these problems and suggest a logical solution.

Use no more than 200 words.

{Total marks 5}
