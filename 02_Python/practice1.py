import pandas as pd

data = {
    "customerID": [1, 2, 3],
    "name": ["Alice", "Bob", "Charlie"],
    "city": ["San Ramon", "Dublin", "Pleasanton"],
    "sales": [500, 700, 450]
}

df = pd.DataFrame(data)
#this is like a select * from table in sql, it gives you the summary of the data frame
print("desc dataframe") 
print(df)
print()

#this is like select the column from the table.
print("select name and sales series from dataframe")
print(df[["name", "sales"]])
print()

#select * from table, sort by sales asc
print("select * from table, sort by sales asc")
print(df.sort_values("sales"))
print()

#this is order by desc
print("select * from table, sort by sales desc")
print(df.sort_values("sales", ascending=False))
print()

#select name & city
print("select name & city")
print(df[["name", "city"]])
print()

#select * from table where sales > 600
print("select * from table where sales > 600")
print(df[df["sales"] > 600])
print()

#select * from table where city == 'San Ramon'
print("select * from table where city == 'San Ramon'")
print(df[df["city"] == "San Ramon"])
print()

#return the first 5 rows of the dataframe
print("return the first 5 rows of the dataframe")
print(df.head())
print()

#return the first 2 rows of the dataframe
print("return the first 2 rows of the dataframe")
print(df.head(2))
print()

#return how many rows and columns in the dataframe
print("return how many rows and columns in the dataframe")
print(df.shape)
print()

#return the column names of the dataframe
print("return the column names of the dataframe")
print(df.columns)
print()

#return the data types of the columns in the dataframe
print("return the data types of the columns in the dataframe")
print(df.info())
print()

#return the summary statistics of the dataframe
print("return the summary statistics of the dataframe")
print(df.describe())
print()

#returns the rows where sales is greater than 500 and only returns the name and sales columns
print("returns the rows where sales is greater than 500 and only returns the name and sales")
print(df[df["sales"] > 500][["name", "sales"]])
print()

#returns the sum of the sales column
print("returns the sum of the sales column")
print(df["sales"].sum())
print()

#returns the average of the sales column
print("returns the average of the sales column using len()")
print(df["sales"].sum() / len(df))
print()

#returns the average of the sales column using mean()
print("returns the average of the sales column using mean()")
print(df["sales"].mean())
print()

#returns the sum of the sales column where sales is greater than 500
print("returns the sum of the sales column where sales is greater than 500")
print(df[df["sales"] > 500]["sales"].sum())
print()