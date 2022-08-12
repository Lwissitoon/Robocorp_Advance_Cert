*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium  auto_close=${True}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Robocorp.Process
Library    RPA.Archive
Library    RPA.Dialogs
Library    RPA.Robocorp.Vault
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
 Open the robot order website
    ${secret}=    Get Secret    data
    # Note: In real robots, you should not print secrets to the log.
    # This is just for demonstration purposes. :)
   

   Open Available Browser   ${secret}[url]
Get orders
  
  #https://robotsparebinindustries.com/orders.csv
   ${url} =   Input form dialog
 
  Download    ${url}   overwrite=True
  ${ordes} =  Read table from CSV    orders.csv  header=TRUE  delimiters=,
  Return From Keyword  ${ordes}
  
Close the annoying modal
  Click Button    OK
 Fill the form
     [Arguments]  ${row}
     Select From List By Index    id:head  ${row}[Head]
     Click Element    xpath://input[@name="body"][@value=${row}[Body]]
     Input Text   xpath://input[@placeholder="Enter the part number for the legs"]     ${row}[Legs]
     Input Text    id:address     ${row}[Address]

Preview the robot
  Click Element    id:preview
Submit the order
  Wait Until Element Is Visible    id:order
  Click Button    Order
Store the receipt as a PDF file
    [Arguments]  ${orderNumber}
   # Wait Until Element Is Visible    id:receipt
     
     
      ${rec} =   Is Element Visible    id:receipt
      Run Keyword Unless   ${rec}  Wait Until Keyword Succeeds    1 min    1 sec    Submit the order
      ${Receipt_html}=    Get Element Attribute    id:receipt    outerHTML
      Html To Pdf    ${Receipt_html}    ${OUTPUT_DIR}${/}Receipts/receipt${orderNumber}.pdf
      ${pdf}   Set Variable  ${OUTPUT_DIR}${/}Receipts/receipt${orderNumber}.pdf
 
    Return From Keyword    ${pdf} 
Take a screenshot of the robot
     [Arguments]  ${orderNumber}
      Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}Robots/Robot${orderNumber}.png
      
      ${screenshot}  set variable   ${CURDIR}/Robots/Robot${orderNumber}.png
      Return From Keyword  ${screenshot}
Embed the robot screenshot to the receipt PDF file
  [Arguments]  ${screenshot}    ${pdf}
  ${files}=    Create List   ${screenshot}
  Open Pdf    ${pdf}
  Add Files To Pdf   ${files}  ${pdf}
  Close Pdf
        
Go to order another robot
  Click Element When Visible    id:order-another
Create a ZIP file of the receip
Create A ZIP File Of The Receipts
    [Documentation]    Create A ZIP File Of The Receipts
        ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/Receipts.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}Receipts
    ...    ${zip_file_name}

Input form dialog
    Add heading       Add CSV
    Add text input    name=csv
    ${result}=    Run dialog
    Return From Keyword   ${result.csv}