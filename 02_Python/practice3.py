import pandas as pd

data = {
    "customerID": [1, 2, 3],
    "name": ["Alice", "Bob", "Charlie"],
    "city": ["San Ramon", "Dublin", "Pleasanton"],
    "sales": [500, 700, 450]
}

df = pd.DataFrame(data)

print("add a new column to the dataframe called sales_after_discount which is 90% of sales")
df["sales_after_discount"] = df["sales"] * .90
print(df)

print("add a new column to the dataframe called sales_level which is 'High' if sales >= 600 and 'Low' otherwise")
df["sales_level"] = df["sales"].apply(
    lambda x: "High" if x >= 600 else "Low"
)
print(df)
print()

df["sales_difference"] = df["sales"] - 550
print("add a new column to the dataframe called sales_difference which is sales - 550")
print(df)
print()

df["tax"] = df["sales"] * 0.08
print("add a new column to the dataframe called tax which is 8% of sales")
df["sales_plus_tax"] = df["sales"] + df["tax"]
print("add a new column to the dataframe called sales_plus_tax which is sales + tax")
print(df)
print()

df["sales_difference_abs"] = abs(df["sales_difference"])
print("add a new column to the dataframe called sales_difference_abs which is the absolute value of sales_difference")
print(df)
print()

df["sales_status"] = df["sales_difference"].apply(
    lambda x: "Above" if x > 0 else "Below" if x < 0 else "Equal"
)
print("add a new column to the dataframe called sales_status which indicates if sales_difference is Above, Below, or Equal to zero")
print(df)
print()

df["tax_rate"] = df["tax"] / df["sales"]
print("add a new column to the dataframe called tax_rate which is tax / sales")
print(df)
print()

df["tax_rate_percent"] = df["tax_rate"] * 100
print("add a new column to the dataframe called tax_rate_percent which is tax_rate * 100")
print(df)
print()

high_sales_customers = df[df["sales"] > 500]
print("created a new dataframe for customers with sales greater than 500:")
print(high_sales_customers)
print()