MINI PROJECT – 1

Dataset

Imagine you are realtor company or property agency; you would like to use data to help clients understand the worth of their unit prior or during transaction, whether is for sale or to derive an appropriate rent.

The original dataset comes from Housing Development Board (Singapore), kindly download the latest dataset from: https://data.gov.sg/dataset/resale-flat-prices 

Field name	Description	Sample Value	Data Type
Month	The month of the transacted unit	2022-01	Date
Town	The town that the transacted unit was from	ANG MO KIO	Nominal
Flat Type	The flat type for the transacted unit	4-Room	<Unknown>
Block	The apartment identifier where the transacted unit belongs to 	123	Nominal
Street Name	The location of the apartment of the transacted unit	ANG MO KIO AVENUE 5	Nominal
Storey Range	The floor level of the transacted unit. The range was quoted as a form of data aggregation for confidentiality purposes.	01 TO 03	Ordinal
Floor Area sqm (sqm)	The size in square metres of the transaction unit.	93	Integer
Flat Model	The model type of the transacted unit	Model A	Nominal
Leases commence date	For the transacted unit, it is the recognised date for the started of the homeownership 	1990	Date
Remaining lease	For the transacted unit, it is the remaining months till its land lease expires and the rights of the homeownership will be extinguished and therefore return to the relevant authority 	67years and 00 months	Date
Resale price ($)	For the transacted unit, it is the transacted price agreed between a buyer and a seller.	600,000	Real

Analyse the data in suitable Programming Languages (Java / Python / R / d3.js) or Non-Programming software tool (Excel / Power BI / Weka / Tableau) by consulting with me and attempt the following, detail down your steps for some of the following questions:

Part I 
•	How many units have been transacted over the COVID period i.e., 2019 to 2021?
•	What are the characteristics of the transacted unit?
•	What are the demographics that was observed?

Part II
•	Under the Field name - Flat Type, what do you think is the appropriate Data Type?
o	Substantiate with relevant research paper or.
o	Justify with the appropriate statistical test i.e., significance p-value test.
•	Which field name do you think is less meaningful?
o	Justify with either Data techniques that you have learned in previous courses such as either Dimensionality Reduction / Feature Selection / Statistical Techniques and Test / Multivariate analysis




Part III
•	Conduct Data Blending and add additional fields or variables where you can scrape
o	You may extract geospatial data from geospatial provider i.e., OneMap API
	You may consider testing for confounding variables or variables with effects on housing price i.e., proximity to train / good schools / eateries and substantiate why you would choose it?

Part IV
•	Create a dashboard to highlight the following:
o	The demographics of certain seller
o	The obvious trends and patterns
o	A suitable predictive modelling with the appropriate charts i.e., Visual Analytics
