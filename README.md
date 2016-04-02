# Dataiku US census analysis
This report was produced as part of the interview process at Dataiku: https://www.dataiku.com/ 

##Introduction:
I will detail the steps I followed to solve the problematic, and present my analysis methodology.
It should be read along with the associated R script that aims to process the "US Census Data" containing information about around 300,000 people. 
After having analyzed the data, the objective is to accurately predict if an individual saves more or less than $50,000 per year, from the given attributes. 

Before jumping into the analysis, I spent some time exploring the raw data, and tried to better understand the different attributes and instances, that would later help predict whether an individual earns more or less than $50,000 a year. 
In particular, I did some research to understand the meaning of “Not in universe” values: they indicate that this attribute is not relevant for this particular individual (the universe is the population at risk of having a response for the variable in question).

## Data preparation
I started by doing a quick exploration of the provided data set. First of all, I displayed a quick summary of all columns using summary(train_set), to have an overview of the data types, the data distribution etc.
I looked for possible correlations with:
* numeric_attributes <- sapply(train_set, is.numeric)
* cor(train_set[, numeric_attributes])

I also detected (with the box-and-whiskers method) and removed outliers if they seemed to be errors.
Because there were a lot of data attributes on which I had little knowledge, I decided not to do any inconsistency check.
Below, I will detail some of the main points revealed by my approach.

The first task was to reduce the number of predictors. There are 41 potential explanatory attributes, but I decided to only keep the ones that are relevant, in order to later simplify the predictive model and boost its performances by reducing noisy data.

* The information about the proportion of the population that is being represented by each row is not relevant, so we can delete the "INSTANCE_WEIGHT" column. 
* I removed the columns "CHANGE_IN_MSA", "CHANGE_IN_REGION", "MOVE_WITHIN_REGION", "SAME_HOUSE_1_YEAR_AGO" AND "PREVIOUS_RESIDENCE_SUNBELT” because around half of the records in the training set didn’t have any value for those attributes: the information provided by those was limited. Similarly, less than 1% of the training set is affected by the “VETERAN_FORM” column (99% of “Not in universe”) so we can delete it, having observed that it doesn’t affect the class to predict.
* By plotting the distribution of each class depending on “PREVIOUS_RESIDENCE_REGION”, “PREVIOUS_RESIDENCE_STATE”, “LABOR_UNION_MEMBER” or “YEAR”, it is clear that those attributes have very little effect on the class we’re looking to predict. Therefore, because they are not significant for our classification, we can remove them.
* Also, the “UNEMPLOYMENT_REASON” is not relevant to identify people who save more or less than $50k per year, as we can rely on the “EMPLOYMENT_STATUS” to distinguish those who are unemployed. We can remove the “UNEMPLOYMENT_REASON” column.
* Similarly, we decide to only keep the “HOUSEHOLD_SUMMARY” column as it is a simplified version of the “HOUSEHOLD_STATUS”, avoiding redundant information.
* We can also argue that “FATHER_BIRTH_COUNTRY”, “MOTHER_BIRTH_COUNTRY”, “BIRTH_COUNTRY” and “CITIZENSHIP” are highly correlated, so we choose to keep only the “CITIZENSHIP” attribute to simplify our model.
* The “HISPANIC_ORIGIN” information is of little interest considering that the “RACE” attribute has the predominant effect on the class category: we remove the “HISPANIC_ORIGIN” column.
* I chose to remove columns that don’t provide additional information. For example, “INDUSTRY_CODE” lists 52 different industries whereas “MAJOR_INDUSTRY” classifies 24 industries. Same for “OCCUPATION_CODE” and “MAJOR_OCCUPATION”. We prefer to keep the “MAJOR_INDUSTRY” and “MAJOR_OCCUPATION” columns for sake of simplicity, as they also appear to better correlate with the revenue class.

I decided to remove all elements with missing values (NAs). But I kept duplicate rows that result from the removal of several columns, that still indicate the weight and frequency of the information (that wasn’t duplicate prior to the attribute selection).

Overall, we can also observe that the distribution of the classes is not at all even: only 6% of the training set is composed of inputs of class “50000+.” Our model will only have a few examples from which to learn to recognize this class.

Thanks to all of these data preprocessing steps, I was able to reduce the number of attributes from 41 to 21, which will considerably simplify the building of a predictive model! 

## Data visualization
