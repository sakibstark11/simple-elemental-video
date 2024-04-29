from webdavRequest import sendWebDavRequest

def __isRootManifestFile(fileName):
    return "_" not in fileName and ".m3u8" in fileName

def __getIngestUrlForMediaPackage(mediaPackageUrl, fileName):
    return f"{mediaPackageUrl}.m3u8" if __isRootManifestFile(fileName) else mediaPackageUrl.replace('channel', fileName)

def postStreamToMediaPackage(envVariables, fileName, data, headerValues = {}):
    mediaPackageUrl = envVariables["url"]
    username = envVariables["username"]
    password = envVariables["password"]

    ingestUrl = __getIngestUrlForMediaPackage(mediaPackageUrl, fileName)
    response = sendWebDavRequest(ingestUrl, username, password, data, headerValues)
    
    if response.status_code != 201:
        print(f"Error ingesting file {fileName} to {ingestUrl}. error: {response.text}")

    return {"ingestUrl": ingestUrl, "fileName": fileName, "status": response.status_code}