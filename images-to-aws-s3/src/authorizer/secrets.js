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

const secretManager = new AWS.SecretsManager();

const getSecret = async (secretId) => {
  let secret = await secretManager
    .getSecretValue({ SecretId: secretId })
    .promise();

  if (!secret || !secret.SecretString) {
    throw new Error(
      `Unable to get secret with id ${secretId} from Secrets Manager`
    );
  }

  return secret.SecretString;
};

let accessToken;

const getAccessToken = async () => {
  if (accessToken === undefined) {
    const secret = await getSecret(env.accessTokenId);
    accessToken = JSON.parse(secret).accessToken;
  }

  return accessToken;
};

module.exports = {
  getAccessToken,
};
