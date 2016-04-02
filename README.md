# Dataiku US census analysis
This report was produced as part of the interview process at Dataiku: https://www.dataiku.com/ 

##Introduction:
It will detail the steps I followed to solve the problematic, and present my analysis methodology.
It should be read along with the associated R script that aims to process the "US Census Data" containing information about around 300,000 people. After having analyzed the data, the objective is to accurately predict if an individual saves more or less than $50,000 per year, from the given attributes. 

Before jumping into the analysis, I spent some time exploring the raw data, and tried to better understand the different attributes and instances, that would later help predict whether an individual earns more or less than $50,000 a year. 
In particular, I did some research to understand the meaning of “Not in universe” values: they indicate that this attribute is not relevant for this particular individual (the universe is the population at risk of having a response for the variable in question).
