import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
      transitionProperty: {
        "box-shadow": "box-shadow",
        "max-width": "max-width",
        "padding-left": "padding-left",
        "padding-right": "padding-right",
      },
    },
  },
  plugins: [],
} satisfies Config;
