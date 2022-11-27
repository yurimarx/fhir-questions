Class PackageSample.ObjectScript
{

ClassMethod Test() As %Status
{
    set a=42
    return "It works!"
}

ClassMethod GetPatient() As %Status
{
    set url = "/fhir/r4" 
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/Patient/1"
    set request.RequestMethod = "GET"
    do fhirService.DispatchRequest(request, .response)
    Write response.Json.id
}

ClassMethod CreateQuestionnaire() As %Status
{
    Set sc = $$$OK
    set url = "/fhir/r4"
    Try {
        set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
        set request = ##class(HS.FHIRServer.API.Data.Request).%New()
        set request.RequestPath = "/Questionnaire"
        set request.RequestMethod = "POST"
        set request.Json = {}.%FromJSONFile("/opt/irisapp/fhirdata/questionary.json")
        do fhirService.DispatchRequest(request, .response)
    } Catch Err {
        Write Err.Name
    }
    Return sc
}

ClassMethod GetQuestionnaire() As %Status
{
    set url = "/fhir/r4" 
    set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
    set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    set request.RequestPath = "/Questionnaire/1984"
    set request.RequestMethod = "GET"
    do fhirService.DispatchRequest(request, .response)
    Write response.Json.id
}

}
