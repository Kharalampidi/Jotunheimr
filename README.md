Jötunheimr [![Build Status](https://drone.io/github.com/Turistforeningen/Jotunheimr/status.png)](https://drone.io/github.com/Turistforeningen/Jotunheimr/latest)
==========

![Smørstabbrean by Per Roger Lauritzen](https://raw.githubusercontent.com/Turistforeningen/Jotunheimr/master/images/jotunheimen.png)

> From Jötunheimr, the giants menace the humans in Midgard and the gods in
> Asgard. The river Ifing separates Asgard, the realm of the gods, from
> Jötunheimr, the land of giants. Gastropnir, home of Menglad, and Þrymheimr,
> home of Þjazi, were both located in Jötunheimr, which was ruled by King Thrym.
> Glæsisvellir was a location in Jötunheimr, where lived the giant Gudmund,
> father of Höfund. Utgard was a stronghold surrounding the land of the
> giants.

This Node.JS microservice processes images before uploading them to a designated
bucket on AWS S3. Utilizing [express](https://github.com/strongloop/express) for
handling requests, and
[node-s3-uploader](https://github.com/Turistforeningen/node-s3-uploader) for
resizing and uploading to AWS S3.

## Features

* CORS support
* Image resizing
* Color conversion
* Image auto orientate
* Upload to AWS S3

## Install

```
npm install jotunheimr
```

## Usage

### Environment Variables

* `PORT_WWW` - server listening port
* `ALLOW_ORIGINS` - allowed origins whitelist (comma seperated)
* `AWS_ACCESS_KEY_ID` AWS public key
* `AWS_SECRET_ACCESS_KEY` AWS secret key
* `AWS_BUCKET_NAME` AWS S3 bucket name
* `AWS_BUCKET_PATH` Path inside bucket

### Start

```
npm start
```

### Upload

```
curl -X POST -F image=/path/to/file.jpg http://localhost:4010/upload
```

## [MIT lisenced](https://github.com/Turistforeningen/Jotunheimr/blob/master/LICENSE)



