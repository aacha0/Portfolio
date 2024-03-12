# 8 Weeks Challenge: Foodie-fi SQL Case Study 
## Introduction: 
#### Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
#### Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
#### Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.
#### Source: <https://8weeksqlchallenge.com/case-study-3/>
## Available Data: 
#### Plans 

<img width="317" alt="Screenshot 2024-03-11 at 11 37 26 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/78a4833b-b5cf-475d-be48-84ecfd7077d9">

#### Subscriptions 
<img width="355" alt="Screenshot 2024-03-11 at 11 38 07 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/abf761f0-753b-4605-931a-cb9dc5f75a1e">

## 1. Data Analysis 
### Q: How many customers has Foodie-Fi ever had?

```sql
 select count(distinct customer_id)
    from subscriptions;
```
#### Output: 
| count(distinct customer_id) |
| --------------------------- |
| 1000                        |
What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
What is the number and percentage of customer plans after their initial free trial?
What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
How many customers have upgraded to an annual plan in 2020?
How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
