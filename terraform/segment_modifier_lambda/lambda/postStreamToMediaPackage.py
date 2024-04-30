from webdavRequest import sendWebDavRequest, sendAsyncWebDavRequests

def __isRootManifestFile(fileName):
    return "_" not in fileName and ".m3u8" in fileName

def __getIngestUrlForMediaPackage(mediaPackageUrl, fileName):
    return f"{mediaPackageUrl}.m3u8" if __isRootManifestFile(fileName) else mediaPackageUrl.replace('channel', fileName)

def __logIfErrorAndReturn(result, fileName, ingestUrl):
    if result["status_code"] != 201:
        print(f"Error ingesting file {fileName} to {ingestUrl}. error: {result['text']}")

    return result

def __getWebDavRequestVarsFromEnv(envVariables, fileName):
    return { **envVariables, "ingestUrl": __getIngestUrlForMediaPackage(envVariables["url"], fileName) }

def postStreamToMediaPackage(envVariables, fileName, data, headerValues = {}):
    result = sendWebDavRequest(__getWebDavRequestVarsFromEnv(envVariables, fileName), fileName, data, headerValues)
    return __logIfErrorAndReturn(result, fileName, result["ingestUrl"])

def postStreamToMultipleMediaPackageEndpoints(envVariables, fileName, data, headerValues = {}):
    resultList = sendAsyncWebDavRequests(
        [__getWebDavRequestVarsFromEnv(webDavRequestVars, fileName) for webDavRequestVars in envVariables], fileName, data, headerValues
    )
    return [__logIfErrorAndReturn(result, fileName, result["ingestUrl"]) for result in resultList]
