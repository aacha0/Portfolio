# Danny Ma - Clique Bait
## Introduction: 
#### Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!
## Available Data: 
#### Users, Events, Event Identifier, Campaign Identifier, and Page Hierarchy

### 1. Enterprise Relationship Diagram
<img width="872" alt="Screenshot 2024-03-06 at 9 15 58 PM" src="https://github.com/aacha0/Portfolio/assets/148589444/697124e3-f26e-4dc3-96ff-131a5a698fd5">

#### Note: Table Campaign Identifier does not have a direct connection with the other four tables 

### 2. Digital Analysis

### Q: How many users are there?
````sql
select count(distinct user_id) as number_of_users
from users
````
