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

#add a new column to the dataframe called bonus which is 10% of sales
print("add a new column to the dataframe called bonus which is 10% of sales")
df["bonus"] = df["sales"] * 0.10
print(df)
print()

#add a new column to the dataframe called tax which is 8% of sales
print("add a new column to the dataframe called tax which is 8% of sales")
df["tax"] = df["sales"] * 0.08
print(df)
print()

#add a new column to the dataframe called high_sales which is True if sales > 500 and False otherwise
print("add a new column to the dataframe called high_sales which is True if sales > 500 and False otherwise")
df["high_sales"] = df["sales"] > 500
print(df)
print()

#select * from table where high_sales is True
print("select * from table where high_sales is True")   
print(df[df["high_sales"]])
print()

#add a new column to the dataframe called sales_category which is 'High' if sales > 500 and 'Low' otherwise
print("add a new column to the dataframe called sales_category which is 'High' if sales > 500 and 'Low' otherwise")
df["sales_category"] = df["sales"].apply(
    lambda x: "High" if x > 500 else "Low"
)
print(df)
print()

#axis=1 → columns, axis=0 → rows
df = df.drop("tax", axis=1)
print("drop the tax column from the dataframe")
print(df)
print()

#rename the customerID column to Customer ID
print("rename the customerID column to Customer ID")
df = df.rename(columns={"customerID": "Customer ID"})
print(df)