# Created on Fri Apr 01 16:25:36 2016
# 
# @author: Alexandre Cortyl

# This R script aims to process the "US Census Data" containing information about
# around 300,000 people.
# After having analyzed the data, the objective is to accurately predict if an 
# individual saves more or less than $50,000 per year, from the given attributes.
# This was produced as part of the interview process at Dataiku: https://www.dataiku.com/

# Make sure to set the working directory to the one containing the input data
# using setwd(dir) where "dir" is the absolute path to the directory 
# Download source files from http://thomasdata.s3.amazonaws.com/ds/us_census_full.zip


# Load necessary packages (previously installed, check for dependencies)
library(plyr) # count(train_set, "CLASS")
library(tree) # Decision tree

# ----
# 1/ Data preparation
# ----

# Import initial data from provided files
train_set <- read.csv("census_income_learn.csv", header = FALSE, stringsAsFactors = TRUE)

# Add attribute names for comprehension 
attribute_names <- c("AGE", "WORK_CLASS", "INDUSTRY_CODE", "OCCUPATION_CODE", 
                     "EDUCATION", "WAGE_PER_HOUR", "ENROLL_IN_EDU", "MARITAL_STATUS", 
                     "MAJOR_INDUSTRY", "MAJOR_OCCUPATION", "RACE", "HISPANIC_ORIGIN", 
                     "SEX", "LABOR_UNION_MEMBER", "UNEMPLOYMENT_REASON", "EMPLOYMENT_STATUS", 
                     "CAPITAL_GAINS", "CAPITAL_LOSSES", "STOCKS_DIVIDENDS", "TAX_STATUS", 
                     "PREVIOUS_RESIDENCE_REGION", "PREVIOUS_RESIDENCE_STATE", "HOUSEHOLD_STATUS", 
                     "HOUSEHOLD_SUMMARY", "INSTANCE_WEIGHT", "CHANGE_IN_MSA", "CHANGE_IN_REGION", 
                     "MOVE_WITHIN_REGION", "SAME_HOUSE_1_YEAR_AGO", "PREVIOUS_RESIDENCE_SUNBELT", 
                     "NUM_PERSONS_WORKED_FOR_EMPLOYER", "FAMILY_MEMBERS_UNDER_18" , 
                     "FATHER_BIRTH_COUNTRY", "MOTHER_BIRTH_COUNTRY", "BIRTH_COUNTRY", 
                     "CITIZENSHIP", "SELF_EMPLOYED", "VETERAN_FORM", "VETERANS_BENEFITS", 
                     "WEEKS_WORKED", "YEAR", "CLASS")
colnames(train_set) <- attribute_names

# Remove undisered attributes, determined by previous data manipulation
# See Readme.md for details
to_remove <- c("INDUSTRY_CODE", "OCCUPATION_CODE", "ENROLL_IN_EDU", "HISPANIC_ORIGIN", "LABOR_UNION_MEMBER", 
               "UNEMPLOYMENT_REASON", "PREVIOUS_RESIDENCE_REGION", "PREVIOUS_RESIDENCE_STATE", 
               "HOUSEHOLD_STATUS", "INSTANCE_WEIGHT", "CHANGE_IN_MSA", "CHANGE_IN_REGION", 
               "MOVE_WITHIN_REGION", "SAME_HOUSE_1_YEAR_AGO", "PREVIOUS_RESIDENCE_SUNBELT", 
               "FATHER_BIRTH_COUNTRY", "MOTHER_BIRTH_COUNTRY", "BIRTH_COUNTRY", "VETERAN_FORM", "YEAR")
for (column in to_remove){
  train_set[[column]] <- NULL
}

# Convert type of attributes containing numeric values although they are categorical
categorical_attributes <- c("SELF_EMPLOYED", "VETERANS_BENEFITS")
for (attribute in categorical_attributes){
  train_set[, attribute] <- as.factor(train_set[, attribute])
}

# Change every value that is a " ?" to NA, and remove elements with missing values
train_set[train_set == " ?"] <- NA
train_set <- train_set[complete.cases(train_set),]

# ----
# 2/ Data visualization
# ----

# Age distribution graphical display
age_distrib <- count(train_set, "AGE")
plot(age_distrib$AGE, age_distrib$freq, main = "Age distribution", xlab = "Age", ylab = "Number of entities")
dev.copy(png, "age_distribution.png")
dev.off()
# Split data by class into two subsets
more_50k <- train_set[train_set$CLASS == " 50000+.",]
less_50k <- train_set[train_set$CLASS == " - 50000.",]
# Class repartition depending on age category
more_50k_young_count <- 0
more_50k_active_count <- 0
more_50k_senior_count <- 0
for (i in 1:nrow(more_50k)){
  age <- more_50k[i,"AGE"]
  if (age <= 20){
    more_50k_young_count <- more_50k_young_count + 1
  } else if (age > 60){
    more_50k_senior_count <- more_50k_senior_count + 1
  } else {
    more_50k_active_count <- more_50k_active_count + 1
  }
}
less_50k_young_count <- 0
less_50k_active_count <- 0
less_50k_senior_count <- 0
for (i in 1:nrow(less_50k)){
  age <- less_50k[i,"AGE"]
  if (age <= 20){
    less_50k_young_count <- less_50k_young_count + 1
  } else if (age > 60){
    less_50k_senior_count <- less_50k_senior_count + 1
  } else {
    less_50k_active_count <- less_50k_active_count + 1
  }
}
age_group <- data.frame(Young = numeric(0), Active = numeric(0), Senior = numeric())
age_less_50k <- data.frame(Young = less_50k_young_count, Active = less_50k_active_count, 
                       Senior = less_50k_senior_count)
age_group <- rbind(age_group, age_less_50k)
age_more_50k <- data.frame(Young = more_50k_young_count, Active = more_50k_active_count, 
                       Senior = more_50k_senior_count)
age_group <- rbind(age_group, age_more_50k)
age_group <- as.matrix(age_group)
barplot(age_group, main = "Age vs Income", legend = c("<50k", ">50k"), col = c("blue", "red"))
dev.copy(png, "age_vs_income.png")
dev.off()

# Class repartition depending on sex
temp <- table(train_set$CLASS, train_set$SEX)
barplot(temp, beside=TRUE, main = "Sex vs Income", legend.text=rownames(temp), ylab="absolute frequency", 
        col = c("blue", "red"))
dev.copy(png, "sex_vs_income.png")
dev.off()

# Class repartition depending on work category
temp <- table(train_set$CLASS, train_set$WORK_CLASS)
temp <- as.data.frame.matrix(temp)
temp <- data.frame(t(temp)) # reverse
temp <- temp[order(temp$X.50000.., decreasing = TRUE),] # order by decreasing number of people earning more than $50k
temp <- temp[1:4,] # Only keep the main records  
temp <- data.frame(t(temp)) # reverse
temp <- as.matrix(temp)
x <- barplot(temp, main = "Work Category vs Income", legend = c("<50k", ">50k"), col = c("blue", "red"), xaxt='n')
text(cex=1, x=x, y= 2*x, c("Private", "S.E. Incor", "S.E. not Incor", "N.I.U."), xpd=TRUE, srt=45, pos=2)
dev.copy(png, "work_category_vs_income.png")
dev.off()

# Class repartition depending on Nb of weeks worked
more_50k_less_10_weeks <- 0
more_50k_in_between <- 0
more_50k_more_45_weeks <- 0
for (i in 1:nrow(more_50k)){
  weeks <- more_50k[i,"WEEKS_WORKED"]
  if (weeks <= 10){
    more_50k_less_10_weeks <- more_50k_less_10_weeks + 1
  } else if (weeks > 45){
    more_50k_more_45_weeks <- more_50k_more_45_weeks + 1
  } else {
    more_50k_in_between <- more_50k_in_between + 1
  }
}
less_50k_less_10_weeks <- 0
less_50k_in_between <- 0
less_50k_more_45_weeks <- 0
for (i in 1:nrow(more_50k)){
  weeks <- less_50k[i,"WEEKS_WORKED"]
  if (weeks <= 10){
    less_50k_less_10_weeks <- less_50k_less_10_weeks + 1
  } else if (weeks > 45){
    less_50k_mre_45_weeks <- less_50k_more_45_weeks + 1
  } else {
    less_50k_in_between <- less_50k_in_between + 1
  }
}
weeks_group <- data.frame(Less_10_weeks = numeric(0), In_between = numeric(0), More_45_weeks = numeric(0))
weeks_less_50k <- data.frame(Less_10_weeks = less_50k_less_10_weeks, In_between = less_50k_in_between, 
                             More_45_weeks = less_50k_more_45_weeks)
weeks_group <- rbind(weeks_group, weeks_less_50k)
weeks_more_50k <- data.frame(Less_10_weeks = more_50k_less_10_weeks, In_between = more_50k_in_between, 
                             More_45_weeks = more_50k_more_45_weeks)
weeks_group <- rbind(weeks_group, weeks_more_50k)
weeks_group <- as.matrix(weeks_group)
barplot(weeks_group, main = "Weeks worked vs Income", legend = c("<50k", ">50k"), col = c("blue", "red"))
dev.copy(png, "weeks_worked_vs_income.png")
dev.off()

# Class repartition depending on Education
temp <- table(train_set$CLASS, train_set$EDUCATION)
temp <- as.data.frame.matrix(temp)
temp <- data.frame(t(temp)) # reverse
temp <- temp[order(temp$X.50000.., decreasing = TRUE),] # order by decreasing number of people earning more than $50k
temp <- temp[1:6,] # Only keep the main records  
temp <- data.frame(t(temp)) # reverse
temp <- as.matrix(temp)
x <- barplot(temp, main = "Education vs Income", legend = c("<50k", ">50k"), col = c("blue", "red"), xaxt='n')
text(cex=1, x=x, y= 2*x, c("Bachelor", "Master", "High school", "College", "Prof school", "PhD"), xpd=TRUE, srt=45, pos=2)
dev.copy(png, "education_vs_income.png")
dev.off()

# Class repartition depending on "Race"

temp <- table(train_set$CLASS, train_set$RACE)
temp <- as.data.frame.matrix(temp)
temp <- data.frame(t(temp)) # reverse
temp <- temp[order(temp$X.50000.., decreasing = TRUE),] # order by decreasing number of people earning more than $50k  
temp <- data.frame(t(temp)) # reverse
temp <- as.matrix(temp)
x <- barplot(temp, main = "Race vs Income", legend = c("<50k", ">50k"), col = c("blue", "red"), xaxt='n')
text(cex=1, x=x, y= 2*x, c("White", "Black", "Asian", "Other", "Amerindian"), xpd=TRUE, srt=45, pos=2)
dev.copy(png, "race_vs_income.png")
dev.off()

# ----
# 3/ Build two predictive models using the training set, and compare them
# ----

# Generalized Linear Model
glm_model <- glm(CLASS ~ ., data = train_set, family = binomial)
summary(glm_model) # Identify significant variables (they have low p-values)
glm_probs <- predict(glm_model, type = "response") # predict
glm_pred = rep("<50k", length(glm_probs)) # vector initialized at majority class
glm_pred[glm_probs > 0.5] = ">50k" # change value if probability > 50%
table(glm_pred, train_set$CLASS) # Display confusion matrix get prediction accuracy but overfitted!

# Decision tree
dec_tree <- tree(CLASS ~ ., data = train_set)
plot(dec_tree, uniform=TRUE, main="Classification Tree")
text(dec_tree, use.n=TRUE, all=TRUE, cex=.8)
tree_probs <- predict(dec_tree, type = "class")
tree_pred = rep("<50k", length(tree_probs))
tree_pred[tree_probs == " 50000+."] = ">50k"
table(tree_pred, train_set$CLASS)

# ----
# 4/ Apply the model with best performances on the test set, for evaluation
# ----

# Remove the train set to free memory
rm(train_set)
# We perform the same data processing done on the train_set to the test_set
test_set <- read.csv("census_income_test.csv", header = FALSE)
colnames(test_set) <- attribute_names
for (column in to_remove){
  test_set[[column]] <- NULL
}
for (attribute in categorical_attributes){
  test_set[, attribute] <- as.factor(test_set[, attribute])
}
test_set[test_set == " ?"] <- NA
test_set <- test_set[complete.cases(test_set),]

# Evaluate GLM
glm_test_probs <- predict(glm_model, test_set, type = "response") # predict
glm_test_pred = rep("<50k", length(glm_test_probs)) # vector initialized at majority class
glm_test_pred[glm_test_probs > 0.5] = ">50k" # change value if probability > 50%
table(glm_test_pred, test_set$CLASS) # Display confusion matrix to get prediction accuracy

# Evaluate Tree
tree_test_probs <- predict(dec_tree, test_set, type = "class") # predict
tree_test_pred = rep("<50k", length(tree_test_probs)) # vector initialized at majority class
tree_test_pred[tree_test_probs == " 50000+."] = ">50k" # change value if value = " 50000+."
table(tree_test_pred, test_set$CLASS) # Display confusion matrix to get prediction accuracy
