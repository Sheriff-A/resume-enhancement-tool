import withNuxt from './.nuxt/eslint.config.mjs';

export default withNuxt(
  // your custom flat configs go here, for example:
  // {
  //   files: ['**/*.ts', '**/*.tsx'],
  //   rules: {
  //     'no-console': 'off' // allow console.log in TypeScript files
  //   }
  // },
  // {
  //   ...
  // }
  {
    plugins: {
      // '@stylistic': stylistic,
    },
    rules: {
      '@stylistic/indent': ['error', 2],
      '@stylistic/semi': ['off'],
      'prettier/prettier': 0,
      'vue/no-multiple-template-root': 0,
      'vue/multi-word-component-names': 0,
      'object-shorthand': 0,
      '@typescript-eslint/no-inferrable-types': 0,
      'no-lonely-if': 0,
      'require-await': 0, // sometimes I don't understand why these rules are default on - making a synchronous function async is being proactive if it's possible or expected to become async at a later time
      'no-console': [
        'warn',
        {
          allow: ['warn', 'error'],
        },
      ],
    },
  },
);
