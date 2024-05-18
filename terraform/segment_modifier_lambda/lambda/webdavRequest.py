import requests
from requests.auth import HTTPDigestAuth

import asyncio

def __getHeaderValues(headersValues):
    headers = {}
    if "contentLength" in headersValues:
        headers["Content-Length"] = str(headersValues["contentLength"])
    if "contentType" in headersValues:
        headers["Content-Type"] = headersValues["contentType"]
    return headers

def sendWebDavRequest(webDavRequestVars, fileName, data, headers = {}):
    response = requests.put(
        webDavRequestVars["ingestUrl"], 
        data=data, 
        auth=HTTPDigestAuth(webDavRequestVars["username"], webDavRequestVars["password"]), 
        headers=__getHeaderValues(headers)
    )
    return {
        "ingestUrl": webDavRequestVars["ingestUrl"],
        "fileName": fileName,
        "status_code": response.status_code,
        "text": response.text if response.status_code != 201 else ""
    }

def sendAsyncWebDavRequests(webDavRequestVars, fileName, data, headerValues):
    async def executeAsync():
        loop = asyncio.get_event_loop()
        futures = [loop.run_in_executor(None, sendWebDavRequest, webDavRequestVar, fileName, data, headerValues) 
                   for webDavRequestVar in webDavRequestVars]
        return await asyncio.gather(*futures)

    eventLoop = asyncio.get_event_loop()
    return eventLoop.run_until_complete(executeAsync())
    
