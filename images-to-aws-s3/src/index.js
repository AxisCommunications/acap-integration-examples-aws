/**
 * Copyright (C) 2021 Axis Communications AB, Lund, Sweden
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

"use strict";

const AWS = require("aws-sdk");
const env = require("./env");
const response = require("./response");
const secrets = require("./secrets");

const s3 = new AWS.S3();

const post = async (event) => {
  const apiAccessToken = await secrets.getApiAccessToken();

  if (event?.queryStringParameters?.accessToken !== apiAccessToken) {
    return response.Forbidden;
  }

  const contentType = event.headers["content-type"];
  if (!contentType || !contentType.startsWith("image/")) {
    return response.UnsupportedMediaType;
  }

  const contentDisposition = event.headers["content-disposition"];
  if (!contentDisposition) {
    return response.BadRequest;
  }

  const filename = contentDisposition.match(
    /^attachment;\s*filename=\"(?<filename>.*)\"$/
  )?.groups?.filename;
  if (!filename) {
    return response.BadRequest;
  }

  const encoding = event.isBase64Encoded ? "base64" : "binary";
  const body = Buffer.from(event.body, encoding);

  await s3
    .upload({
      Bucket: env.bucketName,
      Key: filename,
      Body: body,
    })
    .promise();

  return response.OK;
};

const get = async () => {
  return response.OK;
};

const handler = async (event) => {
  switch (event.requestContext.http.method) {
    case "GET":
      return get();

    case "POST":
      return post(event);

    default:
      return response.MethodNotAllowed;
  }
};

module.exports = {
  handler,
};
