export default defineAppConfig({
  // https://ui.nuxt.com/getting-started/theme#design-system
  ui: {
    colors: {
      primary: 'indigo',
      secondary: 'purple',
      accent: 'driftwood',
      neutral: 'slate',
    },
    button: {
      slots: {
        base: [
          'cursor-pointer active:scale-95 transition-transform duration-100 ease-in-out',
        ],
      },
      defaultVariants: {
        // Set default button color to neutral
        // color: 'neutral'
      },
    },
    card: {
      slots: {
        root: ['rounded-xl'],
      },
    },
    alert: {
      defaultVariants: {
        variant: 'subtle',
        orientation: 'horizontal',
      },
    },
  },
})
