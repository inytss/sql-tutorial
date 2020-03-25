library(RSQLite)
library(DBI)

# set-up connection
connection <- dbConnect(SQLite(), "data_input/chinook.db")

# check table in db
dbListTables(connection)

# use min function 
query <- "SELECT MIN(UnitPrice) AS LowestPrice FROM tracks"
min_price <- dbSendQuery(conn = connection, statement = query)
dbFetch(min_price)

# use count function
query <- "SELECT Composer, COUNT(composer) AS Value FROM tracks 
          WHERE Composer = 'Alanis Morissette & Glenn Ballard'"
alanis <- dbSendQuery(conn = connection, statement = query)
dbFetch(alanis)

# use sum funtion
query <- "SELECT t.Composer, SUM(i.UnitPrice * i.Quantity) AS Revenue FROM invoice_items AS i
          LEFT JOIN tracks AS t ON t.TrackId = i.TrackId 
          WHERE t.Composer = 'Alanis Morissette & Glenn Ballard'"
sum_composer <- dbSendQuery(conn = connection, statement = query)
dbFetch(sum_composer)

# use avg function
query <- "SELECT t.Composer, AVG(i.UnitPrice) AS MeanPrice FROM invoice_items AS i
          LEFT JOIN tracks AS t ON t.TrackId = i.TrackId 
          WHERE t.Composer = 'Alanis Morissette & Glenn Ballard'"
mean_composer <- dbSendQuery(conn = connection, statement = query)
dbFetch(mean_composer)

# use GROUP BY and ORDER BY
represent_genre <- dbSendQuery(conn = connection, statement = "SELECT g.Name, COUNT(t.TrackId) AS 
                               Count 
                               FROM tracks AS t
                               LEFT JOIN genres AS g ON g.GenreId = t.GenreId
                               GROUP BY g.Name ORDER BY Count DESC")
dbFetch(represent_genre)

revenue_per_genre <- dbSendQuery(conn = connection, 
                                 statement = "SELECT g.Name, SUM(i.UnitPrice*i.Quantity) AS 
                                 TotalRevenue FROM tracks AS t 
                                 LEFT JOIN genres AS g ON g.GenreId = t.GenreId 
                                 LEFT JOIN invoice_items AS i ON i.TrackId = t.TrackId 
                                 GROUP BY g.Name ORDER BY TotalRevenue DESC LIMIT 3")
dbFetch(revenue_per_genre)

# using UPDATE and DELETE
## make connection
conn_update <- dbConnect(SQLite(), "data_input/chinook-update.db")
dbListTables(conn_update)

## ---
dbSendQuery(conn = conn_update, statement = "UPDATE genres SET Name = 'Rock Metal' WHERE GenreId = 1")
dbFetch(dbSendQuery(conn = conn_update, statement = "SELECT * FROM genres"))
## ---
dbSendQuery(conn = conn_update, statement = "DELETE FROM genres WHERE Name = 'Rock Metal'")
dbFetch(dbSendQuery(conn = conn_update, statement = "SELECT * FROM genres"))

