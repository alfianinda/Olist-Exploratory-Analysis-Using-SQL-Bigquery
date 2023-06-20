# Olist Exploratory Analysis Using SQL Bigquery


## Description

> Explore Brazilian ecommerce public dataset using SQL as the main tool for extracting and manipulating data from the database.


## Dataset

> https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce


## Executive summary

1. 
* The year 2016. It shows a total of 326 customers listed in that year. The cumulative customer count is also 326, as it is the first year in the dataset. The growth percentage is null because there is no previous year to compare the growth.
* The year 2017. The total number of customers listed in that year is 43,713. The cumulative customer count is 44,039, which is the sum of the previous cumulative count (326) and the current year's total customers. The growth percentage is calculated as 13,408.9, representing the significant increase from the previous year.
* The year 2018. In this year, there were 52,749 customers listed. The cumulative customer count is 96,788, obtained by adding the previous cumulative count (44,039) to the total customers of the current year. The growth percentage is calculated as 119.78, indicating a substantial growth rate compared to the previous year.

2. 
* the state "RO" has an order count of 253 and a population of 240. The calculated order density for "RO" is 1.05, indicating that there is an average of 1.05 orders per person in that state.
* Therefore, based on the highest order density, the company should consider locating their warehouse in "RO". This state has the highest concentration of orders relative to its population, making it a potentially favorable area for warehouse placement.

3.
* The second highest selling product has a product ID of "aca2eb7d00ea1a7b8ebd4e68314663af" and belongs to the category "furniture_decor" in English and "moveis_decoracao" in Portuguese. It has a total order count of 431.
* On the other hand, the second lowest selling product category has a product category in English called "electronics" and in Portuguese "eletronicos". It has an order count of 1.
* These insights reveal the products that are performing well in terms of sales, with the second highest selling product category indicating a strong demand for furniture and decor items. Conversely, the second lowest selling product category suggests a relatively lower demand for electronics. These findings can be valuable for business decision-making, such as inventory management and marketing strategies, to capitalize on popular product categories and potentially improve sales in underperforming categories.

4. 
* `late_arrivals_count`: There are 6,666 products that arrived late, exceeding the promised delivery date.
* `on_time_or_faster_percentage`: Approximately 91.31% of the orders were delivered on schedule or faster.
* These insights indicate that a significant portion of the orders (91.31%) were delivered on schedule or faster, while 6,666 products arrived late. It highlights the importance of monitoring and improving delivery performance to ensure a higher percentage of orders are delivered within the promised timeframe.

5.
* The average percentage of late arrivals is decreasing as the review score increases. This suggests that higher-rated products tend to have lower instances of late delivery.
* The count of reviews decreases as the review score increases. This is expected since higher-rated products may have fewer reviews overall.
* The highest average percentage of late arrivals is observed for products with a review score of 1, indicating that these products have a higher likelihood of experiencing late delivery.
* Products with a review score of 5 have the lowest average percentage of late arrivals, indicating that these products are more likely to be delivered on time or ahead of schedule.
* Based on these insights, it can be inferred that there is a correlation between late delivery and lower review scores. Products with a higher incidence of late delivery tend to receive lower ratings, while products with better delivery performance tend to receive higher ratings. However, it's important to note that these observations are based on the provided data and further analysis may be required to establish a definitive causal relationship between late delivery and ratings.


## Codes 

https://alfianinda.github.io/Olist-Exploratory-Analysis-Using-SQL-Bigquery/


## Developer

> **NUR INNA ALFIANINDA**

> ni.alfianinda@gmail.com

