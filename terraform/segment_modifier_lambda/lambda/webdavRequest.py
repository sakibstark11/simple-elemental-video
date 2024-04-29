import requests
from requests.auth import HTTPDigestAuth

def __getHeaderValues(headersValues):
    headers = {}
    if "contentLength" in headersValues:
        headers["Content-Length"] = str(headersValues["contentLength"])
    if "contentType" in headersValues:
        headers["Content-Type"] = headersValues["contentType"]
    return headers

def sendWebDavRequest(ingestUrl, username, password, data, headers = {}):
  return requests.put(ingestUrl, data=data, auth=HTTPDigestAuth(username, password), headers=__getHeaderValues(headers))
