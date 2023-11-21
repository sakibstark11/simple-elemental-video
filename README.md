# simple-elemental-video
Deploy a simple aws video pipeline


#### Cloudformation Docs
MediaConnect: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaConnect.html
MediaLive: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaLive.html
MediaPackage: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaPackage.html
# Todo
- Code Medialive
- Code Mediapackage
- Add a r53 dns A record for Mediaconnect input
- Deploy a cheap ec2 machine to run ffmpeg test stream


eval "$(aws configure export-credentials --profile your-profile-name --format env)"
