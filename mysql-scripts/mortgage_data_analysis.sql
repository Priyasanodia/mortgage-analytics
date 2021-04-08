# 1.
# Calculate the % of closed loans of brokerage vs non-brokerage 

Select Month(close_date) as month ,Year(close_date) as year,
CONCAT(100*sum(case when loan_status = 'Funded' and deal_id !='' then 1 else 0 end)/sum(case when loan_status = 'Funded' then 1 else 0 end),'%') brokerage_closed_percentage,
CONCAT(100*sum(case when loan_status = 'Funded' and deal_id ='' then 1 else 0 end)/sum(case when loan_status = 'Funded' then 1 else 0 end),'%') non_brokerage_closed_percentage
From Mortgage
Group by month(close_date),year(close_date)
Order by year,month;

# 2.
# Calculate the conversion rates of brokerage and non-brokerage closed loans.

Select Month(close_date) as month,Year(close_date) as year,
CONCAT(100*sum(case when loan_status = 'Funded' and deal_id !='' then 1 else 0 end)/sum(case when deal_id !='' then 1 else 0 end),'%') brokerage_conversion_rate,

CONCAT(100*sum(case when loan_status = 'Funded' and deal_id ='' then 1 else 0 end)/sum(case when deal_id ='' then 1 else 0 end),'%') non_brokerage_conversion_rate
From Mortgage
Group by Month(close_date),Year(close_date) Order by year,month;

# 3.
# Calculate the % of business received from mortgages where the market is active. 

select t.Year, 
case
	when t.month = '1' then 'January'
    when t.month = '2' then 'February'
    when t.month = '3' then 'March'
    when t.month = '4' then 'April'
    when t.month = '5' then 'May'
    when t.month = '6' then 'June'
    when t.month = '7' then 'July'
    when t.month = '8' then 'August'
    when t.month = '9' then 'September'
    when t.month = '10' then 'October'
    when t.month = '11' then 'November'
    when t.month = '12' then 'December'
end as Month, t.Rate_of_business
from (
Select Month(b.close_date) as month, Year(b.close_date) as Year,
CONCAT(100*sum(case when b.lender = 'Rocket Mortgage' then 1 else 0 end)/sum(case when (b.lender) !='' then 1 else 0 end),'%') Rate_of_business
From Brokerage b
INNER JOIN Market m ON b.state_abbr = m.state_code
Group by month(b.close_date),year(b.close_date)
Order by year, month) t;

# 4.
# Identify the top financing type with the highest closed loans rate by each state. 

With cte as 
(Select state_abbr, financing_type, 
CONCAT(ROUND((100*sum(case When deal_status = 'Closed' Then 1 Else 0 end)/count(*)),2),"%") as Closed_loan, 
Rank() Over 
(Partition By state_abbr Order By 
sum(case when deal_status = 'Closed' then 1 else 0 end)/count(*) desc) 
as r
From brokerage
Group by state_abbr, financing_type )

Select cte.state_abbr as State, cte.financing_type as Finance_Type, cte.Closed_loan 
From cte 
Where r = 1
Order by state_abbr Asc;

#5.
# Find the Month over Month variance for Brokerage conversion rates in the year of 2020.

With cte as (
Select Month(close_date) as month, Year(close_date) as year,
CONCAT(100*sum(case when loan_status = 'Funded' and deal_id !='' then 1 else 0 end)/
sum(case when deal_id !='' then 1 else 0 end),'%') brokerage_conversion_rate,
CONCAT(100*sum(case when loan_status = 'Funded' and deal_id ='' then 1 else 0 end)/
sum(case when deal_id ='' then 1 else 0 end),'%') non_brokerage_conversion_rate
from Mortgage
Group by Month(close_date),Year(close_date) 
Order by year,month)
Select 
(case when c2.month = '1' then 'January'
	  when c2.month = '2' then 'February'
      when c2.month = '3' then 'March'
      when c2.month = '4' then 'April'
      when c2.month = '5' then 'May'
      when c2.month = '6' then 'June'
      when c2.month = '7' then 'July'
      when c2.month = '8' then 'August'
      when c2.month = '9' then 'September'
      when c2.month = '10' then 'October'
      when c2.month = '11' then 'November'
      when c2.month = '12' then 'December'
      end) as Month,
CONCAT(ROUND(c2.brokerage_conversion_rate - c1.brokerage_conversion_rate , 2), "%") as Month_Over_Month_Variance
From cte c1
JOIN cte c2 ON c1.month = c2.month - 1 
Where c1.year = 2020 and c2.year = 2020;
