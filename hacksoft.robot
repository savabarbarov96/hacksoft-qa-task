*** Settings ***
Library           RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    String
*** Variables ***
${LOGIN_URL}       https://qa-task-be.hacksoft.io/api/auth/jwt/login/
${EMPLOYEES_ENDPOINT}    https://qa-task-be.hacksoft.io/api/employees
${CREATE_EMPLOYEE_ENDPOINT}    https://qa-task-be.hacksoft.io/api/employees/create/
${DELETE_EMPLOYEE_ENDPOINT}    https://qa-task-be.hacksoft.io/api/employees/delete/
${UPDATE_EMPLOYEE_ENDPOINT}    
${USERNAME}       savabarbarov961@gmail.com
${PASSWORD}       vV53nFpB4OeuHFF
${TOKEN}    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InNhdmFiYXJiYXJvdjk2MUBnbWFpbC5jb20iLCJpYXQiOjE2NzkxNDMxNTIsImV4cCI6MTcxMDY3OTE1MiwianRpIjoiNTFhM2QwMDQtMzczNS00YzQxLWExODgtZjdjNDMwODU1ZWY4IiwidXNlcl9pZCI6MjR9.E2-ujLK1iZ_gnOmxwyGZVir7yWPcXlv4b49o5mhOWt8    
${employee_id}
${id}
*** Test Cases ***
TC-01 Login test (POST)
    [Documentation]    Attempt to get authorization to the page 
    [Tags]             Login
    Create Session    login    ${LOGIN_URL}
    ${auth}=          Create List        ${USERNAME}    ${PASSWORD}
    ${body}=    Create Dictionary    email=${USERNAME}    password=${PASSWORD}
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    verify=True
    ${response}=      POST On Session       login    json=${body}    url=${LOGIN_URL}    headers=${headers}
    
        #VALIDATIONS
    ${test_id}=    Convert String To Json    ${response.content}
    ${TOKEN}=    Get Value From Json    ${test_id}    $.token
    Log To Console    The token is ${TOKEN}
    Status Should Be    200
    [Teardown]        Delete All Sessions

TC-02 Get Employee Details (GET)
    [Documentation]    Attempt to get employee details
    [Tags]    Employees
    Create Session    employees    ${EMPLOYEES_ENDPOINT}
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    verify=True    authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    employees    url=${EMPLOYEES_ENDPOINT}    headers=${headers}
        #VALIDATIONS
    Status Should Be    200
    Log To Console    ${response.content}
    Check if response body contains first_name, last_name, email    ${response.content}
    [Teardown]        Delete All Sessions

TC-03 Create employee (POST)
    [Documentation]    Check if user is able to create employee
    [Tags]    Employees
    Create Session    employees    ${EMPLOYEES_ENDPOINT}
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    verify=True    authorization=Bearer ${TOKEN}
    ${body}=    Create Dictionary    first_name=Sava    last_name=Barbarov    email=testing123321@abv.bg
    ${response}=    POST On Session    employees    json=${body}    url=${CREATE_EMPLOYEE_ENDPOINT}    headers=${headers}
    Log To Console    ${response.content}
        #VALIDATIONS
    Status Should Be    200
    ${test_id}=    Convert String To Json    ${response.content}
    ${employee_id}=    Get Value From Json    ${test_id}    $.id
    Set Suite Variable    ${id}    ${employee_id}[0]
    Log To Console    Employee created successfully. ID is ${employee_id}[0]

TC-05 Update employee (UPDATE)
    [Documentation]    Update employee
    [Tags]    Employees
    Create Session    employees    ${EMPLOYEES_ENDPOINT}
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    verify=True    authorization=Bearer ${TOKEN}
    ${body}=    Create Dictionary    director=${id}    salary=1500    description=Testing123
    ${response}=    POST On Session    employees    json=${body}    url=https://qa-task-be.hacksoft.io/api/employees/${id}/update/    headers=${headers}
        #VALIDATIONS
    Status Should Be    200
TC-04 Delete employee (POST)
    [Documentation]    Delete employee
    [Tags]    Employees
    Create Session    employees    ${EMPLOYEES_ENDPOINT}
    ${headers}=    Create Dictionary    accept=application/json    Content-Type=application/json    verify=True    authorization=Bearer ${TOKEN}
    ${body}=    Create Dictionary    id=${id}
    ${response}=    POST On Session    employees    json=${body}    url=${DELETE_EMPLOYEE_ENDPOINT}    headers=${headers}
        #VALIDATIONS
    Status Should Be    200
    [Teardown]        Delete All Sessions


*** Keywords ***
Check if response body contains first_name, last_name, email
    [Arguments]    ${response.content}
    Log To Console    ${response.content}
    ${string}=    Decode Bytes To String    ${response.content}    UTF-8
    Log To Console    ${string}
    Should Contain Any    ${string}    first_name    last_name    email
