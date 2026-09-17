import pandas as pd

data = {
    "customerID": [1, 2, 3],
    "name": ["Alice", "Bob", "Charlie"],
    "city": ["San Ramon", "Dublin", "Pleasanton"],
    "sales": [500, 700, 450]
}

df = pd.DataFrame(data)

#select * from table where sales > 500 and city == 'Dublin'
print("select * from table where sales > 500 and city == 'Dublin'") 
print(df[(df["sales"] > 500) & (df["city"] == "Dublin")])
print()

#select * from table where city == 'San Ramon' or sales > 600
print("select * from table where city == 'San Ramon' or sales > 600")
print(df[(df["city"] == "San Ramon") | (df["sales"] > 600)])
print()

#select * from table where sales is between 400 and 600
print("select * from table where sales is between 400 and 600")
print(df[(df["sales"] >= 400) & (df["sales"] <= 600)])
print()