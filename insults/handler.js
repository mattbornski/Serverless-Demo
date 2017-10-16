'use strict';

const leadins = [
  'buzz off',
  'get bent',
  'go jump off a cliff',
  'scram',
];

const buildups = [
  'ye pestilent',
  'oh putrid',
  'you scruffy',
];

const pronouns = [
  'no good drifter',
  'low life',
  'nerf herder',
  'beauty school dropout',
];

function sample(choices) {
  return choices[Math.floor(Math.random() * choices.length)];
}

module.exports.insults = (event, context, callback) => {
  const message = `${sample(leadins)}, ${sample(buildups)} ${sample(pronouns)}`;
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: message,
      input: event,
    }),
  };

  callback(null, response);

  // Use this code if you don't use the http event with the LAMBDA-PROXY integration
  // callback(null, { message: message, event });
};
