module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": 0,
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "linebreak-style": 0,
    "max-len": [
      "error",
      {
        "code": 120,
        "tabWidth": 2,
        "ignoreComments": true,
        "ignoreUrls": true,
        "ignoreStrings": true,
        "ignoreTemplateLiterals": true,
      },
    ],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
