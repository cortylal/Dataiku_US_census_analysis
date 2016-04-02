# Dataiku US census analysis
This report was produced as part of the interview process at Dataiku: https://www.dataiku.com/ 

##Introduction:
I will detail the steps I followed to solve the problematic, and present my analysis methodology.
It should be read along with the associated R script that aims to process the "US Census Data" containing information about around 300,000 people. 
After having analyzed the data, the objective is to **accurately predict if an individual saves more or less than $50,000 per year**, from the given attributes. 

Before jumping into the analysis, I spent some time exploring the raw data, and tried to better understand the different attributes and instances, that would later help predict whether an individual earns more or less than $50,000 a year. 
In particular, I did some research to understand the meaning of “Not in universe” values: they indicate that this attribute is not relevant for this particular individual (the universe is the population at risk of having a response for the variable in question).

## Data preparation
I started by doing a **quick exploration** of the provided data set. First of all, I displayed a quick summary of all columns using ``` summary(train_set)```, to have an overview of the data types, the data distribution etc.
I looked for possible **correlations** with:
```R
numeric_attributes <- sapply(train_set, is.numeric)
cor(train_set[, numeric_attributes])
``` 
I also detected (with the box-and-whiskers method) and removed **outliers** if they seemed to be errors.
Because there were a lot of data attributes on which I had little knowledge, I decided not to do any **inconsistency check**.
Below, I will detail some of the main points revealed by my approach.

The first task was to reduce the number of predictors. There are 41 potential explanatory attributes, but I decided to only keep the ones that are relevant, in order to later simplify the predictive model and boost its performances by **removing noisy data**.
The following table summarizes the observations and actions I took for each column. Overall, I chose to remove columns that don’t provide additional information:

Columns | Observation | Action 
------- | ----------- | ------
INSTANCE_WEIGHT | Information about proportion of the population is not relevant | Deleted column
CHANGE_IN_MSA, CHANGE_IN_REGION, MOVE_WITHIN_REGION, SAME_HOUSE_1_YEAR_AGO and PREVIOUS_RESIDENCE_SUNBELT | Half of the records don't have any value for those attributes => information provided by those is limited | Deleted columns
VETERAN_FORM | Less than 1% of the training set is concerned (99% of "Not in universe"), and I observed that it doesn't affect the class to predict | Deleted column
PREVIOUS_RESIDENCE_REGION, PREVIOUS_RESIDENCE_STATE, LABOR_UNION_MEMBER and YEAR | Plotted distribution of the class depending on those: they have very little effect on the class we’re looking to predict => not significant for our classification | Deleted columns
UNEMPLOYMENT_REASON | Not relevant to identify people who save more or less than $50k per year, as we can rely on the EMPLOYMENT_STATUS to distinguish those who are unemployed | Deleted column
HOUSEHOLD_STATUS | To avoid redundant information, we decide to keep the HOUSEHOLD_SUMMARY column as it is a simplified version of HOUSEHOLD_STATUS whilst keeping the best way to distinguish <50K and >50k | Deleted column
FATHER_BIRTH_COUNTRY, MOTHER_BIRTH_COUNTRY and BIRTH_COUNTRY | These are highly correlated with CITIZENSHIP, so we choose to keep this last one to simplify our model | Deleted columns
HISPANIC_ORIGIN | This information is of little interest considering that the “RACE” attribute has the predominant effect on the class category | Delete column
INDUSTRY_CODE and OCCUPATION_CODE | We prefer to keep the MAJOR_INDUSTRY and MAJOR_OCCUPATION columns for sake of simplicity, as they appear to better correlate with the revenue class | Deleted columns

Next, I decided to remove all elements with **missing values** (NAs). But I kept **duplicate rows** that result from the removal of several columns, that still indicate the weight and frequency of the information (that wasn’t duplicate prior to the attribute selection).

Overall, we can also observe that the distribution of the classes is not at all even: only 6% of the training set is composed of inputs of class “50000+.” Our model will only have a few examples from which to learn to recognize this class.
Thanks to all of these data preprocessing steps, I was able to reduce the number of attributes from 41 to 21, which will considerably simplify the building of a predictive model! 

## Data visualization
