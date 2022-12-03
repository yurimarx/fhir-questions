Class dc.fhirquestions.FHIRQuestionsRESTApp Extends %CSP.REST
{

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter CONTENTTYPE = "application/json";

Parameter Version = "1.0.0";

Parameter HandleCorsRequest = 1;

Parameter URL = "/fhir/r4";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />

<!-- Get all questionnairies -->
<Route Url="/questionnaire" Method="GET" Call="GetAllQuestionnaire"/>
<!-- Get a questionnarie by id-->
<Route Url="/questionnaire/:id" Method="GET" Call="GetQuestionnaire"/> 
<!-- Update a questionnarie by id-->
<Route Url="/questionnaire/:id" Method="PUT" Call="UpdateQuestionnaire"/>
<!-- Delete a questionnaire by id-->
<Route Url="/questionnaire/:id" Method="DELETE" Call="DeleteQuestionnaire"/>
<!-- Create a questionnaire-->
<Route Url="/questionnaire" Method="POST" Call="CreateQuestionnaire"/>
<!-- update the questionnaire-->
<Route Url="/questionnaire/:id" Method="PUT" Call="UpdateQuestionnaire"/>

<!-- Get all questionnairie responses -->
<Route Url="/questionnaireResponse" Method="GET" Call="GetAllQuestionnaireResponse"/>
<!-- Get a questionnarie response by id-->
<Route Url="/questionnaireResponse/:id" Method="GET" Call="GetQuestionnaireResponse"/> 
<!-- Update a questionnarie response by id-->
<Route Url="/questionnaireResponse/:id" Method="PUT" Call="UpdateQuestionnaireResponse"/>
<!-- Delete a questionnaire response by id-->
<Route Url="/questionnaireResponse/:id" Method="DELETE" Call="DeleteQuestionnaireResponse"/>
<!-- Create a questionnaire response-->
<Route Url="/questionnaireResponse" Method="POST" Call="CreateQuestionnaireResponse"/>
<!-- update the questionnaire response-->
<Route Url="/questionnaireResponse/:id" Method="PUT" Call="UpdateQuestionnaireResponse"/>


</Routes>
}

/// FHIR Questions REST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET fmt=##class(%SYS.NLS.Format).%New("ptbw")
  
  SET info = {
    "Service": "FHIR Questionnaire API",
    "version": (version),
    "Developer": "Yuri Gomes",
    "Status": "Ok",
    "Date": ($ZDATETIME($HOROLOG))
  }
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Write info.%ToJSON()
  Quit $$$OK
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  SET tSC = $$$OK
  IF $$$ISERR(pStatus) {
    SET %response.Status = 500
    SET tSC = ..StatusToJSON(pStatus, .tJSON)
    IF $isobject(tJSON) {
      SET pResult = tJSON
    } ELSE {
      SET pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ELSEIF pStatus=1 {
    IF '$isobject(pResult){
      SET pResult = {
      }
    }
  }
  ELSE {
    SET %response.Status = pStatus
    SET error = $PIECE(pStatus, " ", 2, *)
    SET pResult = {
      "error": (error)
    }
  }
  
  IF pResult.%Extends("%Library.DynamicAbstractObject") {
    WRITE pResult.%ToJSON()
  }
  ELSEIF pResult.%Extends("%JSON.Adaptor") {
    DO pResult.%JSONExport()
  }
  ELSEIF pResult.%Extends("%Stream.Object") {
    DO pResult.OutputToDevice()
  }
  
  QUIT tSC
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/rest/questionnaire" 
  Set swagger.info.title = "FHIR Questionnaire API"
  Set swagger.info.version = "1.0"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

/// Retrieve all the records of questionnaire
ClassMethod GetAllQuestionnaire() As %Status
{

    set tSC = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/Questionnaire/"
        set request.RequestMethod = "GET"
        do fhirService.DispatchRequest(request, .pResponse)
        set json = pResponse.Json
        set resp = []
        set iter = json.entry.%GetIterator()
        while iter.%GetNext(.key, .value) { 
          do resp.%Push(value.resource)
        }
        
        write resp.%ToJSON()    
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on get all questionnairies"       
    }
    
    Quit tSC
}

/// Retreive a questionnaire by id
ClassMethod GetQuestionnaire(id As %String) As %Status
{

    set tSC = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/Questionnaire/"_id
        set request.RequestMethod = "GET"
        do fhirService.DispatchRequest(request, .pResponse)
        write pResponse.Json.%ToJSON()    
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on get the questionnaire"       
    }
    
    Quit tSC
}

/// Create questionnaire
ClassMethod CreateQuestionnaire() As %Status
{
  set tSC = $$$OK
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Try {
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/Questionnaire/"
    set request.RequestMethod = "POST"
    set data = {}.%FromJSON(%request.Content)
    set data.resourceType = "Questionnaire"
    set request.Json = data
    do fhirService.DispatchRequest(request, .response)
    write response.Json.%ToJSON()
  } Catch Err {
    set tSC = 1
    set message = {}
    set message.type= "ERROR"
    set message.details = "Error on create questionnaire"
  }
  
  Return tSC
}

/// Update a questionnaire
ClassMethod UpdateQuestionnaire(id As %String) As %Status
{
  set tSC = $$$OK
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Try {
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/Questionnaire/"_id
    set request.RequestMethod = "PUT"
    set data = {}.%FromJSON(%request.Content)
    set data.resourceType = "Questionnaire"
    set request.Json = data
    do fhirService.DispatchRequest(request, .response)
    write response.Json.%ToJSON()
  }Catch Err {
    set tSC = 1
    set message = {}
    set message.type= "ERROR"
    set message.details = "Error on update questionnaire"
  }
  Return tSC
}

/// Delete a questionnaire by id
ClassMethod DeleteQuestionnaire(id As %String) As %Status
{

    set tSC = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/Questionnaire/"_id
        set request.RequestMethod = "DELETE"
        do fhirService.DispatchRequest(request, .pResponse)
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on delete the questionnaire"       
    }
    
    Quit tSC
}

/// Retrieve all the records of questionnaire response
ClassMethod GetAllQuestionnaireResponse() As %Status
{

    set tSC = $$$OK 
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/QuestionnaireResponse/"
        set request.RequestMethod = "GET"
        do fhirService.DispatchRequest(request, .pResponse)
        set json = pResponse.Json
        set resp = []
        set iter = json.entry.%GetIterator()
        while iter.%GetNext(.key, .value) { 
          do resp.%Push(value.resource)
        }
        
        write resp.%ToJSON()    
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on get all questionnairies responses"       
    }
    
    Quit tSC
}

/// Retreive a questionnaire response by id
ClassMethod GetQuestionnaireResponse(id As %String) As %Status
{

    set tSC = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/QuestionnaireResponse/"_id
        set request.RequestMethod = "GET"
        do fhirService.DispatchRequest(request, .pResponse)
        write pResponse.Json.%ToJSON()    
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on get the questionnaire response"       
    }
    
    Quit tSC
}

/// Create the questionnaire response
ClassMethod CreateQuestionnaireResponse() As %Status
{
  set tSC = $$$OK
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Try {
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/QuestionnaireResponse/"
    set request.RequestMethod = "POST"
    set data = {}.%FromJSON(%request.Content)
    set data.resourceType = "QuestionnaireResponse"
    set request.Json = data
    do fhirService.DispatchRequest(request, .response)
    
    set request2 = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request2.RequestPath = response.Location
    set request2.RequestMethod = "GET"
    do fhirService.DispatchRequest(request2, .response2)
    
    write response2.Json.%ToJSON()
  } Catch Err {
    set tSC = 1
    set message = {}
    set message.type= "ERROR"
    set message.details = "Error on create the questionnaire response"
  }
  
  Return tSC
}

/// Update a questionnaire response
ClassMethod UpdateQuestionnaireResponse(id As %String) As %Status
{
  set tSC = $$$OK
  Set %response.ContentType = ..#CONTENTTYPEJSON
  Set %response.Headers("Access-Control-Allow-Origin")="*"

  Try {
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/QuestionnaireResponse/"_id
    set request.RequestMethod = "PUT"
    set data = {}.%FromJSON(%request.Content)
    set data.resourceType = "QuestionnaireResponse"
    set request.Json = data
    do fhirService.DispatchRequest(request, .response)
    write response.Json.%ToJSON()
  }Catch Err {
    set tSC = 1
    set message = {}
    set message.type= "ERROR"
    set message.details = "Error on update questionnaire response"
  }
  Return tSC
}

/// Delete a questionnaire response by id
ClassMethod DeleteQuestionnaireResponse(id As %String) As %Status
{

    set tSC = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set %response.Headers("Access-Control-Allow-Origin")="*"

    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(..#URL)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/QuestionnaireResponse/"_id
        set request.RequestMethod = "DELETE"
        do fhirService.DispatchRequest(request, .pResponse)
    } Catch Err {
        set tSC = 1
        set message = {}
        set message.type= "ERROR"
        set message.details = "Error on delete the questionnaire response"       
    }
    
    Quit tSC
}

}
