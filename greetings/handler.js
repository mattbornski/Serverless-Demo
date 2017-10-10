'use strict';

const leadins = [
  'greetings',
  'salutations',
  'top of the morning to ye',
  'you are looking mighty fine today',
];

const buildups = [
  'my dearest',
  'my favorite',
  'oh great',
  'oh mighty',
  'you divine',
  'you fine specimen of a',
  'you noble',
];

const pronouns = [
  'bearer of the ring',
  'hero of might and magic',
  'lumberjack',
  'nerf herder',
  's/he who must not be named',
];

function sample(choices) {
  return choices[Math.floor(Math.random() * choices.length)];
}

module.exports.greetings = (event, context, callback) => {
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
