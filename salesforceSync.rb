#!/usr/bin/ruby

require 'pg'
require 'restforce'
require 'date'

$PG_HOST="localhost"
$PG_DBNAME="postgres"
$PG_USERNAME="postgres"
$PG_PASSWORD="123456789"

$SALESFORCE_URI="https://login.salesforce.com"
$SALESFORCE_USERNAME="y.bayed@webline.fr"
$SALESFORCE_PASSWORD="ipaG6zEcv7"
$SALESFORCE_SECURITY_TOKEN="bX0eZ9HSCZrmAtRopzj1BAxXd"
$SALESFORCE_CLIENT_ID="3MVG95NPsF2gwOiMqhu6dVx3sOx0XcF4rrvZNdkto2b9IpmbX7cygrfyqDKjJ5sOIOrXfYHEz4WpX7MbBLzY7"
$SALESFORCE_CLIENT_SECRET="9165032268062141764"
$SALESFORCE_API_VERSION="41.0"


def getLastData(con,tableName,referenceDate)

   	query = "SELECT * FROM " + tableName
   	# + "WHERE last-modified-date > " + strftime(referenceDate)

   	con.exec query

   	rs = con.exec query
	
	puts 'There are %d columns ' % rs.nfields
	puts 'The column names are:'
	puts rs.fields

	retunedValue = "<data>"

	rs.each do |row|

		retunedValue += "<" + tableName + ">"

		rs.fields.each do |field|
			retunedValue += "<" + field + ">" + row[field] + "</" + field + ">"
        end

        retunedValue += "</" + tableName + ">"
    end

    retunedValue += "</data>"

    puts retunedValue

	return retunedValue
end

def sendToSalesforce(customerData)

	client = Restforce.new(username: $SALESFORCE_USERNAME,
							password: $SALESFORCE_PASSWORD,
							security_token: $SALESFORCE_SECURITY_TOKEN,
							client_id: $SALESFORCE_CLIENT_ID,
							client_secret: $SALESFORCE_CLIENT_SECRET,
							instance_url: SALESFORCE_URI,
							api_version: $SALESFORCE_API_VERSION)
#accounts = client.query("select id, name from account limit 5")
#puts accounts
    puts client.create('LCDS_UPDATES__c', customers: customerData)
end


begin

	#database connexion
    con = PG.connect :host => $PG_HOST,:dbname => $PG_DBNAME, :user => $PG_USERNAME, :password => $PG_PASSWORD

    referenceDate = DateTime.now - (90/1440.0) #1h30 avant

    #get xml data
    customerData = getLastData(con,'user',referenceDate)

    #send data to salesforce
    sendToSalesforce(customerData)
    
rescue PG::Error => e

    puts 'ERROR : ' + e.message 
    
ensure

    con.close if con
    
end

