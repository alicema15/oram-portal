Feature: Client document
  As a client looking for refugee status
  In order for an administrator to consider me for refugee status
  I want to be able to upload a document with necessary information that the administrators can review

Background: Client in the database
  Given I am logged in as the following client:
    | first_name  | last_name   | email                 | password     	  | role					|
    | Bryan       | Adams     	| bryan@adams.com       | oram123         | client			  |

Scenario: Viewing Case Document
  Given I follow "Documents"
  Then I should see "Case Document"
