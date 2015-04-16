    express = require 'express'
    Upload  = require 's3-uploader'
    multer  = require 'multer'
    async   = require 'async'
    dms2dec = require 'dms2dec'

    sentry  = require '../sentry'
    librato = require '../librato'

Make a new Express router object for this part of the application.

    api = express.Router()

## Metrics

Agregate metrics for all requests and wheter they succeded (`finish`) or closed
before the request succeeded (`close`).

    api.use (req, res, next) ->
      librato.logRequest req.method

      res.once 'close', ->
        librato.logResponse 'closed'
        sentry.captureResClose res

      res.once 'finish', ->
        librato.logResponse res.statusCode

      next()

## GET /

    api.get '/', (req, res, next) ->
      res.status(204).end()

## POST /upload

Configure [s3-uploader](https://github.com/Turistforeningen/node-s3-uploader) to
store three versions of the image `320px`, `780px`, and `1040px`. The original
image is also uploaded but not publicly avaiable.

    s3 = new Upload process.env.AWS_BUCKET_NAME,
      aws:
        region: process.env.AWS_BUCKET_REGION
        path: process.env.AWS_BUCKET_PATH
        acl: 'public-read'
        httpOptions: timeout: 60000
      returnExif: true

      versions: [
        original: true
        awsImageAcl: 'private'
      ,
        suffix: '-large'
        quality: 80
        maxHeight: 1040
        maxWidth: 1040
      ,
        suffix: '-medium'
        maxHeight: 780
        maxWidth: 780
      ,
        suffix: '-small'
        maxHeight: 320
        maxWidth: 320
      ]

Configure [multer](https://github.com/expressjs/multer) to store files in the
OS's temorary directory `tempdir()`. This way we should not need to clean up the
uploaded files since that should be the job of the OS.

    multer = require('multer')
      putSingleFilesInArray: true
      dest: require('os').tmpdir()

Configure the `/upload` route handler.

    api.post '/upload', multer, (req, res, next) ->
      librato.logImagesUploaded Object.keys req.files

      files = []
      for key, f of req.files
        files.push file for file in f

      async.mapSeries files, (file, cb) ->
        if file.extension.toLowerCase() not in ['jpg', 'jpeg', 'png', 'gif']
          error = new Error "Invalid Image #{file.extension}"
          error.status = 422
          return cb error

        t1 = new Date().getTime()
        s3.upload file.path, {}, (err, images, meta) ->
          return cb err if err

          librato.logImageProcessingTime t1, new Date().getTime()

          if meta.exif['exif:GPSLatitude'] and meta.exif['exif:GPSLongitude']
            meta.geojson =
              type: 'Point'
              coordinates: dms2dec \
                meta.exif['exif:GPSLatitude'], \
                meta.exif['exif:GPSLatitudeRef'], \
                meta.exif['exif:GPSLongitude'], \
                meta.exif['exif:GPSLongitudeRef']
              .reverse()

          if meta.imageSize.height > meta.imageSize.width
            ratio = meta.imageSize.height / meta.imageSize.width
            edge = 'width'
          else
            ratio = meta.imageSize.width / meta.imageSize.height
            edge = 'height'

          for image in images
            image[edge] = Math.floor(image[edge] / ratio)

            image.path = undefined
            image.src = undefined

          return cb null, versions: images.splice(1), meta: meta
      , (err, files) ->
        return next err if err
        sentry.captureHeaderSent req, files if res._headerSent
        return res.status(201).json files

    module.exports = api
