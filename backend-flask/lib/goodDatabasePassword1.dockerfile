goodDatabasePassword1

postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]

export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

export PROD_CONNECTION_URL="postgresql://cruddurroot:goodDatabasePassword1@cruddur-db-instance.clfedzzkkjls.ca-central-1.rds.amazonaws.com:5432/cruddur"

gp env PROD_CONNECTION_URL="postgresql://cruddurroot:goodDatabasePassword1@cruddur-db-instance.clfedzzkkjls.ca-central-1.rds.amazonaws.com:5432/cruddur"
